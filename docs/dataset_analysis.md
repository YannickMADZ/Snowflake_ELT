# Analyse du dataset avant modélisation

Analyse du **CSV nettoyé produit par le Projet 1** (NYC TLC Yellow Taxi, janvier
2023, API Socrata `4b4i-vvec`). Le Projet 1 a extrait 3 066 726 lignes, appliqué
5 règles de suppression et ajouté 3 colonnes dérivées et 7 indicateurs d'anomalie.
Les volumes exacts du fichier livré figurent dans `docs/evidence/01_ingestion.md`.

## 1. Colonnes et type logique

| # | Colonne | Type logique | Type Bronze | Famille | Rôle |
|---|---|---|---|---|---|
| 1 | `row_id` | identifiant texte | VARCHAR | identifiant | clé du trajet |
| 2 | `vendorid` | code catégoriel | NUMBER | fournisseur | attribut descriptif |
| 3 | `tpep_pickup_datetime` | horodatage local NY | TIMESTAMP_NTZ | temps | attribut (dates, heures) |
| 4 | `tpep_dropoff_datetime` | horodatage local NY | TIMESTAMP_NTZ | temps | attribut + calcul de durée |
| 5 | `passenger_count` | entier | NUMBER | trajet | mesure |
| 6 | `trip_distance` | décimal (miles) | FLOAT | distance | mesure |
| 7 | `ratecodeid` | code catégoriel | NUMBER | tarif | attribut descriptif |
| 8 | `store_and_fwd_flag` | booléen codé Y/N | VARCHAR | technique | attribut descriptif |
| 9 | `pulocationid` | code de zone | NUMBER | localisation | attribut (départ) |
| 10 | `dolocationid` | code de zone | NUMBER | localisation | attribut (arrivée) |
| 11 | `payment_type` | code catégoriel | NUMBER | paiement | attribut descriptif |
| 12-20 | `fare_amount`, `extra`, `mta_tax`, `tip_amount`, `tolls_amount`, `improvement_surcharge`, `total_amount`, `congestion_surcharge`, `airport_fee` | montant ($) | FLOAT | montants | mesures |
| 21 | `duration_min` | décimal (minutes) | FLOAT | durée | mesure (dérivée P1) |
| 22 | `speed_mph` | décimal | FLOAT | durée/distance | mesure non additive (dérivée P1) |
| 23 | `total_gap` | décimal ($) | FLOAT | contrôle | qualité (dérivée P1) |
| 24-30 | `flag_*` (7) | booléen | BOOLEAN | qualité | indicateurs d'anomalie |

## 2. Identifiant d'un trajet

Le dictionnaire TLC ne fournit **aucun identifiant de trajet**. Le Projet 1 a
demandé à l'API l'identifiant interne Socrata `:id`, renommé `row_id`.

**Peut-on le considérer comme unique ?** Oui, avec des preuves et une limite :

- le Projet 1 a validé l'absence de doublon de `row_id` dans le CSV (contrôle 4 de
  `validate.py`) ;
- le Projet 2 le revérifie **après ingestion** (`source_unique_..._row_id`,
  `unique_fct_trips_trip_id`) : un COPY rejoué sans `TRUNCATE` ou un fichier chargé
  deux fois serait détecté ;
- **limite** : c'est un identifiant technique de la plateforme Socrata, pas un
  identifiant métier. Il est stable pour une version publiée du jeu de données mais
  rien ne garantit qu'une republication par la TLC le conserve. Une clé naturelle
  composite (`vendorid`, horodatages, zones, montant) a été écartée : deux courses
  du même terminal peuvent légitimement partager ces valeurs à la seconde près, ce
  qui la rendrait non unique.

## 3. Familles de colonnes

| Famille | Colonnes |
|---|---|
| Temps | `tpep_pickup_datetime`, `tpep_dropoff_datetime` (+ `duration_min`) |
| Localisation | `pulocationid`, `dolocationid` (codes de zones TLC 1-265) |
| Paiement | `payment_type`, `tip_amount` |
| Montants | `fare_amount`, `extra`, `mta_tax`, `tip_amount`, `tolls_amount`, `improvement_surcharge`, `congestion_surcharge`, `airport_fee`, `total_amount` |
| Distance | `trip_distance` |
| Durée | `duration_min`, `speed_mph` (dérivées) |
| Fournisseur | `vendorid` |
| Qualité | `total_gap`, `flag_*` |

## 4. Attributs descriptifs vs colonnes de mesure

- **Attributs descriptifs** (deviennent des clés vers des dimensions ou des
  attributs dégénérés) : `vendorid`, `ratecodeid`, `payment_type`, `pulocationid`,
  `dolocationid`, `store_and_fwd_flag`, les dates et heures tirées des horodatages.
- **Mesures additives** (somme pertinente) : montants, `trip_distance`,
  `duration_min`, `passenger_count`.
- **Mesures non additives** (à moyenner, jamais à sommer) : `speed_mph`, le
  pourboire en % du tarif.

## 5. Colonnes conservées en Bronze même si Gold ne les utilise pas

**Toutes.** La Bronze est la copie fidèle du livrable du Projet 1 : on doit pouvoir
reconstruire Silver et Gold, ou répondre à une question d'audit, sans revenir au
fichier. En particulier :

- `total_gap` : Gold utilise `total_amount`, mais l'écart du Projet 1 sert à
  vérifier que l'ingestion n'a altéré aucun montant (`stg_trips_total_gap_matches_p1`) ;
- `store_and_fwd_flag` : sans usage analytique, utile pour diagnostiquer des
  horodatages transmis en différé ;
- les 7 `flag_*` : trace de la décision du Projet 1 (conserver et marquer) ;
- colonnes techniques `_source_file`, `_source_row_number`, `_loaded_at` : lineage
  ligne à ligne jusqu'au fichier chargé.

## 6. Anomalies du Projet 1 à contrôler à nouveau dans Snowflake

| Garantie / anomalie du Projet 1 | Contrôle dans le Projet 2 | Sévérité | Pourquoi |
|---|---|---|---|
| Nombre de lignes du CSV | `load_bronze.py` : CSV = stage = COPY = Bronze ; test `assert_fct_trips_reconciles_with_bronze` | bloquant | une ligne perdue fausse tous les comptages |
| `row_id` unique | `unique` sur la source et sur `fct_trips` | bloquant | grain du fait |
| Prises en charge dans un seul mois | `stg_trips_single_month` | bloquant | règle `pickup_hors_du_mois` |
| 0 < durée ≤ 180 min | `stg_trips_duration_within_p1_rules` | bloquant | règles `duree_*` |
| Vitesse ≤ 80 mph | `stg_trips_speed_within_p1_rules` | bloquant | règle de vitesse |
| Horodatages intacts après chargement | `stg_trips_duration_survived_ingestion` (durée recalculée = durée P1) | bloquant | détecte un décalage de fuseau ou de format au COPY |
| Indicateurs cohérents avec les valeurs | `stg_trips_flags_*_consistent` (4 tests) | bloquant | prouve que les booléens et les nombres ont été lus correctement |
| `extra` inclut les surcharges (vendor 1, ~27 % des lignes) | `int_trips_extra_net_explains_total` | bloquant | prouve que la correction `extra_net` résout exactement l'anomalie |
| Écart de total recalculé = écart P1 | `stg_trips_total_gap_matches_p1` | avertissement | dépend de la façon dont le P1 a traité les NULL |
| 5 métadonnées manquantes ensemble (payment_type 0) | `assert_missing_metadata_is_all_or_nothing` | avertissement | constat qui justifie la non-imputation |
| `passenger_count` > 6, pourboire > 100 % | `stg_trips_passenger_count_plausible`, `int_trips_tip_pct_plausible` | avertissement | saisies douteuses mais transactions réelles |
| Montants négatifs, distance nulle, zones inconnues | non bloquant : `is_*_analyzable` dans le fait | documenté | chaque analyse exclut ce qui la fausse |
