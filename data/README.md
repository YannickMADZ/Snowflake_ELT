# data/ — emplacement du CSV du Projet 1 (non versionné)

Copier ici les deux fichiers produits par le Projet 1 :

| Fichier | Origine (Projet 1) | Obligatoire |
|---|---|---|
| `trips_clean.csv` | `data/processed/2023-01/trips_clean.csv` | oui |
| `transform_summary.json` | `reports/2023-01/transform_summary.json` | non (sert à comparer `rows_out`) |

PowerShell, depuis la racine de ce dépôt (adapter le chemin du Projet 1) :

```powershell
Copy-Item ..\nyc-taxi-pipeline\data\processed\2023-01\trips_clean.csv data\
Copy-Item ..\nyc-taxi-pipeline\reports\2023-01\transform_summary.json data\
```

Le `.gitignore` exclut tout ce dossier sauf ce README : le CSV (plusieurs
centaines de Mo) ne doit pas entrer dans Git. Un autre emplacement est possible
via `P1_CSV_PATH` dans `.env`.
