{#
  DIMENSION — dim_date
  Grain : une date calendaire.
  Clé : date_key (entier AAAAMMJJ), stable et lisible, utilisée par fct_trips.

  La plage n'est PAS écrite en dur : elle couvre les années civiles complètes
  des données présentes (min/max des prises en charge ET des déposes). Charger
  un autre mois étendrait la dimension automatiquement. Les déposes sont
  incluses car un trajet du 31 janvier peut finir le 1er février.
#}
with bounds as (

    select
        date_trunc('year', min(pickup_date))                               as start_date,
        dateadd('year', 1, date_trunc('year', max(cast(dropoff_at as date)))) as end_date_excl
    from {{ ref('stg_yellow_trips') }}

),

numbered as (

    -- generator() produit N lignes ; row_number() donne une suite sans trou
    -- (seq4() peut en avoir). 3 660 jours = 10 ans, largement suffisant.
    select row_number() over (order by seq4()) - 1 as day_offset
    from table(generator(rowcount => 3660))

),

spine as (

    select dateadd('day', n.day_offset, b.start_date) as calendar_date
    from numbered n
    cross join bounds b
    where dateadd('day', n.day_offset, b.start_date) < b.end_date_excl

)

select
    cast(to_char(calendar_date, 'YYYYMMDD') as integer) as date_key,
    calendar_date,
    year(calendar_date)                                 as year,
    quarter(calendar_date)                              as quarter,
    month(calendar_date)                                as month,
    monthname(calendar_date)                            as month_name,
    day(calendar_date)                                  as day_of_month,
    dayofweekiso(calendar_date)                         as day_of_week_iso,   -- 1 = lundi
    dayname(calendar_date)                              as day_name,
    weekiso(calendar_date)                              as iso_week,
    dayofweekiso(calendar_date) in (6, 7)               as is_weekend
from spine
