{#
  Appelée en on-run-end (dbt_project.yml) : suspend le warehouse dès la fin
  d'un dbt run / build / test / seed / snapshot.

  PROBLÈME RÉSOLU : AUTO_SUSPEND = 60 fait payer jusqu'à 60 s de plus après
  chaque commande dbt. On ne peut pas écrire simplement « alter warehouse ...
  suspend » : Snowflake renvoie une ERREUR si le warehouse est déjà suspendu,
  ce qui ferait échouer dbt build. La macro génère donc un bloc Snowflake
  Scripting qui intercepte cette erreur précise.
  Le nom du warehouse vient du profil (target.warehouse) : rien en dur.
  Désactivable : dbt build --vars '{suspend_warehouse_on_run_end: false}'
#}
{% macro suspend_warehouse() %}
    {%- if var('suspend_warehouse_on_run_end', true) and target.type == 'snowflake' -%}
execute immediate $$
begin
    alter warehouse {{ target.warehouse | upper }} suspend;
    return 'Warehouse {{ target.warehouse | upper }} suspendu';
exception
    when other then
        return 'Warehouse {{ target.warehouse | upper }} déjà suspendu : rien à faire';
end;
$$
    {%- else -%}
select 'suspension automatique désactivée' as info
    {%- endif -%}
{% endmacro %}
