"""
Génère une paire de clés RSA pour l'authentification Snowflake par clé
(recommandée pour les scripts et dbt : pas de MFA à saisir, pas de mot de passe
dans l'environnement). Fonctionne sous Windows sans OpenSSL.

    python scripts/generate_keypair.py

- La clé PRIVÉE est écrite HORS du dépôt : ~/.snowflake/rsa_key_nyc_taxi.p8
- Le script affiche l'instruction ALTER USER à exécuter UNE fois dans Snowsight
  et la ligne à mettre dans .env.
"""
from pathlib import Path

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa

key_dir = Path.home() / ".snowflake"
key_dir.mkdir(exist_ok=True)
key_path = key_dir / "rsa_key_nyc_taxi.p8"
if key_path.exists():
    raise SystemExit(f"{key_path} existe déjà : supprime-le d'abord si tu veux en générer une nouvelle.")

key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
key_path.write_bytes(key.private_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PrivateFormat.PKCS8,
    encryption_algorithm=serialization.NoEncryption(),
))
public = key.public_key().public_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PublicFormat.SubjectPublicKeyInfo,
).decode()
body = "".join(line for line in public.splitlines() if "-----" not in line)

print(f"Clé privée écrite : {key_path}  (hors du dépôt, ne jamais la committer)\n")
print("1) Dans Snowsight (Worksheet), exécute UNE fois :\n")
print(f"   ALTER USER <TON_UTILISATEUR> SET RSA_PUBLIC_KEY='{body}';\n")
print("2) Dans .env :\n")
print("   DBT_TARGET=keypair")
print(f"   SNOWFLAKE_PRIVATE_KEY_PATH={key_path.as_posix()}")
