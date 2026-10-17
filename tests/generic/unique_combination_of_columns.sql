{#
  Test générique : vérifie le GRAIN d'une table dont la clé est composée
  (ex. agrégat date x heure). Renvoie chaque combinaison présente plus d'une fois.
#}
{% test unique_combination_of_columns(model, combination_of_columns) %}
select {{ combination_of_columns | join(', ') }}, count(*) as n_rows
from {{ model }}
group by {{ combination_of_columns | join(', ') }}
having count(*) > 1
{% endtest %}
