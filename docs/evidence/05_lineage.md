# Preuve — lineage dbt

_Généré depuis `target/manifest.json` le 2026-10-17 22:05:39 UTC. Même graphe que dans `dbt docs serve` (icône lineage en bas à droite) ; capture conseillée : `docs/evidence/lineage.png`._

```mermaid
flowchart LR
  csv[["CSV Projet 1<br/>trips_clean.csv"]] -->|PUT + COPY INTO| n16
  n0{{"tableau_de_bord_activite_revenus"}}
  n1["agg_trips_hourly"]
  n2["agg_zone_pairs"]
  n3["dim_date"]
  n4["dim_location"]
  n5["dim_payment_type"]
  n6["dim_rate_code"]
  n7["dim_time_of_day"]
  n8["dim_vendor"]
  n9["fct_trips"]
  n10["int_trips_enriched"]
  n11["stg_yellow_trips"]
  n12(["payment_types"])
  n13(["rate_codes"])
  n14(["taxi_zone_lookup"])
  n15(["vendors"])
  n16[("source: bronze.yellow_trips_raw")]
  n1 --> n0
  n2 --> n0
  n9 --> n0
  n5 --> n0
  n9 --> n1
  n3 --> n1
  n7 --> n1
  n9 --> n2
  n4 --> n2
  n11 --> n3
  n14 --> n4
  n12 --> n5
  n13 --> n6
  n15 --> n8
  n10 --> n9
  n11 --> n10
  n12 --> n10
  n16 --> n11
```
