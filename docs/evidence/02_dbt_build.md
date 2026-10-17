# Preuve — dbt build

_Généré par `scripts/collect_evidence.py` le 2026-10-17 22:04:50 UTC à partir de `target/run_results.json` (dbt 1.12.6, durée totale 42.2 s)._

## Verdict : ✅ dbt build sans erreur

## Synthèse par type de ressource

| type | statut | nombre |
|---|---|---|
| exposure | no-op | 1 |
| model | success | 11 |
| operation | success | 1 |
| seed | success | 4 |
| test | pass | 80 |
| test | warn | 2 |


`warn` = anomalie documentée (test en sévérité warn, n'interrompt pas le build) ; `fail`/`error` = règle bloquante violée.


## Détail

| type | nom | statut | lignes en défaut (tests) | durée (s) |
|---|---|---|---|---|
| exposure | tableau_de_bord_activite_revenus | no-op |  | 0.0 |
| model | agg_trips_hourly | success |  | 2.9 |
| model | agg_zone_pairs | success |  | 3.2 |
| model | dim_date | success |  | 2.1 |
| model | dim_location | success |  | 2.3 |
| model | dim_payment_type | success |  | 2.0 |
| model | dim_rate_code | success |  | 2.1 |
| model | dim_time_of_day | success |  | 3.1 |
| model | dim_vendor | success |  | 1.9 |
| model | fct_trips | success |  | 4.9 |
| model | int_trips_enriched | success |  | 4.5 |
| model | stg_yellow_trips | success |  | 1.6 |
| operation | nyc_taxi_dw-on-run-end-0 | success |  | 3.1 |
| seed | payment_types | success |  | 2.9 |
| seed | rate_codes | success |  | 3.6 |
| seed | taxi_zone_lookup | success |  | 3.8 |
| seed | vendors | success |  | 2.7 |
| test | accepted_values_dim_location_borough__Bronx__Brooklyn__EWR__Manhattan__Queens__Staten_Island__Unknown__N_A | pass | 0 | 0.6 |
| test | accepted_values_dim_time_of_day_hour_key__False__0__1__2__3__4__5__6__7__8__9__10__11__12__13__14__15__16__17__18__19__20__21__22__23 | pass | 0 | 0.7 |
| test | accepted_values_stg_yellow_trips_payment_type_id__False__0__1__2__3__4__5__6 | pass | 0 | 0.6 |
| test | accepted_values_stg_yellow_trips_rate_code_id__False__1__2__3__4__5__6__99 | pass | 0 | 0.5 |
| test | assert_agg_hourly_reconciles_with_fct | pass | 0 | 0.7 |
| test | assert_fct_trips_reconciles_with_bronze | pass | 0 | 0.7 |
| test | assert_missing_metadata_is_all_or_nothing | pass | 0 | 1.8 |
| test | int_trips_extra_net_explains_total | pass | 0 | 0.7 |
| test | int_trips_tip_pct_plausible | warn | 3536 | 0.7 |
| test | not_null_agg_trips_hourly_date_key | pass | 0 | 0.6 |
| test | not_null_agg_trips_hourly_hour_key | pass | 0 | 0.6 |
| test | not_null_dim_date_calendar_date | pass | 0 | 0.7 |
| test | not_null_dim_date_date_key | pass | 0 | 0.7 |
| test | not_null_dim_location_location_id | pass | 0 | 0.5 |
| test | not_null_dim_payment_type_payment_type_id | pass | 0 | 0.6 |
| test | not_null_dim_rate_code_rate_code_id | pass | 0 | 0.6 |
| test | not_null_dim_time_of_day_hour_key | pass | 0 | 0.6 |
| test | not_null_dim_vendor_vendor_id | pass | 0 | 0.6 |
| test | not_null_fct_trips_date_key | pass | 0 | 0.6 |
| test | not_null_fct_trips_dropoff_location_id | pass | 0 | 0.6 |
| test | not_null_fct_trips_hour_key | pass | 0 | 0.6 |
| test | not_null_fct_trips_payment_type_id | pass | 0 | 0.7 |
| test | not_null_fct_trips_pickup_location_id | pass | 0 | 0.5 |
| test | not_null_fct_trips_total_amount | pass | 0 | 0.7 |
| test | not_null_fct_trips_trip_id | pass | 0 | 0.6 |
| test | not_null_fct_trips_vendor_id | pass | 0 | 0.5 |
| test | not_null_int_trips_enriched_distance_band | pass | 0 | 0.7 |
| test | not_null_int_trips_enriched_duration_band | pass | 0 | 0.7 |
| test | not_null_int_trips_enriched_trip_id | pass | 0 | 0.4 |
| test | not_null_payment_types_payment_type_id | pass | 0 | 0.6 |
| test | not_null_rate_codes_rate_code_id | pass | 0 | 0.5 |
| test | not_null_stg_yellow_trips_dropoff_at | pass | 0 | 0.5 |
| test | not_null_stg_yellow_trips_dropoff_location_id | pass | 0 | 0.5 |
| test | not_null_stg_yellow_trips_payment_type_id | pass | 0 | 0.5 |
| test | not_null_stg_yellow_trips_pickup_at | pass | 0 | 0.6 |
| test | not_null_stg_yellow_trips_pickup_location_id | pass | 0 | 0.6 |
| test | not_null_stg_yellow_trips_trip_id | pass | 0 | 0.6 |
| test | not_null_stg_yellow_trips_vendor_id | pass | 0 | 0.5 |
| test | not_null_taxi_zone_lookup_location_id | pass | 0 | 0.6 |
| test | not_null_vendors_vendor_id | pass | 0 | 0.5 |
| test | relationships_agg_trips_hourly_date_key__date_key__ref_dim_date_ | pass | 0 | 0.5 |
| test | relationships_fct_trips_date_key__date_key__ref_dim_date_ | pass | 0 | 0.6 |
| test | relationships_fct_trips_dropoff_location_id__location_id__ref_dim_location_ | pass | 0 | 0.6 |
| test | relationships_fct_trips_hour_key__hour_key__ref_dim_time_of_day_ | pass | 0 | 0.6 |
| test | relationships_fct_trips_payment_type_id__payment_type_id__ref_dim_payment_type_ | pass | 0 | 0.6 |
| test | relationships_fct_trips_pickup_location_id__location_id__ref_dim_location_ | pass | 0 | 1.0 |
| test | relationships_fct_trips_rate_code_id__rate_code_id__ref_dim_rate_code_ | pass | 0 | 1.0 |
| test | relationships_fct_trips_vendor_id__vendor_id__ref_dim_vendor_ | pass | 0 | 1.0 |
| test | relationships_stg_yellow_trips_dropoff_location_id__location_id__ref_taxi_zone_lookup_ | pass | 0 | 1.1 |
| test | relationships_stg_yellow_trips_pickup_location_id__location_id__ref_taxi_zone_lookup_ | pass | 0 | 1.2 |
| test | relationships_stg_yellow_trips_vendor_id__vendor_id__ref_vendors_ | pass | 0 | 0.7 |
| test | source_accepted_values_bronze_yellow_trips_raw_store_and_fwd_flag__Y__N | pass | 0 | 0.7 |
| test | source_not_null_bronze_yellow_trips_raw_row_id | pass | 0 | 0.4 |
| test | source_not_null_bronze_yellow_trips_raw_tpep_dropoff_datetime | pass | 0 | 0.6 |
| test | source_not_null_bronze_yellow_trips_raw_tpep_pickup_datetime | pass | 0 | 0.5 |
| test | source_unique_bronze_yellow_trips_raw_row_id | pass | 0 | 0.7 |
| test | stg_trips_duration_survived_ingestion | pass | 0 | 0.7 |
| test | stg_trips_duration_within_p1_rules | pass | 0 | 0.6 |
| test | stg_trips_flags_negative_amount_consistent | pass | 0 | 1.2 |
| test | stg_trips_flags_unknown_zone_consistent | pass | 0 | 0.8 |
| test | stg_trips_flags_zero_distance_consistent | pass | 0 | 0.7 |
| test | stg_trips_flags_zero_passenger_consistent | pass | 0 | 0.5 |
| test | stg_trips_passenger_count_plausible | warn | 20 | 0.5 |
| test | stg_trips_single_month | pass | 0 | 0.6 |
| test | stg_trips_speed_within_p1_rules | pass | 0 | 0.6 |
| test | stg_trips_total_gap_matches_p1 | pass | 0 | 0.7 |
| test | unique_combination_of_columns_agg_trips_hourly_date_key__hour_key | pass | 0 | 0.5 |
| test | unique_combination_of_columns_agg_zone_pairs_pickup_location_id__dropoff_location_id | pass | 0 | 0.6 |
| test | unique_dim_date_calendar_date | pass | 0 | 0.7 |
| test | unique_dim_date_date_key | pass | 0 | 0.6 |
| test | unique_dim_location_location_id | pass | 0 | 0.5 |
| test | unique_dim_payment_type_payment_type_id | pass | 0 | 0.5 |
| test | unique_dim_rate_code_rate_code_id | pass | 0 | 0.6 |
| test | unique_dim_time_of_day_hour_key | pass | 0 | 0.5 |
| test | unique_dim_vendor_vendor_id | pass | 0 | 0.6 |
| test | unique_fct_trips_trip_id | pass | 0 | 0.8 |
| test | unique_int_trips_enriched_trip_id | pass | 0 | 0.5 |
| test | unique_payment_types_payment_type_id | pass | 0 | 0.6 |
| test | unique_rate_codes_rate_code_id | pass | 0 | 0.5 |
| test | unique_stg_yellow_trips_trip_id | pass | 0 | 0.6 |
| test | unique_taxi_zone_lookup_location_id | pass | 0 | 0.6 |
| test | unique_vendors_vendor_id | pass | 0 | 0.5 |
