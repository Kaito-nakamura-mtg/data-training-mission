select
    users.prefecture
    , count(distinct users.user_id) as user_count
    /* 売上が存在しない場合の補完値として0を指定 */
    , coalesce(sum(sales.amount), 0) as total_amount
from
    `training_dataset.users` as users
    left join
        `training_dataset.sales` as sales
        on users.user_id = sales.user_id
group by
    users.prefecture
order by
    total_amount desc
;
