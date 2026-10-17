{#
  ANALYSE — Qualité : volume de chaque anomalie conservée après ingestion.
  Question : « Les données du Projet 1 sont-elles toujours cohérentes après
  ingestion ? ». À comparer ligne à ligne avec le rapport qualité du Projet 1
  (kept_despite_anomaly) : des nombres identiques prouvent que l'ingestion n'a
  rien perdu ni altéré.
#}
select 'flag_missing_metadata' as flag, count_if(flag_missing_metadata) as rows_flagged, round(100 * avg(flag_missing_metadata::int), 3) as pct from {{ ref('fct_trips') }}
union all select 'flag_extra_includes_surcharges', count_if(flag_extra_includes_surcharges), round(100 * avg(flag_extra_includes_surcharges::int), 3) from {{ ref('fct_trips') }}
union all select 'flag_total_mismatch_other', count_if(flag_total_mismatch_other), round(100 * avg(flag_total_mismatch_other::int), 3) from {{ ref('fct_trips') }}
union all select 'flag_negative_amount', count_if(flag_negative_amount), round(100 * avg(flag_negative_amount::int), 3) from {{ ref('fct_trips') }}
union all select 'flag_zero_distance', count_if(flag_zero_distance), round(100 * avg(flag_zero_distance::int), 3) from {{ ref('fct_trips') }}
union all select 'flag_zero_passenger', count_if(flag_zero_passenger), round(100 * avg(flag_zero_passenger::int), 3) from {{ ref('fct_trips') }}
union all select 'flag_unknown_zone', count_if(flag_unknown_zone), round(100 * avg(flag_unknown_zone::int), 3) from {{ ref('fct_trips') }}
union all select 'au moins un indicateur', count_if(has_any_quality_flag), round(100 * avg(has_any_quality_flag::int), 3) from {{ ref('fct_trips') }}
