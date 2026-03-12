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

## MCP Tools

```
check-railway-status    list-projects           create-project-and-link
list-services           link-service            deploy
deploy-template         create-environment      link-environment
list-variables          set-variables           generate-domain
get-logs
```

Call via: `mcporter call railway.<tool> key=value`
