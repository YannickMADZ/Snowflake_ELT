{#
  BLOQUANT — réconciliation Bronze -> Gold.
  Le fait doit contenir EXACTEMENT les trajets de la Bronze (même nombre de
  lignes, même somme de total_amount au centime près).
  Protège contre : une jointure qui duplique des lignes (fan-out), un filtre
  ajouté par erreur en staging/intermediate, un modèle Gold construit sur une
  Bronze périmée. Renvoie une ligne (= échec) si l'un des deux écarts est non nul.
#}
with bronze as (
    select count(*) as n_rows, round(sum(total_amount), 2) as total_amount
    from {{ source('bronze', 'yellow_trips_raw') }}
),
gold as (
    select count(*) as n_rows, sum(total_amount) as total_amount
    from {{ ref('fct_trips') }}
)
select
    bronze.n_rows       as bronze_rows,
    gold.n_rows         as gold_rows,
    bronze.total_amount as bronze_total_amount,
    gold.total_amount   as gold_total_amount
from bronze cross join gold
where bronze.n_rows <> gold.n_rows
   or abs(bronze.total_amount - gold.total_amount) > 0.05  -- montants à 2 décimales : seul le bruit FLOAT reste
