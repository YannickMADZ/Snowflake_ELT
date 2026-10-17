{#
  Range une valeur numérique dans des tranches lisibles par un analyste.

  PROBLÈME RÉSOLU : les tranches de distance et de durée (et toute autre future
  tranche) s'écrivent sinon sous forme de longs CASE WHEN copiés-collés, dont
  les bornes et les libellés divergent vite. Ici, les bornes sont une liste
  dans dbt_project.yml (vars) et le CASE est GÉNÉRÉ : changer une borne ne
  touche qu'une ligne de configuration.

  Exemple : bucketize('trip_distance_mi', [1, 2, 5], 'mi') produit
    case
      when trip_distance_mi is null then null
      when trip_distance_mi < 1 then '01. < 1 mi'
      when trip_distance_mi < 2 then '02. 1-2 mi'
      when trip_distance_mi < 5 then '03. 2-5 mi'
      else '04. >= 5 mi'
    end
  Le préfixe numérique garde l'ordre naturel quand on trie sur le libellé.
#}
{% macro bucketize(column, bounds, unit) -%}
    case
        when {{ column }} is null then null
    {%- for b in bounds %}
        {%- set label_num = '%02d' | format(loop.index) %}
        {%- if loop.first %}
        when {{ column }} < {{ b }} then '{{ label_num }}. < {{ b }} {{ unit }}'
        {%- else %}
        when {{ column }} < {{ b }} then '{{ label_num }}. {{ bounds[loop.index0 - 1] }}-{{ b }} {{ unit }}'
        {%- endif %}
    {%- endfor %}
        else '{{ '%02d' | format(bounds | length + 1) }}. >= {{ bounds[-1] }} {{ unit }}'
    end
{%- endmacro %}
