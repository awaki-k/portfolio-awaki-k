# Gate Level Simulation（Quartus Prime/ ModelSim-Altera）

**INT8 量子化 CNN を Cyclone IV E（DE2-115）向けに Verilog で実装。Quartus Prime で合成〜Fitter〜STA〜**Gate-Level Simulation**（GL-Sim）までを再現するための README です。**
設計方針・アーキテクチャ・最適化手法・計測値はスライド類に基づきます。 &#x20;

---

## 対象 / 目的

* **目的**：CNN 推論を **FPGA** で高速化（CPU 比）。
* **対象ボード**：Terasic **DE2-115（Cyclone IV E EP4CE115）**。LEs 114,480 / 18×18 DSP 266 / on-board SDRAM 等。
* **モデル**：Conv(1→4, k=3) → MaxPool(2) → Conv(4→8, k=3) → MaxPool(2) → FC(200→10)。

---

## アーキテクチャ概要

<img width="1936" height="796" alt="image" src="https://github.com/user-attachments/assets/b550b474-4e07-41a4-b560-2c3a76c2fc03" />


* **ストリーミング構成**：ラインバッファで窓生成 → **Dot-Product Unit**（並列 MAC）→ 各層で **Requant(M,r) → Bias → ReLU/Clamp**（最終 FC は Clamp のみ）。
* **並列度**：Conv1 用に DP×**4**、Conv2 用に DP×**8**、FC 用に DP×**10** を常時並列。
* **DP ユニット**：`N` 要素の乗算 → AdderTree（パイプライン化、`STAGE_DEPTH` 可変）、`acc` は **32bit**。パラメタ化 Verilog。

---

## 最適化方針（実装レベル）

* **チャネル並列化**：出力チャネルごとに独立な MAC を**4/8/10 並列**に配置。スループットを DP 個数で引き上げ。
* **ループ展開 + パイプライン**：畳み込み内ループを展開、AdderTree とレジスタ挿入でクリティカルパスを分割。&#x20;
* **DSP 予算管理**：EP4CE115 は 18×18 DSP **266 個**（≒8×8 換算 **532**）。本設計の同時 MAC 需要は **Conv1(9×4)+Conv2(36×8)+FC(8×10)=404** で予算内。
* **ボトルネックの局在化**：再量子化の **32×32 乗算**（DSP）を最長経路とし、他段を緩和。

---

## ツール / バージョン

* **Quartus Prime 18.1 Lite** / **Platform Designer 18.1** / **Nios II SBT for Eclipse (Mars.2 4.5.2)**。学習側は **PyTorch 2.7.1+cu118**（QAT）。

---

## 再現手順（Quartus Prime：GL-Sim まで）

1. **プロジェクト作成**
   `rtl/qcnn_top.v` と依存モジュールを追加。**トップは `qcnn_top`**。必要に応じて `qcnn_top_tb.v` をシミュレーション用に追加。
2. **Platform Designer**（使う場合）
   Nios II / SDRAM / VGA / CNN を接続し **System Generation**。
3. **Analysis & Synthesis → Fitter → TimeQuest STA**
   目標 **10.0 ns（100 MHz）**。本設計では **Slack +0.001 ns**（コア単体）。最長経路は **再量子化×DSP**。
4. **Functional Verification (RTL-Sim / GL-Sim)**
   Quartus から **Functional Verification(GL-Sim)** を実行（Design Flow 図参照）。**GL-Sim** の波形/コンソールで、**平均レイテンシ ≈ 7,800 ns/画像、10 枚、Accuracy 100%（サンプル）** を確認。
   ※ テストベンチは `img_mem.hex` を読み込む想定（波形例と同一）。

> Design Flow（QAT → Parameter Export → RTL → 合成/配置配線 → **Functional Verification (RTL/GL)** → STA → FPGA 書き込み）を図で整理。

---

## 測定・評価（GL-Sim 範囲）

* **GL-Sim（コア）**：**7.8 µs/枚（−48% vs CPU 15 µs）**。
* **CPU ベースライン**：i7-13700KF、O3 平均 **15 µs/枚**（8,077 件）。
* **実機参考**：12.2 µs/枚（−19%）。I/O・メモリ・周辺回路・Nios II のオーバヘッド影響。

---

## 資源使用量 / タイミング（合成結果）

* **コア回路**：LE **30,717 (27%)**、DSP(9-bit) **251 (47%)**、MemBits **739 (<1%)**。
* **全体（SoC）**：LE **34,370 (30%)**、DSP **251 (47%)**、PLL **1 (25%)**。
* **Fmax**：要件 **100 MHz** に対し **Slack +0.001 ns**。ボトルネック＝**Requant 32×32**。

---

## テストベンチ / 入出力

* **テストベンチ**：`qcnn_top_tb.v`（クロック/リセット/入力ストリーム/完了信号）。GL-Sim のコンソールに **Avg latency / Throughput / Accuracy** を出力。
* **入力**：`img_mem.hex` から 28×28（INT8）を順送り（波形 例参照）。
* **出力**：`out_valid` で 10 クラスの予測（argmax）を提示。

---

## 結果

* Gate-Level Simulation
<img width="5645" height="2509" alt="image" src="https://github.com/user-attachments/assets/d896e189-fa8c-493b-b5b9-fccad7abc777" />

* Inference time and accuracy
<img width="804" height="458" alt="image" src="https://github.com/user-attachments/assets/b274019e-fc4b-4463-90e8-272cd0474896" />

<img width="990" height="266" alt="image" src="https://github.com/user-attachments/assets/9161d4cc-d55b-460d-b295-b25b8ab307da" />

