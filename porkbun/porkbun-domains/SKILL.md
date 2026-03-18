---
name: porkbun-domains
description: Use this skill to list domains, check their status, viewing expiration dates, and seeing nameserver configuration.
---

# porkbun-domains

This skill provides an inventory of your Porkbun domains. It's the "dashboard" view of your portfolio.

## When to use
- "What domains do I have?"
- "When does my domain expire?"
- "Is auto-renew on for my-domain.com?"
- "Which nameservers is my-domain.com using?"

## Instructions

### 1. Prerequisite
Ensure credentials exist at `~/.porkbun/credentials.json`. If not, direct the user to the `porkbun-setup` skill.

### 2. List All Domains
Endpoint: `POST https://api.porkbun.com/api/json/v3/domain/listAll`
Payload: `{"start": "0", "includeLabels": "yes"}` (plus auth)

**Action**: Fetch the list.
**Output**: Present a table or concise list.
- **Columns**: Domain, Status, Expiry Date, Auto-Renew
- **Formatting**:
  - Highlight 🔴 expired or expiring within 30 days
  - Highlight 🟢 active and healthy
  - specific nameservers if requested

### 3. Check Specific Domain
If the user asks about a specific domain (e.g., "Check status of google.com"), filter the list or use the specific lookup if available (Porkbun API listing is usually best as it gives the full overview).

## Examples

### Listing Domains
**User**: "List my domains"
**Claude**: [Calls `domain/listAll`]
"Here is your domain portfolio:

| Domain | Status | Expires | Auto-Renew |
|,---|---|---|---|
| **cool-app.io** | 🟢 ACTIVE | 2026-12-01 | ✅ ON |
| **forgotten-project.net** | 🟡 EXPIRING SOON | 2025-02-15 | ❌ OFF |
| **family-blog.com** | 🟢 ACTIVE | 2027-04-20 | ✅ ON |

> [!WARNING]
> **forgotten-project.net** expires in less than 30 days and auto-renew is OFF. You should log in to porkbun.com to renew it if you want to keep it.
"

### Checking Details
**User**: "What nameservers is cool-app.io using?"
**Claude**: [Calls `domain/getNs`]
"**cool-app.io** is using the following nameservers:
1. `curitiba.ns.porkbun.com`
2. `fortaleza.ns.porkbun.com`
3. `maceio.ns.porkbun.com`
4. `salvador.ns.porkbun.com`

This means it's using Porkbun's default DNS. You can use the `porkbun-dns` skill to manage records directly."
