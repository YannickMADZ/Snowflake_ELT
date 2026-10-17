-- =============================================================================
-- 08 — (OPTIONNEL) RESOURCE MONITOR — nécessite le rôle ACCOUNTADMIN
-- =============================================================================
-- Plafond de dépense : notifie à 75 %, suspend le warehouse à 100 % du quota
-- mensuel (les requêtes en cours se terminent), le coupe net à 110 %.
-- Optionnel car il demande ACCOUNTADMIN, que l'on n'utilise pas pour le reste
-- du projet (principe du moindre privilège).
--   snow sql -f sql/snowflake/08_resource_monitor_optional.sql \
--     -D warehouse=NYC_TAXI_WH --role ACCOUNTADMIN
-- =============================================================================
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE RESOURCE MONITOR NYC_TAXI_RM
  WITH CREDIT_QUOTA = 5
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 75  PERCENT DO NOTIFY
    ON 100 PERCENT DO SUSPEND
    ON 110 PERCENT DO SUSPEND_IMMEDIATE;

ALTER WAREHOUSE <% warehouse %> SET RESOURCE_MONITOR = NYC_TAXI_RM;
