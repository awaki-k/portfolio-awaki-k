作成中（下書き/メモ）

- 進捗
  - 8bit学習で実装したが、Genus結果がWNS=0psから好転せず、Innovusうまく収束してくれなかった。

  ```
    No-driven Nets: 4011            （機能的に危険。ネットリスト/接続/合成の問題の典型）
    Effective Utilization: 0.95326  （95%超で物理的にかなり厳しい）
    Unplaced IO Pin ... 22          （IO計画未完）
    HFO (>200) Nets: 24             （scan_en/reset/test_mode等が高fanoutで要対策）
  ```

    - 抵抗（失敗）
      - OPUの並列度を64to32に変更→requantの64bit乗算が厳しすぎた。
      - requantは32並列せずに、ベクトルを分割してパイプラインを作成→rquant処理はタイミング収束したが、メモリバンクアクセスがボトルネックに。
      - スタセルにSRAMメモリが無いので実質レジスタのみでの補間で現状のパラメータ数は無理があることに気づく。
      - やむなく4bit QATを検討。
  - 4bitで再度学習/28x28 to 14x14に画像リサイズ→なるべくハードコーディングしてタイミングエラーを最小に抑えたい。
    - 仕様設計・見積もりの大切さを身に染みて感じた。
    - プロセスノード依存になると思うので、ここら辺の感覚は経験がないと身につかないものなのかも。
  - 


- githubの勉強
  - pushのやり方（コピペでOK）
    ```
    # 1. 現在の状態を一旦退避（念のため）
    git status
    
    # 2. main を完全初期化
    git checkout --orphan temp-clean
    
    # 3. 追跡したいものだけ add（.gitignore を先に）
    git add .gitignore
    git add 04_asic_opu_based_mlp_mnist
    
    # 4. 初回コミットとして作り直す
    git commit -m "Add ASIC OPU-based MLP MNIST project (clean)"
    
    # 5. main を置き換え
    git branch -D main
    git branch -m main
    
    # 6. 強制 push（GitHub 側は安全）
    git push -f origin main
    ```
