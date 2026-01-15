// run_indata.c
// CMD: gcc -O3 -march=native -std=c11 -DREQUANT_MODE=1 -I . run_indata.c qcnn.c indata.c -o run_indata
#include <stdio.h>
#include <stdint.h>
#include "qcnn_params.h"
#include "indata.h"

// qcnn_forward_i8（qcnn.c とリンク）
void qcnn_forward_i8 (const int8_t in[IN_C][IN_H][IN_W], int8_t  logits[FC_OUT]);

static inline int argmax_i8(const int8_t *v, int n){
    int mi = 0; int8_t mv = v[0];
    for(int i=1;i<n;++i){
        if(v[i] > mv){ mv = v[i]; mi = i; }
    }
    return mi;
}

int main(void){
    for(int i=0; i<DATANUM; ++i){
        int8_t logits[FC_OUT];
        qcnn_forward_i8(indata[i], logits);

        int pred = argmax_i8(logits, FC_OUT);
        uint8_t label = inlabels[i];

        // 出力フォーマット: img[番号],pred=値,label=値
        printf("img[%d]: pred=%d,label=%u\n", i, pred, (unsigned)label);
    }
    return 0;
}
