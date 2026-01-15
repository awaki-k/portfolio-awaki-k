# QCNN on DE2-115 — Platform Designer 〜 Nios II 実機測定


---

## 1. システム構成（Platform Designer）

<img width="1954" height="951" alt="image" src="https://github.com/user-attachments/assets/49d09176-7915-4f7c-9b12-49944f0c84df" />


**ブロック（抜粋）**：Nios II / SDRAM Ctl / SRAM Ctl / JTAG UART / PIO(SW/HEX) / Timer / VGA サブシステム（Pixel Buffer DMA #0, RGB Resampler, Scaler, FIFO, VGA Ctl）/ **Pixel Buffer DMA #1（ST 出力）** / **QCNN IP（ST 入力 + MM レジスタ）** / System ID / PLL。**100 MHz（コア）/25 MHz（VGA）**。

> **デバイス名の前提**（Nios アプリはこれらに依存）
>
> * VGA 表示用 **`/dev/video_pixel_buffer_dma_0`**、ST 送信用 **`/dev/video_pixel_buffer_dma_1`**。
> * QCNN IP の MM ベース：`ST2MM_QCNN_IP_0_BASE`（`system.h` に自動生成）。レジスタオフセット `pred(0x08)`, `status(0x0C)` を使用。

**ユーザ操作**：`SW[3:0]`＝画像選択（0..9 を VGA へ 8 倍表示）、`SW[4]` 立上りで推論実行、**7-seg** に選択番号を遅延表示、UART に測定ログを出力。&#x20;

---

## 2. ビルド前提（ツール）

* **Quartus Prime 18.1 Lite / Platform Designer 18.1 / Nios II SBT for Eclipse (Mars.2 4.5.2)**。

---

## 3. Platform Designer：セットアップ手順

1. **IP 追加**
   `top/` にあるカスタム IP 定義（例：`qcnn_ip_hw.tcl`, `st2mm_qcnn_ip_hw.tcl`）を **IP Catalog** に取り込み。QCNN IP は Avalon-ST **sink** + MM レジスタ（pred/status）を持つ前提です。アーキ図と一致するよう Pixel Buffer DMA #1（ST **source**）を **QCNN IP の ST 入力**に配線。

2. **クロック/リセット**
   PLL 50 MHz → {**100 MHz（Nios/QCNN/PDMA1）**, **25 MHz（VGA 系/PDMA0）**} を生成し各ブロックへ配線。

3. **メモリ/周辺**

* **SDRAM**：VGA フレームバッファ 2 面を確保（後述アプリの固定アドレス使用）。
* **SRAM**：PDMA#1 が読む **28×28 8 bpp** の DMA バッファ置き場。
* **PIO**：スイッチ（`SW_BASE`）、7-seg（`HEX0_BASE`）。
* **Timer**：100 MHz ダウンカウンタでスナップショット読み。

4. **System Generation**
   HDL を生成し、`<system>.qip` を Quartus プロジェクトへ追加。

---

## 4. Quartus（top/）：合成〜書き込み

* **トップ HDL**：`vga_qcnn.v`（PD システムのインスタンスを含む）。**SDC** は `vga_qcnn.sdc` を使用（100 MHz / 25 MHz 制約）。
* **コンパイル**：**Analysis & Synthesis → Fitter → TimeQuest STA**。コア回路は **Slack +0.001 ns @100 MHz**、クリティカルは **再量子化 32×32 乗算（DSP）**。
* **書き込み**：`output_files/*.sof` を DE2-115 へプログラム。

**参考（資源使用量）**：SoC 全体 LEs **34,370(30%)**, DSP **251(47%)**, PLL **1(25%)**。コア単体 LEs **30,717**, DSP **251**。

---

## 5. Nios II SBT for Eclipse：ワークスペース & アプリ

1. **ワークスペース作成**
   `File > New > Nios II Application and BSP from Template` → **Empty Application** を選択。ターゲットは PD 生成の `.sopcinfo`。

2. **ソース追加**

* **実機デモ**：`test13.c`（本プロジェクトのメイン）。次を行います：

  * **VGA**：MNIST（int8）を 8 倍で矩形塗りつぶし描画（**ルックアップ+ランレングス風に連続 Box 描画**で高速化）。
  * **DMA バッファ構築**：`SRAM_1` に **28×28 8 bpp** を生成（`IMG_H=26` のため**下 2 行は 0 でパディング**）。`alt_dcache_flush_all()` で可視化。&#x20;
  * **PDMA#1 送出**→ **QCNN IP**（ST sink）→ **MM レジスタから pred 読出し**。
  * **Timer 計測**：ダウンカウンタの SNAP で **ticks** を取得し **ns** へ変換。
  * **7-seg 遅延表示 & SW\[4] デバウンス**：**2 ms 安定後**に確定、**立下り即消灯**。
* **入力画像**：`mnist.c`（`img0..img9`, `IMG_W=28, IMG_H=26`）。

3. **BSP 設定**

* ドライバ：`altera_up_avalon_video_pixel_buffer_dma` を含む（PD のインスタンス名と一致）。
* `system.h` の `ST2MM_QCNN_IP_0_BASE` / `TIMER_0_FREQ` 等が生成されていること。

4. **ビルド & 実行**

* BSP / App をビルド → **Program Device (.sof)** → **Run As > Nios II Hardware**。
* **Nios II Console**（JTAG UART）にログが出ます。

---

## 6. 実機デモ & 測定手順

<img width="1892" height="891" alt="image" src="https://github.com/user-attachments/assets/9f967c1b-5265-42b0-aff2-f7bf35e1e3c7" />

1. **画像選択**：`SW[3:0]` で `0..9` を選び、VGA に 8 倍描画されるのを確認。
2. **推論開始**：`SW[4]` を押す（**デバウンス後に有効**）。PDMA#1 が SRAM の 28×28 バッファをストリーム出力 → QCNN IP が推論。
3. **完了/記録**：`out_valid` 相当で **pred** が MM レジスタに出現。UART には

<img width="1895" height="940" alt="image" src="https://github.com/user-attachments/assets/b68a9b11-3cb0-4bcc-9490-81d54e1e7985" />

4. **目安**：本構成で **\~12.2 µs/枚**（複数回計測の平均）。I/O, メモリアクセス, 周辺回路, Nios II オーバヘッドの影響で GL-Sim（7.8 µs/枚）より遅くなります。

---

