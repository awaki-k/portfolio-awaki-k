// mlp_hex_infer_rowmajor_full.c
// MNIST MLP inference (784->64->32->10) using exported HEX files (ROW-MAJOR, NO PADDING, NO TILING)
// Inputs:
//   - export_dir/meta.json
//   - export_dir/fc{1,2,3}_W_rowmajor_int8.hex   (out-major then in-major, 1 byte/line hex "00".."FF")
//   - export_dir/fc{1,2,3}_b_int32.hex          (1 uint32/line hex "00000000".., interpreted as int32)
//   - single input hex: 784 lines, 1 byte/line hex
//   - meta csv: index,label,pred,hex_file  (pred column optional; we only need label+hex_file)
//
// Modes:
//   (1) Single input bench:
//       mlp_hex_infer_rowmajor_full <export_dir> <input_u8_hex> [bench_iters]
//   (2) Meta accuracy:
//       mlp_hex_infer_rowmajor_full <export_dir> <meta.csv> [max_samples] [show_mismatch]
//
// Build:
//   gcc -O3 -std=c11 mlp_hex_infer_rowmajor_full.c -o mlp_hex_infer_rowmajor_full
//
// Notes:
// - Requant matches your Python "HW fixed (round half-up)" rule:
//     mul = acc * rq_s
//     rnd = mul + (1<<(shift-1))
//     out = rnd >> shift   (arithmetic right shift on signed int64_t)
// - Relu fused clamps to [out_zp,255], otherwise [0,255].
// - meta.json is parsed with a minimal string search (no external JSON lib).

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>

#if defined(_WIN32)
  #define WIN32_LEAN_AND_MEAN
  #include <windows.h>
#else
  #include <time.h>
#endif

#define INT32_MIN_V (-2147483647 - 1)
#define INT32_MAX_V (2147483647)

typedef struct {
    int out_ch;        // out_features (NO padding)
    int in_ch;         // in_features
    int in_zp;         // in_zero_point
    int out_zp;        // out_zero_point
    int32_t rq_s;      // requant_s
    int32_t rq_shift;  // requant_shift
    int is_relu_fused; // 1/0
    double out_scale;  // optional (not required for argmax)
} LayerMeta;

typedef struct {
    LayerMeta m;
    const int8_t  *W;  // row-major [out_ch][in_ch]
    const int32_t *b;  // [out_ch]
} LayerParams;

typedef struct {
    LayerParams fc1;
    LayerParams fc2;
    LayerParams fc3;
} MLPParams;

// ------------------------
// High-resolution timer
// ------------------------
#if defined(_WIN32)
static LARGE_INTEGER g_qpf;
static void timer_init(void) {
    if (!QueryPerformanceFrequency(&g_qpf)) {
        fprintf(stderr, "QueryPerformanceFrequency failed.\n");
        exit(EXIT_FAILURE);
    }
}
static double now_ms(void) {
    LARGE_INTEGER t;
    QueryPerformanceCounter(&t);
    return (double)t.QuadPart * 1000.0 / (double)g_qpf.QuadPart;
}
#else
static void timer_init(void) {}
static double now_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec * 1000.0 + (double)ts.tv_nsec / 1e6;
}
#endif

static void die(const char *msg) {
    perror(msg);
    exit(EXIT_FAILURE);
}

static char* read_entire_file(const char *path, size_t *out_size) {
    FILE *fp = fopen(path, "rb");
    if (!fp) {
        fprintf(stderr, "cannot open: %s\n", path);
        die("fopen");
    }
    if (fseek(fp, 0, SEEK_END) != 0) die("fseek");
    long sz = ftell(fp);
    if (sz < 0) die("ftell");
    if (fseek(fp, 0, SEEK_SET) != 0) die("fseek");

    char *buf = (char*)malloc((size_t)sz + 1);
    if (!buf) die("malloc");

    size_t rd = fread(buf, 1, (size_t)sz, fp);
    fclose(fp);
    if (rd != (size_t)sz) die("fread");
    buf[sz] = '\0';
    if (out_size) *out_size = (size_t)sz;
    return buf;
}

static const char* skip_ws(const char *p) {
    while (*p && isspace((unsigned char)*p)) p++;
    return p;
}

static int parse_long_after_colon(const char *p, long *out) {
    p = strchr(p, ':');
    if (!p) return 0;
    p++;
    p = skip_ws(p);
    char *endp = NULL;
    long v = strtol(p, &endp, 10);
    if (endp == p) return 0;
    *out = v;
    return 1;
}

static int parse_double_after_colon(const char *p, double *out) {
    p = strchr(p, ':');
    if (!p) return 0;
    p++;
    p = skip_ws(p);
    char *endp = NULL;
    double v = strtod(p, &endp);
    if (endp == p) return 0;
    *out = v;
    return 1;
}

static int parse_bool_after_colon(const char *p, int *out) {
    p = strchr(p, ':');
    if (!p) return 0;
    p++;
    p = skip_ws(p);
    if (strncmp(p, "true", 4) == 0)  { *out = 1; return 1; }
    if (strncmp(p, "false", 5) == 0) { *out = 0; return 1; }
    return 0;
}

static int parse_int_array2_after_colon(const char *p, int *a0, int *a1) {
    p = strchr(p, ':');
    if (!p) return 0;
    p++;
    p = skip_ws(p);
    p = strchr(p, '[');
    if (!p) return 0;
    p++;
    p = skip_ws(p);

    char *endp = NULL;
    long v0 = strtol(p, &endp, 10);
    if (endp == p) return 0;
    p = endp;

    p = strchr(p, ',');
    if (!p) return 0;
    p++;
    p = skip_ws(p);

    long v1 = strtol(p, &endp, 10);
    if (endp == p) return 0;

    *a0 = (int)v0;
    *a1 = (int)v1;
    return 1;
}

// Find section for "fc1"/"fc2"/"fc3" and parse required fields.
// Compatible with your exported meta.json keys:
//   "w_shape", "in_zero_point", "out_zero_point", "requant_s", "requant_shift", "is_relu_fused", "out_scale"
static int load_layer_meta(const char *json, const char *layer_name, LayerMeta *m) {
    char key[32];
    snprintf(key, sizeof(key), "\"%s\"", layer_name);

    const char *sec = strstr(json, key);
    if (!sec) return 0;

    const char *p_wshape = strstr(sec, "\"w_shape\"");
    if (!p_wshape) return 0;
    int out_ch = 0, in_ch = 0;
    if (!parse_int_array2_after_colon(p_wshape, &out_ch, &in_ch)) return 0;

    const char *p_inzp = strstr(sec, "\"in_zero_point\"");
    const char *p_outzp = strstr(sec, "\"out_zero_point\"");
    if (!p_inzp || !p_outzp) return 0;
    long inzp = 0, outzp = 0;
    if (!parse_long_after_colon(p_inzp, &inzp)) return 0;
    if (!parse_long_after_colon(p_outzp, &outzp)) return 0;

    const char *p_rqs  = strstr(sec, "\"requant_s\"");
    const char *p_rqsh = strstr(sec, "\"requant_shift\"");
    if (!p_rqs || !p_rqsh) return 0;
    long rqs = 0, rqsh = 0;
    if (!parse_long_after_colon(p_rqs, &rqs)) return 0;
    if (!parse_long_after_colon(p_rqsh, &rqsh)) return 0;

    const char *p_relu = strstr(sec, "\"is_relu_fused\"");
    if (!p_relu) return 0;
    int relu = 0;
    if (!parse_bool_after_colon(p_relu, &relu)) return 0;

    const char *p_os = strstr(sec, "\"out_scale\"");
    if (!p_os) return 0;
    double out_scale = 0.0;
    if (!parse_double_after_colon(p_os, &out_scale)) return 0;

    m->out_ch = out_ch;
    m->in_ch = in_ch;
    m->in_zp = (int)inzp;
    m->out_zp = (int)outzp;
    m->rq_s = (int32_t)rqs;
    m->rq_shift = (int32_t)rqsh;
    m->is_relu_fused = relu;
    m->out_scale = out_scale;
    return 1;
}

static int32_t clamp_i32(int64_t v) {
    if (v < (int64_t)INT32_MIN_V) return (int32_t)INT32_MIN_V;
    if (v > (int64_t)INT32_MAX_V) return (int32_t)INT32_MAX_V;
    return (int32_t)v;
}

// HW requant (matches python):
// mul = acc * rq_s
// rnd = mul + (1<<(shift-1))
// out = rnd >> shift   (arithmetic right shift on signed int64)
static int32_t requant_round_half_up_i32(int32_t acc, int32_t rq_s, int32_t rq_shift) {
    if (rq_shift <= 0) {
        int64_t mul = (int64_t)acc * (int64_t)rq_s;
        return clamp_i32(mul);
    }
    int64_t mul = (int64_t)acc * (int64_t)rq_s;
    int64_t rnd = mul + ((int64_t)1 << (rq_shift - 1));
    int64_t out = (rnd >> rq_shift);
    return clamp_i32(out);
}

// input hex: 784 lines, each "00".."FF"
static void load_input_u8_hex(const char *path, uint8_t *dst, int count) {
    FILE *fp = fopen(path, "rb");
    if (!fp) {
        fprintf(stderr, "cannot open input: %s\n", path);
        die("fopen input hex");
    }
    for (int i = 0; i < count; i++) {
        unsigned int v;
        if (fscanf(fp, "%x", &v) != 1) {
            fprintf(stderr, "input hex: insufficient tokens at %d (%s)\n", i, path);
            exit(EXIT_FAILURE);
        }
        dst[i] = (uint8_t)(v & 0xFF);
    }
    fclose(fp);
}

// Weight HEX (ROW-MAJOR): out-major then in-major, 1 byte per line
static void load_weight_rowmajor_int8_hex(const char *path, int8_t *W, int out_ch, int in_ch) {
    FILE *fp = fopen(path, "rb");
    if (!fp) {
        fprintf(stderr, "cannot open weight: %s\n", path);
        die("fopen weight hex");
    }
    char line[64];
    const long expected = (long)out_ch * (long)in_ch;
    long got = 0;
    for (long idx = 0; idx < expected; idx++) {
        if (!fgets(line, (int)sizeof(line), fp)) {
            fprintf(stderr, "weight hex: unexpected EOF at %ld (%s)\n", idx, path);
            exit(EXIT_FAILURE);
        }
        unsigned int bytev = 0;
        if (sscanf(line, "%x", &bytev) != 1) {
            fprintf(stderr, "weight hex: parse error: %s (%s)\n", line, path);
            exit(EXIT_FAILURE);
        }
        uint8_t u = (uint8_t)(bytev & 0xFF);
        W[idx] = (int8_t)u; // two's complement bit-identical
        got++;
    }

    // If file has extra lines, we ignore; but you can enforce strictness if desired.
    (void)got;
    fclose(fp);
}

// b_int32.hex: one uint32 per line in hex (8 digits). Interpret as int32 two's complement.
static void load_bias_int32_hex(const char *path, int32_t *b, int len) {
    FILE *fp = fopen(path, "rb");
    if (!fp) {
        fprintf(stderr, "cannot open bias: %s\n", path);
        die("fopen bias hex");
    }
    char line[64];
    for (int i = 0; i < len; i++) {
        if (!fgets(line, (int)sizeof(line), fp)) {
            fprintf(stderr, "bias hex: unexpected EOF (%s)\n", path);
            exit(EXIT_FAILURE);
        }
        unsigned int u32 = 0;
        if (sscanf(line, "%x", &u32) != 1) {
            fprintf(stderr, "bias hex: parse error: %s (%s)\n", line, path);
            exit(EXIT_FAILURE);
        }
        b[i] = (int32_t)u32;
    }
    fclose(fp);
}

static int argmax_u8(const uint8_t *v, int n) {
    int best_i = 0;
    int best_v = (int)v[0];
    for (int i = 1; i < n; i++) {
        int vi = (int)v[i];
        if (vi > best_v) { best_v = vi; best_i = i; }
    }
    return best_i;
}

// ------------------------
// One layer inference in quant domain (NO padding)
// x_u8: length=in_ch
// y_u8: length=out_ch
// ------------------------
static void layer_u8_val(LayerParams lp, const uint8_t *x_u8, uint8_t *y_u8) {
    const LayerMeta *m = &lp.m;
    const int8_t *W = lp.W;
    const int32_t *b = lp.b;

    for (int o = 0; o < m->out_ch; o++) {
        const int8_t *wrow = &W[o * m->in_ch];
        int64_t acc = 0;

        for (int i = 0; i < m->in_ch; i++) {
            int32_t xc = (int32_t)x_u8[i] - (int32_t)m->in_zp;
            int32_t w  = (int32_t)wrow[i];
            acc += (int64_t)xc * (int64_t)w;
        }
        acc += (int64_t)b[o];

        int32_t acc_i32 = clamp_i32(acc);
        int32_t rq = requant_round_half_up_i32(acc_i32, m->rq_s, m->rq_shift);

        int64_t qy = (int64_t)rq + (int64_t)m->out_zp;

        if (m->is_relu_fused) {
            if (qy < (int64_t)m->out_zp) qy = (int64_t)m->out_zp;
            if (qy > 255) qy = 255;
        } else {
            if (qy < 0) qy = 0;
            if (qy > 255) qy = 255;
        }
        y_u8[o] = (uint8_t)qy;
    }
}

// ------------------------
// MLP inference core (value-passed params)
// - p is passed BY VALUE (as requested)
// - returns prediction (argmax of final u8)
// ------------------------
static int mlp_infer_u8_val(MLPParams p, const uint8_t x0[784], uint8_t y3_out[10]) {
    uint8_t y1[64];
    uint8_t y2[32];
    uint8_t y3[10];

    layer_u8_val(p.fc1, x0, y1);
    layer_u8_val(p.fc2, y1, y2);
    layer_u8_val(p.fc3, y2, y3);

    if (y3_out) memcpy(y3_out, y3, 10);
    return argmax_u8(y3, 10);
}

static void join_path(char *out, size_t out_sz, const char *dir, const char *file) {
    snprintf(out, out_sz, "%s/%s", dir, file); // '/' works on Windows too
}

static void dirname_of(char *dst, size_t dst_sz, const char *path) {
    const char *p1 = strrchr(path, '/');
    const char *p2 = strrchr(path, '\\');
    const char *p = p1;
    if (!p || (p2 && p2 > p1)) p = p2;

    if (!p) { snprintf(dst, dst_sz, "."); return; }
    size_t len = (size_t)(p - path);
    if (len >= dst_sz) len = dst_sz - 1;
    memcpy(dst, path, len);
    dst[len] = '\0';
}

static void trim_line(char *s) {
    size_t n = strlen(s);
    while (n > 0 && (s[n-1] == '\n' || s[n-1] == '\r' || isspace((unsigned char)s[n-1]))) {
        s[n-1] = '\0';
        n--;
    }
    char *p = s;
    while (*p && isspace((unsigned char)*p)) p++;
    if (p != s) memmove(s, p, strlen(p) + 1);
}

static int is_meta_file_path(const char *path) {
    const char *ext = strrchr(path, '.');
    if (ext && (strcmp(ext, ".txt") == 0 || strcmp(ext, ".csv") == 0)) return 1;
    return 0;
}

// ------------------------
// Single bench
// ------------------------
static int run_single(
    MLPParams p,
    const char *input_hex_path,
    long bench_iters
) {
    uint8_t x0[784];
    uint8_t y3_last[10];

    load_input_u8_hex(input_hex_path, x0, 784);

    if (bench_iters < 1) bench_iters = 1;

    // warmup (1回)
    (void)mlp_infer_u8_val(p, x0, y3_last);

    double t0 = now_ms();
    int pred = 0;
    for (long it = 0; it < bench_iters; it++) {
        pred = mlp_infer_u8_val(p, x0, y3_last);
    }
    double t1 = now_ms();

    double total_ms = t1 - t0;
    double avg_us = (bench_iters > 0) ? (total_ms * 1000.0 / (double)bench_iters) : 0.0;

    printf("INFER_ITERS=%ld INFER_TOTAL_MS=%.3f INFER_AVG_US=%.3f\n", bench_iters, total_ms, avg_us);

    printf("PRED=%d\n", pred);
    printf("qy3 (u8) = ");
    for (int i = 0; i < 10; i++) {
        printf("%u%s", (unsigned)y3_last[i], (i + 1 == 10) ? "" : ",");
    }
    printf("\n");
    return pred;
}

// ------------------------
// Meta accuracy (with IO & timing)
// CSV expected: index,label,pred,hex_file OR index,label,hex_file
// ------------------------
static int run_meta_accuracy(
    MLPParams p,
    const char *meta_path,
    long max_samples,
    int show_mismatch
) {
    FILE *fp = fopen(meta_path, "rb");
    if (!fp) {
        fprintf(stderr, "cannot open meta: %s\n", meta_path);
        die("fopen meta");
    }

    char meta_dir[1024];
    dirname_of(meta_dir, sizeof(meta_dir), meta_path);

    long total = 0;
    long correct = 0;
    long shown = 0;

    double io_total_ms = 0.0;
    double infer_total_ms = 0.0;

    double wall0 = now_ms();

    char line[4096];

    // if first line isn't header, restart (same behavior as your older code)
    if (fgets(line, (int)sizeof(line), fp)) {
        trim_line(line);
        if (!(strncmp(line, "index", 5) == 0)) {
            fclose(fp);
            fp = fopen(meta_path, "rb");
            if (!fp) {
                fprintf(stderr, "cannot reopen meta: %s\n", meta_path);
                die("fopen meta");
            }
        }
    } else {
        fclose(fp);
        fprintf(stderr, "meta is empty: %s\n", meta_path);
        return 0;
    }

    while (fgets(line, (int)sizeof(line), fp)) {
        trim_line(line);
        if (line[0] == '\0') continue;

        // tokenization (comma)
        // Accept:
        //   A) index,label,hex_file
        //   B) index,label,pred,hex_file
        char *tok1 = strtok(line, ",");
        char *tok2 = strtok(NULL, ",");
        char *tok3 = strtok(NULL, ",");
        char *tok4 = strtok(NULL, ",");

        if (!tok1 || !tok2 || !tok3) continue;

        int label = 0;
        char *hex_rel = NULL;

        // If 4 tokens exist => tok4 is hex_file
        // Else 3 tokens => tok3 is hex_file
        if (tok4) {
            trim_line(tok2);
            trim_line(tok4);
            label = atoi(tok2);
            hex_rel = tok4;
        } else {
            trim_line(tok2);
            trim_line(tok3);
            label = atoi(tok2);
            hex_rel = tok3;
        }

        char input_path[4096];
        // join meta_dir + hex_rel unless absolute/drive
        if (strchr(hex_rel, ':') || hex_rel[0] == '/' || hex_rel[0] == '\\') {
            snprintf(input_path, sizeof(input_path), "%s", hex_rel);
        } else {
            snprintf(input_path, sizeof(input_path), "%s/%s", meta_dir, hex_rel);
        }

        uint8_t x0[784];
        uint8_t y3_last[10];

        double t_io0 = now_ms();
        load_input_u8_hex(input_path, x0, 784);
        double t_io1 = now_ms();
        io_total_ms += (t_io1 - t_io0);

        double t_inf0 = now_ms();
        int pred = mlp_infer_u8_val(p, x0, y3_last);
        double t_inf1 = now_ms();
        infer_total_ms += (t_inf1 - t_inf0);

        total++;
        if (pred == label) {
            correct++;
        } else if (show_mismatch > 0 && shown < show_mismatch) {
            printf("[MISM] file=%s label=%d pred=%d\n", input_path, label, pred);
            shown++;
        }

        if (max_samples > 0 && total >= max_samples) break;
    }

    fclose(fp);

    double wall1 = now_ms();
    double wall_ms = wall1 - wall0;

    double acc = (total > 0) ? (100.0 * (double)correct / (double)total) : 0.0;
    printf("TOTAL=%ld CORRECT=%ld ACC=%.4f%%\n", total, correct, acc);

    double infer_avg_us = (total > 0) ? (infer_total_ms * 1000.0 / (double)total) : 0.0;
    double io_avg_us    = (total > 0) ? (io_total_ms * 1000.0 / (double)total) : 0.0;

    printf("IO_TOTAL_MS=%.3f IO_AVG_US=%.3f\n", io_total_ms, io_avg_us);
    printf("INFER_TOTAL_MS=%.3f INFER_AVG_US=%.3f\n", infer_total_ms, infer_avg_us);
    printf("WALL_TOTAL_MS=%.3f\n", wall_ms);

    return (int)correct;
}

int main(int argc, char **argv) {
    timer_init();

    if (argc < 3) {
        fprintf(stderr,
            "Usage:\n"
            "  %s <export_dir> <input_u8_hex> [bench_iters]\n"
            "  %s <export_dir> <meta.csv> [max_samples] [show_mismatch]\n"
            "Example:\n"
            "  %s export_hw_fixed_halfup_rowmajor mnist_00000_label7_pred7_OK_u8.hex 10000\n"
            "  %s export_hw_fixed_halfup_rowmajor mnist_inputs_correct_meta.csv 0 10\n",
            argv[0], argv[0], argv[0], argv[0]);
        return EXIT_FAILURE;
    }

    const char *export_dir = argv[1];
    const char *path2 = argv[2];

    long max_samples = 0;   // 0 = all
    int show_mismatch = 10; // default show first 10 mismatches
    long bench_iters = 1000;

    const int is_meta = is_meta_file_path(path2);

    if (is_meta) {
        if (argc >= 4) max_samples = strtol(argv[3], NULL, 10);
        if (argc >= 5) show_mismatch = atoi(argv[4]);
    } else {
        if (argc >= 4) bench_iters = strtol(argv[3], NULL, 10);
        if (bench_iters < 1) bench_iters = 1;
    }

    // ----- meta.json -----
    char meta_json_path[1024];
    join_path(meta_json_path, sizeof(meta_json_path), export_dir, "meta.json");
    size_t jsz = 0;
    char *json = read_entire_file(meta_json_path, &jsz);

    LayerMeta fc1m, fc2m, fc3m;
    if (!load_layer_meta(json, "fc1", &fc1m)) { fprintf(stderr, "meta parse failed: fc1\n"); return EXIT_FAILURE; }
    if (!load_layer_meta(json, "fc2", &fc2m)) { fprintf(stderr, "meta parse failed: fc2\n"); return EXIT_FAILURE; }
    if (!load_layer_meta(json, "fc3", &fc3m)) { fprintf(stderr, "meta parse failed: fc3\n"); return EXIT_FAILURE; }

    // sanity for your network (784->64->32->10)
    if (fc1m.in_ch != 784 || fc1m.out_ch != 64 ||
        fc2m.in_ch != 64  || fc2m.out_ch != 32 ||
        fc3m.in_ch != 32  || fc3m.out_ch != 10) {
        fprintf(stderr, "shape mismatch:\n"
                        "  fc1: in=%d out=%d\n"
                        "  fc2: in=%d out=%d\n"
                        "  fc3: in=%d out=%d\n",
                        fc1m.in_ch, fc1m.out_ch, fc2m.in_ch, fc2m.out_ch, fc3m.in_ch, fc3m.out_ch);
        return EXIT_FAILURE;
    }

    // ----- load weights/biases from hex (ROW-MAJOR) -----
    char fc1w_path[1024], fc1b_path[1024];
    char fc2w_path[1024], fc2b_path[1024];
    char fc3w_path[1024], fc3b_path[1024];

    join_path(fc1w_path, sizeof(fc1w_path), export_dir, "fc1_W_rowmajor_int8.hex");
    join_path(fc1b_path, sizeof(fc1b_path), export_dir, "fc1_b_int32.hex");
    join_path(fc2w_path, sizeof(fc2w_path), export_dir, "fc2_W_rowmajor_int8.hex");
    join_path(fc2b_path, sizeof(fc2b_path), export_dir, "fc2_b_int32.hex");
    join_path(fc3w_path, sizeof(fc3w_path), export_dir, "fc3_W_rowmajor_int8.hex");
    join_path(fc3b_path, sizeof(fc3b_path), export_dir, "fc3_b_int32.hex");

    int8_t  *W1 = (int8_t*) malloc((size_t)fc1m.out_ch * (size_t)fc1m.in_ch);
    int8_t  *W2 = (int8_t*) malloc((size_t)fc2m.out_ch * (size_t)fc2m.in_ch);
    int8_t  *W3 = (int8_t*) malloc((size_t)fc3m.out_ch * (size_t)fc3m.in_ch);
    int32_t *b1 = (int32_t*)malloc((size_t)fc1m.out_ch * sizeof(int32_t));
    int32_t *b2 = (int32_t*)malloc((size_t)fc2m.out_ch * sizeof(int32_t));
    int32_t *b3 = (int32_t*)malloc((size_t)fc3m.out_ch * sizeof(int32_t));
    if (!W1 || !W2 || !W3 || !b1 || !b2 || !b3) die("malloc");

    load_weight_rowmajor_int8_hex(fc1w_path, W1, fc1m.out_ch, fc1m.in_ch);
    load_bias_int32_hex(fc1b_path, b1, fc1m.out_ch);

    load_weight_rowmajor_int8_hex(fc2w_path, W2, fc2m.out_ch, fc2m.in_ch);
    load_bias_int32_hex(fc2b_path, b2, fc2m.out_ch);

    load_weight_rowmajor_int8_hex(fc3w_path, W3, fc3m.out_ch, fc3m.in_ch);
    load_bias_int32_hex(fc3b_path, b3, fc3m.out_ch);

    // Build value-passable param struct
    MLPParams p;
    p.fc1.m = fc1m; p.fc1.W = W1; p.fc1.b = b1;
    p.fc2.m = fc2m; p.fc2.W = W2; p.fc2.b = b2;
    p.fc3.m = fc3m; p.fc3.W = W3; p.fc3.b = b3;

    // ----- run -----
    if (is_meta) {
        run_meta_accuracy(p, path2, max_samples, show_mismatch);
    } else {
        run_single(p, path2, bench_iters);
    }

    free(json);
    free(W1); free(W2); free(W3);
    free(b1); free(b2); free(b3);
    return EXIT_SUCCESS;
}
