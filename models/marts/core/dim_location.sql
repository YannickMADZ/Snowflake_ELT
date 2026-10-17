{#
  DIMENSION — dim_location
  Grain : une zone TLC (265 zones).
  Dimension « à rôles multiples » : fct_trips la référence deux fois, comme
  zone de prise en charge et comme zone de dépose. Une seule table évite deux
  copies identiques qui pourraient diverger.
#}
select
    location_id,
    borough,
    zone,
    service_zone,
    location_id in ({{ var('unknown_zone_ids') | join(', ') }}) as is_unknown_zone,
    borough = 'Manhattan'                                       as is_manhattan,
    service_zone in ('Airports', 'EWR')                         as is_airport
from {{ ref('taxi_zone_lookup') }}
