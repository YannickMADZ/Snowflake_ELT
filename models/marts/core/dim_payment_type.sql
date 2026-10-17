{#
  DIMENSION — dim_payment_type
  Grain : un mode de paiement TLC.
  Porte les attributs qui conditionnent l'analyse des revenus : le pourboire
  n'est saisi qu'en carte, et les codes 3 à 6 ne sont pas des recettes.
#}
select
    payment_type_id,
    payment_type_name,
    is_tip_captured,
    is_revenue_payment
from {{ ref('payment_types') }}
