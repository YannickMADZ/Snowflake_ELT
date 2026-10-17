"""
Étape 2 — Ingestion : CSV du Projet 1 -> PUT -> stage -> COPY INTO -> Bronze,
puis PREUVE que le chargement est complet.

    python scripts/load_bronze.py
    python scripts/load_bronze.py --csv C:/.../trips_clean.csv --p1-report C:/.../transform_summary.json

Déroulé :
  1. Contrôles AVANT d'envoyer quoi que ce soit (coût nul) :
     - le fichier existe ;
     - son en-tête est exactement celui attendu (30 colonnes, même ordre que la
       table Bronze) : le COPY charge par position, un ordre différent
       décalerait les colonnes ;
     - comptage local des lignes (lecteur CSV, en-tête exclu) ;
     - si le rapport du Projet 1 est fourni : rows_out == lignes du CSV.
  2. sql/snowflake/05_load_bronze.sql : PUT, TRUNCATE, COPY INTO.
  3. sql/snowflake/06_check_load.sql : COPY_HISTORY, lignes du fichier en stage,
     lignes Bronze, unicité de row_id, types, valeurs manquantes.
  4. Comparaison de tous les comptages ; écriture de docs/evidence/01_ingestion.md ;
     code de sortie 1 si un contrôle échoue.
  5. Suspension du warehouse.
"""
from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path

from sf_common import (EVIDENCE_DIR, ROOT, SQL_DIR, connect, env, md_table, now_utc,
                       run_sql_file, sql_vars, suspend_warehouse)

# Ordre fixé par output.column_order du Projet 1 (config.yaml), suivi des 7
# indicateurs flag_* ajoutés par transform.py.
EXPECTED_COLUMNS = [
    "row_id", "vendorid", "tpep_pickup_datetime", "tpep_dropoff_datetime",
    "passenger_count", "trip_distance", "ratecodeid", "store_and_fwd_flag",
    "pulocationid", "dolocationid", "payment_type", "fare_amount", "extra",
    "mta_tax", "tip_amount", "tolls_amount", "improvement_surcharge",
    "total_amount", "congestion_surcharge", "airport_fee", "duration_min",
    "speed_mph", "total_gap", "flag_missing_metadata",
    "flag_extra_includes_surcharges", "flag_total_mismatch_other",
    "flag_negative_amount", "flag_zero_distance", "flag_zero_passenger",
    "flag_unknown_zone",
]

EXPECTED_TYPES = {  # type Snowflake attendu (INFORMATION_SCHEMA.COLUMNS.DATA_TYPE)
    "ROW_ID": "TEXT", "STORE_AND_FWD_FLAG": "TEXT", "_SOURCE_FILE": "TEXT",
    "TPEP_PICKUP_DATETIME": "TIMESTAMP_NTZ", "TPEP_DROPOFF_DATETIME": "TIMESTAMP_NTZ",
    "_LOADED_AT": "TIMESTAMP_LTZ", "_SOURCE_ROW_NUMBER": "NUMBER",
    **{c.upper(): "NUMBER" for c in ["vendorid", "passenger_count", "ratecodeid",
                                     "pulocationid", "dolocationid", "payment_type"]},
    **{c.upper(): "FLOAT" for c in ["trip_distance", "fare_amount", "extra", "mta_tax",
                                    "tip_amount", "tolls_amount", "improvement_surcharge",
                                    "total_amount", "congestion_surcharge", "airport_fee",
                                    "duration_min", "speed_mph", "total_gap"]},
    **{c.upper(): "BOOLEAN" for c in EXPECTED_COLUMNS if c.startswith("flag_")},
}


def check_csv(csv_path: Path) -> int:
    """Vérifie l'en-tête et renvoie le nombre de lignes de données."""
    if not csv_path.is_file():
        sys.exit(f"[ERREUR] CSV introuvable : {csv_path}\n"
                 "Copie le CSV nettoyé du Projet 1 dans data/ ou renseigne P1_CSV_PATH dans .env")
    with csv_path.open(newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = [h.strip() for h in next(reader)]
        if header != EXPECTED_COLUMNS:
            missing = [c for c in EXPECTED_COLUMNS if c not in header]
            extra = [c for c in header if c not in EXPECTED_COLUMNS]
            sys.exit("[ERREUR] En-tête inattendu : le COPY chargeant par position, il décalerait les colonnes.\n"
                     f"  manquantes : {missing}\n  en trop : {extra}\n  reçu : {header}")
        print(f"En-tête conforme ({len(header)} colonnes). Comptage des lignes...")
        n = sum(1 for _ in reader)
    print(f"Lignes de données dans le CSV local : {n:,}".replace(",", " "))
    return n


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--csv", default=env("P1_CSV_PATH", "data/trips_clean.csv"))
    parser.add_argument("--p1-report", default=env("P1_TRANSFORM_SUMMARY", "", required=False),
                        help="transform_summary.json du Projet 1 (optionnel)")
    args = parser.parse_args()

    csv_path = Path(args.csv)
    if not csv_path.is_absolute():
        csv_path = (ROOT / csv_path).resolve()
    local_rows = check_csv(csv_path)

    p1_rows = None
    if args.p1_report:
        report = Path(args.p1_report)
        report = report if report.is_absolute() else ROOT / report
        if report.is_file():
            p1_rows = int(json.loads(report.read_text(encoding="utf-8"))["rows_out"])
            print(f"rows_out annoncé par le Projet 1 : {p1_rows:,}".replace(",", " "))
        else:
            print(f"[AVERTISSEMENT] Rapport du Projet 1 introuvable ({report.name}) : "
                  "comparaison avec rows_out ignorée.")

    variables = sql_vars(csv_path=csv_path.as_posix())
    conn = connect()
    try:
        load = run_sql_file(conn, SQL_DIR / "05_load_bronze.sql", variables)
        copy_cols, copy_rows = load[-1][1], load[-1][2]
        put_cols, put_rows = next((c, r) for q, c, r in load if q.strip().upper().startswith("PUT"))
        checks = run_sql_file(conn, SQL_DIR / "06_check_load.sql", variables)
        # checks[0..1] = USE ..., puis les 5 requêtes dans l'ordre du fichier.
        (_, hist_cols, hist_rows), (_, stg_cols, stg_rows), (_, cnt_cols, cnt_rows), \
            (_, typ_cols, typ_rows), (_, null_cols, null_rows) = checks[-5:]
        suspend_warehouse(conn, variables["warehouse"])
    finally:
        conn.close()

    # ------------------------------------------------------------------ verdict
    rec = dict(zip(cnt_cols, cnt_rows[0]))
    copy = [dict(zip([c.lower() for c in copy_cols], r)) for r in copy_rows]
    rows_loaded = sum(int(r.get("rows_loaded") or 0) for r in copy)
    errors_seen = sum(int(r.get("errors_seen") or 0) for r in copy)
    staged = int(stg_rows[0][0])
    types = {r[0]: r[1] for r in typ_rows}
    bad_types = {c: (types.get(c), t) for c, t in EXPECTED_TYPES.items() if types.get(c) != t}

    checks_out = [
        ("COPY sans erreur (errors_seen = 0)", errors_seen == 0, f"errors_seen = {errors_seen}"),
        ("Un seul fichier chargé", rec["FILES_LOADED"] == 1, f"{rec['FILES_LOADED']} fichier(s)"),
        ("Lignes CSV local = lignes du fichier en stage", local_rows == staged, f"{local_rows} vs {staged}"),
        ("Lignes CSV local = lignes chargées par COPY", local_rows == rows_loaded, f"{local_rows} vs {rows_loaded}"),
        ("Lignes CSV local = lignes Bronze", local_rows == rec["ROWS_IN_BRONZE"], f"{local_rows} vs {rec['ROWS_IN_BRONZE']}"),
        ("row_id unique dans Bronze", rec["DISTINCT_ROW_IDS"] == rec["ROWS_IN_BRONZE"],
         f"{rec['DISTINCT_ROW_IDS']} distincts / {rec['ROWS_IN_BRONZE']}"),
        ("Types Snowflake = types attendus", not bad_types, "conformes" if not bad_types else f"écarts (réel, attendu) : {bad_types}"),
    ]
    if p1_rows is not None:
        checks_out.insert(2, ("rows_out du rapport Projet 1 = lignes CSV", p1_rows == local_rows, f"{p1_rows} vs {local_rows}"))
    ok = all(c[1] for c in checks_out)

    EVIDENCE_DIR.mkdir(parents=True, exist_ok=True)
    md = [
        "# Preuve d'ingestion — CSV Projet 1 → PUT → stage → COPY INTO → BRONZE\n",
        f"_Généré automatiquement par `scripts/load_bronze.py` le {now_utc()}._ "
        "Aucun identifiant de compte n'apparaît dans ce fichier.\n",
        f"## Verdict : {'✅ CHARGEMENT COMPLET' if ok else '❌ ÉCHEC'}\n",
        md_table(["Contrôle", "Résultat", "Détail"],
                 [(n, "✅" if s else "❌", d) for n, s, d in checks_out]),
        "\n## Fichier source (contrôles locaux avant envoi)\n",
        f"- Fichier : `{csv_path.name}`\n- En-tête : {len(EXPECTED_COLUMNS)} colonnes, ordre conforme\n"
        f"- Lignes de données : **{local_rows}**\n"
        + (f"- `rows_out` du rapport qualité du Projet 1 : **{p1_rows}**\n" if p1_rows is not None else ""),
        "\n## Résultat du PUT\n", md_table(put_cols, put_rows),
        "\n## Résultat du COPY INTO (par fichier)\n", md_table(copy_cols, copy_rows),
        "\n## COPY_HISTORY (24 dernières heures)\n", md_table(hist_cols, hist_rows),
        "\n## Lignes lues directement dans le fichier du stage\n", md_table(stg_cols, stg_rows),
        "\n## Table Bronze\n", md_table(cnt_cols, cnt_rows),
        "\n## Valeurs manquantes (à comparer au rapport qualité du Projet 1)\n", md_table(null_cols, null_rows),
        "\n## Types des colonnes Bronze (INFORMATION_SCHEMA.COLUMNS)\n", md_table(typ_cols, typ_rows, max_rows=40),
    ]
    out = EVIDENCE_DIR / "01_ingestion.md"
    out.write_text("\n".join(md), encoding="utf-8")
    print(f"\nPreuve écrite : {out.relative_to(ROOT)}")
    for name, status, detail in checks_out:
        print(f"  [{'OK' if status else 'KO'}] {name} — {detail}")
    if not ok:
        sys.exit(1)


if __name__ == "__main__":
    main()
