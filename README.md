# data-training-mission

データ抽出・集計業務の実践研修用リポジトリです。

## ディレクトリ構成
tasks/    ... 課題文（各メンバーはここを読んで課題内容を把握する）
queries/  ... 提出用SQLファイル置き場（<自分の名前>.sql 等）
results/  ... 提出用CSV結果置き場（<自分の名前>.csv 等）

## 進め方

1. 本リポジトリを `git clone` する
2. `tasks/` 配下の課題ファイルを確認する
3. 自分の名前のブランチを作成する
4. BigQueryでSQLを実行し、`queries/` と `results/` に成果物を保存する
5. `git add` → `git commit` → `git push` し、Pull Requestを作成する
6. PRのDescriptionに「工夫した点」「悩んだ点」「検算内容」を記載する

詳細は研修マニュアル（training_manual.md）を参照してください。
