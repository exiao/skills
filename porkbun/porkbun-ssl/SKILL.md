---
name: porkbun-ssl
description: Use this skill to retrieve and download SSL certificates for domains.
---

# porkbun-ssl

This skill manages SSL certificates. Porkbun provides free Let's Encrypt certificates for all domains, which is a huge perk.

## When to use
- "Download my SSL certs"
- "I need to install SSL on my server"
- "Get the private key for my-domain.com"

## Instructions

### 1. Retrieve the Bundle
Endpoint: `POST https://api.porkbun.com/api/json/v3/ssl/retrieve/DOMAIN`
- **Output**: JSON containing `privatekey`, `publickey` (cert), `certificatechain`, and `intermediatecertificate`.

### 2. Save Strategy
If the user asks to "download" or "save" the certs:
1. Create a directory: `./ssl-<domain>/`
2. Save files with standard names:
   - `domain.key` (Private Key)
   - `domain.crt` (Public Key)
   - `intermediate.crt` (Chain)
   - `fullchain.crt` (Public + Intermediate concatenated)

### 3. Server-Specific Advice
Explain which files go where based on the user's web server:
- **Nginx**: Uses `fullchain.crt` and `domain.key`.
- **Apache**: Uses `domain.crt`, `domain.key`, and `intermediate.crt`.
- **Heroku/others**: Usually want the `fullchain` and `private key` text pasted into a form.

## Example

**User**: "Get me the SSL certs for my-app.com"

**Claude**: [Calls API, saves files]
"I've downloaded your certificates to `./ssl-my-app.com/`:

- `my-app.com.key`: **Private Key** (Keep this safe! Never share it.)
- `fullchain.crt`: **Certificate Bundle** (Use this for Nginx/Node.js)

To install on Nginx, you would add:
```nginx
ssl_certificate /path/to/fullchain.crt;
ssl_certificate_key /path/to/my-app.com.key;
```
"
