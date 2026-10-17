{#
  AGRÉGAT — agg_trips_hourly
  Grain : une heure calendaire précise (date x heure de prise en charge).
  ~744 lignes pour un mois, contre ~3 M dans le fait.

  Pourquoi un agrégat en plus du fait : les questions « Activité » et
  « Revenus par période » sont les plus fréquentes et alimentent typiquement
  un tableau de bord. Les pré-calculer évite de rescanner 3 M de lignes (et
  de consommer des crédits) à chaque rafraîchissement. Il est construit
  DEPUIS fct_trips : les définitions des mesures restent celles du fait.

  Les mesures de revenu ne portent que sur les trajets is_revenue_analyzable
  (pas de contre-passations, de litiges ni de courses sans frais).
#}
select
    f.date_key,
    f.hour_key,
    d.calendar_date,
    d.day_name,
    d.is_weekend,
    t.day_period,

    count(*)                                                        as trip_count,
    sum(f.passenger_count)                                          as passenger_count,
    round(avg(case when f.is_distance_analyzable then f.trip_distance_mi end), 3)
                                                                    as avg_distance_mi,
    round(avg(f.duration_min), 3)                                   as avg_duration_min,

    count_if(f.is_revenue_analyzable)                               as revenue_trip_count,
    sum(case when f.is_revenue_analyzable then f.total_amount end)  as revenue_total,
    sum(case when f.is_revenue_analyzable then f.fare_amount end)   as fare_total,
    sum(case when f.is_revenue_analyzable and f.is_tip_captured then f.tip_amount end)
                                                                    as tip_total_card,
    round(avg(case when f.is_revenue_analyzable then f.total_amount end), 2)
                                                                    as avg_total_per_trip,
    round(avg(f.tip_pct_of_fare), 2)                                as avg_tip_pct_card

from {{ ref('fct_trips') }} f
join {{ ref('dim_date') }} d on f.date_key = d.date_key
join {{ ref('dim_time_of_day') }} t on f.hour_key = t.hour_key
group by 1, 2, 3, 4, 5, 6
