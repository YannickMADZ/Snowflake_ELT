{#
  DIMENSION — dim_vendor
  Grain : un fournisseur de terminal TPEP.
  Utile malgré sa taille : les anomalies du Projet 1 sont propres à un vendor
  (passenger_count = 0 et `extra` incluant les surcharges chez le vendor 1).
#}
select
    vendor_id,
    vendor_name
from {{ ref('vendors') }}
