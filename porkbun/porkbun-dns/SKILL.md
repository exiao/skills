---
name: porkbun-dns
description: Use this skill to manage DNS records (A, CNAME, MX, TXT, etc.). It prioritizes safety by backing up records before major changes and explaining technical concepts in plain English.
---

# porkbun-dns

This skill is the "Swiss Army Knife" for DNS management. It handles the low-level record manipulation but guides the user through high-level goals.

## When to use
- "Point my domain to IP 1.2.3.4"
- "Add a verification record for Google"
- "Set up email for my domain"
- "Create a subdomain like blog.example.com"
- "What records do I have?"

## Instructions

### Safety First 🛡️
Before performing *any* destructive action (deletion or overwrite):
1. **Retrieve current records** for the domain/subdomain.
2. **Show them to the user** and explain what will be lost.
3. **Ask for explicit confirmation**.
   - Exception: If the user says "force" or "I know what I'm doing", you can proceed with a warning.
   - Ideally, run the `scripts/dns-backup.sh` (if available) or minimally dump the JSON of current records to a file or chat before changing.

### 1. Retrieve/List Records
Endpoint: `POST https://api.porkbun.com/api/json/v3/dns/retrieve/DOMAIN`
- **Output**: A clean table showing Type, Host (Name), Answer (Content), TTL, and Priority (if applicable).
- **Filter**: If user asks for "MX records", only show those.

### 2. Create Records
Endpoint: `POST https://api.porkbun.com/api/json/v3/dns/create/DOMAIN`
Payload: `{"name": "SUBDOMAIN", "type": "TYPE", "content": "VALUE", "ttl": "600"}`
- **Subdomains**: If `name` is empty/null, it affects the root domain (`@` equivalent).
- **TTL**: Default to 600 (10 mins) unless user specifies otherwise.
- **Conflicts**: Check if a record exists for that host/type combo first. Usage of `edit` vs `create` depends on whether you want to add *another* record (e.g., multiple A records for load balancing) or *replace* the destination.
- **Ask**: "Do you want to add this as a new record or replace existing ones?"

### 3. Record Types Explained
Translate user intent to record types:
- **"Point to server/IP"** -> **A** (IPv4) or **AAAA** (IPv6)
- **"Alias to another domain"** -> **CNAME** (subdomains) or **ALIAS** (root domain - Porkbun special type)
- **"Mail server"** -> **MX** (needs priority)
- **"Verify ownership"** -> **TXT**

### 4. Delete Records
Endpoint: `POST https://api.porkbun.com/api/json/v3/dns/delete/DOMAIN/ID`
- Requires the `id` from the Retrieve step.
- **Always** list the record details (Name, Type, Content) before deleting.

## Examples

### Adding a Subdomain
**User**: "Point `app.cool-app.io` to `192.168.1.1`"
**Claude**:
> "I will create an **A record** for `app.cool-app.io` pointing to `192.168.1.1`.
> 
> **Current state**: No records found for `app`.
> **New record**:
> - **Type**: A
> - **Host**: app
> - **Value**: 192.168.1.1
> - **TTL**: 600s (10 min propagation)
>
> Shall I proceed?"

### Setting up Google Workspace
**User**: "Add MX records for Google"
**Claude**:
> "I'll add the 5 Google Workspace MX records to `cool-app.io`.
>
> **Action**:
> 1. `ASPMX.L.GOOGLE.COM` (Priority 1)
> 2. `ALT1.ASPMX.L.GOOGLE.COM` (Priority 5)
> ... (and so on)
>
> [!WARNING]
> This will overwrite your existing MX records for `mail.old-host.com`. You will stop receiving email at the old provider immediately.
>
> Proceed?"
