#!/bin/bash
set -e

CONFIG_FILE=./config/config.php
BACKUP_FILE="${CONFIG_FILE}.bak"
TMP_FILE="$(mktemp)"
INSERT_BLOCK=""

# Vérifie si le fichier existe
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Fichier $CONFIG_FILE introuvable !"
  exit 1
fi

# 🔒 Sauvegarde
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "📦 Sauvegarde faite : $BACKUP_FILE"

# Tableau associatif des clés à injecter
declare -A CONFIG_ENTRIES=(
  ["'maintenance_window_start'"]="1"
  ["'maintenance'"]="false"
  ["'enable_previews'"]="true"
  ["'enabledPreviewProviders'"]="array (
    0 => 'OC\\\\Preview\\\\PNG',
    1 => 'OC\\\\Preview\\\\JPEG',
    2 => 'OC\\\\Preview\\\\GIF',
    3 => 'OC\\\\Preview\\\\BMP',
    4 => 'OC\\\\Preview\\\\XBitmap',
    5 => 'OC\\\\Preview\\\\MP3',
    6 => 'OC\\\\Preview\\\\TXT',
    7 => 'OC\\\\Preview\\\\MarkDown',
    8 => 'OC\\\\Preview\\\\OpenDocument',
    9 => 'OC\\\\Preview\\\\Krita',
    10 => 'OC\\\\Preview\\\\HEIC',
  )"
  ["'default_phone_region'"]="'FR'"
)

# Vérifie si chaque clé est déjà présente
for key in "${!CONFIG_ENTRIES[@]}"; do
  if ! grep -q "$key" "$CONFIG_FILE"; then
    value=${CONFIG_ENTRIES[$key]}
    INSERT_BLOCK+="  $key => $value,"$'\n'
  fi
done

# Rien à faire ?
if [[ -z "$INSERT_BLOCK" ]]; then
  echo "✅ Toutes les clés sont déjà présentes. Aucun changement."
  exit 0
fi

echo "🔧 Insertion des clés manquantes..."

# Injection juste avant ); ou ];
injected=0
while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]*[\]\)]\; ]]; then
    echo -n "$INSERT_BLOCK" >> "$TMP_FILE"
    injected=1
  fi
  echo "$line" >> "$TMP_FILE"
done < "$CONFIG_FILE"

if [[ $injected -eq 1 ]]; then
  mv "$TMP_FILE" "$CONFIG_FILE"
  echo "✅ Clés injectées avec indentation 2 espaces."
  echo -e "\n📄 Diff avec l'original :"
  diff -u "$BACKUP_FILE" "$CONFIG_FILE" || true
else
  echo "⚠️ Aucun point d'injection trouvé. Fichier inchangé."
  rm "$TMP_FILE"
fi
