{#
  AVERTISSEMENT — constat du Projet 1 à surveiller.
  Les 5 colonnes de métadonnées (passenger_count, ratecodeid,
  store_and_fwd_flag, congestion_surcharge, airport_fee) sont manquantes
  TOUJOURS ENSEMBLE, et seulement pour payment_type = 0. C'est ce constat qui
  justifie de ne PAS imputer ces valeurs. Une ligne où elles ne manquent que
  partiellement contredirait l'analyse : on la signale sans bloquer, car la
  donnée reste chargeable.
#}
{{ config(severity='warn') }}

select row_id, payment_type, passenger_count, ratecodeid, store_and_fwd_flag,
       congestion_surcharge, airport_fee
from {{ source('bronze', 'yellow_trips_raw') }}
where (
        (passenger_count is null)::int + (ratecodeid is null)::int + (store_and_fwd_flag is null)::int
      + (congestion_surcharge is null)::int + (airport_fee is null)::int
      ) not in (0, 5)
   or (passenger_count is null and payment_type <> 0)
