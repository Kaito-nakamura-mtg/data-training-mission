# 課題01: 都道府県別 ユーザー分析 & 売上集計

## 背景

あなたはデータ分析チームに配属された新人データエンジニアです。
マーケティングチームから、都道府県ごとのユーザー傾向と売上状況を知りたいという依頼が来ました。

対象データは BigQuery のデータセット `training_dataset` にある以下2テーブルです。

- `users`（ユーザーマスタ）
  - user_id: STRING
  - name: STRING
  - prefecture: STRING
  - signup_date: DATE
- `sales`（売上明細）
  - sale_id: STRING
  - user_id: STRING
  - product_name: STRING
  - amount: INT64
  - sale_date: DATE

## 要件

以下の条件を満たす集計結果を1本のSQLで作成し、CSVとして出力してください。

1. 都道府県（prefecture）ごとに、ユーザー数（重複なし）を集計すること
2. 都道府県（prefecture）ごとに、売上合計金額（amount の合計）を集計すること
3. 売上合計金額が高い順に並び替えること
4. ユーザーが1人もいない都道府県も、結果として除外しないこと（0件・0円で表示）

## 提出物

- `queries/<あなたの名前>.sql`（実行したSQL本体）
- `results/<あなたの名前>.csv`（実行結果のCSV）

## SQLコーディングルール

SQLを書く際は、[`docs/sql_coding_rules.md`](../docs/sql_coding_rules.md) のSQLコーディングルールを参照してください。🔴 Must（必須）のルールは必ず守り、🟡 Want（推奨）のルールもできる限り適用してください。

## 検算のヒント

- 全ユーザー数の合計と、都道府県別ユーザー数の合計が一致するか確認しましょう
- 全売上合計と、都道府県別売上合計の合計が一致するか確認しましょう
