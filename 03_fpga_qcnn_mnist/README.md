# Lightweight CNN on FPGA for MNIST (QAT / INT8)

MNIST の手書き数字認識用に軽量 CNN を設計し Terasic DE2-115 (Cyclone IV E, EP4CE115) へ実装。CPU 実行に対して高速化を確認しました。学習時は **Quantization Aware Training（QAT）で 8-bit 量子化**を適用しています。&#x20;

> [デモURL](https://drive.google.com/file/d/1jjf_ymlUtIszF1WXhxcUTPicZBGf92-6/view?usp=drive_link)
---

## 特長

* **INT8 QAT**：学習時から量子化効果を織り込み、推論時の精度劣化を抑制（**Test Acc ≈ 98.15%**）。
* **ストリーミング畳み込み**：ラインバッファ＋並列 **Dot-Product ユニット**、各層で **Requant→Bias→ReLU/Clamp** を固定小数点で一貫実装。
* **SoC 構成**：Nios II、SDRAM、VGA、CNN IP を Avalon-ST で接続（100 MHz/25 MHz）。
* **実機での高速化**：CPU(O3) 15 µs/枚に対し、GL-Sim 7.8 µs、実機 12.2 µs。

---

## モデル

* **アーキテクチャ**：Conv(1→4, k=3) → MaxPool(2) → Conv(4→8, k=3) → MaxPool(2) → FC(200→10)（入力 1×28×28）。
* **学習設定**：Adam(lr=1e-3, wd=1e-4), batch=128, 10 epochs、データ分割 55k/5k/10k。**QAT は 1 epoch のウォームアップ後に有効化**。
* **結果**：Test Loss ≈ 0.0588、Accuracy ≈ **98.15%**。

---

## ハードウェア / ツール

* **FPGA ボード**：DE2-115（LEs 114,480、\~3.9 Mbit メモリ、18×18 DSP 266、SDRAM 128 MB ほか）。
* **設計フロー**：PyTorch（2.7.1+cu118）で QAT → パラメータ出力 → Verilog RTL → Quartus Prime 18.1（合成/STA, RTL/GL シミュレーション）→ Platform Designer → **Nios II SBT for Eclipse** で SW 実行。

---

## システム構成（要点）

* Nios II、SDRAM/PIO/VGA サブシステムと **CNN IP** を Avalon-ST で接続。コアは 100 MHz、VGA 系は 25 MHz。
* **CNN IP**：ラインバッファで 3×3/2×2 の窓を生成し、並列 Dot-Product（32bit Acc）→ Requant（スケール乗算）→ Bias → ReLU/Clamp。

---

## ベンチマーク

| 指標         | CPU (i7-13700KF, O3) |     FPGA（GL-Sim） |          FPGA（実機） |
| ---------- | -------------------: | ---------------: | ----------------: |
| レイテンシ / 画像 |            **15 µs** | **7.8 µs**（−48%） | **12.2 µs**（−19%） |

* CPU ベースライン：**7,982 / 8,077 = 98.82%**、平均 **15 µs/枚**（O3）。
* まとめ：GL-Sim で **約 2×**、実機で **約 1.2×** 高速化。

---

## 資源使用量 / タイミング

**コア回路（CNN IP 単体）**
LE **30,717**（27%）、DSP(9-bit) **251**（47%）、MemBits **739**（<1%）。**Slack +0.001 ns @ 100 MHz**。クリティカルは **再量子化 32×32 乗算（DSP）**。

**SoC 全体**
LE **34,370**（30%）、DSP **251**（47%）、MemBits **34,851**（<1%）、Pins **154**（29%）、PLL **1**（25%）。

---

## デモ（操作フロー）

`SW[3:0]` で画像選択 → `SW[4]` で推論開始 → `out_valid` で完了。結果は **7-seg** と **UART ログ**へ表示（VGA でも画像表示）。

---

## 再現手順

1. **学習（QAT, PyTorch）**

   * MNIST を用意し、上記設定で学習。**QAT を有効化**して INT8 の重み・スケール・バイアスをエクスポート。
2. **RTL / システム生成**

   * Verilog で CNN IP を実装。Quartus で合成/STA、Platform Designer で Nios II/SDRAM/VGA/CNN IP を接続。
3. **書き込み / 実行**

   * FPGA に書き込み、Nios II SBT で SW をビルド・実行（ボード上スイッチでデモ操作）。

> ツールバージョン：PyTorch 2.7.1+cu118 / Quartus Prime 18.1 Lite / Platform Designer 18.1 / Nios II SBT（Mars.2 4.5.2）。

---

## リポジトリ構成（例）

```
.
├─ train/　　              # QAT 学習・エクスポート
├─ original_c/             # CPU実行用
├─ rtl/                    # coreモジュールのRTL
└─ soc/                    # .qpf/.qsf, .qsys/.sopcinfo 
```

---

## 既知の課題 / 今後

* **より低ビット幅（INT4 等）での精度維持**。
* **I/O・メモリアクセス・周辺回路**によるオーバヘッドの最小化、Nios II 側処理の最適化。


