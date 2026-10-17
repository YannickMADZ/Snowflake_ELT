# =============================================================================
# Image d'exécution du projet : Python 3.12 + dbt Core + dbt-snowflake +
# connecteur Snowflake. Le CODE n'est pas copié dans l'image : le dépôt est
# monté en volume (/app) par docker-compose.yml, si bien que les fichiers
# produits (docs/evidence/, target/, profiles.yml) apparaissent directement
# sur ta machine, et qu'une modification de modèle ne demande pas de rebuild.
# Aucun secret dans l'image : les identifiants arrivent au lancement via .env.
# =============================================================================
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    DBT_PROJECT_DIR=/app \
    DBT_PROFILES_DIR=/app \
    DBT_SEND_ANONYMOUS_USAGE_STATS=false

# git : utilisé par dbt deps / dbt debug ; nettoyage du cache apt pour une image légère
RUN apt-get update \
 && apt-get install -y --no-install-recommends git \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Dépendances seules : couche mise en cache tant que requirements.txt ne change pas
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# Point d'entrée écrit DANS l'image (fins de ligne LF garanties, même si le
# dépôt est cloné sous Windows) : crée profiles.yml depuis le modèle s'il
# manque, puis exécute la commande demandée.
RUN printf '%s\n' \
      '#!/bin/sh' \
      'set -e' \
      'if [ ! -f /app/profiles.yml ] && [ -f /app/profiles.example.yml ]; then' \
      '  cp /app/profiles.example.yml /app/profiles.yml' \
      '  echo "profiles.yml créé depuis profiles.example.yml (ignoré par Git)."' \
      'fi' \
      'exec "$@"' \
    > /usr/local/bin/entrypoint.sh \
 && chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["python", "scripts/run_all.py"]
