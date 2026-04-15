#!/bin/bash

# Configuration
CRED_FILE="$HOME/.porkbun/credentials.json"
API_ENDPOINT="https://api.porkbun.com/api/json/v3/ping"

# Check if credentials file exists
if [ ! -f "$CRED_FILE" ]; then
    echo "Error: Credentials file not found at $CRED_FILE"
    echo "Please run the setup process first."
    exit 1
fi

# Check permissions (should be 600)
PERMS=$(ls -l "$CRED_FILE" | awk '{print $1}')
if [[ "$PERMS" != *"-rw-------"* && "$PERMS" != *"-rw-------@"* ]]; then
    # Warn but don't fail, just strict advice
    echo "WARNING: $CRED_FILE permissions are $PERMS. Should be -rw------- (600)."
fi

# Make the request
# We use curl with -d @filename to avoid passing keys in command line arguments
RESPONSE=$(curl -s -X POST "$API_ENDPOINT" \
    -H "Content-Type: application/json" \
    -d @"$CRED_FILE")

# Parse status with jq (if available) or grep/awk fallback
if command -v jq &> /dev/null; then
    STATUS=$(echo "$RESPONSE" | jq -r '.status')
else
    # Simple grep fallback for JSON status
    STATUS=$(echo "$RESPONSE" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
fi

if [ "$STATUS" == "SUCCESS" ]; then
    YOUR_IP=$(echo "$RESPONSE" | grep -o '"yourIp":"[^"]*"' | cut -d'"' -f4)
    echo "Connection Successful!"
    echo "Status: $STATUS"
    echo "Your IP: $YOUR_IP"
    exit 0
else
    echo "Connection Failed."
    echo "Response: $RESPONSE"
    exit 1
fi
