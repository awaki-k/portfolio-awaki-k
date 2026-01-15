#ifndef QCNN_H_
#define QCNN_H_
#include <stdint.h>
#include "qcnn_params.h"

// 推論（最終ロジットを int8 出力）
void qcnn_forward_i8 (const int8_t in[IN_C][IN_H][IN_W], int8_t  logits[FC_OUT]);
// 推論（最終ロジットを int32 出力：評価/同点回避向け）
void qcnn_forward_i32(const int8_t in[IN_C][IN_H][IN_W], int32_t logits[FC_OUT]);

#endif
