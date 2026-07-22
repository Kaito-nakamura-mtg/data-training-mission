select
    u.prefecture
    , count(distinct u.user_id) as user_count
    , coalesce(sum(s.amount), 0) as amount_sum
from
    p158-mtg-test.training_dataset.users as u
        left join p158-mtg-test.training_dataset.sales  as s
            on u.user_id = s.user_id
group by
    u.prefecture
order by
    amount_sum desc
;