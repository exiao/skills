# Fly.io Reference

Fly.io is used as both a source and target provider. **MCP is built into flyctl** (`flyctl mcp server`) — use it for natural language provisioning. Falls back to `flyctl` CLI for operations not covered by MCP.

## MCP Server (built-in)

```bash
# Start the Fly.io MCP server (built into flyctl, no separate install)
flyctl mcp server

# Configure in mcporter.json:
# {
#   "fly": {
#     "command": "flyctl mcp server"
#   }
# }
```

Covers: volume management, machine provisioning, app creation, secrets, logs. Use `mcporter call fly <tool>` once configured.

## Setup

```bash
# Install
brew install flyctl
# or: curl -L https://fly.io/install.sh | sh

# Auth
flyctl auth login    # opens browser

# Verify
flyctl auth whoami
```

---

## CLI Quick Reference

### Apps

```bash
flyctl apps list                     # list all your apps
flyctl apps create myapp             # create new app
flyctl apps destroy myapp            # delete app (irreversible)
flyctl status -a myapp               # app status
flyctl open -a myapp                 # open in browser
```

### Machines (replaces old VM model)

```bash
flyctl machines list -a myapp       # list running machines
flyctl machines start <id> -a myapp # start a machine
flyctl machines stop <id> -a myapp  # stop a machine
```

### Deploy

```bash
# From directory with fly.toml
flyctl deploy -a myapp              # build + deploy
flyctl deploy --no-cache -a myapp   # force fresh build
flyctl deploy --image registry.fly.io/myapp:latest  # from image
```

### Secrets (env vars)

```bash
flyctl secrets list -a myapp                        # list key names (not values)
flyctl secrets set KEY1=value1 KEY2=value2 -a myapp # set secrets
flyctl secrets import -a myapp < env-vars.txt        # import from file
flyctl secrets unset KEY1 -a myapp                  # remove a secret
```

**Note:** Fly secrets are one-way — you can set and unset them, but you can't read the values back via CLI. To retrieve values, SSH into a machine and run `printenv`.

```bash
flyctl ssh console -a myapp    # SSH into the app
# Inside:
printenv | sort
```

### Logs

```bash
flyctl logs -a myapp            # stream live logs
flyctl logs -a myapp --no-tail  # recent logs (no stream)
```

### Scaling

```bash
flyctl scale show -a myapp      # current scale
flyctl scale count 2 -a myapp   # set to 2 machines
flyctl scale memory 512 -a myapp  # set RAM (MB)
flyctl scale vm shared-cpu-1x -a myapp  # set VM size
```

---

## Postgres on Fly.io

Fly Postgres is a separately deployed Fly app (not a managed service).

### Create Postgres

```bash
flyctl postgres create \
  --name myapp-db \
  --region iad \
  --vm-size shared-cpu-1x \
  --volume-size 1 \
  --initial-cluster-size 1   # single node (dev/staging)
  # Use 3 for HA production
```

### Attach to your app

```bash
flyctl postgres attach myapp-db -a myapp
# Sets DATABASE_URL secret automatically on myapp
```

### Connect to Postgres (from local machine)

Fly Postgres is internal-only by default. Use proxy to connect:

```bash
# Start proxy (forward local 5432 → Fly Postgres)
flyctl proxy 5432 -a myapp-db &

# Now connect locally
psql "postgresql://postgres:<password>@localhost:5432/myapp"

# Or get full connection string
flyctl postgres connect -a myapp-db  # opens psql session
```

### pg_dump from Fly Postgres

```bash
# Start proxy
flyctl proxy 5432 -a myapp-db &
PROXY_PID=$!

# Dump through proxy
LOCAL_DB_URL="postgresql://postgres:<pass>@localhost:5432/myapp"
pg_dump "$LOCAL_DB_URL" -Fc -Z6 -j4 -f fly-backup.dump --no-owner --no-privileges

# Stop proxy
kill $PROXY_PID
```

### Restore to Fly Postgres

```bash
flyctl proxy 5432 -a myapp-db &

pg_restore -d "postgresql://postgres:<pass>@localhost:5432/myapp" \
  --no-owner --no-privileges -j4 backup.dump

kill $PROXY_PID
```

### Fly Postgres connection string format

```
# External (via proxy): 
postgresql://postgres:<password>@localhost:5432/myapp

# Internal (within Fly network):
postgresql://postgres:<password>@myapp-db.flycast:5432/myapp
```

---

## Redis on Fly.io (Upstash)

Fly.io integrates with Upstash for Redis:

```bash
# Create
flyctl redis create --name myapp-redis --region iad --plan 200mb

# List
flyctl redis list

# Get connection URL
flyctl redis status myapp-redis

# Connect
flyctl redis connect myapp-redis    # opens redis-cli session
```

Upstash Redis URL format:
```
rediss://default:<password>@<hash>.upstash.io:6379
```

Note the `rediss://` (with double s) — Upstash uses TLS.

---

## fly.toml for Django

```toml
app = "myapp-prod"
primary_region = "iad"
kill_signal = "SIGTERM"
kill_timeout = "5s"

[build]
  # Dockerfile is auto-detected, or specify:
  # dockerfile = "Dockerfile"

[env]
  PORT = "8080"
  DJANGO_SETTINGS_MODULE = "myapp.settings.production"

[deploy]
  release_command = "python manage.py migrate --noinput"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 1
  [http_service.concurrency]
    type = "connections"
    hard_limit = 25
    soft_limit = 20

[[vm]]
  memory = "512mb"
  cpu_kind = "shared"
  cpus = 1
```

### Dockerfile for Django + Fly

```dockerfile
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev gcc && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN python manage.py collectstatic --noinput

EXPOSE 8080
CMD gunicorn myapp.asgi:application \
    -k uvicorn.workers.UvicornWorker \
    --bind 0.0.0.0:8080 \
    --workers 2
```

---

## Custom Domains on Fly.io

```bash
# Add domain
flyctl certs create api.myapp.com -a myapp

# Check cert status
flyctl certs show api.myapp.com -a myapp

# List all certs
flyctl certs list -a myapp
```

DNS record to set:
```
Type:  CNAME
Name:  api
Value: myapp.fly.dev   (or the CNAME target shown by certs create)
```

Fly.io supports both CNAME and A records. Fly provides dedicated IPs:
```bash
flyctl ips list -a myapp          # show assigned IPs
flyctl ips allocate-v4 -a myapp   # allocate dedicated IPv4 (billed)
```

---

## Railway → Fly.io Migration Pattern

1. **Provision Fly app** + Postgres + Redis (as above)
2. **Export Railway data:**
   ```bash
   # Railway: link to Postgres, get public URL
   railway service link Postgres
   DB_URL=$(railway variable list --json | python3 -c "import sys,json; print(json.load(sys.stdin)['DATABASE_PUBLIC_URL'])")
   pg_dump "$DB_URL" -Fc -Z6 -j4 -f railway-backup.dump
   ```
3. **Start Fly Postgres proxy** and restore backup
4. **Set secrets** on Fly from Railway vars
5. **Deploy to Fly**
6. **Verify parity** (see phase-verify.md)
7. **Cut over DNS** to Fly domain

---

## Common Fly.io Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Deploy timeout | Health check not responding | App must respond on internal_port within timeout |
| DB connection refused | Using flycast URL outside Fly | Use proxy for external access |
| Secrets not showing | Fly secrets are one-way | SSH in and run `printenv` |
| High memory usage | Python keeping connections | Tune `--max-requests` in gunicorn |
| Auto-stop killing app | min_machines_running = 0 | Set min_machines_running = 1 for always-on |
