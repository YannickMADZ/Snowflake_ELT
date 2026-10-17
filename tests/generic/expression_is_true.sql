{#
  Test générique : renvoie les lignes qui VIOLENT une règle métier exprimée en
  SQL. 0 ligne = test réussi.
  Une expression évaluée à NULL n'est pas comptée comme violation (une valeur
  manquante n'est pas une valeur fausse ; les NULL sont testés à part avec
  not_null quand ils sont interdits).

  Pourquoi un test générique plutôt que dix tests singuliers : la même forme
  (« aucune ligne ne doit contredire X ») protège des règles différentes ;
  chaque usage dans les .yml porte son propre nom, sa sévérité et sa
  description, et la règle reste lisible à côté du modèle qu'elle protège.
#}
{% test expression_is_true(model, expression) %}
select *
from {{ model }}
where not ({{ expression }})
{% endtest %}
