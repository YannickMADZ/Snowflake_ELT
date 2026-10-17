{#
  INTERMEDIATE — int_trips_enriched
  Grain : un trajet (même nombre de lignes que stg_yellow_trips).

  Pourquoi un modèle à part plutôt que dans le staging ou dans le fait :
    - le staging ne fait que typer/renommer ; ici on applique des RÈGLES
      MÉTIER (correction de `extra`, éligibilité aux analyses, tranches) qui
      doivent être décidées et testées une seule fois ;
    - trois modèles Gold (fct_trips et deux agrégats via le fait) en dépendent :
      les recalculer dans chacun dupliquerait la logique ;
    - matérialisé en TABLE : les règles coûtent un scan complet, payé une
      fois au lieu d'à chaque lecture.
#}
with trips as (

    select * from {{ ref('stg_yellow_trips') }}

),

payment as (

    select payment_type_id, is_tip_captured, is_revenue_payment
    from {{ ref('payment_types') }}

),

enriched as (

    select
        t.*,

        -- ---------------------------------------------------------------
        -- Règle 1 — correction de `extra` (anomalie « piège » du Projet 1)
        -- Pour ces lignes, `extra` contient déjà congestion + aéroport, qui
        -- sont AUSSI dans leurs propres colonnes : le total est juste, mais
        -- additionner les composantes compterait deux fois les surcharges.
        -- extra_net retire ce double comptage ; total_amount n'est pas touché.
        -- ---------------------------------------------------------------
        case
            when t.flag_extra_includes_surcharges
                then t.extra - coalesce(t.congestion_surcharge, 0) - coalesce(t.airport_fee, 0)
            else t.extra
        end                                                   as extra_net,

        -- ---------------------------------------------------------------
        -- Règle 2 — éligibilité aux analyses (chaque indicateur dit dans
        -- quelles analyses la ligne est fiable, au lieu de la supprimer)
        -- ---------------------------------------------------------------
        not t.flag_negative_amount
            and coalesce(p.is_revenue_payment, false)         as is_revenue_analyzable,
        not t.flag_zero_distance                              as is_distance_analyzable,
        not t.flag_unknown_zone                               as is_location_analyzable,
        coalesce(p.is_tip_captured, false)                    as is_tip_captured,
        (t.flag_missing_metadata or t.flag_extra_includes_surcharges
            or t.flag_total_mismatch_other or t.flag_negative_amount
            or t.flag_zero_distance or t.flag_zero_passenger
            or t.flag_unknown_zone)                           as has_any_quality_flag,

        -- ---------------------------------------------------------------
        -- Règle 3 — pourboire en % du tarif : seulement là où il est saisi
        -- (carte bancaire). En espèces le pourboire n'est pas enregistré :
        -- un 0 y signifierait « inconnu », pas « pas de pourboire ».
        -- ---------------------------------------------------------------
        case
            when coalesce(p.is_tip_captured, false) and t.fare_amount > 0
                then round(100 * t.tip_amount / t.fare_amount, 2)
        end                                                   as tip_pct_of_fare,

        -- ---------------------------------------------------------------
        -- Règle 4 — tranches d'analyse (macro bucketize, bornes en vars)
        -- ---------------------------------------------------------------
        {{ bucketize('t.trip_distance_mi', var('distance_bands_mi'), 'mi') }}  as distance_band,
        {{ bucketize('t.duration_min', var('duration_bands_min'), 'min') }}    as duration_band

    from trips t
    left join payment p
        on t.payment_type_id = p.payment_type_id

)

select * from enriched
