-- =============================================================================
-- 03 — FILE FORMAT ET STAGE INTERNE
-- =============================================================================
-- Le file format décrit le CSV écrit par pandas dans le Projet 1 :
--   - séparateur virgule, 1 ligne d'en-tête, fin de ligne par défaut (LF ou CRLF) ;
--   - valeurs manquantes écrites comme champ vide -> NULL (EMPTY_FIELD_AS_NULL
--     et NULL_IF '') : AUCUNE valeur de remplacement n'est inventée ;
--   - guillemets optionnels (pandas n'en met que si nécessaire) ;
--   - COMPRESSION = AUTO : le PUT compresse le fichier en .gz, Snowflake le
--     détecte à la lecture ;
--   - ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE : une ligne avec une colonne de trop
--     ou de moins est une erreur, pas un décalage silencieux.
--
-- Le stage est INTERNE (stockage géré par Snowflake) : pas besoin de bucket
-- S3/Azure ni d'identifiants cloud supplémentaires, ce qui supprime une source
-- de secrets. Le file format lui est attaché par défaut.
--
-- Variables : <% database %>
-- =============================================================================

USE DATABASE <% database %>;
USE SCHEMA BRONZE;

CREATE OR REPLACE FILE FORMAT BRONZE.FF_TRIPS_CSV
  TYPE                           = CSV
  FIELD_DELIMITER                = ','
  SKIP_HEADER                    = 1
  FIELD_OPTIONALLY_ENCLOSED_BY   = '"'
  NULL_IF                        = ('', 'NULL')
  EMPTY_FIELD_AS_NULL            = TRUE
  TRIM_SPACE                     = FALSE
  ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE
  TIMESTAMP_FORMAT               = 'AUTO'
  ENCODING                       = 'UTF8'
  COMPRESSION                    = AUTO
  COMMENT = 'CSV nettoyé du Projet 1 (pandas.to_csv, en-tête, vides = NULL)';

CREATE STAGE IF NOT EXISTS BRONZE.STG_TRIPS_CSV
  FILE_FORMAT = BRONZE.FF_TRIPS_CSV
  COMMENT = 'Stage interne : réception du CSV du Projet 1 via PUT';
