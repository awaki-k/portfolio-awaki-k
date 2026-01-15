// indata.h (auto-generated)
#ifndef INDATA_H_
#define INDATA_H_

#include <stdint.h>
#include "qcnn_params.h"

#define DATA_NUM 10

// shape: [DATA_NUM][1][28][28] (int8)
extern int8_t indata[DATA_NUM][IN_C][IN_H][IN_W];

// labels: 0..9
extern const uint8_t inlabels[DATA_NUM];

#endif /* INDATA_H_ */
