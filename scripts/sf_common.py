"""
Outils partagés par les scripts Snowflake du projet.

- Lecture de la configuration dans les VARIABLES D'ENVIRONNEMENT (chargées
  depuis .env s'il existe). Aucun identifiant n'est écrit dans le code.
- Connexion par mot de passe OU par paire de clés (recommandé : Snowflake
  impose désormais la MFA aux connexions par mot de passe sur beaucoup de
  comptes, la paire de clés évite ce blocage pour les scripts).
- Rendu des scripts SQL de sql/snowflake/ : les variables <% nom %> sont
  remplacées par leur valeur (même syntaxe que Snowflake CLI, donc les mêmes
  fichiers s'exécutent aussi avec `snow sql -f ... -D nom=valeur`).
"""
from __future__ import annotations

import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SQL_DIR = ROOT / "sql" / "snowflake"
EVIDENCE_DIR = ROOT / "docs" / "evidence"

try:  # python-dotenv est optionnel : sans lui, on lit l'environnement tel quel.
    from dotenv import load_dotenv

    load_dotenv(ROOT / ".env")
except ImportError:  # pragma: no cover
    pass


def env(name: str, default: str | None = None, required: bool = True) -> str | None:
    """Lit une variable d'environnement ; arrête le script si elle manque."""
    value = os.environ.get(name, default)
    if required and not value:
        sys.exit(f"[ERREUR] Variable d'environnement manquante : {name} (voir .env.example)")
    return value


def sql_vars(**extra: str) -> dict[str, str]:
    """Variables disponibles dans les scripts SQL."""
    values = {
        "warehouse": env("SNOWFLAKE_WAREHOUSE", "NYC_TAXI_WH"),
        "database": env("SNOWFLAKE_DATABASE", "NYC_TAXI_DB"),
    }
    values.update(extra)
    return values


def connect():
    """Ouvre une connexion Snowflake à partir des variables d'environnement."""
    import snowflake.connector  # import tardif : message clair si absent

    params = {
        "account": env("SNOWFLAKE_ACCOUNT"),
        "user": env("SNOWFLAKE_USER"),
        "role": env("SNOWFLAKE_ROLE", "SYSADMIN"),
        "session_parameters": {"QUERY_TAG": "nyc_taxi_dw_scripts"},
        "client_session_keep_alive": False,
    }
    key_path = os.environ.get("SNOWFLAKE_PRIVATE_KEY_PATH")
    if key_path:
        params["private_key_file"] = key_path
        if os.environ.get("SNOWFLAKE_PRIVATE_KEY_PASSPHRASE"):
            params["private_key_file_pwd"] = os.environ["SNOWFLAKE_PRIVATE_KEY_PASSPHRASE"]
    else:
        params["password"] = env("SNOWFLAKE_PASSWORD")
        if os.environ.get("SNOWFLAKE_AUTHENTICATOR"):
            params["authenticator"] = os.environ["SNOWFLAKE_AUTHENTICATOR"]
        if os.environ.get("SNOWFLAKE_MFA_PASSCODE"):
            params["passcode"] = os.environ["SNOWFLAKE_MFA_PASSCODE"]
    return snowflake.connector.connect(**params)


_VAR = re.compile(r"<%\s*([A-Za-z_][A-Za-z0-9_.]*)\s*%>")


def render_sql(path: Path, variables: dict[str, str]) -> str:
    """Remplace les <% nom %> ; refuse d'exécuter un script incomplet."""
    text = path.read_text(encoding="utf-8")
    missing = sorted({m for m in _VAR.findall(text) if m not in variables})
    if missing:
        sys.exit(f"[ERREUR] {path.name} : variables non fournies {missing}")
    return _VAR.sub(lambda m: str(variables[m.group(1)]), text)


def run_sql_file(conn, path: Path, variables: dict[str, str], verbose: bool = True):
    """
    Exécute toutes les instructions d'un fichier SQL.
    Renvoie une liste de (instruction, colonnes, lignes) pour chaque instruction.
    """
    if verbose:
        print(f"--> {path.relative_to(ROOT)}")
    results = []
    for cur in conn.execute_string(render_sql(path, variables), remove_comments=True):
        cols = [d[0] for d in cur.description] if cur.description else []
        rows = cur.fetchall() if cur.description else []
        first_line = (cur.query or "").strip().splitlines()[0][:90] if cur.query else ""
        if verbose:
            print(f"    ok  {first_line}")
        results.append((cur.query, cols, rows))
    return results


def query(conn, sql: str):
    cur = conn.cursor()
    try:
        cur.execute(sql)
        cols = [d[0] for d in cur.description] if cur.description else []
        return cols, cur.fetchall()
    finally:
        cur.close()


def suspend_warehouse(conn, warehouse: str) -> None:
    """Suspend le warehouse s'il tourne (ALTER ... SUSPEND échoue s'il est déjà arrêté)."""
    cols, rows = query(conn, f"SHOW WAREHOUSES LIKE '{warehouse}'")
    if not rows:
        return
    state = rows[0][cols.index("state")]
    if state in ("STARTED", "RESUMING"):
        query(conn, f"ALTER WAREHOUSE {warehouse} SUSPEND")
        print(f"Warehouse {warehouse} suspendu (fin de facturation immédiate).")
    else:
        print(f"Warehouse {warehouse} déjà {state}.")


def md_table(cols, rows, max_rows: int = 50) -> str:
    """Convertit un résultat de requête en tableau Markdown."""
    if not cols:
        return "_(aucun résultat)_\n"
    out = ["| " + " | ".join(str(c) for c in cols) + " |",
           "|" + "---|" * len(cols)]
    for r in rows[:max_rows]:
        out.append("| " + " | ".join("" if v is None else str(v).replace("|", "\\|") for v in r) + " |")
    if len(rows) > max_rows:
        out.append(f"\n_… {len(rows) - max_rows} lignes supplémentaires non affichées_")
    return "\n".join(out) + "\n"


def now_utc() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
