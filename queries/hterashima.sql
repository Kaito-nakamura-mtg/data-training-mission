with user_counts as (
    /* user_counts: 都道府県別の利用者数を集計するCTE。PK: user_id, 処理目的: 都道府県別のユーザー数を把握する */
    select
        u.prefecture
        , count(distinct u.user_id) as distinct_user_count
    from
        `p158-mtg-test.training_dataset.users` as u
    group by
        u.prefecture
),
sales_sums as (
    /* sales_sums: 都道府県別の売上合計を集計するCTE。PK: user_id, 処理目的: 都道府県別の売上総額を把握する */
    select
        u.prefecture
        , sum(s.amount) as total_sales_amount
    from
        `p158-mtg-test.training_dataset.users` as u
        left join `p158-mtg-test.training_dataset.sales` as s
        on u.user_id = s.user_id
    group by
        u.prefecture
)
select
    u.prefecture
    , ifnull(s.total_sales_amount, 0) as total_sales_amount
    , u.distinct_user_count
from
    user_counts as u
    left join sales_sums as s
    on u.prefecture = s.prefecture
order by
    s.total_sales_amount desc
;