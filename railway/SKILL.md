---
name: railway
description: Deploy, manage, and operate Railway projects via CLI and MCP. Use when creating Railway services, deploying code, adding databases (Postgres, Redis), setting environment variables, viewing logs, managing domains, or doing anything with Railway infrastructure. Also use when asked about the Bloom backend on Railway.
---

# Railway

## Setup

**CLI:** `brew install railway` → `railway login`
**MCP:** Configured in `config/mcporter.json` as `railway` (stdio: `npx -y @railway/mcp-server`)

Check auth:
```bash
mcporter call railway.check-railway-status
railway whoami
```

## Common Operations

### Link a directory to a project + service
```bash
railway link                       # interactive picker
railway link --project <id>        # non-interactive
railway service link <name>        # link to a specific service
```

### Deploy code
```bash
railway up --detach    # upload current dir, returns build URL
```

### View logs
```bash
railway logs           # deploy logs (must be linked to a service)
# via MCP:
mcporter call railway.get-logs workspacePath="<path>" logType="deploy"
mcporter call railway.get-logs workspacePath="<path>" logType="build"
```

### Add a database
```bash
railway add --database postgres    # or redis, mysql, mongo
```

### Add an empty service
```bash
railway add --service <name>
railway service link <name>
railway up --detach
```

### Set environment variables
```bash
railway variable set KEY=value KEY2=value2

# Service reference — links one service's var into another:
railway variable set 'DATABASE_URL=${{Postgres.DATABASE_URL}}'
railway variable set 'REDIS_URL=${{Redis.REDIS_URL}}'

# List all vars for linked service
railway variable list
```

### Domains
```bash
railway domain                     # auto-generate railway.app domain
railway domain my.example.com      # custom domain — prints required DNS records
```

### List projects / services
```bash
mcporter call railway.list-projects
mcporter call railway.list-services workspacePath="<path>"
```

## New Service from Scratch

```bash
railway link --project <project-id>
railway add --service <name>
railway service link <name>
railway variable set KEY=value
railway domain
railway up --detach
```

## Django/ASGI — Key Notes

- Use `app.asgi:application` not `app.wsgi` — UvicornWorker requires ASGI
- Bind gunicorn to `0.0.0.0:$PORT` (Railway injects `PORT`) — not a unix socket
- Add `.python-version` (e.g. `3.11.11`) for Nixpacks to pick the right Python
- `release:` in Procfile runs before deploy (good for migrations)
- `DATABASE_URL` auto-resolves via service reference `${{Postgres.DATABASE_URL}}`
- Large builds may need `NODE_OPTIONS=--max-old-space-size=8192` if frontend bundling

## Database Backup & Restore

### Backup (dump to local file)

Railway Postgres is accessible externally via the proxy URL. Use `pg_dump` with the public connection string.

```bash
# Ensure libpq tools are in PATH (macOS homebrew)
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Get the public DB URL (from the Postgres service vars)
cd ~/bloom-railway
railway service link Postgres
DB_URL=$(railway variable list --json | python3 -c "import sys,json; print(json.load(sys.stdin)['DATABASE_PUBLIC_URL'])")

# Dump (custom format, compressed, parallel)
pg_dump "$DB_URL" -Fc -Z6 -j4 -f backup_$(date +%Y%m%d_%H%M%S).dump

# Dump (plain SQL, if you need readable SQL)
pg_dump "$DB_URL" --no-owner --no-privileges -f backup_$(date +%Y%m%d_%H%M%S).sql
```

### Restore to a new Railway Postgres

```bash
# Create a fresh Postgres service (or use existing)
railway add --database postgres

# Get the new DB's public URL
NEW_DB_URL="postgresql://postgres:<password>@<host>:<port>/railway"

# Restore from custom-format dump
pg_restore -d "$NEW_DB_URL" --no-owner --no-privileges -j4 backup.dump

# Restore from SQL dump
psql "$NEW_DB_URL" < backup.sql
```

### Restore to local Postgres (for dev/testing)

```bash
createdb bloom_local
pg_restore -d bloom_local --no-owner --no-privileges -j4 backup.dump
```

### Verify backup integrity

```bash
# Compare row counts between source and restored DB
psql "$DB_URL" -c "
SELECT schemaname, relname, n_live_tup
FROM pg_stat_user_tables
WHERE n_live_tup > 0
ORDER BY n_live_tup DESC
LIMIT 20;
"
```

### Automated backup (cron)

Set up a Clawdbot cron job to dump weekly:

```
Schedule: 0 4 * * 0 (Sunday 4am)
Task: Back up Railway Postgres to ~/backups/railway/
```

The dump file goes to `~/backups/railway/bloom_YYYYMMDD.dump`. Keep last 4 weekly backups.

### Important notes

- Railway Postgres proxy URL (`*.proxy.rlwy.net`) is the external-access URL. Internal services use `*.railway.internal`.
- `pg_dump` requires matching major version. Railway runs Postgres 17. Install with: `brew install libpq`.
- PostGIS/extension errors during restore are expected and harmless if you don't use spatial features.
- Custom format (`-Fc`) is preferred: compressed, supports parallel restore, selective table restore.
- Always use `--no-owner --no-privileges` on restore to avoid role-mismatch errors.

## MCP Tools

```
check-railway-status    list-projects           create-project-and-link
list-services           link-service            deploy
deploy-template         create-environment      link-environment
list-variables          set-variables           generate-domain
get-logs
```

Call via: `mcporter call railway.<tool> key=value`
