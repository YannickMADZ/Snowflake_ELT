{#
  ANALYSE — Quelles périodes concentrent le plus de trajets ?
  Croise jour de la semaine et plage horaire depuis l'agrégat horaire (quelques
  centaines de lignes lues au lieu de 3 M : c'est l'intérêt de l'agrégat).
  avg_trips_per_hour normalise par le nombre d'heures observées, sinon un jour
  présent 5 fois dans le mois paraîtrait plus actif qu'un jour présent 4 fois.
#}
select
    a.day_name,
    a.day_period,
    sum(a.trip_count)                                     as trips,
    count(*)                                              as observed_hours,
    round(sum(a.trip_count) / count(*), 0)                as avg_trips_per_hour,
    round(sum(a.revenue_total) / nullif(sum(a.revenue_trip_count), 0), 2) as avg_revenue_per_trip
from {{ ref('agg_trips_hourly') }} a
group by 1, 2
order by avg_trips_per_hour desc
limit 15
