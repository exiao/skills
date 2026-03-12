# Phase 2: Data Migration

Move all data from source to target. This is the riskiest phase — do it carefully, verify everything, and keep the source running until parity is confirmed.

**Safety rule:** Never delete source data until Phase 4 (parity verification) passes.

---

## Postgres Migration

### Prerequisites

```bash
# Ensure libpq tools match or are lower version than source
psql --version && pg_dump --version

# macOS install (Postgres 17):
brew install libpq
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
# Add to ~/.zshrc for persistence

# Check versions match:
psql "$SOURCE_DB_URL" -c "SELECT version();"  # source Postgres version
pg_dump --version                              # must be >= source version
```

### Step 1: Dump source database

```bash
# Custom format (preferred): compressed, supports parallel restore, selective table restore
# Directory format is required for parallel dump (-j). Custom format (-Fc) does not support -j.
pg_dump "$SOURCE_DB_URL" \
  -Fd \
  -Z6 \
  -j4 \
  -f migration_$(date +%Y%m%d_%H%M%S).dump \
  --no-owner \
  --no-privileges

# Plain SQL (use if custom format causes issues on restore):
pg_dump "$SOURCE_DB_URL" \
  --no-owner --no-privileges \
  -f migration_$(date +%Y%m%d_%H%M%S).sql
```

### Step 2: Verify dump

```bash
# Custom format: verify integrity
pg_restore --list migration.dump | head -30  # should show table of contents

# Check file size is reasonable (shouldn't be tiny)
ls -lh migration.dump
```

### Step 3: Restore to target

```bash
# From custom-format dump (parallel restore)
pg_restore \
  -d "$TARGET_DB_URL" \
  --no-owner \
  --no-privileges \
  -j4 \                     # parallel restore
  migration.dump

# From SQL dump
psql "$TARGET_DB_URL" < migration.sql
```

**Expected errors (harmless):**
- `role "xyz" does not exist` — because `--no-owner` strips role names but restore may still warn
- `extension "postgis" does not exist` — if you don't use spatial features
- `already exists` warnings if restore is retried

**Real errors to fix:**
- `connection refused` — wrong URL or DB not accessible
- `authentication failed` — wrong password
- `database does not exist` — target DB not created yet

### Step 4: Verify row counts

```bash
# Run on both source and target, compare output
ROW_COUNT_QUERY="
SELECT schemaname, relname, n_live_tup
FROM pg_stat_user_tables
WHERE n_live_tup > 0
ORDER BY n_live_tup DESC
LIMIT 20;
"

echo "=== SOURCE ===" && psql "$SOURCE_DB_URL" -c "$ROW_COUNT_QUERY"
echo "=== TARGET ===" && psql "$TARGET_DB_URL" -c "$ROW_COUNT_QUERY"
```

Counts should match exactly (or within a few rows if the source is actively receiving writes).

### Heroku-specific dump

Heroku manages Postgres backups differently:

```bash
APP="myapp"
# Create a fresh backup
heroku pg:backups:capture -a $APP

# Get download URL (expires in a few hours)
BACKUP_URL=$(heroku pg:backups:url -a $APP)
curl -o heroku-backup.dump "$BACKUP_URL"

# Restore (same as above)
pg_restore -d "$TARGET_DB_URL" --no-owner --no-privileges -j4 heroku-backup.dump
```

Or use direct connection (if Heroku allows external connections on your plan):
```bash
SOURCE_DB_URL=$(heroku config:get DATABASE_URL -a $APP)
pg_dump "$SOURCE_DB_URL" -Fc -Z6 -j4 -f heroku-migration.dump
```

### Render-specific dump

Get the external connection string from Render dashboard (not the internal one):
- Go to your Postgres service → Connect tab → External Database URL

```bash
SOURCE_DB_URL="postgres://user:pass@dpg-xxxx.render.com:5432/dbname"
pg_dump "$SOURCE_DB_URL" -Fc -Z6 -j4 -f render-migration.dump
```

Note: Render external connections may require SSL (`?sslmode=require`):
```bash
pg_dump "${SOURCE_DB_URL}?sslmode=require" -Fc -Z6 -f render-migration.dump
```

---

## Redis Migration

### Option A: RDB file dump (offline — requires Redis restart)

Best for: staging migrations, when you can tolerate a few minutes of downtime.

```bash
# Trigger BGSAVE and wait for completion
redis-cli -u "$SOURCE_REDIS_URL" BGSAVE
# Wait for: redis-cli -u "$SOURCE_REDIS_URL" LASTSAVE  (check timestamp changes)

# Download the RDB file (varies by provider access)
# If you have filesystem access:
cp /var/lib/redis/dump.rdb ~/migration/redis-dump.rdb

# Restore: stop target Redis, replace dump.rdb, restart
# (Usually you can't do this with managed Redis — use MIGRATE instead)
```

### Option B: MIGRATE command (online — no downtime)

Best for: managed Redis instances where you have CLI access to both.

```bash
# Connect to source Redis and migrate all keys to target
SOURCE_HOST="source.redis.host"
SOURCE_PORT="6379"
TARGET_HOST="target.redis.host"
TARGET_PORT="6379"
TARGET_AUTH="target-password"

redis-cli -u "$SOURCE_REDIS_URL" \
  --scan \
  | xargs -I {} redis-cli -u "$SOURCE_REDIS_URL" \
    MIGRATE "$TARGET_HOST" "$TARGET_PORT" {} 0 5000 AUTH "$TARGET_AUTH"
```

### Option C: redis-dump tool (CLI utility)

```bash
# Install
npm install -g redis-dump

# Dump
redis-dump -u "$SOURCE_REDIS_URL" > redis-data.json

# Restore
cat redis-data.json | redis-load -u "$TARGET_REDIS_URL"
```

### Verify Redis migration

```bash
# Compare key counts
echo "Source keys:" && redis-cli -u "$SOURCE_REDIS_URL" DBSIZE
echo "Target keys:" && redis-cli -u "$TARGET_REDIS_URL" DBSIZE

# Spot check a few keys
redis-cli -u "$SOURCE_REDIS_URL" KEYS "user:*" | head -5 | \
  while read KEY; do
    echo "Key: $KEY"
    echo "  Source: $(redis-cli -u $SOURCE_REDIS_URL GET $KEY)"
    echo "  Target: $(redis-cli -u $TARGET_REDIS_URL GET $KEY)"
  done
```

---

## File / Object Storage Migration

### S3 to S3 (or S3-compatible)

```bash
# Install rclone
brew install rclone

# Configure source (e.g., AWS S3)
rclone config  # interactive setup

# Sync bucket to local first, then to target
rclone sync s3:my-source-bucket /tmp/storage-backup/ --progress
rclone sync /tmp/storage-backup/ s3:my-target-bucket --progress

# Or direct sync (no local copy)
rclone sync s3:my-source-bucket s3:my-target-bucket --progress
```

### Render disk to S3

Render has no persistent disk by default (each deploy is fresh). If you use Render disk storage:

```bash
# SSH into Render service (if SSH enabled)
rsync -avz user@ssh.render.com:/app/storage/ /tmp/render-storage/
rclone sync /tmp/render-storage/ s3:my-target-bucket --progress
```

### Heroku to S3

Heroku also has no persistent storage (ephemeral filesystem). Any persistent files should already be on S3/Cloudinary/etc. No migration needed — just update env vars to point to the same storage bucket.

---

## Data Migration Checklist

- [ ] `pg_dump` completed successfully (check exit code = 0)
- [ ] Dump file size is reasonable (> 0, < something suspicious)
- [ ] `pg_restore` completed (check for real errors vs harmless warnings)
- [ ] Row counts match on top 20 tables
- [ ] Redis key counts match (if applicable)
- [ ] Object storage synced (if applicable)
- [ ] Source DB still running (don't decommission yet)

**Time estimates:**
- 100MB dump: ~5 min dump, ~5 min restore
- 1GB dump: ~15 min dump, ~20 min restore
- 10GB dump: ~45 min dump, ~60 min restore
