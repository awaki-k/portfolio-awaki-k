# QAT MNIST（INT8）— 学習〜パラメータ出力ノートブック

このノートブック（`train.ipynb`）は、MNIST の軽量 CNN に **QAT（Quantization Aware Training）** を適用し、**INT8 推論用パラメータ（.npz / .json / Cヘッダ）** を出力します。
学習・評価・エクスポート・Cヘッダ生成・検証用データの作成まで一通り含みます。

---

## 1. 環境

* Python 3.9+（推奨）
* PyTorch / torchvision / numpy / jupyter
* CUDA/GPU は任意（あれば高速）

```bash
pip install torch torchvision numpy jupyter
```

---

## 2. モデル/量子化の要点

* アーキテクチャ：Conv(1→4, k=3) → MaxPool(2) → Conv(4→8, k=3) → MaxPool(2) → FC(200→10)
* 量子化：**LSQ**

  * 重み：**per-channel** scale（各出力チャネル）
  * 活性：**per-tensor** scale（層ごと）
* 活性関数：**PACT-ReLU**（学習可能クリップ上限 α）
* 最適化：Adam（`lr=1e-3, weight_decay=1e-4`）
* ウォームアップ：最初の `--warmup-epochs` は重み量子化を無効、その後有効化

---

## 3. すぐ試す（Notebook で Run All）

1. `train.ipynb` を開き、**上から順に実行**
2. 既定のままでも学習 → 評価 → **エクスポート（.npz / .json）** まで進みます
3. 生成ファイル（カレント直下）

   * `qat_mnist.pth`：学習済みチェックポイント
   * `qat_export.npz`：INT8 推論パラメータ
   * `qat_export.json`：スケール等のメタデータ

> 既定の主なハイパラ：`epochs=10, batch_size=128, warmup_epochs=1`

---

## 4. 出力 `.npz` の中身（推論実装向け）

キー構成（例）：

```
input_scale                          # float32[1]

conv1_weight_int8    int8[4,1,3,3]
conv1_bias_int32     int32[4]
conv1_w_scale        float32[4]      # per-channel
conv1_in_scale       float32[1]
conv1_out_scale      float32[1]
conv1_requant_mult   uint32[4]
conv1_requant_rshift uint32[4]

conv2_weight_int8    int8[8,4,3,3]
conv2_bias_int32     int32[8]
conv2_w_scale        float32[8]
conv2_in_scale       float32[1]
conv2_out_scale      float32[1]
conv2_requant_mult   uint32[8]
conv2_requant_rshift uint32[8]

fc_weight_int8       int8[10,200]
fc_bias_int32        int32[10]
fc_w_scale           float32[10]
fc_in_scale          float32[1]
fc_out_scale         float32[1]
fc_requant_mult      uint32[10]
fc_requant_rshift    uint32[10]
```

* 再量子化は各層で `y = (acc_int64 * mult + rounding) >> rshift` を想定
* `*_w_scale` は学習で得た実数スケール（デバッグ/解析用）

---

## 5. C ヘッダ生成（IP/組込み向け）

ノートブック内の **「ヘッダ生成スクリプト」セル**（`make_qheader.py` 相当）を実行すると、`.npz` から C ヘッダを出力します。スクリプトとして使う場合は以下。

```bash
# デフォルト: ./qat_export.npz → ./qcnn_params.h
python make_qheader.py --npz qat_export.npz --out qcnn_params.h --prefix Q --dump-csv
```

* `--prefix`：シンボル名接頭辞（例：`Qconv1_weight_int8`）
* `--dump-csv`：各行列を CSV でも保存（検証用）

ヘッダ内には shapes/スケール/再量子化係数が `static const` 配列として生成されます。

---

## 6. 検証用データの作成

### 6.1 ラベル 0〜9 を 1 枚ずつ（`indata.h` / `indata.c`）

ノートブックの該当セルを実行すると、以下を自動生成します。

* `indata.h`：`int8_t indata[10][1][28][28]`、`uint8_t inlabels[10]`
* `indata.c`：上記の実体（`qcnn_params.h` を `#include`）

内部で **Normalize(mean=0.1307, std=0.3081) → INT8 量子化（`1/128`）** を適用。

### 6.2 テスト全件をバイナリで（`mnist_test_i8.bin` / `mnist_test_labels.bin`）

`dump_mnist_bin.py` 相当セルを実行。最初に **保存先 `ROOT` を自分の環境に合わせて変更**してください。

```python
ROOT = Path(r"D:/cfs/final").resolve()  # ここを変更
S_IN = 1/128.0                          # 入力スケール（ヘッダと一致）
```

* 変換パイプ：**Normalize → /S\_IN → round/clamp to INT8**
* 出力：`mnist_test_i8.bin`（int8 N×1×28×28）, `mnist_test_labels.bin`（uint8 N）

### 6.3 .bin → C ヘッダ（`qmnist_data.h`）

`emit_header(...)` セルで `.bin` から `qmnist_data.h` を生成できます。例：

```python
emit_header(
  images_bin="mnist_test_i8.bin",
  labels_bin="mnist_test_labels.bin",
  out_path="src_c2/qmnist_data.h",
  sym_images="test_images",
  sym_labels="test_labels",
  limit=10000,
)
```

（セル末尾に **gcc のワンライナー**例も出力します。C 版推論検証に利用可能。）

---

## 7. 推奨 I/O 方針（Normalize の折り込み）

* **推論入力を INT8（-128..127, scale=1/128）で与える**場合
  → `--no-fold-normalize` を付けて **conv1 に Normalize を折り込まない**
  → 前処理側で **Normalize → INT8 量子化** を行う（本ノートブックの .bin 生成と整合）
* 逆に、前処理で Normalize せず生の INT8 を入れたい場合
  → `--no-fold-normalize` を付けない（＝conv1 に Normalize を **折り込む**）

---

## 8. 再現メモ

* 乱数固定：`torch.manual_seed(0)`, `np.random.seed(0)`
* DataLoader：`pin_memory=True`、`num_workers=2`（適宜調整）
* 精度/速度はデバイスと実行回により微変動

---

## 9. リポジトリ構成（例）

```
.
├─ train.ipynb
├─ qat_mnist.pth           # 学習後（Run All で生成）
├─ qat_export.npz          # INT8 推論パラメータ
├─ qat_export.json         # メタデータ（スケール等）
├─ qcnn_params.h           # C ヘッダ（ヘッダ生成セル or make_qheader.py）
└─ indata.h / indata.c     # 検証用 10 サンプル
 ```
