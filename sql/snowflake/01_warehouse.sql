-- =============================================================================
-- 01 — WAREHOUSE (ressource de calcul)
-- =============================================================================
-- Un warehouse Snowflake est un cluster de calcul facturé en crédits À LA
-- SECONDE (minimum 60 s à chaque reprise) UNIQUEMENT quand il est démarré.
-- Le stockage est facturé à part. Les choix ci-dessous limitent la dépense :
--
--   WAREHOUSE_SIZE = XSMALL     1 crédit/heure, la plus petite taille. ~3 M de
--                               lignes et quelques centaines de Mo : un XS suffit
--                               (le COPY prend environ une minute).
--   AUTO_SUSPEND = 60           suspension après 60 s d'inactivité (minimum
--                               utile : en dessous, chaque reprise refacture 60 s).
--   AUTO_RESUME = TRUE          redémarre seul à la requête suivante : pas besoin
--                               de le laisser allumé « au cas où ».
--   INITIALLY_SUSPENDED = TRUE  la création ne consomme rien.
--   STATEMENT_TIMEOUT 1800 s    une requête qui part en boucle (jointure qui
--                               explose) est tuée au bout de 30 min.
--
-- Variables (remplacées par scripts/setup_snowflake.py ou par Snowflake CLI :
--   snow sql -f sql/snowflake/01_warehouse.sql -D warehouse=NYC_TAXI_WH) :
--   <% warehouse %>   nom du warehouse (SNOWFLAKE_WAREHOUSE dans .env)
-- =============================================================================

CREATE WAREHOUSE IF NOT EXISTS <% warehouse %>
  WAREHOUSE_SIZE      = 'XSMALL'
  AUTO_SUSPEND        = 60
  AUTO_RESUME         = TRUE
  INITIALLY_SUSPENDED = TRUE
  STATEMENT_TIMEOUT_IN_SECONDS = 1800
  COMMENT = 'Projet 2 NYC Taxi DW - calcul ingestion + dbt (XS, auto-suspend 60 s)';

-- Réapplique les paramètres si le warehouse existait déjà avec d'autres valeurs
-- (CREATE ... IF NOT EXISTS ne modifie pas un objet existant).
ALTER WAREHOUSE <% warehouse %> SET
  WAREHOUSE_SIZE      = 'XSMALL'
  AUTO_SUSPEND        = 60
  AUTO_RESUME         = TRUE
  STATEMENT_TIMEOUT_IN_SECONDS = 1800;
