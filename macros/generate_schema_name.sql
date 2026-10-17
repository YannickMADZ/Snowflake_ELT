{#
  Surcharge de la macro native de dbt.

  PROBLÈME RÉSOLU : par défaut, dbt CONCATÈNE le schema du profil et le schema
  personnalisé : un modèle avec +schema: gold atterrirait dans SILVER_GOLD.
  Notre architecture Medallion impose des schemas EXACTS (BRONZE / SILVER /
  GOLD), déjà créés par sql/snowflake/02_database_schemas.sql.

  Règle : si un modèle déclare un schema, on l'utilise tel quel ; sinon on
  prend celui du profil (SILVER).
#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema | trim | upper }}
    {%- else -%}
        {{ custom_schema_name | trim | upper }}
    {%- endif -%}
{%- endmacro %}
