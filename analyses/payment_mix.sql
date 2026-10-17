{#
  ANALYSE — Modes de paiement : part de chacun et montants moyens.
  Question : « Quels modes de paiement, quelle part, les montants diffèrent-ils ? »
  Le pourboire moyen n'est significatif qu'en carte (is_tip_captured) : en
  espèces il n'est pas saisi, la moyenne serait 0 par construction.
#}
select
    p.payment_type_id,
    p.payment_type_name,
    count(*)                                                    as trips,
    round(100 * ratio_to_report(count(*)) over (), 2)           as pct_trips,
    round(avg(f.total_amount), 2)                               as avg_total_usd,
    round(avg(f.fare_amount), 2)                                as avg_fare_usd,
    round(avg(case when p.is_tip_captured then f.tip_amount end), 2)      as avg_tip_usd_if_captured,
    round(avg(f.tip_pct_of_fare), 2)                            as avg_tip_pct_card,
    count_if(f.flag_negative_amount)                            as negative_amount_trips
from {{ ref('fct_trips') }} f
join {{ ref('dim_payment_type') }} p on f.payment_type_id = p.payment_type_id
group by 1, 2
order by trips desc
