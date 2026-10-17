{#
  Liste unique des 8 composantes monétaires d'une course TLC, et deux macros
  qui en dérivent.

  PROBLÈME RÉSOLU : ces 8 colonnes apparaissent dans le typage (staging), dans
  le recalcul de l'écart de total (staging) et dans les mesures du fait. Écrites
  en dur, il suffit d'en oublier une à un endroit (airport_fee a été ajoutée par
  la TLC en 2023) pour que le contrôle « total = somme des composantes » soit
  faux sans que rien ne casse. Ici, la liste est définie UNE fois.
#}
{% macro fare_components() -%}
    {{ return(['fare_amount', 'extra', 'mta_tax', 'tip_amount', 'tolls_amount',
               'improvement_surcharge', 'congestion_surcharge', 'airport_fee']) }}
{%- endmacro %}

{# Convertit un montant FLOAT (Bronze) en décimal monétaire exact à 2 chiffres. #}
{% macro to_money(column) -%}
    cast(round({{ column }}, 2) as number(12, 2))
{%- endmacro %}

{#
  Somme des composantes d'un trajet. Les composantes NULL (lignes à
  métadonnées manquantes) comptent pour 0 dans la SOMME, sans être imputées
  dans les colonnes elles-mêmes.
  prefix : alias de table éventuel ("t." -> t.fare_amount + ...).
#}
{% macro sum_fare_components(prefix='') -%}
    (
    {%- for col in fare_components() %}
        coalesce({{ prefix }}{{ col }}, 0){{ ' +' if not loop.last }}
    {%- endfor %}
    )
{%- endmacro %}
