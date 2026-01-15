# HLS_software

## 概要
本プロジェクトは、高位合成（HLS: High-Level Synthesis）によるハードウェア設計を支援するためのアルゴリズム開発および性能評価を目的としています。Google Colab上のNotebook（`HLS_software.ipynb`）を活用し、C/C++等で記述されたアルゴリズムのハードウェア実装に向けた検証や最適化を行います。

---

## Google Colab URL（閲覧のみ）

[https://colab.research.google.com/drive/19VpM77iqPbaX-y9EGcGR5AVowtxgRIfY?usp=sharing](https://colab.research.google.com/drive/19VpM77iqPbaX-y9EGcGR5AVowtxgRIfY?usp=sharing)

---

## 目的

- HLSツール向けソフトウェアアルゴリズムの設計・最適化
- シミュレーションによる機能・性能評価
- PythonおよびGoogle Colabによる開発・検証効率の向上
- 実装結果の可視化とドキュメンテーション

---

## 使用方法

### 環境準備

- Google アカウント
- Google Colab（追加インストール不要、Webブラウザで実行可能）
- HLSツール（例：Xilinx Vivado HLS, Cadence Stratus HLS 等。必要に応じてローカルで）

### Notebookの実行（Google Colab）

1. 上記URLから `HLS_software.ipynb` をGoogle Colabで開く
2. セルを上から順に実行
3. 必要に応じて、ご自身のGoogle Driveにコピーして編集・実行

### ソースコードのビルド・検証

- `src/` 配下のC/C++ソースをローカルまたはクラウド環境でHLSツール等により合成・シミュレーション
- 結果は `results/` 配下に格納

### ドキュメント参照

- 仕様や考察、結果分析は `doc/` に格納

---

## 要件

- Google Colab（Python 3.7 以上の環境が標準搭載）
- 必要に応じてHLSツール
- C/C++コンパイラ（gcc/g++ など、必要な場合）

---

## 推奨される使い方

- Pythonによる前処理・後処理、データセット生成、結果解析を行い、HLS設計の反復的な最適化に役立ててください。
- Notebook内でアルゴリズムの動作検証 → C/C++へ反映 → HLSで合成・検証、の流れで設計を進めます。

---

## 作者

- m5291005 Kyoji Awaki

---

## 補足・今後の展望

- より高度な最適化（量子化・パイプライン化・並列化等）や、最新HLS技術への適用検証
- 実際のFPGA/ASIC実装に向けた物理合成・ベンチマーク評価
- 機械学習/画像処理等の応用アルゴリズム拡充

---

## 参考文献・リンク

- [高位合成（HLS）とは](https://www.xilinx.com/products/design-tools/vivado/integration/esl-design.html)
- [Google Colab公式ドキュメント](https://colab.research.google.com/notebooks/intro.ipynb)


