# Preuve d'ingestion — CSV Projet 1 → PUT → stage → COPY INTO → BRONZE

_Généré automatiquement par `scripts/load_bronze.py` le 2026-10-17 22:03:49 UTC._ Aucun identifiant de compte n'apparaît dans ce fichier.

## Verdict : ✅ CHARGEMENT COMPLET

| Contrôle | Résultat | Détail |
|---|---|---|
| COPY sans erreur (errors_seen = 0) | ✅ | errors_seen = 0 |
| Un seul fichier chargé | ✅ | 1 fichier(s) |
| rows_out du rapport Projet 1 = lignes CSV | ✅ | 3060930 vs 3060930 |
| Lignes CSV local = lignes du fichier en stage | ✅ | 3060930 vs 3060930 |
| Lignes CSV local = lignes chargées par COPY | ✅ | 3060930 vs 3060930 |
| Lignes CSV local = lignes Bronze | ✅ | 3060930 vs 3060930 |
| row_id unique dans Bronze | ✅ | 3060930 distincts / 3060930 |
| Types Snowflake = types attendus | ✅ | conformes |


## Fichier source (contrôles locaux avant envoi)

- Fichier : `trips_clean.csv`
- En-tête : 30 colonnes, ordre conforme
- Lignes de données : **3060930**
- `rows_out` du rapport qualité du Projet 1 : **3060930**


## Résultat du PUT

| source | target | source_size | target_size | source_compression | target_compression | status | message |
|---|---|---|---|---|---|---|---|
| trips_clean.csv | trips_clean.csv.gz | 546274083 | 121530112 | NONE | GZIP | UPLOADED |  |


## Résultat du COPY INTO (par fichier)

| file | status | rows_parsed | rows_loaded | error_limit | errors_seen | first_error | first_error_line | first_error_character | first_error_column_name |
|---|---|---|---|---|---|---|---|---|---|
| stg_trips_csv/project1/trips_clean.csv.gz | LOADED | 3060930 | 3060930 | 1 | 0 |  |  |  |  |


## COPY_HISTORY (24 dernières heures)

| FILE_NAME | STATUS | ROW_PARSED | ROW_COUNT | ERROR_COUNT | FIRST_ERROR_MESSAGE | LAST_LOAD_TIME |
|---|---|---|---|---|---|---|
| project1/trips_clean.csv.gz | Loaded | 3060930 | 3060930 | 0 |  | 2026-10-17 15:06:43.537000-07:00 |


## Lignes lues directement dans le fichier du stage

| ROWS_IN_STAGED_FILE |
|---|
| 3060930 |


## Table Bronze

| ROWS_IN_BRONZE | FILES_LOADED | DISTINCT_ROW_IDS | MIN_PICKUP | MAX_PICKUP |
|---|---|---|---|---|
| 3060930 | 1 | 3060930 | 2023-01-01 00:00:00 | 2023-01-31 23:59:59 |


## Valeurs manquantes (à comparer au rapport qualité du Projet 1)

| NULL_PASSENGER_COUNT | NULL_RATECODEID | NULL_STORE_AND_FWD_FLAG | NULL_CONGESTION_SURCHARGE | NULL_AIRPORT_FEE | FLAG_MISSING_METADATA_TRUE |
|---|---|---|---|---|---|
| 71661 | 71661 | 71661 | 71661 | 71661 | 71661 |


## Types des colonnes Bronze (INFORMATION_SCHEMA.COLUMNS)

| COLUMN_NAME | DATA_TYPE | NUMERIC_PRECISION | NUMERIC_SCALE | IS_NULLABLE |
|---|---|---|---|---|
| ROW_ID | TEXT |  |  | YES |
| VENDORID | NUMBER | 38 | 0 | YES |
| TPEP_PICKUP_DATETIME | TIMESTAMP_NTZ |  |  | YES |
| TPEP_DROPOFF_DATETIME | TIMESTAMP_NTZ |  |  | YES |
| PASSENGER_COUNT | NUMBER | 38 | 0 | YES |
| TRIP_DISTANCE | FLOAT |  |  | YES |
| RATECODEID | NUMBER | 38 | 0 | YES |
| STORE_AND_FWD_FLAG | TEXT |  |  | YES |
| PULOCATIONID | NUMBER | 38 | 0 | YES |
| DOLOCATIONID | NUMBER | 38 | 0 | YES |
| PAYMENT_TYPE | NUMBER | 38 | 0 | YES |
| FARE_AMOUNT | FLOAT |  |  | YES |
| EXTRA | FLOAT |  |  | YES |
| MTA_TAX | FLOAT |  |  | YES |
| TIP_AMOUNT | FLOAT |  |  | YES |
| TOLLS_AMOUNT | FLOAT |  |  | YES |
| IMPROVEMENT_SURCHARGE | FLOAT |  |  | YES |
| TOTAL_AMOUNT | FLOAT |  |  | YES |
| CONGESTION_SURCHARGE | FLOAT |  |  | YES |
| AIRPORT_FEE | FLOAT |  |  | YES |
| DURATION_MIN | FLOAT |  |  | YES |
| SPEED_MPH | FLOAT |  |  | YES |
| TOTAL_GAP | FLOAT |  |  | YES |
| FLAG_MISSING_METADATA | BOOLEAN |  |  | YES |
| FLAG_EXTRA_INCLUDES_SURCHARGES | BOOLEAN |  |  | YES |
| FLAG_TOTAL_MISMATCH_OTHER | BOOLEAN |  |  | YES |
| FLAG_NEGATIVE_AMOUNT | BOOLEAN |  |  | YES |
| FLAG_ZERO_DISTANCE | BOOLEAN |  |  | YES |
| FLAG_ZERO_PASSENGER | BOOLEAN |  |  | YES |
| FLAG_UNKNOWN_ZONE | BOOLEAN |  |  | YES |
| _SOURCE_FILE | TEXT |  |  | YES |
| _SOURCE_ROW_NUMBER | NUMBER | 38 | 0 | YES |
| _LOADED_AT | TIMESTAMP_LTZ |  |  | YES |
