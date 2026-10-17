{#
  DIMENSION — dim_time_of_day
  Grain : une heure de la journée (0 à 23).
  Séparée de dim_date pour éviter une dimension date x heure de 8 760 lignes
  par an : les questions « quelles heures ? » et « quels jours ? » se croisent
  dans le fait, qui porte les deux clés.
  Les plages horaires reprennent les pointes de trafic new-yorkaises.
#}
with hours as (

    select row_number() over (order by seq4()) - 1 as hour_of_day
    from table(generator(rowcount => 24))

)

select
    hour_of_day                                        as hour_key,
    lpad(to_varchar(hour_of_day), 2, '0') || ':00'                 as hour_label,
    case
        when hour_of_day between 0 and 5   then '1. Nuit (0h-6h)'
        when hour_of_day between 6 and 9   then '2. Pointe du matin (6h-10h)'
        when hour_of_day between 10 and 15 then '3. Journée (10h-16h)'
        when hour_of_day between 16 and 19 then '4. Pointe du soir (16h-20h)'
        else                                    '5. Soirée (20h-24h)'
    end                                                as day_period
from hours
