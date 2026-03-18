---
name: porkbun
description: Manage Porkbun domains, DNS records, SSL certificates, URL forwarding, and hosting blueprints via the Porkbun API. Use when the user asks about domain management, DNS, SSL certs, URL redirects, or connecting a domain to a hosting provider.
---

# porkbun

Root skill for all Porkbun domain management. Routes to the appropriate sub-skill based on intent.

## Credentials

Stored at `~/.porkbun/credentials.json` with keys `apikey` and `secretapikey`.
If missing, read and follow `porkbun-setup/SKILL.md` to configure them.

## Routing

Identify the user's intent and read the matching sub-skill:

| Intent | Sub-skill |
|--------|-----------|
| Set up credentials, test connection, auth issues | `porkbun-setup/SKILL.md` |
| List domains, check expiry, nameservers | `porkbun-domains/SKILL.md` |
| Create/edit/delete DNS records (A, CNAME, MX, TXT, etc.) | `porkbun-dns/SKILL.md` |
| Download SSL certificates | `porkbun-ssl/SKILL.md` |
| URL redirects / forwarding | `porkbun-forwards/SKILL.md` |
| Connect domain to Vercel, Netlify, Railway, GitHub Pages, Cloudflare Pages, or self-hosted | `porkbun-hosting-blueprints/SKILL.md` |

All sub-skill paths are relative to this directory.

## API Auth

Every Porkbun API call requires both keys in the JSON body:

```json
{
  "apikey": "<from credentials.json>",
  "secretapikey": "<from credentials.json>"
}
```

Read `~/.porkbun/credentials.json` and include both fields in every request.

## Safety

- Before any destructive action (delete, overwrite), show current state and get explicit confirmation.
- Back up DNS records before bulk changes (see `porkbun-dns/scripts/dns-backup.sh`).
