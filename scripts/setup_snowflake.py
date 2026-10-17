"""
Étape 1 — Création de l'environnement Snowflake à partir des scripts SQL versionnés.

    python scripts/setup_snowflake.py                       # 01 -> 04
    python scripts/setup_snowflake.py --resource-monitor    # + 08 (ACCOUNTADMIN requis)

Crée : warehouse (XS, auto-suspend 60 s), database, schemas BRONZE/SILVER/GOLD,
file format CSV, stage interne et table Bronze. Idempotent (IF NOT EXISTS).
Ne démarre pas le warehouse : les instructions DDL n'en ont pas besoin.
"""
from __future__ import annotations

import argparse

from sf_common import SQL_DIR, connect, run_sql_file, sql_vars

SETUP_FILES = [
    "01_warehouse.sql",
    "02_database_schemas.sql",
    "03_file_format_stage.sql",
    "04_bronze_table.sql",
]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--resource-monitor", action="store_true",
                        help="exécute aussi 08_resource_monitor_optional.sql (rôle ACCOUNTADMIN requis)")
    args = parser.parse_args()

    variables = sql_vars()
    conn = connect()
    try:
        for name in SETUP_FILES:
            run_sql_file(conn, SQL_DIR / name, variables)
        if args.resource_monitor:
            run_sql_file(conn, SQL_DIR / "08_resource_monitor_optional.sql", variables)
    finally:
        conn.close()
    print("\nEnvironnement Snowflake prêt :", variables["database"], "/", variables["warehouse"])


if __name__ == "__main__":
    main()
