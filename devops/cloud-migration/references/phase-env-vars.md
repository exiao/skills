# Phase 1b: Environment Variables & Secrets Migration

Env vars are almost always the #1 cause of post-migration issues. A missing var = silent failure or broken feature. Take this phase seriously.

---

## Strategy

**Copy everything, then override production values.** Don't try to filter — copy all vars from source, then override the ones that need new values (DB URL, domain names, secrets that should be rotated).

**Vars that always need changing after migration:**
- `DATABASE_URL` — new target DB connection string
- `REDIS_URL` — new target Redis connection string
- `ALLOWED_HOSTS` / `HOST` — new domain names
- Any var that references the old provider's domain or service name

**Vars that should be rotated (security best practice):**
- `SECRET_KEY` / `JWT_SECRET` — generate a fresh one
- OAuth credentials (if the old provider's IP/domain is whitelisted anywhere)
- Any API key that was scoped to the old domain

---

## Exporting Vars from Source

### From Render

```bash
RENDER_API_KEY="rnd_..."
SERVICE_ID="srv-..."

# Export as KEY=VALUE pairs
curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
  "https://api.render.com/v1/services/$SERVICE_ID/env-vars" \
  | python3 -c "
import sys, json
for item in json.load(sys.stdin):
    key = item['envVar']['key']
    val = item['envVar']['value']
    # Skip service references (they're dynamic)
    if not val.startswith('@'):
        print(f'{key}={val}')
" > source-env-vars.txt
```

If you used an env group (Render's shared config):
```bash
ENV_GROUP_ID="evg-..."
curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
  "https://api.render.com/v1/env-groups/$ENV_GROUP_ID/env-vars" \
  | python3 -c "
import sys, json
for item in json.load(sys.stdin):
    print(f\"{item['envVar']['key']}={item['envVar']['value']}\")
" >> source-env-vars.txt
```

### From Heroku

```bash
APP="myapp"

# JSON format (all vars)
heroku config -a $APP --json > heroku-config.json

# .env format
heroku config -a $APP --json \
  | python3 -c "import sys,json; [print(f'{k}={v}') for k,v in json.load(sys.stdin).items()]" \
  > source-env-vars.txt

# Verify count
wc -l source-env-vars.txt
```

### From Railway (when Railway is source)

```bash
# Must be linked to service
cd ~/myapp && railway link
railway variable list                # display in terminal
railway variable list --json > railway-vars.json  # save as JSON
```

### From Fly.io

Fly secrets are intentionally not exportable (security design). You need to retrieve them manually:

```bash
flyctl secrets list -a $APP        # shows key names only
flyctl ssh console -a $APP         # SSH in, then:
# Inside SSH session:
printenv | sort > /tmp/env-dump.txt
# Then: flyctl ssh sftp get /tmp/env-dump.txt ./fly-env-dump.txt -a $APP
```

Or check your local `.env` file — most teams keep these in sync locally.

---

## Setting Vars on Target

### On Railway

```bash
# Single set command with all vars (most efficient):
railway variable set \
  KEY1="value1" \
  KEY2="value2" \
  KEY3="value3"

# From a file (parse key=value pairs):
while IFS='=' read -r key value; do
  [[ "$key" =~ ^#.*$ ]] && continue  # skip comments
  [[ -z "$key" ]] && continue        # skip empty lines
  railway variable set "$key=$value"
done < source-env-vars.txt

# Service references (dynamic — better than hardcoded URLs):
railway variable set 'DATABASE_URL=${{Postgres.DATABASE_URL}}'
railway variable set 'REDIS_URL=${{Redis.REDIS_URL}}'
```

Via MCP (for non-interactive use):
```bash
mcporter call railway.set-variables \
  workspacePath="$(pwd)" \
  variables='{"KEY1":"val1","KEY2":"val2"}'
```

### On Fly.io

```bash
# Set secrets (encrypted, not visible in logs)
flyctl secrets set KEY1="value1" KEY2="value2" -a $APP

# From file
flyctl secrets import -a $APP < source-env-vars.txt

# Check what's set
flyctl secrets list -a $APP
```

### On Heroku

```bash
# Set config vars
heroku config:set KEY1="value1" KEY2="value2" -a $APP

# From file
heroku config:set $(cat source-env-vars.txt | tr '\n' ' ') -a $APP
```

---

## Production Overrides

After importing all source vars, apply these production overrides:

```bash
# Django example
railway variable set \
  DEBUG="false" \
  ALLOWED_HOSTS="api.myapp.com,*.railway.app" \
  DATABASE_URL='${{Postgres.DATABASE_URL}}' \
  REDIS_URL='${{Redis.REDIS_URL}}' \
  WORKERS="2"   # tune to available memory

# Generate new SECRET_KEY for Django
python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# Node.js / Express example
railway variable set \
  NODE_ENV="production" \
  PORT="$PORT"   # Railway injects PORT automatically, no need to set
```

---

## Verification

```bash
# Check all expected vars are present
railway variable list | grep -E "DATABASE_URL|REDIS_URL|SECRET_KEY|DJANGO_SETTINGS_MODULE"

# Count total vars (should roughly match source count)
railway variable list --json | python3 -c "import sys,json; print(f'Total vars: {len(json.load(sys.stdin))}')"
```

---

## Security Notes

- **Never commit `source-env-vars.txt` to git.** It contains credentials.
- Add it to `.gitignore` immediately: `echo "source-env-vars.txt" >> .gitignore`
- After migration is complete and confidence window passes: `shred -u source-env-vars.txt` (or at least `rm source-env-vars.txt`)
- The old provider's team had access to all these secrets. If your threat model requires it, rotate all API keys after migration.
