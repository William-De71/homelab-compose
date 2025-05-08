#!/bin/bash

set -e
FORCE=0

COMPOSE_FILE="docker-compose.yml"
CERT_OUTPUT="./web/certs/caddy_root.crt"


if [[ "$1" == "--force" ]]; then
  FORCE=1
fi

echo "🔹 Démarrage de Nextcloud Intranet avec HTTPS interne..."

# Vérifie que Docker et Docker Compose sont installés
command -v docker >/dev/null 2>&1 || { echo >&2 "Docker n'est pas installé. Abandon."; exit 1; }
command -v docker compose >/dev/null 2>&1 || { echo >&2 "Docker Compose Plugin non détecté. Abandon."; exit 1; }

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "❌ Fichier docker-compose.yml introuvable !"
  exit 1
fi

# Recrée complètement le stack si --force est utilisé
if [[ "$FORCE" -eq 1 ]]; then
  echo "♻️ Recréation complète du stack..."
  docker compose down -v
  docker volume prune -f
  rm -rf nextcloud
  rm -rf config
  mkdir -p {nextcloud,config}
fi

# Démarrage des services
echo "🚀 Lancement du stack..."
docker compose up -d

echo "✅ Conteneurs lancés."

echo "🔹 Attente génération certificat..."
sleep 5

CADDY_CONTAINER=$(docker-compose ps -q web)

if [ -z "$CADDY_CONTAINER" ]; then
  echo "❌ Impossible de trouver le conteneur Caddy."
  exit 1
fi

touch "$CERT_OUTPUT"

docker exec "$CADDY_CONTAINER" cat /data/caddy/pki/authorities/local/root.crt > "$CERT_OUTPUT"

echo "✅ Certificat récupéré : $CERT_OUTPUT"

# Trouve la première interface physique avec "state UP", en excluant les virtuelles
interface=$(ip -o link show | awk -F': ' '/state UP/ {print $2}' \
  | grep -Ev 'lo|docker|veth|virbr|br-|vmnet|tun' \
  | head -n 1)

if [ -n "$interface" ]; then
    ip_physique=$(ip -4 addr show "$interface" | awk '/inet / {print $2}' | cut -d/ -f1)
    echo "Interface avec state UP détectée : $interface"
    echo "Adresse IP : $ip_physique"
else
    echo "Aucune interface physique avec state UP détectée."
fi

# Ajout du domaine local si non présent
if ! grep -q "nextcloud.local.lan" /etc/hosts; then
  echo "Ajout de nextcloud.local.lan à /etc/hosts"
  echo "${ip_physique} nextcloud.local.lan" | sudo tee -a /etc/hosts
fi

# Vérification finale
sleep 5
echo "🌐 Test de l'accès à https://nextcloud.local.lan..."
sleep 10
curl -k --silent --head https://nextcloud.local.lan/login | grep "HTTP/2 200" >/dev/null && \
  echo "🎉 Nextcloud est prêt et accessible en HTTPS local sur https://nextcloud.local.lan." || \
  echo "⚠️ Problème d'accès à Nextcloud. Vérifiez les logs."
