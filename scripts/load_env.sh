#!/usr/bin/env bash
# Charge .env dans le shell courant :  source scripts/load_env.sh
set -a
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/../.env"
set +a
echo "Variables .env chargées (valeurs non affichées)."
