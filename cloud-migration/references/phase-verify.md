# Phase 4: Parity Verification & Smoke Tests

Don't cut over DNS until this passes. The goal is to confirm the new environment has the same data and is functionally equivalent to the old one.

---

## Database Parity

### Row count comparison

Run this on both source and target, compare output:

```bash
ROW_COUNT_QUERY="
SELECT schemaname, relname, n_live_tup
FROM pg_stat_user_tables
WHERE n_live_tup > 0
ORDER BY n_live_tup DESC
LIMIT 20;
"

echo "=== SOURCE ===" 
psql "$SOURCE_DB_URL" -c "$ROW_COUNT_QUERY"

echo ""
echo "=== TARGET ==="
psql "$TARGET_DB_URL" -c "$ROW_COUNT_QUERY"
```

Counts should match exactly (or within a small delta if source is actively receiving writes during migration).

### Total table count

```bash
TABLE_COUNT_QUERY="
SELECT COUNT(*) as table_count 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
"

echo "Source tables:" && psql "$SOURCE_DB_URL" -c "$TABLE_COUNT_QUERY"
echo "Target tables:" && psql "$TARGET_DB_URL" -c "$TABLE_COUNT_QUERY"
```

### Schema completeness

```bash
SCHEMA_QUERY="
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;
"

psql "$SOURCE_DB_URL" -c "$SCHEMA_QUERY" > /tmp/source-tables.txt
psql "$TARGET_DB_URL" -c "$SCHEMA_QUERY" > /tmp/target-tables.txt
diff /tmp/source-tables.txt /tmp/target-tables.txt
# Should be empty diff
```

### Spot check specific records

Pick 2-3 records you know exist and verify they're on target:

```bash
# Example: verify a specific user exists
psql "$TARGET_DB_URL" -c "SELECT id, email, created_at FROM auth_user WHERE email = 'test@example.com';"

# Example: verify recent data made it across
psql "$TARGET_DB_URL" -c "SELECT COUNT(*) FROM orders WHERE created_at > NOW() - INTERVAL '7 days';"
```

### Django migration state

For Django apps — verify all migrations are applied on target:

```bash
python manage.py showmigrations --database=target 2>/dev/null
# All should show [X] (applied)

# If not: run migrations
python manage.py migrate --database=target
```

---

## Redis Parity

```bash
# Key count comparison
echo "Source Redis keys:" && redis-cli -u "$SOURCE_REDIS_URL" DBSIZE
echo "Target Redis keys:" && redis-cli -u "$TARGET_REDIS_URL" DBSIZE

# Memory usage comparison (approximate)
echo "Source memory:" && redis-cli -u "$SOURCE_REDIS_URL" INFO memory | grep used_memory_human
echo "Target memory:" && redis-cli -u "$TARGET_REDIS_URL" INFO memory | grep used_memory_human
```

Note: Redis key counts won't match exactly if there are session-type keys with short TTLs — those may have expired during migration. Focus on persistent keys (user data, cache data that has long TTL or no TTL).

---

## Application Smoke Tests

### Health check

```bash
# Using the new Railway/Fly domain (before DNS cutover):
NEW_DOMAIN="myapp-production.up.railway.app"

curl -I https://$NEW_DOMAIN/health/
# Expect: HTTP/2 200
```

### Auth flow

```bash
# Test login endpoint
curl -s -X POST https://$NEW_DOMAIN/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass123"}' \
  | python3 -m json.tool

# Expect: JSON with token or session cookie
```

### Critical API endpoints

Identify your app's 3-5 most important API paths and hit them:

```bash
# Example: Django REST API
TOKEN="your-auth-token"

# List endpoint
curl -s -H "Authorization: Bearer $TOKEN" \
  https://$NEW_DOMAIN/api/v1/items/ | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'Items: {len(d[\"results\"])} returned')"

# Detail endpoint
curl -s -H "Authorization: Bearer $TOKEN" \
  https://$NEW_DOMAIN/api/v1/items/1/ | python3 -m json.tool

# Create endpoint
curl -s -X POST -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"test item"}' \
  https://$NEW_DOMAIN/api/v1/items/ | python3 -m json.tool
```

### Admin panel

```bash
curl -I https://$NEW_DOMAIN/admin/
# Expect: HTTP/2 302 (redirect to login) or 200
```

For Django: verify you can actually log into `/admin/` with a superuser account.

### Background workers

If you have Celery workers or similar:

```bash
# Check worker logs
mcporter call railway.get-logs workspacePath="$(pwd)" logType="deploy"
# Look for: "celery worker ready" or similar startup message

# Trigger a test task
python manage.py shell -c "from myapp.tasks import ping; result = ping.delay(); print(result.get(timeout=10))"
```

---

## Integration Checks

These often get forgotten and break silently after migration:

### Error tracking (Sentry)

After deploying: trigger a test error, verify it appears in Sentry.

```bash
# Via Django shell
python manage.py shell -c "
import sentry_sdk
sentry_sdk.capture_message('Migration verification test', level='info')
print('Sentry event sent — check Sentry dashboard')
"
```

### Analytics (PostHog, Mixpanel)

Trigger a test event, verify it appears in the analytics dashboard.

### Payment webhooks

If using Stripe/etc: update webhook endpoint URL in their dashboard to the new domain. Test with Stripe CLI:

```bash
stripe listen --forward-to https://$NEW_DOMAIN/api/webhooks/stripe/
stripe trigger payment_intent.created
```

### OAuth redirect URIs

Check Google OAuth, GitHub, Apple Sign-In dashboards — update allowed redirect URIs to include the new domain.

---

## Verification Checklist

**Data parity:**
- [ ] Row counts match for top 20 tables
- [ ] Table count matches
- [ ] Schema diff is empty
- [ ] 2-3 spot-check records found on target
- [ ] Django migrations all applied

**Application health:**
- [ ] `/health/` returns 200
- [ ] Auth flow works (login/token endpoint)
- [ ] 3+ critical API endpoints return expected data
- [ ] Admin panel accessible

**Background processes:**
- [ ] Workers started (check logs)
- [ ] Cron jobs configured and scheduled
- [ ] Test task executes successfully

**Integrations:**
- [ ] Sentry receiving events
- [ ] Analytics receiving events
- [ ] Payment webhooks updated
- [ ] OAuth redirect URIs updated

**Only proceed to DNS cutover when ALL of the above pass.**
