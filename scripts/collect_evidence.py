"""
Étape 4 — Preuves : à lancer APRÈS `dbt build`.

    python scripts/collect_evidence.py

Écrit dans docs/evidence/ (sans aucun identifiant de compte) :
  02_dbt_build.md   résultat de chaque modèle / seed / test du dernier dbt build
  03_analyses.md    résultat des requêtes de analyses/ (compilées par dbt)
  04_layers.md      nombre de lignes par objet Bronze / Silver / Gold
  05_lineage.md     graphe de lineage (Mermaid, lisible directement sur GitHub)
et copie la documentation dbt statique dans docs/dbt-docs/index.html.
Suspend le warehouse à la fin.
"""
from __future__ import annotations

import json
import shutil
import sys
from collections import Counter

from dbt_utils_local import dbt
from sf_common import (EVIDENCE_DIR, ROOT, connect, md_table, now_utc, query, sql_vars,
                       suspend_warehouse)

TARGET = ROOT / "target"
PROJECT = "nyc_taxi_dw"


def build_results() -> bool:
    path = TARGET / "run_results.json"
    if not path.exists():
        sys.exit("[ERREUR] target/run_results.json absent : lance d'abord `dbt build`.")
    rr = json.loads(path.read_text(encoding="utf-8"))
    command = rr.get("args", {}).get("which")
    if command != "build":
        sys.exit(f"[ERREUR] Le dernier run_results.json vient de `dbt {command}`, pas de `dbt build`. Relance dbt build.")
    rows, counter = [], Counter()
    for r in rr["results"]:
        uid = r["unique_id"]
        rtype = uid.split(".")[0]
        counter[(rtype, r["status"])] += 1
        rows.append((rtype, uid.split(".")[-1] if rtype != "test" else uid.split(".")[2],
                     r["status"], r.get("failures") if rtype == "test" else "",
                     round(r.get("execution_time") or 0, 1)))
    rows.sort(key=lambda x: (x[0], x[1]))
    failed = [r for r in rows if r[2] in ("error", "fail")]
    md = [
        "# Preuve — dbt build\n",
        f"_Généré par `scripts/collect_evidence.py` le {now_utc()} à partir de `target/run_results.json` "
        f"(dbt {rr['metadata'].get('dbt_version')}, durée totale {round(rr.get('elapsed_time', 0), 1)} s)._\n",
        f"## Verdict : {'✅ dbt build sans erreur' if not failed else '❌ ' + str(len(failed)) + ' échec(s)'}\n",
        "## Synthèse par type de ressource\n",
        md_table(["type", "statut", "nombre"], [(t, s, n) for (t, s), n in sorted(counter.items())]),
        "\n`warn` = anomalie documentée (test en sévérité warn, n'interrompt pas le build) ; "
        "`fail`/`error` = règle bloquante violée.\n",
        "\n## Détail\n",
        md_table(["type", "nom", "statut", "lignes en défaut (tests)", "durée (s)"], rows, max_rows=500),
    ]
    (EVIDENCE_DIR / "02_dbt_build.md").write_text("\n".join(md), encoding="utf-8")
    print("Preuve écrite : docs/evidence/02_dbt_build.md")
    return not failed


def lineage() -> None:
    manifest = json.loads((TARGET / "manifest.json").read_text(encoding="utf-8"))
    nodes = {**manifest["nodes"], **manifest["sources"], **manifest.get("exposures", {})}
    keep = lambda uid: uid.split(".")[0] in ("model", "source", "seed", "exposure")
    label = lambda uid: (f"source: {nodes[uid]['source_name']}.{nodes[uid]['name']}"
                         if uid.startswith("source.") else uid.split(".")[-1])
    ids = {uid: f"n{i}" for i, uid in enumerate(sorted(u for u in nodes if keep(u)))}
    lines = ["flowchart LR", '  csv[["CSV Projet 1<br/>trips_clean.csv"]] -->|PUT + COPY INTO| ' +
             next(ids[u] for u in ids if u.startswith("source."))]
    for uid, nid in ids.items():
        shape = ('[("' + label(uid) + '")]') if uid.startswith("source.") else \
                ('{{"' + label(uid) + '"}}') if uid.startswith("exposure.") else \
                ('(["' + label(uid) + '"])') if uid.startswith("seed.") else ('["' + label(uid) + '"]')
        lines.append(f"  {nid}{shape}")
    for uid, nid in ids.items():
        for parent in nodes[uid].get("depends_on", {}).get("nodes", []):
            if parent in ids:
                lines.append(f"  {ids[parent]} --> {nid}")
    md = ["# Preuve — lineage dbt\n",
          f"_Généré depuis `target/manifest.json` le {now_utc()}. Même graphe que dans `dbt docs serve` "
          "(icône lineage en bas à droite) ; capture conseillée : `docs/evidence/lineage.png`._\n",
          "```mermaid", *lines, "```\n"]
    (EVIDENCE_DIR / "05_lineage.md").write_text("\n".join(md), encoding="utf-8")
    print("Preuve écrite : docs/evidence/05_lineage.md")


def main() -> None:
    EVIDENCE_DIR.mkdir(parents=True, exist_ok=True)
    build_ok = build_results()  # À lire AVANT toute autre commande dbt (qui écraserait run_results.json).

    # Compile les analyses (résolution des ref()) puis génère la doc statique.
    dbt("compile", "--select", "path:analyses")
    dbt("docs", "generate", "--static")

    variables = sql_vars()
    db = variables["database"]
    conn = connect()
    try:
        query(conn, f"USE WAREHOUSE {variables['warehouse']}")
        query(conn, f"USE DATABASE {db}")

        # ---- analyses
        md = ["# Résultats des analyses (`analyses/`)\n",
              f"_Requêtes compilées par dbt et exécutées par `scripts/collect_evidence.py` le {now_utc()}. "
              "L'interprétation est dans le README (section Analyses)._\n"]
        compiled = sorted((TARGET / "compiled" / PROJECT / "analyses").glob("*.sql"))
        for f in compiled:
            cols, rows = query(conn, f.read_text(encoding="utf-8"))
            md += [f"\n## {f.stem}\n", md_table(cols, rows)]
        (EVIDENCE_DIR / "03_analyses.md").write_text("\n".join(md), encoding="utf-8")
        print("Preuve écrite : docs/evidence/03_analyses.md")

        # ---- volumes par couche
        _, objs = query(conn, f"""
            select table_schema, table_name, table_type, row_count
            from {db}.information_schema.tables
            where table_schema in ('BRONZE', 'SILVER', 'GOLD')
            order by case table_schema when 'BRONZE' then 1 when 'SILVER' then 2 else 3 end, table_name""")
        rows = []
        for schema, name, ttype, n in objs:
            if n is None:  # vue : pas de compteur en métadonnées
                n = query(conn, f"select count(*) from {db}.{schema}.{name}")[1][0][0]
            rows.append((schema, name, "VIEW" if ttype == "VIEW" else "TABLE", n))
        md = ["# Preuve — volumes par couche Medallion\n",
              f"_Généré le {now_utc()} depuis INFORMATION_SCHEMA. Bronze, staging, intermediate et "
              "fct_trips doivent avoir le même nombre de lignes (aucun trajet perdu ni dupliqué)._\n",
              md_table(["schema", "objet", "type", "lignes"], rows, max_rows=100)]
        (EVIDENCE_DIR / "04_layers.md").write_text("\n".join(md), encoding="utf-8")
        print("Preuve écrite : docs/evidence/04_layers.md")
        suspend_warehouse(conn, variables["warehouse"])
    finally:
        conn.close()

    lineage()
    static = TARGET / "static_index.html"
    if static.exists():
        (ROOT / "docs" / "dbt-docs").mkdir(parents=True, exist_ok=True)
        shutil.copy(static, ROOT / "docs" / "dbt-docs" / "index.html")
        print("Documentation dbt statique copiée : docs/dbt-docs/index.html")
    if not build_ok:
        sys.exit(1)


if __name__ == "__main__":
    main()
