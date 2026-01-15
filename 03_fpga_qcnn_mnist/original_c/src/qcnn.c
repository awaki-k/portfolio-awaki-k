#include <stdint.h>
#include <stddef.h>
#include <limits.h>
#include "qcnn_params.h"
#include "qcnn.h"

// del
#include <stdio.h>

// ===== 形状フォールバック（qcnn_params.h に C1_H/W, C2_H/W が無い場合に使用）=====
#ifndef C1_H
#define C1_H (IN_H - C1_K + 1)
#endif
#ifndef C1_W
#define C1_W (IN_W - C1_K + 1)
#endif
#ifndef C2_H
#define C2_H (P1_H - C2_K + 1)
#endif
#ifndef C2_W
#define C2_W (P1_W - C2_K + 1)
#endif

// 中間活性は ReLU 後の u8、ゼロ点は 0
#define ZP_U8 0

// ---- 飽和ヘルパ ----
static inline int32_t sat_i32(long long v){
    if (v > INT32_MAX) return INT32_MAX;
    if (v < INT32_MIN) return INT32_MIN;
    return (int32_t)v;
}
static inline uint8_t clamp_u8(int32_t x){
    if (x < 0)   return 0;
    if (x > 255) return 255;
    return (uint8_t)x;
}
static inline int8_t clamp_i8(int32_t x){
    if (x < -128) return -128;
    if (x >  127) return  127;
    return (int8_t)x;
}

// ---- 再量子化（仕様どおり）：(acc * M + 0.5 * 2^r) >> r （論理右シフト）----
static inline int32_t requantize_spec(int32_t acc, uint32_t M, uint32_t r){
    if (r == 0){
        long long p0 = (long long)acc * (long long)M;
        return sat_i32(p0);
    }
    uint64_t p = (uint64_t)((acc < 0) ? -(long long)acc : (long long)acc) * (uint64_t)M;
    p += (uint64_t)1 << (r - 1);        // +0.5 ULP
    uint64_t q = p >> r;                // 論理右シフト
    long long s = (acc < 0) ? -(long long)q : (long long)q;
    return sat_i32(s);
}

/* ===== conv1: int8×int8 -> int32 -> requant -> +bias(out) -> ReLU -> u8 ===== */
static void conv1_forward(const int8_t x[IN_C][IN_H][IN_W], uint8_t y[C1_OC][C1_H][C1_W]) {
    for (int oc=0; oc<C1_OC; ++oc){
        for (int oh=0; oh<C1_H; ++oh){
            for (int ow=0; ow<C1_W; ++ow){
                int32_t sum = 0; // bias は out-domain
                for (int kh=0; kh<C1_K; ++kh){
                    const int ih = oh + kh;
                    for (int kw=0; kw<C1_K; ++kw){
                        const int iw = ow + kw;
                        const int8_t xv = x[0][ih][iw]; // 入力は signed int8 (zp=0)
                        const int8_t wv = Qconv1_weight_int8[oc][0][kh][kw];
                        sum += (int32_t)xv * (int32_t)wv;
                    }
                }
                
                // if (oc == 0) {
                //     printf("conv1_ch0_out_dbg[%d][%d]: %d\n", oh, ow, sum);
                // }

                int32_t rq = requantize_spec(sum, Qconv1_requant_mult[oc], Qconv1_requant_rshift[oc]);
                int32_t z  = rq + Qconv1_bias_int32[oc];
                if (z < 0) z = 0;                     // ReLU
                y[oc][oh][ow] = clamp_u8(z + ZP_U8);  // ZP_U8=0 なので +0

                // if (oc == 0) {
                //     printf("postconv1_ch0_out_dbg[%d][%d]: %d\n", oh, ow, y[0][oh][ow]);
                // }
            }
        }
    }
}
// static void conv1_forward(const int8_t x[IN_C][IN_H][IN_W],
//                           uint8_t y[C1_OC][C1_H][C1_W]) {
//     for (int oc=0; oc<C1_OC; ++oc){
//         for (int oh=0; oh<C1_H; ++oh){
//             for (int ow=0; ow<C1_W; ++ow){
//                 int32_t sum = 0; // bias は out-domain
//                 for (int kh=0; kh<C1_K; ++kh){
//                     const int ih = oh + kh;
//                     for (int kw=0; kw<C1_K; ++kw){
//                         const int iw = ow + kw;
//                         const int8_t xv = x[0][ih][iw]; // 入力は signed int8 (zp=0)
//                         const int8_t wv = Qconv1_weight_int8[oc][0][kh][kw];
//                         sum += (int32_t)xv * (int32_t)wv;
//                     }
//                 }
//                 int32_t rq = requantize_spec(sum, Qconv1_requant_mult[oc], Qconv1_requant_rshift[oc]);
//                 int32_t z  = rq + Qconv1_bias_int32[oc];
//                 if (z < 0) z = 0;                     // ReLU
//                 y[oc][oh][ow] = clamp_u8(z + ZP_U8);  // ZP_U8=0 なので +0
//             }
//         }
//     }
// }

/* ===== MaxPool 2x2 s=2（u8） ===== */
static inline uint8_t umax4(uint8_t a, uint8_t b, uint8_t c, uint8_t d){
    uint8_t m = (a>b)?a:b; m = (m>c)?m:c; m = (m>d)?m:d; return m;
}
static void maxpool2x2_u8_c1(const uint8_t in_ch[C1_OC][C1_H][C1_W], uint8_t out_ch[C1_OC][P1_H][P1_W]) {
    for (int c=0; c<C1_OC; ++c){
        for (int ph=0; ph<P1_H; ++ph){
            const int h0 = ph*2;
            for (int pw=0; pw<P1_W; ++pw){
                const int w0 = pw*2;
                out_ch[c][ph][pw] = umax4(in_ch[c][h0][w0], in_ch[c][h0][w0+1],
                                          in_ch[c][h0+1][w0], in_ch[c][h0+1][w0+1]);

                // if (c == 0) {
                //     printf("pool1_ch0_out_dbg[%d][%d]: %d\n", ph, pw, out_ch[0][ph][pw]);
                // }
            }
        }
    }
}
// static void maxpool2x2_u8_c1(const uint8_t in_ch[C1_OC][C1_H][C1_W],
//                              uint8_t out_ch[C1_OC][P1_H][P1_W]) {
//     for (int c=0; c<C1_OC; ++c){
//         for (int ph=0; ph<P1_H; ++ph){
//             const int h0 = ph*2;
//             for (int pw=0; pw<P1_W; ++pw){
//                 const int w0 = pw*2;
//                 out_ch[c][ph][pw] = umax4(in_ch[c][h0][w0], in_ch[c][h0][w0+1],
//                                           in_ch[c][h0+1][w0], in_ch[c][h0+1][w0+1]);
//             }
//         }
//     }
// }

/* ===== conv2: u8(zp=0)×int8 -> int32 -> requant -> +bias(out) -> ReLU -> u8 ===== */
static void conv2_forward(const uint8_t x[C1_OC][P1_H][P1_W], uint8_t y[C2_OC][C2_H][C2_W]) {
    for (int oc=0; oc<C2_OC; ++oc){
        for (int oh=0; oh<C2_H; ++oh){
            for (int ow=0; ow<C2_W; ++ow){
                int32_t sum = 0; // bias は out-domain
                for (int ic=0; ic<C1_OC; ++ic){
                    // if (ic==0) printf("linebuf_3x3_conv2_ch0_valid_dbg[%d][%d]: ", oh, ow);
                    for (int kh=0; kh<C2_K; ++kh){
                        const int ih = oh + kh;
                        for (int kw=0; kw<C2_K; ++kw){             
                            const int iw = ow + kw;
                            const int32_t xv = (int32_t)x[ic][ih][iw]; // ZP=0 のため減算不要
                            const int8_t wv = Qconv2_weight_int8[oc][ic][kh][kw];
                            sum += xv * (int32_t)wv;
                               
                            // if (ic==0) printf("%x", x[ic][ih][iw]);
                        }
                    }
                    // if(ic==0) printf("\n");
                }
                // if (oc == 0) {
                //     printf("conv2_ch0_out_dbg[%d][%d]: %d\n", oh, ow, (int)sum);
                // }
                int32_t rq = requantize_spec(sum, Qconv2_requant_mult[oc], Qconv2_requant_rshift[oc]);
                int32_t z  = rq + Qconv2_bias_int32[oc];
                if (z < 0) z = 0;
                y[oc][oh][ow] = clamp_u8(z + ZP_U8);

                // if (oc == 5) {
                //     printf("postconv2_ch5_out_dbg[%d][%d]: %d\n", oh, ow, y[5][oh][ow]);
                // }

            }
        }
    }
}
// static void conv2_forward(const uint8_t x[C1_OC][P1_H][P1_W],
//                           uint8_t y[C2_OC][C2_H][C2_W]) {
//     for (int oc=0; oc<C2_OC; ++oc){
//         for (int oh=0; oh<C2_H; ++oh){
//             for (int ow=0; ow<C2_W; ++ow){
//                 int32_t sum = 0; // bias は out-domain
//                 for (int ic=0; ic<C1_OC; ++ic){
//                     for (int kh=0; kh<C2_K; ++kh){
//                         const int ih = oh + kh;
//                         for (int kw=0; kw<C2_K; ++kw){
//                             const int iw = ow + kw;
//                             const int32_t xv = (int32_t)x[ic][ih][iw]; // ZP=0 のため減算不要
//                             const int8_t   wv = Qconv2_weight_int8[oc][ic][kh][kw];
//                             sum += xv * (int32_t)wv;
//                         }
//                     }
//                 }
//                 int32_t rq = requantize_spec(sum, Qconv2_requant_mult[oc], Qconv2_requant_rshift[oc]);
//                 int32_t z  = rq + Qconv2_bias_int32[oc];
//                 if (z < 0) z = 0;
//                 y[oc][oh][ow] = clamp_u8(z + ZP_U8);
//             }
//         }
//     }
// }

/* ===== MaxPool 2x2 s=2（u8） ===== */
static void maxpool2x2_u8_c2(const uint8_t in_ch[C2_OC][C2_H][C2_W], uint8_t out_ch[C2_OC][P2_H][P2_W]) {
    for (int c=0; c<C2_OC; ++c){
        for (int ph=0; ph<P2_H; ++ph){
            const int h0 = ph*2;
            for (int pw=0; pw<P2_W; ++pw){
                const int w0 = pw*2;
                out_ch[c][ph][pw] = umax4(in_ch[c][h0][w0], in_ch[c][h0][w0+1],
                                          in_ch[c][h0+1][w0], in_ch[c][h0+1][w0+1]);

                // if (c == 0) {
                //     printf("pool2_ch0_out_dbg[%d][%d]: %d\n", ph, pw, out_ch[0][ph][pw]);
                // }
            }
        }
    }
}
// static void maxpool2x2_u8_c2(const uint8_t in_ch[C2_OC][C2_H][C2_W],
//                              uint8_t out_ch[C2_OC][P2_H][P2_W]) {
//     for (int c=0; c<C2_OC; ++c){
//         for (int ph=0; ph<P2_H; ++ph){
//             const int h0 = ph*2;
//             for (int pw=0; pw<P2_W; ++pw){
//                 const int w0 = pw*2;
//                 out_ch[c][ph][pw] = umax4(in_ch[c][h0][w0], in_ch[c][h0][w0+1],
//                                           in_ch[c][h0+1][w0], in_ch[c][h0+1][w0+1]);
//             }
//         }
//     }
// }

/* ===== FC: u8(zp=0)×int8 -> int32 -> requant -> +bias(out) -> (i8 or i32) ===== */
static void fc_forward_i32(const uint8_t x[C2_OC][P2_H][P2_W], int32_t out_i32[FC_OUT]) {
    for (int o=0; o<FC_OUT; ++o){
        int32_t sum = 0; // bias は out-domain
        int idx = 0;
        for (int c=0; c<C2_OC; ++c){
            for (int h=0; h<P2_H; ++h){
                for (int w=0; w<P2_W; ++w){
                    const int32_t xv = (int32_t)x[c][h][w]; // ZP=0
                    sum += xv * (int32_t)Qfc_weight_int8[o][idx++];
                    // if(o == 0 && h==0 && w==0)printf("[%d][%d][%d]: x*w=%d*%d\n", c, h, w, (int)xv, (int)Qfc_weight_int8[o][idx-1]);
                    // if(o == 0)printf("pool2_ch%d_out_dbg[%d][%d]: %d\n", c, h, w, (int)xv);
                }
            }
        }
        int32_t rq = requantize_spec(sum, Qfc_requant_mult[o], Qfc_requant_rshift[o]);
        out_i32[o] = rq + Qfc_bias_int32[o];  // 最終層は signed 出力

        // if (o >= 0) {
        // //     printf("Qfc_mult=%u r=%u bias=%d\n",
        // //    Qfc_requant_mult[o], Qfc_requant_rshift[o], Qfc_bias_int32[o]);
        //     printf("fc_ch%d_out_dbg: %d\n", o, sum);
        //     printf("postfc_ch%d_out_dbg: %d\n", o, out_i32[o]);
        // }
    }
}
// static void fc_forward_i32(const uint8_t x[C2_OC][P2_H][P2_W],
//                            int32_t out_i32[FC_OUT]) {
//     for (int o=0; o<FC_OUT; ++o){
//         int32_t sum = 0; // bias は out-domain
//         int idx = 0;
//         for (int c=0; c<C2_OC; ++c){
//             for (int h=0; h<P2_H; ++h){
//                 for (int w=0; w<P2_W; ++w){
//                     const int32_t xv = (int32_t)x[c][h][w]; // ZP=0
//                     sum += xv * (int32_t)Qfc_weight_int8[o][idx++];
//                 }
//             }
//         }
//         int32_t rq = requantize_spec(sum, Qfc_requant_mult[o], Qfc_requant_rshift[o]);
//         out_i32[o] = rq + Qfc_bias_int32[o];  // 最終層は signed 出力
//     }
// }

static void fc_forward_i8(const uint8_t x[C2_OC][P2_H][P2_W],
                          int8_t out_i8[FC_OUT]) {
    int32_t tmp[FC_OUT];
    fc_forward_i32(x, tmp);
    for (int o=0; o<FC_OUT; ++o) out_i8[o] = clamp_i8(tmp[o]);
}

/* ===== 全体前向き ===== */
static void feature_forward(const int8_t in[IN_C][IN_H][IN_W],
                            uint8_t p2[C2_OC][P2_H][P2_W]) {
    static uint8_t c1_out[C1_OC][C1_H][C1_W];
    static uint8_t p1    [C1_OC][P1_H][P1_W];
    static uint8_t c2_out[C2_OC][C2_H][C2_W];

    conv1_forward(in, c1_out);
    maxpool2x2_u8_c1(c1_out, p1);

    conv2_forward(p1, c2_out);
    maxpool2x2_u8_c2(c2_out, p2);
}

void qcnn_forward_i8 (const int8_t in[IN_C][IN_H][IN_W], int8_t  logits[FC_OUT]) {
    static uint8_t p2[C2_OC][P2_H][P2_W];
    feature_forward(in, p2);
    fc_forward_i8(p2, logits);
}

void qcnn_forward_i32(const int8_t in[IN_C][IN_H][IN_W], int32_t logits[FC_OUT]) {
    static uint8_t p2[C2_OC][P2_H][P2_W];
    feature_forward(in, p2);
    fc_forward_i32(p2, logits);
}
