# Preuve — volumes par couche Medallion

_Généré le 2026-10-17 22:05:38 UTC depuis INFORMATION_SCHEMA. Bronze, staging, intermediate et fct_trips doivent avoir le même nombre de lignes (aucun trajet perdu ni dupliqué)._

| schema | objet | type | lignes |
|---|---|---|---|
| BRONZE | YELLOW_TRIPS_RAW | TABLE | 3060930 |
| SILVER | INT_TRIPS_ENRICHED | TABLE | 3060930 |
| SILVER | PAYMENT_TYPES | TABLE | 7 |
| SILVER | RATE_CODES | TABLE | 7 |
| SILVER | STG_YELLOW_TRIPS | VIEW | 3060930 |
| SILVER | TAXI_ZONE_LOOKUP | TABLE | 265 |
| SILVER | VENDORS | TABLE | 4 |
| GOLD | AGG_TRIPS_HOURLY | TABLE | 744 |
| GOLD | AGG_ZONE_PAIRS | TABLE | 22105 |
| GOLD | DIM_DATE | TABLE | 365 |
| GOLD | DIM_LOCATION | TABLE | 265 |
| GOLD | DIM_PAYMENT_TYPE | TABLE | 7 |
| GOLD | DIM_RATE_CODE | TABLE | 7 |
| GOLD | DIM_TIME_OF_DAY | TABLE | 24 |
| GOLD | DIM_VENDOR | TABLE | 4 |
| GOLD | FCT_TRIPS | TABLE | 3060930 |
