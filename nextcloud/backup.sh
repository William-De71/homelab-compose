#!/bin/bash

DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="./backups/$DATE"
mkdir -p "$BACKUP_DIR"

# Sauvegarde base de données
docker exec nextcloud-db-1 mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > "$BACKUP_DIR/db.sql"

# Sauvegarde des données
docker run --rm \
  -v nextcloud_data:/data \
  -v "$BACKUP_DIR:/backup" \
  alpine tar czf /backup/html.tar.gz -C /data .

# Garder les 7 derniers backups
ls -dt ./backups/* | tail -n +8 | xargs rm -rf
