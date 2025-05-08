#!/bin/bash

BACKUP_FOLDER="$1"

if [[ -z "$BACKUP_FOLDER" || ! -d "./backups/$BACKUP_FOLDER" ]]; then
  echo "❌ Dossier de sauvegarde invalide."
  exit 1
fi

read -p "⚠️ Cela écrasera vos données actuelles. Continuer ? (y/N): " confirm
if [[ "$confirm" != "y" ]]; then
  exit 0
fi

echo "🔄 Restauration en cours..."

docker compose down

# Restauration base de données
docker volume create nextclouddb_data
cat "./backups/$BACKUP_FOLDER/db.sql" | docker exec -i nextcloud-db-1 mysql -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE

# Restauration des fichiers
docker run --rm \
  -v nextcloud_data:/data \
  -v "./backups/$BACKUP_FOLDER:/backup" \
  alpine tar xzf /backup/html.tar.gz -C /data

docker compose up -d
