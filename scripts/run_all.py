"""
Exécution complète et reproductible, dans l'ordre :

    python scripts/run_all.py                  # tout
    python scripts/run_all.py --skip-setup     # environnement déjà créé
    python scripts/run_all.py --skip-load      # Bronze déjà chargée

  1. setup_snowflake.py   warehouse, database, schemas, file format, stage, table Bronze
  2. load_bronze.py       PUT + COPY INTO + preuves de chargement
  3. dbt debug            vérifie la connexion dbt
  4. dbt build            seeds + modèles + tests, dans l'ordre du DAG
  5. collect_evidence.py  preuves (build, analyses, volumes, lineage, docs statiques)
"""
from __future__ import annotations

import argparse
import subprocess
import sys

from dbt_utils_local import dbt
from sf_common import ROOT


def step(script: str) -> None:
    print(f"\n========== {script} ==========")
    code = subprocess.call([sys.executable, str(ROOT / "scripts" / script)], cwd=ROOT)
    if code != 0:
        sys.exit(f"[ERREUR] {script} a échoué (code {code}).")


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--skip-setup", action="store_true")
    p.add_argument("--skip-load", action="store_true")
    a = p.parse_args()
    if not a.skip_setup:
        step("setup_snowflake.py")
    if not a.skip_load:
        step("load_bronze.py")
    dbt("debug")
    build_code = dbt("build", check=False)
    step("collect_evidence.py")
    sys.exit(build_code)


if __name__ == "__main__":
    main()
