{#
  ANALYSE — Relation entre distance, durée et montant total.
  Question : « Comment la durée et le prix évoluent-ils avec la distance ? »

  Non matérialisée : c'est une question exploratoire ponctuelle, pas une
  table dont les analystes ont besoin en permanence. dbt la compile (ref()
  résolus) dans target/compiled/ ; scripts/collect_evidence.py l'exécute et
  écrit le résultat dans docs/evidence/03_analyses.md.

  Périmètre : trajets à distance non nulle et recette réelle (sinon les
  distances GPS nulles et les remboursements écrasent les moyennes).
#}
with base as (
    select distance_band, trip_distance_mi, duration_min, speed_mph, total_amount
    from {{ ref('fct_trips') }}
    where is_distance_analyzable and is_revenue_analyzable
)

select
    distance_band,
    count(*)                                           as trips,
    round(100 * ratio_to_report(count(*)) over (), 2)  as pct_trips,
    round(avg(trip_distance_mi), 2)                    as avg_distance_mi,
    round(median(duration_min), 1)                     as median_duration_min,
    round(avg(speed_mph), 1)                           as avg_speed_mph,
    round(median(total_amount), 2)                     as median_total_usd,
    round(median(total_amount / nullif(trip_distance_mi, 0)), 2) as median_usd_per_mile
from base
group by distance_band

union all

-- Ligne de synthèse : corrélations de Pearson sur l'ensemble du périmètre.
select
    '99. corrélations (r)',
    count(*), null,
    round(corr(trip_distance_mi, duration_min), 3),    -- r distance / durée
    round(corr(duration_min, total_amount), 3),        -- r durée / montant
    null,
    round(corr(trip_distance_mi, total_amount), 3),    -- r distance / montant
    null
from base

order by 1
