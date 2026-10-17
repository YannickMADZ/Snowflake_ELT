"""Lancement de dbt en sous-processus, avec le projet et le profil du dépôt."""
from __future__ import annotations

import shutil
import subprocess
import sys

from sf_common import ROOT


def ensure_profile() -> None:
    """Crée profiles.yml depuis le modèle s'il n'existe pas (il ne contient que des env_var)."""
    target = ROOT / "profiles.yml"
    if not target.exists():
        shutil.copy(ROOT / "profiles.example.yml", target)
        print("profiles.yml créé à partir de profiles.example.yml (ignoré par Git).")


def dbt(*args: str, check: bool = True) -> int:
    ensure_profile()
    exe = shutil.which("dbt")
    cmd = [exe] if exe else [sys.executable, "-m", "dbt.cli.main"]
    cmd += list(args) + ["--project-dir", str(ROOT), "--profiles-dir", str(ROOT)]
    print("\n$ dbt " + " ".join(args))
    code = subprocess.call(cmd, cwd=ROOT)
    if check and code != 0:
        sys.exit(f"[ERREUR] dbt {' '.join(args)} a échoué (code {code}).")
    return code
