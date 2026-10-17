{#
  DIMENSION — dim_rate_code
  Grain : un code tarifaire TLC (dont 99 = inconnu).
  Permet d'isoler les forfaits aéroport (JFK, Newark), qui pèsent lourd dans
  les revenus.
#}
select
    rate_code_id,
    rate_code_name,
    rate_code_id in (2, 3) as is_airport_rate
from {{ ref('rate_codes') }}
