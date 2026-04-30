---
name: porkbun-cli
description: Manage Porkbun domains, DNS records, SSL certificates, URL forwarding, and hosting blueprints via the Porkbun API. Use when the user asks about domain management, DNS, SSL certs, URL redirects, or connecting a domain to a hosting provider.
preloaded: true
---

# Porkbun CLI

Manage Porkbun domains, DNS, SSL, URL forwarding, and hosting blueprints via the Porkbun REST API.

## Credentials

Stored at `~/.porkbun/credentials.json`:
```json
{"apikey": "pk1_...", "secretapikey": "sk1_..."}
```

If missing, direct user to https://porkbun.com/account/api to generate keys. Save with `chmod 600`.

Every API call requires both keys in the JSON body.

## Setup & Test Connection

Run `scripts/test-connection.sh` to verify credentials work.

```bash
curl -s -X POST https://api.porkbun.com/api/json/v3/ping \
  -H "Content-Type: application/json" \
  -d '{"apikey":"...","secretapikey":"..."}'
```

## Domains

### List All Domains
```
POST https://api.porkbun.com/api/json/v3/domain/listAll
Payload: {"start": "0", "includeLabels": "yes", ...auth}
```

Output as table: Domain, Status, Expiry Date, Auto-Renew. Highlight 🔴 expiring within 30 days, 🟢 active.

### Check Nameservers
```
POST https://api.porkbun.com/api/json/v3/domain/getNs/DOMAIN
```

## DNS Records

### Safety First
Before any destructive action (delete/overwrite):
1. Retrieve current records for the domain/subdomain
2. Show them to the user
3. Ask for explicit confirmation
4. Ideally run `scripts/dns-backup.sh` first

### Retrieve Records
```
POST https://api.porkbun.com/api/json/v3/dns/retrieve/DOMAIN
```
Output: Type, Host, Answer, TTL, Priority (if applicable).

### Create Records
```
POST https://api.porkbun.com/api/json/v3/dns/create/DOMAIN
Payload: {"name": "SUBDOMAIN", "type": "TYPE", "content": "VALUE", "ttl": "600", ...auth}
```
- Empty `name` = root domain (@)
- Default TTL: 600 (10 min)
- Check for existing records first; ask "add new or replace?"

### Record Type Cheatsheet
- "Point to IP" → **A** (IPv4) or **AAAA** (IPv6)
- "Alias to domain" → **CNAME** (subdomains) or **ALIAS** (root)
- "Mail server" → **MX** (needs priority)
- "Verify ownership" → **TXT**

### Delete Records
```
POST https://api.porkbun.com/api/json/v3/dns/delete/DOMAIN/ID
```
Requires `id` from Retrieve. Always show record details before deleting.

## SSL Certificates

### Retrieve SSL Bundle
```
POST https://api.porkbun.com/api/json/v3/ssl/retrieve/DOMAIN
```
Returns: `privatekey`, `publickey`, `certificatechain`, `intermediatecertificate`.

Save to `./ssl-DOMAIN/`:
- `domain.key` (Private Key)
- `domain.crt` (Public Key)
- `intermediate.crt` (Chain)
- `fullchain.crt` (Public + Intermediate concatenated)

Server-specific:
- **Nginx**: `fullchain.crt` + `domain.key`
- **Apache**: `domain.crt` + `domain.key` + `intermediate.crt`

## URL Forwarding

### Check Existing Forwards
```
POST https://api.porkbun.com/api/json/v3/domain/getUrlForwarding/DOMAIN
```

### Create Forward
```
POST https://api.porkbun.com/api/json/v3/domain/addUrlForward/DOMAIN
Payload: {"subdomain": "", "location": "https://dest.com", "type": "temporary", "includePath": "yes", "wildcard": "yes", ...auth}
```

- **301 (permanent)**: SEO-friendly, use for permanent moves
- **302 (temporary)**: For testing or temporary redirects
- **includePath**: `old.com/blog/post` → `new.com/blog/post` (usually ON)
- **wildcard**: Matches `*.old.com` (usually ON)

## Hosting Blueprints

One-click DNS configs for popular platforms. Read the blueprint from `references/blueprints/` then apply via DNS create.

| Platform | Blueprint file |
|----------|---------------|
| Vercel | `references/blueprints/vercel.md` |
| Netlify | `references/blueprints/netlify.md` |
| GitHub Pages | `references/blueprints/github-pages.md` |
| Cloudflare Pages | `references/blueprints/cloudflare-pages.md` |
| Railway | `references/blueprints/railway.md` |
| Self-hosted / VPS | `references/blueprints/self-hosted.md` |

### Execution Protocol
1. Explain the plan: "To set up Vercel, I need A record → 76.76.21.21 and CNAME www → cname.vercel-dns.com"
2. Check for conflicts (existing A/CNAME on root/www)
3. Warn about records being replaced
4. Execute after confirmation
5. Verify with brief output
