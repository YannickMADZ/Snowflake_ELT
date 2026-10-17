-- =============================================================================
-- 06 — CONTRÔLES DU CHARGEMENT (preuves)
-- =============================================================================
-- Répond aux quatre questions de la consigne avec les outils de Snowflake :
--   a. combien de fichiers et de lignes ont été chargés ?      -> COPY_HISTORY
--   b. des erreurs sont-elles apparues ?                       -> COPY_HISTORY
--   c. le nombre de lignes correspond-il au fichier source ?   -> stage vs table
--   d. les types chargés sont-ils ceux attendus ?              -> INFORMATION_SCHEMA
-- scripts/load_bronze.py exécute ces requêtes, compare aussi avec le comptage
-- local du CSV et écrit le résultat dans docs/evidence/01_ingestion.md.
--
-- Variables : <% database %>, <% warehouse %>
-- =============================================================================

USE WAREHOUSE <% warehouse %>;
USE DATABASE <% database %>;

-- a + b. Historique du COPY sur les dernières 24 h : fichier, statut, lignes
--        analysées / chargées, nombre d'erreurs, première erreur.
SELECT file_name, status, row_parsed, row_count, error_count, first_error_message, last_load_time
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'BRONZE.YELLOW_TRIPS_RAW',
        START_TIME => DATEADD(HOUR, -24, CURRENT_TIMESTAMP())))
ORDER BY last_load_time DESC
LIMIT 5;

-- c1. Lignes lues DIRECTEMENT dans le fichier du stage (lecture du fichier
--     source par Snowflake lui-même, en-tête exclu).
SELECT COUNT(*) AS rows_in_staged_file
FROM @BRONZE.STG_TRIPS_CSV/project1/ (FILE_FORMAT => 'BRONZE.FF_TRIPS_CSV', PATTERN => '.*trips_clean[.]csv([.]gz)?');

-- c2. Lignes dans la table Bronze, fichiers distincts, unicité de l'identifiant.
SELECT
    COUNT(*)                     AS rows_in_bronze,
    COUNT(DISTINCT _source_file) AS files_loaded,
    COUNT(DISTINCT row_id)       AS distinct_row_ids,
    MIN(tpep_pickup_datetime)    AS min_pickup,
    MAX(tpep_pickup_datetime)    AS max_pickup
FROM BRONZE.YELLOW_TRIPS_RAW;

-- d. Types réellement créés dans Snowflake.
SELECT column_name, data_type, numeric_precision, numeric_scale, is_nullable
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = 'BRONZE' AND table_name = 'YELLOW_TRIPS_RAW'
ORDER BY ordinal_position;

-- e. Valeurs manquantes par colonne (doivent correspondre au rapport qualité
--    du Projet 1 : 5 colonnes de métadonnées manquantes ensemble).
SELECT
    COUNT_IF(passenger_count IS NULL)      AS null_passenger_count,
    COUNT_IF(ratecodeid IS NULL)           AS null_ratecodeid,
    COUNT_IF(store_and_fwd_flag IS NULL)   AS null_store_and_fwd_flag,
    COUNT_IF(congestion_surcharge IS NULL) AS null_congestion_surcharge,
    COUNT_IF(airport_fee IS NULL)          AS null_airport_fee,
    COUNT_IF(flag_missing_metadata)        AS flag_missing_metadata_true
FROM BRONZE.YELLOW_TRIPS_RAW;
