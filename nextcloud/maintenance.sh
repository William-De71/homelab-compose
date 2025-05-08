#!/bin/bash

echo "🧹 Maintenance Nextcloud..."

# Nettoyage des fichiers temporaires
sudo docker exec nextcloud-app-1 php occ maintenance:repair
sudo docker exec nextcloud-app-1 php occ maintenance:mode --on

# Réparation automatique de la base de données
sudo docker exec nextcloud-app-1 php occ db:add-missing-indices
sudo docker exec nextcloud-app-1 php occ db:add-missing-columns

# Mise à jour Nextcloud (si image mise à jour)
sudo docker compose pull
sudo docker compose up -d

sudo docker exec nextcloud-app-1 php occ maintenance:mode --off
