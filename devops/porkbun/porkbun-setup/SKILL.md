---
name: porkbun-setup
description: Use this skill to configure Porkbun API credentials or troubleshoot connection issues. It securely stores API keys in ~/.porkbun/credentials.json and verifies connectivity.
---

# porkbun-setup

This skill handles the initial authentication setup for the Porkbun capabilities. It ensures credentials are stored securely and verifies they work by pinging the API.

## When to use
- User says "Set up my Porkbun account" or "Connect to Porkbun"
- User provides new API keys to use
- Troubleshooting "authentication failed" errors in other skills

## Instructions

### 1. Check for existing credentials
First, check if credentials already exist at `~/.porkbun/credentials.json`.
- If they exist, ask if the user wants to overwrite them or just test the connection.
- If they don't exist, proceed to step 2.

### 2. Request API Keys
If you don't have keys yet, ask the user to provide their **API Key** and **Secret Key**.
- Provide this link for them to generate keys: https://porkbun.com/account/api
- **IMPORTANT**: Ask them to provide the keys in the chat. Remind them you will save them locally and they won't be shared.

### 3. Create/Update Credentials File
Create the directory `~/.porkbun` if it doesn't exist.
Write the JSON file to `~/.porkbun/credentials.json` with the following structure:
```json
{
  "apikey": "pk1_...",
  "secretapikey": "sk1_..."
}
```

### 4. Secure the File
**CRITICAL**: You MUST run `chmod 600 ~/.porkbun/credentials.json` immediately after creating it. This ensures only the user can read the file.

### 5. Verify Connection
Run the `scripts/test-connection.sh` script included in this skill.
- If successful, it will return "SUCCESS" and the user's IP.
- If failed, it will return the error message from Porkbun.

## Examples

**User**: "I want to set up my porkbun domains"
**Claude**: "I can help with that. Do you have your API keys ready? You can get them at https://porkbun.com/account/api. Once you paste them here (API Key and Secret Key), I'll save them securely to `~/.porkbun/credentials.json`."

**User**: "Here are my keys: pk1_123... and sk1_456..."
**Claude**: [Creates file, chmods it 600, runs test-connection.sh] "Great! I've saved your credentials securely. I successfully pinged the Porkbun API, and we are ready to go. You can now ask me to list your domains or manage DNS."
