{#
  AGRÉGAT — agg_zone_pairs
  Grain : un couple (zone de prise en charge, zone de dépose).

  Répond à « quels trajets / zones concentrent le plus d'activité ? » :
  le classement des origines-destinations demande un GROUP BY sur deux
  colonnes de 3 M de lignes ; pré-calculé, il se lit instantanément.
  Exclut les zones inconnues (264/265), inexploitables géographiquement.
#}
select
    f.pickup_location_id,
    f.dropoff_location_id,
    pu.borough                                                       as pickup_borough,
    pu.zone                                                          as pickup_zone,
    dz.borough                                                       as dropoff_borough,
    dz.zone                                                          as dropoff_zone,

    count(*)                                                         as trip_count,
    round(avg(case when f.is_distance_analyzable then f.trip_distance_mi end), 3)
                                                                     as avg_distance_mi,
    round(avg(f.duration_min), 3)                                    as avg_duration_min,
    round(median(f.duration_min), 3)                                 as median_duration_min,
    sum(case when f.is_revenue_analyzable then f.total_amount end)   as revenue_total,
    round(avg(case when f.is_revenue_analyzable then f.total_amount end), 2)
                                                                     as avg_total_per_trip

from {{ ref('fct_trips') }} f
join {{ ref('dim_location') }} pu on f.pickup_location_id = pu.location_id
join {{ ref('dim_location') }} dz on f.dropoff_location_id = dz.location_id
where f.is_location_analyzable
group by 1, 2, 3, 4, 5, 6
