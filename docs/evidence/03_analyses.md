# Résultats des analyses (`analyses/`)

_Requêtes compilées par dbt et exécutées par `scripts/collect_evidence.py` le 2026-10-17 22:05:33 UTC. L'interprétation est dans le README (section Analyses)._


## anomaly_overview

| FLAG | ROWS_FLAGGED | PCT |
|---|---|---|
| flag_missing_metadata | 71661 | 2.341 |
| flag_extra_includes_surcharges | 761286 | 24.871 |
| flag_total_mismatch_other | 68783 | 2.247 |
| flag_negative_amount | 25174 | 0.822 |
| flag_zero_distance | 44755 | 1.462 |
| flag_zero_passenger | 50896 | 1.663 |
| flag_unknown_zone | 56798 | 1.856 |
| au moins un indicateur | 934855 | 30.542 |


## distance_duration_amount

| DISTANCE_BAND | TRIPS | PCT_TRIPS | AVG_DISTANCE_MI | MEDIAN_DURATION_MIN | AVG_SPEED_MPH | MEDIAN_TOTAL_USD | MEDIAN_USD_PER_MILE |
|---|---|---|---|---|---|---|---|
| 01. < 1 mi | 604111 | 20.36 | 0.7 | 5.1 | 8.8 | 13.3 | 18.90 |
| 02. 1-2 mi | 1009744 | 34.02 | 1.44 | 9.4 | 9.6 | 17.64 | 12.44 |
| 03. 2-5 mi | 855300 | 28.82 | 2.98 | 15.8 | 11.6 | 25.2 | 8.86 |
| 04. 5-10 mi | 257662 | 8.68 | 7.19 | 22.4 | 20.0 | 43.32 | 6.43 |
| 05. 10-20 mi | 209958 | 7.07 | 15.0 | 35.1 | 25.8 | 81.8 | 5.39 |
| 06. >= 20 mi | 30889 | 1.04 | 23.43 | 45.3 | 31.0 | 97.91 | 4.52 |
| 99. corrélations (r) | 2967664 |  | 0.817 | 0.829 |  | 0.948 |  |


## payment_mix

| PAYMENT_TYPE_ID | PAYMENT_TYPE_NAME | TRIPS | PCT_TRIPS | AVG_TOTAL_USD | AVG_FARE_USD | AVG_TIP_USD_IF_CAPTURED | AVG_TIP_PCT_CARD | NEGATIVE_AMOUNT_TRIPS |
|---|---|---|---|---|---|---|---|---|
| 1 | Credit card | 2408408 | 78.68 | 28.28 | 18.64 | 4.17 | 26.25 | 21 |
| 2 | Cash | 530093 | 17.32 | 23.01 | 18.06 |  |  | 5844 |
| 0 | Flex Fare trip | 71661 | 2.34 | 29.13 | 20.82 |  |  | 46 |
| 4 | Dispute | 33122 | 1.08 | 2.51 | 1.92 |  |  | 14741 |
| 3 | No charge | 17646 | 0.58 | 10.42 | 8.05 |  |  | 4522 |


## peak_periods

| DAY_NAME | DAY_PERIOD | TRIPS | OBSERVED_HOURS | AVG_TRIPS_PER_HOUR | AVG_REVENUE_PER_TRIP |
|---|---|---|---|---|---|
| Thu | 4. Pointe du soir (16h-20h) | 121106 | 16 | 7569 | 28.72 |
| Wed | 4. Pointe du soir (16h-20h) | 118729 | 16 | 7421 | 27.94 |
| Fri | 4. Pointe du soir (16h-20h) | 116103 | 16 | 7256 | 28.42 |
| Sat | 4. Pointe du soir (16h-20h) | 110578 | 16 | 6911 | 25.67 |
| Tue | 4. Pointe du soir (16h-20h) | 134025 | 20 | 6701 | 28.46 |
| Fri | 5. Soirée (20h-24h) | 97541 | 16 | 6096 | 26.82 |
| Thu | 3. Journée (10h-16h) | 145930 | 24 | 6080 | 26.89 |
| Sat | 5. Soirée (20h-24h) | 96635 | 16 | 6040 | 26.67 |
| Fri | 3. Journée (10h-16h) | 140244 | 24 | 5844 | 26.81 |
| Wed | 3. Journée (10h-16h) | 140061 | 24 | 5836 | 25.97 |
| Sat | 3. Journée (10h-16h) | 139318 | 24 | 5805 | 24.76 |
| Thu | 5. Soirée (20h-24h) | 91151 | 16 | 5697 | 27.45 |
| Tue | 3. Journée (10h-16h) | 170470 | 30 | 5682 | 26.91 |
| Mon | 4. Pointe du soir (16h-20h) | 111510 | 20 | 5576 | 29.11 |
| Wed | 5. Soirée (20h-24h) | 80647 | 16 | 5040 | 27.45 |
