{#
  STAGING — stg_yellow_trips
  Grain : un trajet (une ligne de la Bronze), aucune ligne ajoutée ni retirée.

  Rôle : rendre la Bronze utilisable SANS appliquer de règle métier.
    - renommage explicite (snake_case, suffixes _id / _at / _mi / _min) ;
    - typage final : montants FLOAT -> NUMBER(12,2) (macro to_money) ;
    - normalisation : store_and_fwd_flag 'Y'/'N' -> booléen ;
    - colonnes dérivées de calendrier (date, heure, clé de date) ;
    - RECALCUL indépendant de la durée et de l'écart de total, pour vérifier
      (tests) que les colonnes produites par le Projet 1 ont survécu intactes
      à l'ingestion.
  Pas de filtre : le nettoyage a été fait par le Projet 1 ; supprimer des
  lignes ici casserait la réconciliation Bronze = Gold.
#}
with source as (

    select * from {{ source('bronze', 'yellow_trips_raw') }}

),

renamed as (

    select
        -- identifiant -------------------------------------------------------
        row_id                                         as trip_id,

        -- dimensions (codes TLC) --------------------------------------------
        cast(vendorid as integer)                      as vendor_id,
        cast(ratecodeid as integer)                    as rate_code_id,
        cast(payment_type as integer)                  as payment_type_id,
        cast(pulocationid as integer)                  as pickup_location_id,
        cast(dolocationid as integer)                  as dropoff_location_id,
        case upper(trim(store_and_fwd_flag))
            when 'Y' then true
            when 'N' then false
        end                                            as is_store_and_forward,

        -- temps ---------------------------------------------------------------
        tpep_pickup_datetime                           as pickup_at,
        tpep_dropoff_datetime                          as dropoff_at,
        cast(tpep_pickup_datetime as date)             as pickup_date,
        cast(to_char(tpep_pickup_datetime, 'YYYYMMDD') as integer) as pickup_date_key,
        hour(tpep_pickup_datetime)                     as pickup_hour,

        -- mesures de trajet ---------------------------------------------------
        cast(passenger_count as integer)               as passenger_count,
        cast(round(trip_distance, 2) as number(10, 2)) as trip_distance_mi,
        cast(round(duration_min, 3) as number(10, 3))  as duration_min,
        cast(round(speed_mph, 3) as number(10, 3))     as speed_mph,
        cast(round(datediff('second', tpep_pickup_datetime, tpep_dropoff_datetime) / 60, 3)
             as number(10, 3))                         as duration_min_recomputed,

        -- montants (8 composantes + total), typés en décimal exact ----------
        {%- for col in fare_components() %}
        {{ to_money(col) }}{{ ' ' * (25 - col | length) }}as {{ col }},
        {%- endfor %}
        {{ to_money('total_amount') }}                 as total_amount,
        cast(round(total_gap, 2) as number(12, 2))     as total_gap_p1,
        cast(round(total_amount - {{ sum_fare_components() }}, 2) as number(12, 2))
                                                       as total_gap_recomputed,

        -- indicateurs d'anomalies du Projet 1 (conservés tels quels) ---------
        flag_missing_metadata,
        flag_extra_includes_surcharges,
        flag_total_mismatch_other,
        flag_negative_amount,
        flag_zero_distance,
        flag_zero_passenger,
        flag_unknown_zone,

        -- traçabilité --------------------------------------------------------
        _source_file,
        _source_row_number,
        _loaded_at

    from source

)

select * from renamed
