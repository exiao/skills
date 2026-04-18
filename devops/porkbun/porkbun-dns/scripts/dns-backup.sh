#!/bin/bash

# Configuration
CRED_FILE="$HOME/.porkbun/credentials.json"
BACKUP_DIR="$HOME/.porkbun/backups"
DOMAIN=$1

if [ -z "$DOMAIN" ]; then
    echo "Usage: ./dns-backup.sh <domain>"
    exit 1
fi

mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUT_FILE="$BACKUP_DIR/${DOMAIN}-${TIMESTAMP}.json"

# Fetch records
RESPONSE=$(curl -s -X POST "https://api.porkbun.com/api/json/v3/dns/retrieve/$DOMAIN" \
    -H "Content-Type: application/json" \
    -d @"$CRED_FILE")

STATUS=$(echo "$RESPONSE" | grep -o '"status":"SUCCESS"')

if [ -n "$STATUS" ]; then
    echo "$RESPONSE" > "$OUT_FILE"
    echo "✅ Backup saved to: $OUT_FILE"
    
    # Prune old backups (keep last 10)
    ls -t "$BACKUP_DIR"/${DOMAIN}-*.json | tail -n +11 | xargs -I {} rm -- {} 2>/dev/null
    exit 0
else
    echo "❌ Backup failed."
    echo "$RESPONSE"
    exit 1
fi
