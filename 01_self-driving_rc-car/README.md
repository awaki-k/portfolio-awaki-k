# ラジコンカーの自動運転物体検出

## 概要 / Overview

本プロジェクトは、物流業界の人材不足問題を背景として、物体検出・自動運転技術を搭載したラジコンカーを開発したものです。  
Raspberry Piを搭載したラジコンカーが、コース上を自動走行し、「Uber Eats」ロゴを認識して自動停止するデモを実現しています。

---

## 動機・目的 / Motivation

- 急速に成長する物流業界では人材不足が深刻化しており、AI・自動化による業務効率化が求められている:contentReference[oaicite:0]{index=0}。
- 本プロジェクトは、自動運転技術の基礎を学び、将来的な産業応用を視野に入れた取り組みです。

---

## システム構成 / System Structure

- **ハードウェア:**  
  - ラジコンカー
  - Raspberry Pi
  - Webカメラ
  - PC
  - ルーター
- **操作:**  
  - 自動運転（コース走行）
  - 物体検出による停止制御

---

## 機能・仕様 / Features

- 学習させたコースをラジコンカーが自動で一周
- コース上の「Uber Eats」ロゴを検出したら車体が自動で停止

---

## 技術スタック / Tech Stack

- **分類モデル:** Python, TensorFlow, Numpy, Matplotlib（Google Colab環境）
- **物体検出モデル:** Python, PyTorch, YOLOv5, Matplotlib, Pandas（Google Colab環境）

---

## データセット / Dataset

- 分類モデル：  
  - train：Straight(2058枚), Right(10173枚), Left(1377枚)
  - val/test 各クラス有:
- 物体検出モデル：  
  - train：画像61枚・ラベル61枚

---

## モデル構成 / Model Architecture

### 分類モデル
- CNN構成（Conv2D, MaxPooling, Dense, Softmax）
- 入力：32×32画像  
- 出力：Straight/Right/Left の3クラス分類

### 物体検出モデル
- YOLOv5による転移学習

---

## 成果・性能 / Results

### 分類モデル
- Loss: 0.10 / Accuracy: 0.96
- テスト精度: Straight 86%、Right 97%、Left 50%
### 物体検出モデル
- Loss: 0.02 / Accuracy: 0.89
- stop_obj（停止対象物）認識精度: 0.92、その他: 0.58

---

## デモ / Demo

- 自動走行のデモ  
  ![自動走行デモ](./demo/auto.mp4)
- 車体停止のデモ  
  ![停止デモ](./demo/detect.mp4)

---

## 工夫・学び / Key Challenges & Learnings

- 教師画像の質・データ前処理がモデル性能に直結することを体感
- モデルの中間層追加による性能向上
- タイヤ摩擦向上のため物理対策（輪ゴム追加）
- YOLOv5転移学習の適用と、ラベル付けルールの明確化
- カメラ設置角度による誤検出防止

---

## ライセンス / License

MIT License などを必要に応じて明記

---

## 連絡先 / Contact

- 会津大学 学部3年 粟木恭司

