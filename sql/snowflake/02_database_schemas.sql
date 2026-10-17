-- =============================================================================
-- 02 — DATABASE ET SCHEMAS MEDALLION
-- =============================================================================
-- Une database, trois schemas : un par couche. Séparer les couches en schemas
-- (et non en préfixes de tables) permet de donner des droits différents à
-- chaque couche (un analyste ne lit que GOLD) et rend le rôle de chaque objet
-- lisible dans son nom complet : NYC_TAXI_DB.GOLD.FCT_TRIPS.
--
--   BRONZE  données telles que livrées par le Projet 1 + stage + file format.
--           Écrit UNIQUEMENT par le COPY INTO, jamais par dbt.
--   SILVER  staging + intermediate dbt + seeds de référence.
--   GOLD    modèles analytiques dbt (faits, dimensions, agrégats).
--
-- Variables : <% database %>  (SNOWFLAKE_DATABASE dans .env)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS <% database %>
  COMMENT = 'Projet 2 - Data Warehouse NYC Yellow Taxi (architecture Medallion)';

-- DATA_RETENTION_TIME_IN_DAYS = 1 : Time Travel d'un jour (valeur par défaut en
-- Standard). On ne l'augmente pas : chaque jour de rétention conservé est du
-- stockage facturé, et la Bronze se recharge depuis le CSV en une minute.
CREATE SCHEMA IF NOT EXISTS <% database %>.BRONZE
  DATA_RETENTION_TIME_IN_DAYS = 1
  COMMENT = 'Couche Bronze : CSV nettoyé du Projet 1, chargé tel quel par COPY INTO';

CREATE SCHEMA IF NOT EXISTS <% database %>.SILVER
  DATA_RETENTION_TIME_IN_DAYS = 1
  COMMENT = 'Couche Silver : modèles dbt staging/intermediate + seeds de référence';

CREATE SCHEMA IF NOT EXISTS <% database %>.GOLD
  DATA_RETENTION_TIME_IN_DAYS = 1
  COMMENT = 'Couche Gold : modèles analytiques dbt (étoile fct_trips + agrégats)';
