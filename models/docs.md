{% docs __overview__ %}
# NYC Yellow Taxi — Data Warehouse (Projet 2)

Entrepôt construit à partir du **CSV nettoyé du Projet 1** (janvier 2023), selon
une architecture **Medallion** :

| Couche | Schema | Construit par | Contenu |
|---|---|---|---|
| Bronze | `BRONZE` | `PUT` + `COPY INTO` (scripts SQL) | `YELLOW_TRIPS_RAW`, le CSV tel quel |
| Silver | `SILVER` | dbt (staging, intermediate, seeds) | données typées, règles métier, référentiels |
| Gold | `GOLD` | dbt (marts) | étoile `fct_trips` + 6 dimensions + 2 agrégats |

**Remonter d'une métrique au CSV** : ouvrir le graphe de lineage (icône en bas à
droite), partir de `agg_trips_hourly.revenue_total` :
`agg_trips_hourly` ← `fct_trips` ← `int_trips_enriched` ← `stg_yellow_trips` ←
`source(bronze.yellow_trips_raw)` ← `_source_file` / `_source_row_number` (ligne
exacte du CSV chargé).
{% enddocs %}

{% docs fct_trips %}
**Table de faits centrale du schéma en étoile.**

- **Grain : un trajet de taxi jaune** (une ligne = une course facturée), le
  niveau le plus fin disponible. Toutes les questions analytiques s'obtiennent
  par agrégation ; aucun grain plus grossier ne permettrait d'étudier les
  distributions (trajets anormalement longs, durée selon la distance).
- **Clé primaire** : `trip_id`.
- **Clés étrangères** : `date_key` → dim_date, `hour_key` → dim_time_of_day,
  `pickup_location_id` / `dropoff_location_id` → dim_location (rôles),
  `payment_type_id` → dim_payment_type, `vendor_id` → dim_vendor,
  `rate_code_id` → dim_rate_code.
- **Aucune ligne n'est supprimée** entre la Bronze et ce fait (test
  `assert_fct_trips_reconciles_with_bronze`). Les anomalies sont des
  **indicateurs d'éligibilité** (`is_*_analyzable`) : chaque analyse exclut
  seulement ce qui la fausse.
{% enddocs %}

{% docs rule_revenue %}
**Règle métier — recette analysable.** Vrai si le trajet n'est pas une
contre-passation (`total_amount >= 0`) ET si son mode de paiement correspond à
une recette (Flex Fare, carte, espèces). Faux pour « sans frais », « litige »,
« inconnu », « annulé ». Toute métrique de revenu doit filtrer sur cette colonne,
sinon les annulations (montants négatifs) viennent diminuer le chiffre d'affaires.
{% enddocs %}

{% docs metric_revenue_total %}
**Métrique — revenu total ($).** `sum(total_amount)` sur les trajets
`is_revenue_analyzable`. Chemin : CSV Projet 1 (`total_amount`) → Bronze
`YELLOW_TRIPS_RAW.total_amount` (FLOAT) → `stg_yellow_trips.total_amount`
(NUMBER(12,2) via macro `to_money`) → `int_trips_enriched.is_revenue_analyzable`
→ `fct_trips` → `agg_trips_hourly.revenue_total`.
{% enddocs %}
