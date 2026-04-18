# Phase 0: Audit Source Environment

Before touching anything on the target, know exactly what you're moving. This phase prevents "oh, I forgot about the cron job" surprises at 2am.

## What to Capture

### 1. Service Inventory

List all running processes:
- Web server (count of instances/replicas)
- Background workers (Celery, Sidekiq, RQ, etc.)
- Cron jobs / scheduled tasks
- Any admin or one-off services

### 2. Database Inventory

For each database:
- Type (Postgres, Redis, MySQL, MongoDB, S3)
- Size (disk usage, row counts for top tables)
- Connection string / URL (save this!)
- Postgres major version

### 3. Environment Variables

**Export all of them.** Don't rely on memory. Most providers let you dump them via API or CLI.

### 4. Custom Domains + SSL

- Which services have custom domains
- Whether DNS is via Cloudflare (orange cloud = proxied, grey = DNS only)
- SSL cert type (provider-managed vs Let's Encrypt vs custom)

### 5. Resource Sizing

- RAM per service
- CPU
- Replica count
- Any autoscaling config

### 6. External Integrations

Anything that knows your current URL or IP:
- Error tracking (Sentry DSN)
- Analytics (PostHog, Mixpanel)
- Payment webhooks (Stripe, etc.)
- Email services (SendGrid, Mailgun)
- OAuth redirect URIs (Google, GitHub, Apple)

These all need to be updated after DNS cutover.

---

## Provider-Specific Audit Commands

### Render

No official CLI. Use the API:

```bash
RENDER_API_KEY="rnd_..."

# List all services
curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
  "https://api.render.com/v1/services?limit=100" \
  | python3 -c "import sys,json; [print(s['service']['name'], s['service']['type'], s['service']['id']) for s in json.load(sys.stdin)['services']]"

# Get env vars for a specific service
SERVICE_ID="srv-..."
curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
  "https://api.render.com/v1/services/$SERVICE_ID/env-vars" \
  | python3 -c "import sys,json; [print(f\"{e['envVar']['key']}={e['envVar']['value']}\") for e in json.load(sys.stdin)]"

# Get env group vars
ENV_GROUP_ID="evg-..."
curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
  "https://api.render.com/v1/env-groups/$ENV_GROUP_ID/env-vars" \
  | python3 -c "import sys,json; [print(f\"{e['envVar']['key']}={e['envVar']['value']}\") for e in json.load(sys.stdin)]"
```

Render Postgres: Connection string is shown in the Render dashboard under the database's "Connect" tab. There are two: **internal** (for other Render services) and **external** (for pg_dump, migrations from local). Use the **external** one.

### Heroku

```bash
APP="myapp-prod"

# All env vars (config vars)
heroku config -a $APP

# Export to .env format
heroku config -a $APP --json \
  | python3 -c "import sys,json; [print(f'{k}={v}') for k,v in json.load(sys.stdin).items()]" \
  > heroku-env-vars.txt

# List all dynos/processes
heroku ps -a $APP

# DB info
heroku pg:info -a $APP

# DB size (row counts)
heroku pg:psql -a $APP -c "
SELECT schemaname, relname, n_live_tup
FROM pg_stat_user_tables
WHERE n_live_tup > 0
ORDER BY n_live_tup DESC
LIMIT 20;
"

# Redis info  
heroku redis:info -a $APP

# List all addons
heroku addons -a $APP

# List cron / Heroku Scheduler jobs
heroku addons:open scheduler -a $APP  # opens browser
```

### Railway (when Railway is your source)

```bash
# Via MCP
mcporter call railway.list-projects
mcporter call railway.list-services workspacePath="/path/to/project"
mcporter call railway.list-variables workspacePath="/path/to/project"

# Via CLI (must be linked)
cd ~/project && railway link
railway variable list          # all vars for linked service
railway service list           # all services in project

# DB connection string
railway service link Postgres
railway variable list --json \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('DATABASE_PUBLIC_URL',''))"
```

### Fly.io (when Fly is your source)

```bash
APP="myapp"

# List apps
flyctl apps list

# List services / machines
flyctl machines list -a $APP

# Env vars / secrets
flyctl secrets list -a $APP     # shows key names only (not values — by design)
flyctl ssh console -a $APP      # SSH in, then `printenv` to see values

# Postgres info (if using Fly Postgres)
flyctl postgres list
flyctl postgres connect -a $APP-db   # psql shell

# App size/resources
flyctl scale show -a $APP
```

---

## Audit Checklist

Save outputs to a scratch directory (`~/migration-YYYYMMDD/`):

- [ ] `services.txt` — list of all services with types
- [ ] `env-vars.txt` — all environment variables (SENSITIVE — don't commit)
- [ ] `databases.txt` — DB URLs, types, sizes
- [ ] `domains.txt` — custom domains, DNS settings
- [ ] `integrations.txt` — Sentry DSN, analytics tokens, webhooks
- [ ] `resource-sizing.txt` — RAM/CPU per service

Total audit time: 15-30 minutes. Well worth it.
