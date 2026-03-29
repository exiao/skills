# Render Reference

Render is most commonly a **source** provider in migrations (migrating away from Render).

**Important:** Render accounts can be deactivated unexpectedly with little warning. If you see your services are all down and the dashboard shows "account deactivated", you may have lost access to your data. **Always keep regular pg_dump backups when hosting on Render.**

---

## Setup

**No official CLI.** All automation uses the Render REST API.

```bash
RENDER_API_KEY="rnd_..."    # from Render dashboard: Account Settings → API Keys
```

---

## API Reference

### List all services

```bash
curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
  "https://api.render.com/v1/services?limit=100" \
  | python3 -c "
import sys, json
data = json.load(sys.stdin)
for item in data:
    svc = item['service']
    print(f\"{svc['id']} | {svc['name']} | {svc['type']} | {svc.get('serviceDetails',{}).get('url','no-url')}\")
"
```

### Get env vars for a service

```bash
SERVICE_ID="srv-..."

curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
  "https://api.render.com/v1/services/$SERVICE_ID/env-vars" \
  | python3 -c "
import sys, json
for item in json.load(sys.stdin):
    ev = item['envVar']
    # Skip service-internal references
    if not ev.get('value','').startswith('@'):
        print(f\"{ev['key']}={ev['value']}\")
" > service-env-vars.txt
```

### Get env group vars

Render "environment groups" are shared config sets applied to multiple services:

```bash
ENV_GROUP_ID="evg-..."

curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
  "https://api.render.com/v1/env-groups/$ENV_GROUP_ID/env-vars" \
  | python3 -c "
import sys, json
for item in json.load(sys.stdin):
    ev = item['envVar']
    print(f\"{ev['key']}={ev['value']}\")
" >> service-env-vars.txt
```

### List cron jobs

```bash
curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
  "https://api.render.com/v1/services?type=cron&limit=100" \
  | python3 -m json.tool
```

---

## Postgres on Render

Render manages Postgres as a separate service. Key points:

### Connection strings

There are two connection strings per Render Postgres:
1. **Internal URL** — for other Render services in the same region (hostname: `dpg-*.internal`)
2. **External URL** — for your laptop, pg_dump, external tools (hostname: `dpg-*.render.com`)

**Always use the External URL for pg_dump.**

Find them in the Render dashboard: Database service → Connect tab.

### pg_dump from Render

```bash
# External URL format:
# postgres://user:password@dpg-xxxx.render.com:5432/dbname
# May need SSL:
SOURCE_DB_URL="postgres://user:pass@dpg-xxxx.render.com:5432/dbname?sslmode=require"

pg_dump "$SOURCE_DB_URL" -Fc -Z6 -j4 -f render-backup.dump --no-owner --no-privileges
```

If `pg_dump` fails with SSL error:
```bash
# Try different SSL modes
pg_dump "${BASE_URL}?sslmode=require" ...    # require SSL
pg_dump "${BASE_URL}?sslmode=prefer" ...    # prefer SSL
pg_dump "${BASE_URL}?sslmode=disable" ...   # no SSL (less secure)
```

### Render Postgres major version

Check the version in the Render dashboard (usually Postgres 15 or 16 as of 2025-2026).

Ensure your `pg_dump` binary matches or is newer:
```bash
pg_dump --version  # must be >= source version
```

### Render Postgres external access

Render free-tier Postgres may have connection limits. If you get "too many connections" during dump:
```bash
# Reduce parallel workers
pg_dump "$SOURCE_DB_URL" -Fc -Z6 -j1 -f render-backup.dump  # single worker
```

---

## Redis on Render

Render Redis is also a separate service with internal + external URLs.

```bash
# Get Redis connection info from Render dashboard
# External URL for redis-cli: redis://:<password>@<hash>.render.com:<port>

redis-cli -u "$SOURCE_REDIS_URL" INFO server | head -5
redis-cli -u "$SOURCE_REDIS_URL" DBSIZE
```

---

## Known Render IDs (Bloom)

For reference:

| Resource | Value |
|----------|-------|
| Web service | `srv-bpfldo88atn28fgm5td0` (bloom-api) |
| Env group | `evg-bpflhvo8atn28fgm60u0` (Bloom Production) |
| API key env var | `RENDER_API_KEY` (see TOOLS.md for value) |

---

## Account Deactivation Recovery

If Render deactivated your account before you could dump data:

1. **Contact Render support immediately** at support@render.com
2. Explain you need a data export window (even 1 hour of access to pg_dump)
3. Render sometimes grants a brief re-activation for data recovery
4. If unsuccessful: check if you have any recent local backups, Render's automated backups (paid plans), or any data exports you may have made

**Lesson from Bloom migration (2026-03-11):** Render deactivated without warning. No pg_dump was possible. The Bloom backend was rebuilt on Railway with a fresh database and Django migrations re-applied to reconstruct the schema. User data was lost.

This is why regular off-provider backups are critical: `openclaw cron` can run weekly `pg_dump` and save to `~/backups/`.

---

## Migration Timeline: Render → Railway

Based on the actual Bloom migration:

1. Discover Render account deactivated — all services dead
2. Create Railway project (`bloom-backend`)
3. Provision Railway Postgres + web service
4. Set all env vars from local `~/bloom/.env` + production overrides
5. Fix Procfile: `bloom.wsgi` → `bloom.asgi` (ASGI required for UvicornWorker)
6. Fix gunicorn.conf.py: unix socket → `0.0.0.0:$PORT`
7. Deploy via `railway up`
8. Update DNS: `api.getbloom.app` CNAME → `tmnv267w.up.railway.app` (DNS only, no CF proxy)
9. Verify API responding on new domain

Total time: ~2 hours from discovery to live.

**Note:** In a normal migration (source is alive), add Phase 2 (data migration) between steps 6 and 7. That adds ~30-60 minutes for a typical small/medium database.
