{#
  FAIT — fct_trips
  Grain : UN TRAJET de taxi jaune (une ligne = une course facturée).

  Pourquoi ce grain : c'est le niveau le plus fin disponible. Toutes les
  questions du besoin (comptages, moyennes, répartitions par heure, jour,
  zone, paiement) s'obtiennent en agrégeant ce fait ; un grain plus grossier
  (par jour, par zone) rendrait impossibles les analyses de distribution
  (trajets anormalement longs, durée en fonction de la distance).

  Clés étrangères : date_key, hour_key, pickup/dropoff_location_id,
  payment_type_id, vendor_id, rate_code_id.
  Mesures additives : montants, distance, durée, passagers.
  Mesures non additives : vitesse, pourboire en % (à moyenner, jamais sommer).
#}
select
    -- clé primaire
    trip_id,

    -- clés étrangères
    pickup_date_key               as date_key,
    pickup_hour                   as hour_key,
    pickup_location_id,
    dropoff_location_id,
    payment_type_id,
    vendor_id,
    rate_code_id,

    -- attributs dégénérés (propres au trajet, sans dimension)
    pickup_at,
    dropoff_at,
    is_store_and_forward,
    distance_band,
    duration_band,

    -- mesures
    passenger_count,
    trip_distance_mi,
    duration_min,
    speed_mph,
    fare_amount,
    extra,
    extra_net,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    congestion_surcharge,
    airport_fee,
    total_amount,
    tip_pct_of_fare,

    -- éligibilité aux analyses (règles métier de int_trips_enriched)
    is_revenue_analyzable,
    is_distance_analyzable,
    is_location_analyzable,
    is_tip_captured,
    has_any_quality_flag,

    -- indicateurs d'origine (Projet 1), pour l'audit
    flag_missing_metadata,
    flag_extra_includes_surcharges,
    flag_total_mismatch_other,
    flag_negative_amount,
    flag_zero_distance,
    flag_zero_passenger,
    flag_unknown_zone

from {{ ref('int_trips_enriched') }}
