-- =============================================================================
-- 04 — TABLE BRONZE
-- =============================================================================
-- Une colonne par colonne du CSV, DANS LE MÊME ORDRE et avec le type logique
-- produit par le Projet 1 (pandas) :
--     Int64 -> NUMBER(38,0)   float64 -> FLOAT   datetime64 -> TIMESTAMP_NTZ
--     bool  -> BOOLEAN        object  -> VARCHAR
-- Aucun renommage, aucun arrondi, aucune règle métier : ce sont les données
-- telles que reçues. Le typage sert ici de CONTRAT : si une valeur ne respecte
-- pas le type annoncé, le COPY INTO échoue entièrement (ON_ERROR = ABORT).
--
-- FLOAT (et non NUMBER(12,2)) pour les montants : c'est le type exact écrit par
-- pandas ; convertir en décimal à 2 chiffres serait déjà une transformation
-- (arrondi), faite en Silver par dbt.
--
-- Trois colonnes techniques sont ajoutées pour la traçabilité (lineage
-- ligne à ligne jusqu'au fichier) :
--     _source_file         nom du fichier dans le stage (METADATA$FILENAME)
--     _source_row_number   numéro de ligne dans ce fichier
--     _loaded_at           horodatage du chargement
--
-- TIMESTAMP_NTZ : les horodatages TLC sont en heure locale de New York sans
-- fuseau ; NTZ évite toute conversion implicite selon le fuseau de session.
--
-- Variables : <% database %>
-- =============================================================================

USE DATABASE <% database %>;

CREATE TABLE IF NOT EXISTS BRONZE.YELLOW_TRIPS_RAW (
    row_id                          VARCHAR        COMMENT 'Identifiant de ligne Socrata (:id), renommé par le Projet 1',
    vendorid                        NUMBER(38,0)   COMMENT 'Fournisseur du terminal (1 = CMT, 2 = Curb)',
    tpep_pickup_datetime            TIMESTAMP_NTZ  COMMENT 'Prise en charge, heure locale NY',
    tpep_dropoff_datetime           TIMESTAMP_NTZ  COMMENT 'Dépose, heure locale NY',
    passenger_count                 NUMBER(38,0)   COMMENT 'Nombre de passagers (saisi par le chauffeur)',
    trip_distance                   FLOAT          COMMENT 'Distance en miles (taximètre)',
    ratecodeid                      NUMBER(38,0)   COMMENT 'Code tarifaire final',
    store_and_fwd_flag              VARCHAR        COMMENT 'Y = trajet stocké puis transmis (pas de connexion)',
    pulocationid                    NUMBER(38,0)   COMMENT 'Zone TLC de prise en charge',
    dolocationid                    NUMBER(38,0)   COMMENT 'Zone TLC de dépose',
    payment_type                    NUMBER(38,0)   COMMENT 'Mode de paiement (code TLC)',
    fare_amount                     FLOAT          COMMENT 'Tarif temps + distance',
    extra                           FLOAT          COMMENT 'Suppléments divers',
    mta_tax                         FLOAT          COMMENT 'Taxe MTA',
    tip_amount                      FLOAT          COMMENT 'Pourboire (carte uniquement)',
    tolls_amount                    FLOAT          COMMENT 'Péages',
    improvement_surcharge           FLOAT          COMMENT 'Surcharge d''amélioration',
    total_amount                    FLOAT          COMMENT 'Montant total facturé',
    congestion_surcharge            FLOAT          COMMENT 'Surcharge de congestion NYS',
    airport_fee                     FLOAT          COMMENT 'Frais aéroport (LGA/JFK)',
    duration_min                    FLOAT          COMMENT 'Projet 1 : durée en minutes',
    speed_mph                       FLOAT          COMMENT 'Projet 1 : vitesse moyenne implicite',
    total_gap                       FLOAT          COMMENT 'Projet 1 : total_amount - somme des composantes',
    flag_missing_metadata           BOOLEAN        COMMENT 'Projet 1 : 5 colonnes de métadonnées manquantes ensemble',
    flag_extra_includes_surcharges  BOOLEAN        COMMENT 'Projet 1 : extra inclut déjà congestion + aéroport (vendor 1)',
    flag_total_mismatch_other       BOOLEAN        COMMENT 'Projet 1 : autre écart de total non expliqué',
    flag_negative_amount            BOOLEAN        COMMENT 'Projet 1 : total négatif (contre-passation)',
    flag_zero_distance              BOOLEAN        COMMENT 'Projet 1 : distance nulle',
    flag_zero_passenger             BOOLEAN        COMMENT 'Projet 1 : passenger_count = 0',
    flag_unknown_zone               BOOLEAN        COMMENT 'Projet 1 : zone 264/265 en départ ou arrivée',
    _source_file                    VARCHAR        COMMENT 'Technique : fichier du stage',
    _source_row_number              NUMBER(38,0)   COMMENT 'Technique : ligne dans le fichier',
    _loaded_at                      TIMESTAMP_LTZ  DEFAULT CURRENT_TIMESTAMP() COMMENT 'Technique : date de chargement'
)
COMMENT = 'Bronze : CSV nettoyé du Projet 1 (NYC Yellow Taxi 2023-01), chargé tel quel par PUT + COPY INTO';
