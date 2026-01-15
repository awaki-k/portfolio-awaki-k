# C 実装 INT8 CNN 推論（MNIST想定）

`qcnn.c` は、INT8 量子化済みの小型 CNN を **純 C（C11）** で推論する実装です。前段の QAT で生成したパラメータを `qcnn_params.h` に埋め込み、**畳み込み→ReLU→MaxPool×2→全結合** の順で計算します。API は `qcnn.h` で提供します。 &#x20;

---

## 特長

* **完全固定小数点（INT8/INT32）**：中間活性は ReLU 後の **u8（ZP=0）**、最終ロジットは **int8 または int32** を選択可。
* **再量子化の明示実装**：`(acc * M + 0.5·2^r) >> r`（論理右シフト、飽和あり）を関数 `requantize_spec` として実装。
* **パラメータは自動生成ヘッダ**：学習ノートブックから出力した `qcnn_params.h`（形状・スケール・重み・バイアス・再量子化係数）。

---

## 実行結果

- OS: Windows 11 Pro 24H2
- CPU: Intel Core i7-13700KF
- Memory: 32 GB


<img width="1668" height="337" alt="Image" src="https://github.com/user-attachments/assets/9b4ec48f-870f-444d-b794-07b192befce0" />

---

## ファイル構成

* `qcnn.h`：推論 API（`qcnn_forward_i8`, `qcnn_forward_i32`）を宣言。
* `qcnn.c`：畳み込み・MaxPool・FC と再量子化の実装。
* `qcnn_params.h`：**自動生成**されたネットワーク定義と量子化パラメータ（INT8 重み / INT32 バイアス / requant 係数など）。
* `run_indata.c`：サンプル入力（`indata.h`）を流して **`img[i]: pred=…,label=…`** を出力する最小デモ。

> `qcnn_params.h` の形状（例）：`IN=1×28×28`、`C1: 1→4, k=3`、`P1: 13×13`、`C2: 4→8, k=3`、`P2: 5×5`、`FC: 200→10`。

---

## ビルド

### 単体デモ（手元の indata を使用）

```bash
# -O3 / -march=native 推奨。C11 とカレントをインクルード。
gcc -O3 -march=native -std=c11 -I . run_indata.c qcnn.c indata.c -o run_indata
./run_indata
```

`run_indata.c` の先頭コメントにあるコンパイル例と同等です。出力は `img[0]: pred=7,label=7` のように表示されます。

### ライブラリとして組み込み

```bash
gcc -O3 -march=native -std=c11 -I . -c qcnn.c
# アプリ側で qcnn.h / qcnn_params.h を include し、libqcnn.o をリンク
```

API は次の 2 つです。

```c
void qcnn_forward_i8 (const int8_t in[IN_C][IN_H][IN_W], int8_t  logits[FC_OUT]);
void qcnn_forward_i32(const int8_t in[IN_C][IN_H][IN_W], int32_t logits[FC_OUT]);
```

---

## 入出力と前処理

* **入力テンソル**：`int8` 形状 `[1][28][28]`、**ゼロ点 0**、スケール **`Qinput_scale = 1/128`** を想定（学習系と一致）。

  * 浮動小数点 `x_norm` を与えるなら `round(x_norm / 1/128)` を **\[-128,127] に飽和**して `int8` 化してください。
* **中間表現**：`conv1/conv2` 出力は **u8（ZP=0）**、`maxpool` は u8 のまま。
* **出力**：`qcnn_forward_i8` は `int8[10]`、`qcnn_forward_i32` は `int32[10]` を返します（`argmax` 等でクラス決定）。

---

## 実装詳細（要点）

* **conv1**：`int8×int8→int32` 積和→`requantize_spec(sum, M[oc], r[oc])`→`+bias[oc]`→`ReLU`→`u8` へ飽和。ゼロ点は 0 固定。
* **maxpool 2×2 / s=2**：u8 上で最大値を取得。
* **conv2**：`u8(zp=0)×int8→int32`→再量子化→バイアス→ReLU→u8。
* **fc**：`u8×int8→int32`→再量子化→**符号付き出力**（最終層は ReLU なし）。`i8` 版は最後に `clamp_i8`。
* **形状**：`C1_H/W = IN - 3 + 1 = 26`、`P1=13`、`C2_H/W = 13 - 3 + 1 = 11`、`P2=5`（`qcnn_params.h` に未定義時はコード側のフォールバックを使用）。&#x20;
* **係数**：各層の `requant_mult[] / requant_rshift[]` と `bias_int32[]` は `qcnn_params.h` に埋め込み。

---

## サンプル実行（`run_indata`）

`indata.h`（`DATANUM`, `indata[DATANUM][1][28][28]`, `inlabels[DATANUM]` を含む）を用意し、`run_indata` を実行すると、各サンプルについて **`pred` と `label`** を出力します。フォーマットは以下のとおりです。

```
img[0]: pred=7,label=7
img[1]: pred=2,label=2
...
```

---

## 置換・拡張ポイント

* **独自パラメータに差し替え**：`qcnn_params.h` を学習パイプラインから再生成して置き換え。形状マクロ（`IN_*`, `C1_*`, `C2_*`, `FC_*`）と係数配列の整合を保ってください。
* **入力サイズ変更**：`qcnn_params.h` の形状に合わせ、`C1_H/W`・`C2_H/W` はコード側で自動計算（未定義時）。固定としたい場合はヘッダ側で `#define` を明示。
* **出力スケールが必要な場合**：`Qfc_out_scale` を参照（現在は後段で argmax 前提）。

---

## 既知事項

* 内部ワークバッファは静的配列（`c1_out`, `p1`, `c2_out`, `p2`）。スタック消費を避けるため **static** にしています。組込み向けは配置先メモリを調整してください。
* `requantize_spec` は **論理右シフト** 前提です。ターゲット環境で算術シフトになる場合はキャスト/マスクで論理化してください。

