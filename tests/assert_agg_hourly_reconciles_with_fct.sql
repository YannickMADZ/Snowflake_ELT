{#
  BLOQUANT — l'agrégat horaire doit redonner les totaux du fait.
  Protège contre une jointure perdue avec dim_date / dim_time_of_day (INNER
  JOIN : un date_key absent de dim_date ferait disparaître des trajets en
  silence) et contre une divergence de définition de la métrique de revenu.
#}
with agg as (
    select sum(trip_count) as n_trips, sum(revenue_total) as revenue
    from {{ ref('agg_trips_hourly') }}
),
fct as (
    select count(*) as n_trips,
           sum(case when is_revenue_analyzable then total_amount end) as revenue
    from {{ ref('fct_trips') }}
)
select agg.n_trips as agg_trips, fct.n_trips as fct_trips, agg.revenue as agg_revenue, fct.revenue as fct_revenue
from agg cross join fct
where agg.n_trips <> fct.n_trips
   or abs(coalesce(agg.revenue, 0) - coalesce(fct.revenue, 0)) > 0.01
