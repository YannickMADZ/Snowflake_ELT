# Preuves

Fichiers **générés automatiquement** (aucune saisie manuelle, aucun identifiant de compte) :

| Fichier | Produit par | Prouve |
|---|---|---|
| `01_ingestion.md` | `scripts/load_bronze.py` | PUT, COPY INTO, COPY_HISTORY, lignes CSV = stage = Bronze, 0 erreur, types |
| `02_dbt_build.md` | `scripts/collect_evidence.py` | statut de chaque seed, modèle et test du dernier `dbt build` |
| `03_analyses.md` | `scripts/collect_evidence.py` | résultats des requêtes de `analyses/` |
| `04_layers.md` | `scripts/collect_evidence.py` | lignes par objet Bronze / Silver / Gold |
| `05_lineage.md` | `scripts/collect_evidence.py` | graphe de lineage (Mermaid, rendu par GitHub) |
| `../dbt-docs/index.html` | `dbt docs generate --static` | documentation dbt complète, ouvrable hors ligne |

Captures d'écran à ajouter à la main (en masquant l'URL du compte Snowflake) :

- `lineage.png` : graphe de lineage dans `dbt docs serve` ;
- `snowsight_bronze.png` : (facultatif) table Bronze et son nombre de lignes dans Snowsight.
