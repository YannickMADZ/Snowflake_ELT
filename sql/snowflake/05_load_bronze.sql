-- =============================================================================
-- 05 — CHARGEMENT : CSV local -> PUT -> stage -> COPY INTO -> Bronze
-- =============================================================================
-- Exécuté par scripts/load_bronze.py (qui vérifie avant l'en-tête du CSV et
-- compte ses lignes), ou directement avec Snowflake CLI :
--   snow sql -f sql/snowflake/05_load_bronze.sql \
--     -D database=NYC_TAXI_DB -D warehouse=NYC_TAXI_WH \
--     -D csv_path=C:/chemin/vers/trips_clean.csv
--
-- IDEMPOTENCE : le script peut être relancé sans créer de doublons.
--   - PUT ... OVERWRITE = TRUE remplace le fichier déjà présent dans le stage ;
--   - TRUNCATE vide la table ET efface son historique de chargement : sans lui,
--     Snowflake ignorerait le fichier déjà chargé (statut LOAD_SKIPPED) ;
--     avec lui, chaque exécution est un rechargement complet et propre.
--
-- ON_ERROR = ABORT_STATEMENT : à la première ligne invalide (type, nombre de
-- colonnes), RIEN n'est chargé. On préfère une Bronze vide et une erreur
-- explicite à une Bronze partielle qui fausserait silencieusement tous les
-- comptages en aval.
--
-- Variables : <% database %>, <% warehouse %>, <% csv_path %> (chemin absolu
-- du CSV, avec des / même sous Windows).
-- =============================================================================

USE WAREHOUSE <% warehouse %>;
USE DATABASE <% database %>;
USE SCHEMA BRONZE;

-- 1. Envoi du fichier local dans le stage (compressé en gzip côté client).
PUT 'file://<% csv_path %>' @BRONZE.STG_TRIPS_CSV/project1/
  AUTO_COMPRESS = TRUE
  OVERWRITE     = TRUE
  PARALLEL      = 4;

-- 2. Rechargement complet.
TRUNCATE TABLE IF EXISTS BRONZE.YELLOW_TRIPS_RAW;

-- 3. Chargement. Les colonnes sont prises PAR POSITION ($1..$30) dans l'ordre
--    fixé par column_order du Projet 1 (load_bronze.py a vérifié l'en-tête).
--    _loaded_at n'est pas listée : elle prend sa valeur DEFAULT.
COPY INTO BRONZE.YELLOW_TRIPS_RAW (
    row_id, vendorid, tpep_pickup_datetime, tpep_dropoff_datetime,
    passenger_count, trip_distance, ratecodeid, store_and_fwd_flag,
    pulocationid, dolocationid, payment_type, fare_amount, extra, mta_tax,
    tip_amount, tolls_amount, improvement_surcharge, total_amount,
    congestion_surcharge, airport_fee, duration_min, speed_mph, total_gap,
    flag_missing_metadata, flag_extra_includes_surcharges,
    flag_total_mismatch_other, flag_negative_amount, flag_zero_distance,
    flag_zero_passenger, flag_unknown_zone,
    _source_file, _source_row_number
)
FROM (
    SELECT
        $1,  $2,  $3,  $4,  $5,  $6,  $7,  $8,  $9,  $10,
        $11, $12, $13, $14, $15, $16, $17, $18, $19, $20,
        $21, $22, $23, $24, $25, $26, $27, $28, $29, $30,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER
    FROM @BRONZE.STG_TRIPS_CSV/project1/
)
FILE_FORMAT = (FORMAT_NAME = 'BRONZE.FF_TRIPS_CSV')
PATTERN     = '.*trips_clean[.]csv([.]gz)?'
ON_ERROR    = ABORT_STATEMENT
PURGE       = FALSE;
