#!/bin/bash
###############################################################################
# SQL実践テスト（第2弾）環境構築スクリプト（講師 / Claude Code 実行用）
#
# 対象書籍: 『達人に学ぶSQL徹底指南書 第2版』
#           CASE式 / ウィンドウ関数（行間比較含む）/ 自己結合 / 3値論理とNULL /
#           EXISTS述語 / HAVING句 / 外部結合 / 集合演算 / パフォーマンス /
#           GROUP BY と PARTITION BY / 神のいない論理 / 再帰集合 /
#           NULL撲滅委員会 / 存在の階層
#
# 実施内容:
#   1. BigQueryに以下3テーブルを作成
#      - employees     : 従業員マスタ（自己結合・再帰集合・存在の階層の題材）
#      - categories    : 商品カテゴリマスタ（外部結合の題材）
#      - sales_history : 売上履歴（ウィンドウ関数・3値論理・NULL・集合演算の題材）
#   2. テスト問題を解くためのダミーデータを投入
#      意図的に以下のような「少し汚いデータ」を含めています。
#        - amount が NULL の行（返品等で金額未確定の取引）
#        - employee_id が NULL の行（オンライン販売など担当者不明の取引）
#        - customer_id が NULL の行（匿名購入。NOT IN の NULL トラップ検証用）
#        - 一度も売上のないカテゴリ（C05: 玩具。外部結合の検証用）
#
# 前提:
#   - gcloud / bq CLI が認証済みであること（gcloud auth login 済み）
#   - 実行前に下記「要変更」の変数を書き換えること
###############################################################################
set -euo pipefail

# ============ 要変更パラメータ ============
PROJECT_ID="your-gcp-project-id"       # 例: p158-mtg-test
BQ_DATASET="advanced_sql_test"
BQ_LOCATION="asia-northeast1"
# ==========================================

echo ">>> [1/4] データセットを作成します: ${BQ_DATASET}"
bq mk --dataset \
  --location="${BQ_LOCATION}" \
  --description "SQL実践テスト（達人に学ぶSQL徹底指南書 第2版 対応）用データセット" \
  "${PROJECT_ID}:${BQ_DATASET}" || echo "データセットは既に存在する可能性があります。継続します。"

echo ">>> [2/4] テーブルを作成します"

bq mk --table \
  "${PROJECT_ID}:${BQ_DATASET}.employees" \
  employee_id:INT64,name:STRING,manager_id:INT64,department:STRING,hire_date:DATE,salary:INT64 \
  || echo "employees テーブルは既に存在する可能性があります。継続します。"

bq mk --table \
  "${PROJECT_ID}:${BQ_DATASET}.categories" \
  category_id:STRING,category_name:STRING \
  || echo "categories テーブルは既に存在する可能性があります。継続します。"

bq mk --table \
  "${PROJECT_ID}:${BQ_DATASET}.sales_history" \
  sale_id:STRING,sale_date:DATE,store_id:STRING,employee_id:INT64,customer_id:STRING,category_id:STRING,amount:INT64 \
  || echo "sales_history テーブルは既に存在する可能性があります。継続します。"

echo ">>> [3/4] ダミーデータを投入します"

# --- employees（組織階層：CEO(1001) → 部長(1002/1003) → 担当者 → さらにその部下、最大4階層） ---
bq query --use_legacy_sql=false << EOF
INSERT INTO \`${PROJECT_ID}.${BQ_DATASET}.employees\`
  (employee_id, name, manager_id, department, hire_date, salary)
VALUES
  (1001, 'CEO 山田', NULL, '経営', DATE '2015-04-01', 12000000),
  (1002, '佐藤',     1001, '営業', DATE '2016-04-01', 8000000),
  (1003, '鈴木',     1001, '開発', DATE '2016-04-01', 8000000),
  (1004, '田中',     1002, '営業', DATE '2018-04-01', 5000000),
  (1005, '高橋',     1002, '営業', DATE '2019-04-01', 4800000),
  (1006, '伊藤',     1004, '営業', DATE '2021-04-01', 4000000),
  (1007, '渡辺',     1003, '開発', DATE '2018-04-01', 5500000),
  (1008, '中村',     1003, '開発', DATE '2020-04-01', 5000000),
  (1009, '小林',     1007, '開発', DATE '2022-04-01', 4200000),
  (1010, '加藤',     1005, '営業', DATE '2023-04-01', 3900000);
EOF

# --- categories（C05は意図的に売上ゼロ。外部結合で発見させる） ---
bq query --use_legacy_sql=false << EOF
INSERT INTO \`${PROJECT_ID}.${BQ_DATASET}.categories\`
  (category_id, category_name)
VALUES
  ('C01', '家電'),
  ('C02', '食品'),
  ('C03', '衣料'),
  ('C04', '書籍'),
  ('C05', '玩具');
EOF

# --- sales_history ---
# 注1: SALE009, SALE017 は amount が NULL（返品等で金額未確定）
# 注2: SALE011, SALE017 は employee_id が NULL（オンライン販売で担当者不明）
# 注3: SALE025 は customer_id が NULL（匿名購入。NOT IN の NULL トラップ検証用）
# 注4: カテゴリ C05（玩具）は一度も登場しない（外部結合で気づかせる）
bq query --use_legacy_sql=false << EOF
INSERT INTO \`${PROJECT_ID}.${BQ_DATASET}.sales_history\`
  (sale_id, sale_date, store_id, employee_id, customer_id, category_id, amount)
VALUES
  ('SALE001', DATE '2024-01-05', 'S01', 1004, 'K001', 'C01', 50000),
  ('SALE002', DATE '2024-01-12', 'S01', 1004, 'K002', 'C02', 8000),
  ('SALE003', DATE '2024-01-20', 'S01', 1005, 'K003', 'C01', 60000),
  ('SALE004', DATE '2024-01-25', 'S02', 1007, 'K004', 'C03', 15000),
  ('SALE005', DATE '2024-01-28', 'S02', 1008, 'K005', 'C04', 3000),
  ('SALE006', DATE '2024-02-03', 'S01', 1004, 'K001', 'C01', 45000),
  ('SALE007', DATE '2024-02-10', 'S01', 1004, 'K006', 'C02', 9000),
  ('SALE008', DATE '2024-02-15', 'S01', 1005, 'K003', 'C02', 7000),
  ('SALE009', DATE '2024-02-18', 'S02', 1007, 'K004', 'C03', NULL),
  ('SALE010', DATE '2024-02-22', 'S02', 1008, 'K005', 'C04', 3500),
  ('SALE011', DATE '2024-02-25', 'S01', NULL, 'K007', 'C01', 20000),
  ('SALE012', DATE '2024-03-02', 'S01', 1004, 'K001', 'C01', 55000),
  ('SALE013', DATE '2024-03-08', 'S01', 1006, 'K002', 'C02', 8500),
  ('SALE014', DATE '2024-03-14', 'S01', 1005, 'K003', 'C03', 40000),
  ('SALE015', DATE '2024-03-19', 'S02', 1007, 'K004', 'C03', 16000),
  ('SALE016', DATE '2024-03-21', 'S02', 1009, 'K008', 'C04', 4000),
  ('SALE017', DATE '2024-03-27', 'S02', NULL, 'K007', 'C02', NULL),
  ('SALE018', DATE '2024-04-02', 'S01', 1004, 'K001', 'C01', 60000),
  ('SALE019', DATE '2024-04-06', 'S01', 1006, 'K002', 'C02', 9500),
  ('SALE020', DATE '2024-04-11', 'S01', 1005, 'K003', 'C04', 45000),
  ('SALE021', DATE '2024-04-15', 'S02', 1007, 'K004', 'C03', 17000),
  ('SALE022', DATE '2024-04-18', 'S02', 1010, 'K009', 'C01', 30000),
  ('SALE023', DATE '2024-04-22', 'S02', 1008, 'K011', 'C04', 3200),
  ('SALE024', DATE '2024-04-25', 'S01', 1004, 'K010', 'C02', 12000),
  ('SALE025', DATE '2024-04-28', 'S02', 1010, NULL,   'C03', 20000);
EOF

echo ">>> [4/4] 完了。投入データ件数を確認します"
bq query --use_legacy_sql=false \
  "SELECT
     (SELECT COUNT(*) FROM \`${PROJECT_ID}.${BQ_DATASET}.employees\`) AS employees_count,
     (SELECT COUNT(*) FROM \`${PROJECT_ID}.${BQ_DATASET}.categories\`) AS categories_count,
     (SELECT COUNT(*) FROM \`${PROJECT_ID}.${BQ_DATASET}.sales_history\`) AS sales_history_count"

echo ">>> 全セットアップ完了。データセット: ${PROJECT_ID}:${BQ_DATASET} (employees, categories, sales_history)"
