# Phase 1: Provision Target Environment

Stand up the new infrastructure **before** migrating data. This lets you validate connection strings, test deployments, and catch config issues without data in play.

**Rule:** Provision databases first — you need their connection strings before setting app env vars.

---

## Provisioning on Railway (most common target)

Railway is the preferred target when MCP is configured. It has the best tooling.

### Step 1: Create project

```bash
# Via MCP (preferred — non-interactive)
mcporter call railway.create-project-and-link name="myapp-production"

# Via CLI (interactive)
cd ~/myapp
railway init          # creates new project
# OR link to existing:
railway link --project <project-id>
```

### Step 2: Add databases

```bash
# Add Postgres
railway add --database postgres
# Railway creates a "Postgres" service with DATABASE_URL auto-set

# Add Redis  
railway add --database redis
# Railway creates a "Redis" service with REDIS_URL auto-set
```

Wait ~30 seconds for databases to provision, then get their public URLs:

```bash
# Link to Postgres service to get its vars
railway service link Postgres
railway variable list --json \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('DATABASE_PUBLIC_URL',''))"

# Save these — you need them for Phase 2 (data migration)
```

### Step 3: Create web service

```bash
# Add a service for the web app
railway add --service web
railway service link web

# Connect GitHub repo
# In Railway dashboard: Settings → Source → Connect Repo
# This triggers auto-deploys on push
```

### Step 4: Set environment variables

See `phase-env-vars.md` for the full env var migration guide.

Quick version:
```bash
# Bulk set from your audit's env-vars.txt:
railway variable set \
  SECRET_KEY="..." \
  DJANGO_SETTINGS_MODULE="myapp.settings.production" \
  ALLOWED_HOSTS="api.myapp.com,*.railway.app" \
  DEBUG="false" \
  WORKERS="2"

# Service references (DB/Redis auto-link — preferred over hardcoded URLs):
railway variable set 'DATABASE_URL=${{Postgres.DATABASE_URL}}'
railway variable set 'REDIS_URL=${{Redis.REDIS_URL}}'
```

### Step 5: Verify provisioning

```bash
# Check services are up
mcporter call railway.list-services workspacePath="$(pwd)"

# Verify DB is accessible
psql "$DATABASE_PUBLIC_URL" -c "SELECT version();"

# Check all vars are set
railway variable list
```

---

## Provisioning on Fly.io (target)

### Step 1: Create app

```bash
APP="myapp-prod"
flyctl apps create $APP --org personal
```

### Step 2: Launch from existing project (sets up fly.toml)

```bash
cd ~/myapp
flyctl launch --name $APP --no-deploy
# Edit fly.toml before first deploy
```

Sample `fly.toml` for a Django app:
```toml
app = "myapp-prod"
primary_region = "iad"   # us-east

[build]
  [build.args]
    PYTHON_VERSION = "3.11"

[env]
  PORT = "8080"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 1

[[vm]]
  memory = "512mb"
  cpu_kind = "shared"
  cpus = 1
```

### Step 3: Provision Postgres

```bash
# Create a managed Postgres cluster
flyctl postgres create --name $APP-db --region iad --vm-size shared-cpu-1x --volume-size 1

# Attach to your app (sets DATABASE_URL automatically)
flyctl postgres attach $APP-db -a $APP
```

### Step 4: Provision Redis (Upstash)

```bash
# Fly.io Redis uses Upstash
flyctl redis create --name $APP-redis --region iad --plan 200mb
# Get the connection URL
flyctl redis status $APP-redis
```

### Step 5: Set secrets

```bash
flyctl secrets set \
  SECRET_KEY="..." \
  DJANGO_SETTINGS_MODULE="myapp.settings.production" \
  -a $APP
```

---

## Provisioning on Heroku (less common target, but possible)

```bash
APP="myapp-new"
heroku create $APP

# Add Postgres
heroku addons:create heroku-postgresql:essential-0 -a $APP

# Add Redis
heroku addons:create heroku-redis:mini -a $APP

# Set config vars
heroku config:set SECRET_KEY="..." -a $APP
```

---

## Provisioning Checklist

- [ ] Project/app created on target provider
- [ ] Postgres provisioned — connection string saved to scratch dir
- [ ] Redis provisioned (if needed) — connection string saved
- [ ] Web service / app created
- [ ] GitHub repo connected (if using Git-based deploys)
- [ ] All env vars set (see phase-env-vars.md)
- [ ] Databases accessible from local machine (for Phase 2 data migration)
- [ ] No app code deployed yet (wait until after data migration)

**Save to scratch dir before proceeding:**
```bash
echo "TARGET_DB_URL=postgresql://..." >> ~/migration-$(date +%Y%m%d)/target-connections.txt
echo "TARGET_REDIS_URL=redis://..." >> ~/migration-$(date +%Y%m%d)/target-connections.txt
```
