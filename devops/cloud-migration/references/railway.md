# Railway Reference

Full reference for Railway MCP tools and CLI patterns used in migrations.

## Setup

**MCP:** Configured in `config/mcporter.json` as `railway` (stdio: `npx -y @railway/mcp-server`)
**CLI:** `brew install railway` → `railway login`
**Auth check:** `railway whoami` or `mcporter call railway.check-railway-status`

---

## MCP Tools

Call via: `mcporter call railway.<tool> key=value`

### Project management

```bash
# List all projects
mcporter call railway.list-projects

# Create new project and link current directory
mcporter call railway.create-project-and-link name="myapp-production"

# List services in a project
mcporter call railway.list-services workspacePath="/path/to/project"

# Link to an existing service
mcporter call railway.link-service workspacePath="/path/to/project" serviceName="web"
```

### Environment variables

```bash
# List all variables for linked service
mcporter call railway.list-variables workspacePath="/path/to/project"

# Set multiple variables at once
mcporter call railway.set-variables \
  workspacePath="/path/to/project" \
  variables='{"KEY1":"val1","KEY2":"val2","DEBUG":"false"}'
```

### Deploy

```bash
# Deploy current directory
mcporter call railway.deploy workspacePath="/path/to/project"

# Get logs
mcporter call railway.get-logs workspacePath="/path/to/project" logType="deploy"
mcporter call railway.get-logs workspacePath="/path/to/project" logType="build"
```

### Domains

```bash
# Generate a Railway domain (*.railway.app)
mcporter call railway.generate-domain workspacePath="/path/to/project"
```

---

## CLI Reference

### Linking

```bash
railway link                           # interactive project/service picker
railway link --project <project-id>   # non-interactive
railway service link <service-name>   # link to specific service within project
```

### Deploying

```bash
railway up                   # deploy current directory (waits for deploy)
railway up --detach          # deploy and return immediately (shows build URL)
```

### Environment variables

```bash
# Set vars
railway variable set KEY=value KEY2=value2

# Service references (dynamic links between services):
railway variable set 'DATABASE_URL=${{Postgres.DATABASE_URL}}'
railway variable set 'REDIS_URL=${{Redis.REDIS_URL}}'

# List all vars
railway variable list
railway variable list --json    # JSON output for scripting

# Delete a var
railway variable delete KEY
```

### Databases

```bash
# Add Postgres
railway add --database postgres

# Add Redis
railway add --database redis

# Add MySQL
railway add --database mysql

# Add MongoDB
railway add --database mongo
```

### Services

```bash
# Add a new empty service
railway add --service <name>

# List services
railway service list

# Link to a service
railway service link <name>
```

### Logs

```bash
railway logs              # stream logs for linked service
railway logs --build      # build logs only
railway logs --deploy     # deploy logs only (runtime)
```

### Domains

```bash
railway domain                        # auto-generate *.railway.app domain
railway domain api.myapp.com          # add custom domain (prints CNAME record)
```

### Environment management

```bash
railway environment                   # list environments
railway environment create staging    # create new environment
railway environment link staging      # switch to staging environment
```

---

## DB Connection Strings on Railway

Railway Postgres has two URL types:

```bash
# Internal (for services within the same project):
DATABASE_URL = postgresql://postgres:<pass>@Postgres.railway.internal:5432/railway

# Public / External (for pg_dump, local dev, migrations from outside):
DATABASE_PUBLIC_URL = postgresql://postgres:<pass>@<hash>.proxy.rlwy.net:<port>/railway
```

**Always use `DATABASE_PUBLIC_URL` for:**
- `pg_dump` from your laptop
- `pg_restore` from your laptop
- Any connection from outside Railway's network

**Use `DATABASE_URL` (internal) for:**
- App connection string within Railway (faster, no proxy overhead)
- Set via service reference: `${{Postgres.DATABASE_URL}}`

### Getting the public URL

```bash
cd ~/myproject
railway service link Postgres
railway variable list --json \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('DATABASE_PUBLIC_URL','not found'))"
```

---

## Django on Railway — Common Config

### Procfile

```
web: gunicorn -c gunicorn.conf.py myapp.asgi:application
release: python manage.py migrate --noinput
```

**Use `asgi:application` not `wsgi` when using UvicornWorker.**

### gunicorn.conf.py

```python
import os

# Railway injects PORT — bind to it (not a unix socket)
bind = f"0.0.0.0:{os.environ.get('PORT', '8000')}"
workers = int(os.environ.get("WORKERS", 2))
worker_class = "uvicorn.workers.UvicornWorker"
timeout = 120
keepalive = 5
```

### .python-version

```
3.11.11
```
(or whatever version you need — Nixpacks reads this file)

### Key env vars for Railway Django

```bash
railway variable set \
  DEBUG="false" \
  DJANGO_SETTINGS_MODULE="myapp.settings.production" \
  ALLOWED_HOSTS="api.myapp.com,*.railway.app" \
  DATABASE_URL='${{Postgres.DATABASE_URL}}' \
  REDIS_URL='${{Redis.REDIS_URL}}' \
  WORKERS="2" \
  SECRET_KEY="$(python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')"
```

---

## Railway Project IDs (Bloom)

For reference when working on the Bloom app:

| Resource | Value |
|----------|-------|
| Project | `bloom-backend` (ID: `b81d6f59-32a5-4094-8bbd-8671f9e0888a`) |
| Web service | `bloom-web` (ID: `369dfa8d-471d-40c9-9c96-a48515354ad9`) |
| Postgres | `Postgres` (ID: `c9c78cb9-249e-46f9-bca6-8525ff49c176`) |
| Railway domain | `bloom-web-production-d709.up.railway.app` |
| Custom domain | `api.getbloom.app` → CNAME `tmnv267w.up.railway.app` |

---

## Common Railway Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| 502 Bad Gateway | App not binding to $PORT | Use `0.0.0.0:$PORT` in gunicorn |
| Build fails | Nixpacks can't find requirements | Add `requirements.txt` or `pyproject.toml` |
| DB connection refused | Using internal URL externally | Use `DATABASE_PUBLIC_URL` |
| WSGI vs ASGI error | Wrong Procfile | Use `app.asgi:application` for async Django |
| Migrations not running | `release:` not in Procfile | Add `release: python manage.py migrate` |
| Static files 404 | WhiteNoise not installed | Add `whitenoise` to requirements, update middleware |
| Deploy hangs | No health check response | App must respond on `$PORT` within 60s |
