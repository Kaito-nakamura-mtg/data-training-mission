select
    u.prefecture as `都道府県`
    , coalesce(count(distinct s.user_id) , 0) as `ユーザー数`
    , coalesce(sum(s.amount) , 0) as `売上合計金額`
from
    p158-mtg-test.training_dataset.users as u
    left join p158-mtg-test.training_dataset.sales  as s
    on u.user_id = s.user_id
group by
    u.prefecture
order by
    sum(s.amount) desc
;