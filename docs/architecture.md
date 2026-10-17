# Architecture

## 1. Flux de bout en bout

```mermaid
flowchart LR
    subgraph P1["Projet 1 (local)"]
        CSV[["trips_clean.csv<br/>CSV nettoyé, 30 colonnes"]]
    end

    subgraph SF["Snowflake — database NYC_TAXI_DB · warehouse NYC_TAXI_WH (XS, auto-suspend 60 s)"]
        direction LR
        subgraph BR["BRONZE (scripts SQL)"]
            FF[/"FF_TRIPS_CSV<br/>file format"/]
            STG[("STG_TRIPS_CSV<br/>stage interne")]
            RAW[("YELLOW_TRIPS_RAW<br/>table Bronze")]
        end
        subgraph SI["SILVER (dbt)"]
            SEEDS(["seeds : taxi_zone_lookup,<br/>vendors, payment_types, rate_codes"])
            S1["stg_yellow_trips<br/>(view)"]
            I1["int_trips_enriched<br/>(table)"]
        end
        subgraph GO["GOLD (dbt)"]
            F["fct_trips"]
            D1["dim_date"]
            D2["dim_time_of_day"]
            D3["dim_location"]
            D4["dim_payment_type"]
            D5["dim_vendor"]
            D6["dim_rate_code"]
            A1["agg_trips_hourly"]
            A2["agg_zone_pairs"]
        end
    end

    CSV -- "PUT (gzip)" --> STG
    FF -.-> STG
    STG -- "COPY INTO<br/>ON_ERROR = ABORT" --> RAW
    RAW -- "source()" --> S1
    S1 --> I1
    SEEDS --> I1
    I1 --> F
    SEEDS --> D3 & D4 & D5 & D6
    S1 --> D1
    F --> A1 & A2
    D1 & D2 --> A1
    D3 --> A2
```

## 2. Schéma en étoile (couche GOLD)

```mermaid
erDiagram
    FCT_TRIPS }o--|| DIM_DATE : "date_key"
    FCT_TRIPS }o--|| DIM_TIME_OF_DAY : "hour_key"
    FCT_TRIPS }o--|| DIM_LOCATION : "pickup_location_id"
    FCT_TRIPS }o--|| DIM_LOCATION : "dropoff_location_id"
    FCT_TRIPS }o--|| DIM_PAYMENT_TYPE : "payment_type_id"
    FCT_TRIPS }o--|| DIM_VENDOR : "vendor_id"
    FCT_TRIPS }o--o| DIM_RATE_CODE : "rate_code_id (nullable)"

    FCT_TRIPS {
        varchar trip_id PK "grain : 1 trajet"
        int date_key FK
        int hour_key FK
        int pickup_location_id FK
        int dropoff_location_id FK
        int payment_type_id FK
        int vendor_id FK
        int rate_code_id FK
        number total_amount "mesure additive"
        number trip_distance_mi "mesure additive"
        number duration_min "mesure additive"
        number speed_mph "non additive"
        boolean is_revenue_analyzable "règle métier"
    }
    DIM_DATE {
        int date_key PK "grain : 1 date"
        date calendar_date
        varchar day_name
        boolean is_weekend
    }
    DIM_TIME_OF_DAY {
        int hour_key PK "grain : 1 heure (0-23)"
        varchar day_period
    }
    DIM_LOCATION {
        int location_id PK "grain : 1 zone TLC"
        varchar borough
        varchar zone
        boolean is_airport
    }
    DIM_PAYMENT_TYPE {
        int payment_type_id PK "grain : 1 mode"
        boolean is_tip_captured
        boolean is_revenue_payment
    }
    DIM_VENDOR {
        int vendor_id PK "grain : 1 fournisseur"
        varchar vendor_name
    }
    DIM_RATE_CODE {
        int rate_code_id PK "grain : 1 code tarifaire"
        varchar rate_code_name
    }
```

Agrégats construits **depuis** `fct_trips` (mêmes définitions de mesures) :

| Table | Grain | Questions servies |
|---|---|---|
| `agg_trips_hourly` | une heure calendaire (date x heure) | Activité, revenus par période, périodes de pointe |
| `agg_zone_pairs` | un couple zone de départ x zone d'arrivée | Localisation : trajets et zones les plus fréquents |

## 3. Grain de chaque table

| Couche | Table | Une ligne = | Clé |
|---|---|---|---|
| Bronze | `YELLOW_TRIPS_RAW` | une ligne du CSV du Projet 1 (= un trajet) | `row_id` |
| Silver | `stg_yellow_trips` | un trajet | `trip_id` |
| Silver | `int_trips_enriched` | un trajet | `trip_id` |
| Gold | `fct_trips` | un trajet | `trip_id` |
| Gold | `dim_date` | une date calendaire | `date_key` |
| Gold | `dim_time_of_day` | une heure de la journée | `hour_key` |
| Gold | `dim_location` | une zone TLC | `location_id` |
| Gold | `dim_payment_type` | un mode de paiement | `payment_type_id` |
| Gold | `dim_vendor` | un fournisseur | `vendor_id` |
| Gold | `dim_rate_code` | un code tarifaire | `rate_code_id` |
| Gold | `agg_trips_hourly` | une date x une heure | (`date_key`, `hour_key`) |
| Gold | `agg_zone_pairs` | un couple de zones | (`pickup_location_id`, `dropoff_location_id`) |

Chaque clé est protégée par un test `unique` + `not_null` (ou
`unique_combination_of_columns` pour les clés composées).
