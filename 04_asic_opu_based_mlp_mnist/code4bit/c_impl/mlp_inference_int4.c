// mlp_inference_int4.c
// MNIST MLP inference (196->32->16->10) for 4-bit quantized model
//
// Inputs:
//   - export_dir/meta.json
//   - export_dir/fc{1,2,3}_w_int4.hex   (0..F per line) -> interpreted as int4 (-8..7)
//   - export_dir/fc{1,2,3}_b_int16.hex  (0000..FFFF per line) -> interpreted as int16
//   - inputs/correct/*.hex or inputs/incorrect/*.hex (0..F per line) -> uint4
//
// Build:
//   gcc -O3 -std=c11 mlp_inference_int4.c -o mlp_inference_int4
//
// Usage:
//   ./mlp_inference_int4 <export_dir> <inputs_meta.csv> [max_samples] [show_mismatch]

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

// --- Bit Width Constraints ---
#define INT16_MIN_V (-32768)
#define INT16_MAX_V (32767)
#define UINT4_MAX_V (15)

typedef struct {
    int out_ch;        // out_features
    int in_ch;         // in_features
    int out_zp;        // out_zero_point (uint4)
    int32_t rq_s;      // rq_scale_int12
    int32_t rq_shift;  // rq_shift_uint4
} LayerMeta;

typedef struct {
    LayerMeta m;
    const int8_t  *W;  // [out_ch][in_ch] (int4 values stored in int8)
    const int16_t *b;  // [out_ch] (int16 values)
} LayerParams;

typedef struct {
    LayerParams fc1;
    LayerParams fc2;
    LayerParams fc3;
} MLPParams;

// ------------------------
// Timer Utils
// ------------------------
#if defined(_WIN32)
static LARGE_INTEGER g_qpf;
static void timer_init(void) { QueryPerformanceFrequency(&g_qpf); }
static double now_ms(void) {
    LARGE_INTEGER t; QueryPerformanceCounter(&t);
    return (double)t.QuadPart * 1000.0 / (double)g_qpf.QuadPart;
}
#else
static void timer_init(void) {}
static double now_ms(void) {
    struct timespec ts; clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec * 1000.0 + (double)ts.tv_nsec / 1e6;
}
#endif

static void die(const char *msg) { perror(msg); exit(EXIT_FAILURE); }

// ------------------------
// File / Parse Utils
// ------------------------
static char* read_entire_file(const char *path) {
    FILE *fp = fopen(path, "rb");
    if (!fp) die(path);
    fseek(fp, 0, SEEK_END);
    long sz = ftell(fp);
    fseek(fp, 0, SEEK_SET);
    char *buf = (char*)malloc(sz + 1);
    fread(buf, 1, sz, fp);
    fclose(fp);
    buf[sz] = '\0';
    return buf;
}

static const char* skip_ws(const char *p) {
    while (*p && isspace((unsigned char)*p)) p++;
    return p;
}

static int parse_long_val(const char *json, const char *key, long *out) {
    const char *p = strstr(json, key);
    if (!p) return 0;
    p = strchr(p, ':'); if (!p) return 0;
    *out = strtol(p + 1, NULL, 10);
    return 1;
}

static int parse_int_array2(const char *json, const char *key, int *a0, int *a1) {
    const char *p = strstr(json, key);
    if (!p) return 0;
    p = strchr(p, '['); if (!p) return 0;
    *a0 = (int)strtol(p + 1, (char**)&p, 10);
    p = strchr(p, ','); if (!p) return 0;
    *a1 = (int)strtol(p + 1, NULL, 10);
    return 1;
}

// Parse meta.json for one layer
static int load_layer_meta(const char *json, const char *layer_name, LayerMeta *m) {
    char section_key[64];
    snprintf(section_key, sizeof(section_key), "\"%s\"", layer_name);
    const char *sec = strstr(json, section_key);
    if (!sec) return 0;

    // Dimensions
    if (!parse_int_array2(sec, "\"w_shape\"", &m->out_ch, &m->in_ch)) return 0;

    // Quant Params
    long val;
    if (!parse_long_val(sec, "\"out_zp\"", &val)) m->out_zp = 0; // default?
    else m->out_zp = (int)val;

    if (!parse_long_val(sec, "\"rq_scale_int12\"", &val)) return 0;
    m->rq_s = (int32_t)val;

    if (!parse_long_val(sec, "\"rq_shift_uint4\"", &val)) return 0;
    m->rq_shift = (int32_t)val;

    return 1;
}

// ------------------------
// Hex Loaders (4-bit specific)
// ------------------------

// Input: 196 lines, "0".."F". Store as uint8 (0..15).
static void load_input_u4_hex(const char *path, uint8_t *dst, int count) {
    FILE *fp = fopen(path, "rb");
    if (!fp) { fprintf(stderr, "Missing input: %s\n", path); exit(1); }
    for (int i = 0; i < count; i++) {
        unsigned int v;
        if (fscanf(fp, "%x", &v) != 1) break;
        dst[i] = (uint8_t)(v & 0xF);
    }
    fclose(fp);
}

// Weights: "0".."F".
// HW logic: int4 (-8..7). 
// Hex "F" -> 15 -> -1 (using 2's complement adjustment)
static void load_weight_int4_hex(const char *path, int8_t *W, int count) {
    FILE *fp = fopen(path, "rb");
    if (!fp) die(path);
    for (int i = 0; i < count; i++) {
        unsigned int v;
        if (fscanf(fp, "%x", &v) != 1) break;
        // Convert 4-bit hex to signed 8-bit
        uint8_t u = (uint8_t)(v & 0xF);
        if (u >= 8) W[i] = (int8_t)u - 16;
        else        W[i] = (int8_t)u;
    }
    fclose(fp);
}

// Bias: "0000".."FFFF".
// HW logic: int16.
static void load_bias_int16_hex(const char *path, int16_t *b, int count) {
    FILE *fp = fopen(path, "rb");
    if (!fp) die(path);
    for (int i = 0; i < count; i++) {
        unsigned int v;
        if (fscanf(fp, "%x", &v) != 1) break;
        b[i] = (int16_t)(v & 0xFFFF);
    }
    fclose(fp);
}

// ------------------------
// Inference Logic (HW Emulation)
// ------------------------
static int32_t clamp_i16(int32_t v) {
    if (v < INT16_MIN_V) return INT16_MIN_V;
    if (v > INT16_MAX_V) return INT16_MAX_V;
    return v;
}

static int32_t clamp_u4(int32_t v) {
    if (v < 0) return 0;
    if (v > UINT4_MAX_V) return UINT4_MAX_V;
    return v;
}

// HW Requant: acc(16) * scale(12) >> shift(4)
static int32_t requant_hw(int32_t acc, int32_t scale, int32_t shift) {
    int64_t mul = (int64_t)acc * (int64_t)scale; // result fits in 28 bits
    if (shift > 0) {
        // Rounding: + (1 << (shift-1))
        mul += (1LL << (shift - 1));
        return (int32_t)(mul >> shift);
    }
    return (int32_t)mul;
}

static void layer_infer(
    LayerParams lp, 
    const uint8_t *x_in, // uint4 array
    int in_zp,           // uint4
    uint8_t *y_out       // uint4 array
) {
    const LayerMeta *m = &lp.m;
    
    for (int o = 0; o < m->out_ch; o++) {
        const int8_t *w_row = &lp.W[o * m->in_ch];
        
        // MAC: Accumulator is int16 clamped
        int32_t acc = 0; 
        
        // 1. Dot Product: (Input - ZP) * Weight
        // Input: 0..15, ZP: 0..15 -> Range -15..15
        // Weight: -8..7
        // Product: approx -120..105. Sum of 196 elements fits in int16.
        for (int i = 0; i < m->in_ch; i++) {
            int32_t x_val = (int32_t)x_in[i] - in_zp;
            acc += x_val * (int32_t)w_row[i];
        }

        // 2. Add Bias
        acc += (int32_t)lp.b[o];

        // 3. Clamp Accumulator to int16
        acc = clamp_i16(acc);

        // 4. Requantize
        int32_t rq = requant_hw(acc, m->rq_s, m->rq_shift);

        // 5. Add Output ZP and Clamp to uint4
        int32_t qy = rq + m->out_zp;
        y_out[o] = (uint8_t)clamp_u4(qy);
    }
}

static int argmax(const uint8_t *v, int n) {
    int max_i = 0;
    uint8_t max_v = v[0];
    for (int i=1; i<n; i++) {
        if(v[i] > max_v) { max_v = v[i]; max_i = i; }
    }
    return max_i;
}

// ------------------------
// Main
// ------------------------
int main(int argc, char **argv) {
    timer_init();
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <export_dir> <inputs_meta.csv> [max] [show_err]\n", argv[0]);
        return 1;
    }

    const char *export_dir = argv[1];
    const char *csv_path   = argv[2];
    long max_samples = (argc >= 4) ? atol(argv[3]) : 0;
    int show_err     = (argc >= 5) ? atoi(argv[4]) : 1;

    // 1. Load Meta
    char path[1024];
    snprintf(path, sizeof(path), "%s/meta.json", export_dir);
    char *json = read_entire_file(path);

    LayerMeta m1, m2, m3;
    if (!load_layer_meta(json, "fc1", &m1) ||
        !load_layer_meta(json, "fc2", &m2) ||
        !load_layer_meta(json, "fc3", &m3)) die("Meta parse failed");
    free(json);

    // Verify Shape (196 -> 32 -> 16 -> 10)
    if (m1.in_ch != 196 || m1.out_ch != 32 || 
        m2.in_ch != 32  || m2.out_ch != 16 || 
        m3.in_ch != 16  || m3.out_ch != 10) {
        fprintf(stderr, "Error: Unexpected model shape.\n");
        return 1;
    }

    // 2. Alloc & Load Weights/Biases
    MLPParams p;
    p.fc1.m = m1; p.fc2.m = m2; p.fc3.m = m3;

    p.fc1.W = malloc(32*196); p.fc1.b = malloc(32*2);
    p.fc2.W = malloc(16*32);  p.fc2.b = malloc(16*2);
    p.fc3.W = malloc(10*16);  p.fc3.b = malloc(10*2);

    snprintf(path, sizeof(path), "%s/fc1_w_int4.hex", export_dir); load_weight_int4_hex(path, (int8_t*)p.fc1.W, 32*196);
    snprintf(path, sizeof(path), "%s/fc1_b_int16.hex", export_dir); load_bias_int16_hex(path, (int16_t*)p.fc1.b, 32);

    snprintf(path, sizeof(path), "%s/fc2_w_int4.hex", export_dir); load_weight_int4_hex(path, (int8_t*)p.fc2.W, 16*32);
    snprintf(path, sizeof(path), "%s/fc2_b_int16.hex", export_dir); load_bias_int16_hex(path, (int16_t*)p.fc2.b, 16);

    snprintf(path, sizeof(path), "%s/fc3_w_int4.hex", export_dir); load_weight_int4_hex(path, (int8_t*)p.fc3.W, 10*16);
    snprintf(path, sizeof(path), "%s/fc3_b_int16.hex", export_dir); load_bias_int16_hex(path, (int16_t*)p.fc3.b, 10);

    // 3. Process CSV
    FILE *fp = fopen(csv_path, "r");
    if (!fp) die(csv_path);

    char line[1024];
    fgets(line, sizeof(line), fp); // skip header

    long total = 0, correct = 0, mismatch_shown = 0;
    double t_total = 0;

    printf("Starting inference (4-bit/16-bit)...\n");

    while (fgets(line, sizeof(line), fp)) {
        if (max_samples > 0 && total >= max_samples) break;

        // Parse CSV: index,label,prediction,result,filename
        char *tok = strtok(line, ","); // index
        tok = strtok(NULL, ",");       // label
        int label = atoi(tok);
        tok = strtok(NULL, ",");       // pred (python)
        tok = strtok(NULL, ",");       // result
        tok = strtok(NULL, ", \r\n");  // filename (e.g. correct/mnist_...hex)

        snprintf(path, sizeof(path), "%s/inputs/%s", export_dir, tok);

        // Load Input (uint4)
        uint8_t x0[196];
        load_input_u4_hex(path, x0, 196);

        // Inference
        uint8_t y1[32], y2[16], y3[10];
        
        double t0 = now_ms();
        
        // L1: In=x0, ZP=0 (Fixed)
        layer_infer(p.fc1, x0, 0, y1);
        
        // L2: In=y1, ZP=fc1.out_zp
        layer_infer(p.fc2, y1, p.fc1.m.out_zp, y2);
        
        // L3: In=y2, ZP=fc2.out_zp
        layer_infer(p.fc3, y2, p.fc2.m.out_zp, y3);
        
        double t1 = now_ms();
        t_total += (t1 - t0);

        int pred = argmax(y3, 10);

        if (pred == label) correct++;
        else {
            if (mismatch_shown < show_err) {
                printf("[Mismatch] %s: Label=%d, HW_Pred=%d\n", tok, label, pred);
                mismatch_shown++;
            }
        }
        total++;
    }

    printf("--------------------------------------------------\n");
    printf("Processed: %ld\n", total);
    printf("Accuracy:  %.2f%%\n", (double)correct / total * 100.0);
    printf("Avg Time:  %.3f us / sample\n", (t_total * 1000.0) / total);
    printf("--------------------------------------------------\n");

    fclose(fp);
    return 0;
}