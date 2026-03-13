# Provider Reference Index

Master index of cloud provider tooling availability for migrations.

## Provider Matrix

| Provider | Role | MCP | CLI | pg_dump access | Redis access | Notes |
|----------|------|-----|-----|----------------|--------------|-------|
| Railway | source + target | ✅ `railway` via mcporter | `railway` CLI v4+ | Via `DATABASE_PUBLIC_URL` proxy | Via `REDIS_PUBLIC_URL` | Best-supported target |
| Render | source (mainly) | ❌ | Render API (REST) | Via external DB URL | Via external Redis URL | Account may deactivate without warning |
| Heroku | source | ❌ | `heroku` CLI | `heroku pg:backups:capture` | `heroku redis:cli` | Backup download via `heroku pg:backups:url` |
| Fly.io | source + target | ✅ (`flyctl mcp server`) | `flyctl` | Via WireGuard proxy or `fly proxy` | Via `fly proxy` + fly-redis | Volumes for persistent storage |
| Vercel | target (frontend only) | ❌ | `vercel` CLI | N/A | N/A | No long-running processes |
| AWS ECS | source + target | ❌ | `aws` CLI | RDS connection string | ElastiCache endpoint | Complex but scriptable |
| DigitalOcean | source + target | ❌ | `doctl` | Managed DB connection string | Managed Redis endpoint | Similar to Render |

## Railway (target — fully supported)

**MCP:** Configured in `config/mcporter.json` as `railway` server.

Available MCP tools:
```
check-railway-status    list-projects           create-project-and-link
list-services           link-service            deploy
deploy-template         create-environment      link-environment
list-variables          set-variables           generate-domain
get-logs
```

Usage: `mcporter call railway.<tool> key=value`

**CLI:** `railway` (brew install railway). Auth: `railway login`

See `railway.md` for full CLI reference.

## Render (source)

**MCP:** None available.
**CLI:** None — use the Render REST API.

Key API endpoints:
```bash
RENDER_API_KEY="rnd_..."
# List services
curl -H "Authorization: Bearer $RENDER_API_KEY" \
  "https://api.render.com/v1/services?limit=100" | python3 -m json.tool

# Get env vars for a service
curl -H "Authorization: Bearer $RENDER_API_KEY" \
  "https://api.render.com/v1/services/$SERVICE_ID/env-vars" | python3 -m json.tool
```

Postgres URL format: `postgres://user:password@host.render.com:5432/dbname`
External access: Render Postgres has a separate external hostname (check service dashboard).

**Note:** Render accounts can be deactivated unexpectedly. If deactivated, source data may be unrecoverable. Always dump before account issues escalate.

See `render.md` for full Render reference.

## Heroku (source)

**MCP:** None available.
**CLI:** `heroku` (npm install -g heroku or brew tap heroku/brew && brew install heroku)

Key commands for migration:
```bash
heroku config -a myapp                     # list all env vars
heroku pg:info -a myapp                    # DB info
heroku pg:backups:capture -a myapp        # create backup
heroku pg:backups:url -a myapp            # get download URL
heroku redis:info -a myapp                # Redis info
```

Postgres dump download:
```bash
heroku pg:backups:capture -a myapp
BACKUP_URL=$(heroku pg:backups:url -a myapp)
curl -o heroku-backup.dump "$BACKUP_URL"
pg_restore -d "$TARGET_DB_URL" --no-owner --no-privileges -j4 heroku-backup.dump
```

## Fly.io (source + target)

**MCP:** Built into flyctl — `flyctl mcp server`. Add to mcporter.json as `{"command": "flyctl mcp server"}`. Covers volumes, machines, apps, secrets.
**CLI:** `flyctl` (brew install flyctl or curl -L https://fly.io/install.sh | sh)

See `fly.md` for full flyctl reference and MCP setup.

## Connection String Formats by Provider

### Postgres

| Provider | Format |
|----------|--------|
| Railway | `postgresql://postgres:<pass>@<hash>.proxy.rlwy.net:<port>/railway` |
| Render | `postgres://<user>:<pass>@<host>.render.com:5432/<dbname>` |
| Heroku | `postgres://<user>:<pass>@ec2-<ip>.compute-1.amazonaws.com:5432/<dbname>` |
| Fly.io | `postgres://<user>:<pass>@<app>.flycast:5432/<dbname>` (internal) |
| Supabase | `postgresql://postgres:<pass>@db.<ref>.supabase.co:5432/postgres` |

**Important:** pg_dump/restore requires the external/public URL, not internal service mesh URLs.

### Redis

| Provider | Format |
|----------|--------|
| Railway | `redis://default:<pass>@<hash>.proxy.rlwy.net:<port>` |
| Render | `redis://:<pass>@<hash>.render.com:<port>` |
| Heroku | `redis://h:<pass>@ec2-<ip>.compute-1.amazonaws.com:<port>` |
| Upstash | `rediss://default:<pass>@<hash>.upstash.io:<port>` |

## Tooling Requirements

Before starting a migration, verify you have:

```bash
# Postgres tools (must match target major version)
psql --version        # client
pg_dump --version     # dump tool
pg_restore --version  # restore tool

# Install on macOS if missing:
brew install libpq
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"  # add to .zshrc

# Redis tools
redis-cli --version

# File sync (for object storage)
rclone --version

# Provider CLIs (as needed)
railway --version
flyctl version
heroku --version
```

**Version matching:** pg_dump major version must match or be lower than source Postgres major version. Railway runs Postgres 17 (as of 2026-03). Heroku typically runs 15-16.
