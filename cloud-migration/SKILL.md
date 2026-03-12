---
name: cloud-migration
description: Execute full cloud provider migrations end-to-end — provision the new environment, migrate all data (Postgres, Redis, object storage), transfer env vars/secrets, deploy the app, verify data parity, cut over DNS, and clean up the old provider. Use this skill whenever someone wants to move their app between cloud providers (Render, Railway, Heroku, Fly.io, etc.), clone an environment as a backup, or is asking about migrating databases, services, or infrastructure to a new platform. Covers Django, Node, Rails, or any web app. Trigger on phrases like "migrate to Railway", "move off Heroku", "clone to Fly.io", "switch providers", "move our backend", or any request about copying an app from one cloud to another.
---

# Cloud Migration Playbook

This skill executes a full cloud migration — from audit to DNS cutover to cleanup. It's a hands-on execution guide, not a pricing comparison.

**Reference files — load on demand only.** Do NOT read all of these upfront. Read a file only when you reach that phase and need a specific command not already covered inline below:
- `references/railway.md` — only if source or target is Railway and you need MCP tool names
- `references/render.md` — only if source or target is Render and you need API patterns
- `references/fly.md` — only if source or target is Fly.io and you need flyctl patterns
- `references/phase-data.md` — only if pg_dump or Redis migration hits an edge case
- `references/phase-verify.md` — only if you need the full parity SQL checklist
- `references/providers.md` — only if provider is not Railway/Render/Fly

---

## Migration Overview

A migration has 6 phases. Don't skip any of them — each phase catches problems that would be expensive to debug later.

```
Phase 0: Audit     → know exactly what you're moving
Phase 1: Provision → stand up target infrastructure  
Phase 2: Data      → move Postgres, Redis, files
Phase 3: Deploy    → get app running on target
Phase 4: Verify    → confirm data parity and app health
Phase 5: Cutover   → switch DNS, monitor, then clean up
```

Start with **Phase 0** even if you think you know what's running — audits catch forgotten services, surprise cron jobs, and env vars you didn't know about.

**Frontend is part of the migration.** Most apps have a separate frontend (React/Vite, Next.js, etc.) deployed on a static host (Cloudflare Pages, Vercel, Netlify, S3). The frontend points at the backend via an env var (e.g., `VITE_BACKEND_URL`). If you move the backend without updating the frontend's env var and redeploying, the frontend still hits the old backend. Treat frontend as a first-class service in every phase.

---

## Phase 0: Audit Source

**Goal:** Know exactly what you're moving before touching anything.

The minimum you need (read `references/phase-audit.md` only if you need provider-specific export commands not covered below):

1. **Service list** — web, workers, cron jobs, background tasks
2. **Database list** — Postgres, Redis, MySQL, MongoDB, S3/storage buckets
3. **All env vars / secrets** — export now, before you forget
4. **Custom domains** — which services have them, SSL config
5. **Resource sizing** — RAM, CPU, replica count (to right-size on target)
6. **Integrations** — Sentry DSN, PostHog token, payment webhooks that know the old URL
7. **Frontend** — where is it deployed (Cloudflare Pages, Vercel, Netlify, S3)? What env var points it at the backend (`VITE_BACKEND_URL`, `NEXT_PUBLIC_API_URL`, etc.)? Are any backend URLs hardcoded in source rather than env vars? Check: `grep -r "onrender.com\|railway.app\|fly.dev\|heroku.com" src/`

Dump everything to a local audit file:
```bash
# Create a migration scratch directory
mkdir -p ~/migration-$(date +%Y%m%d) && cd ~/migration-$(date +%Y%m%d)
# Save env vars, service list, etc. here — reference throughout
```

---

## Phase 1: Provision Target

**Goal:** Target infra is live, databases provisioned, but no data yet.

Read `references/phase-provision.md` only if you need provider-specific commands not covered inline.

Key decisions:
- **Match resource sizing** from audit (or slightly upsize — not downsize)
- **Provision databases first** — you need connection strings before setting env vars
- **Don't deploy app code yet** — you want the DB to have data before first deploy
- **Get all connection strings** and save them to your scratch dir
- **Frontend hosting** — if the frontend needs a new deployment target (new Cloudflare Pages project, Vercel project, etc.), create it now. If the frontend stays on the same host and just needs a new env var, note the new backend URL for Phase 3.

For Railway specifically (most common target):
```bash
# See references/railway.md for full Railway MCP + CLI reference
# Quick summary:
railway link --project <id>
railway add --database postgres
railway add --database redis
railway variable set KEY=value ...
```

---

## Phase 2: Migrate Data

**Goal:** All data on target matches source.

Read `references/phase-data.md` only if you hit an edge case not covered by the commands below.

### Postgres (quick reference)
```bash
# Dump source (directory format required for parallel jobs)
pg_dump "$SOURCE_DB_URL" -Fd -Z6 -j4 -f migration.dump

# Restore to target
pg_restore -d "$TARGET_DB_URL" --no-owner --no-privileges -j4 migration.dump
```

**Critical:** Run row-count verification before proceeding to Phase 3. See `references/phase-verify.md` for the parity SQL.

### Redis (quick reference)
```bash
# If you have access to source Redis CLI:
redis-cli -u "$SOURCE_REDIS_URL" --rdb /tmp/redis-dump.rdb
# Restore: stop target Redis, replace dump.rdb, restart
# OR use MIGRATE command for online migration — see phase-data.md
```

### No source access (provider deactivated)?
If the source provider is gone (e.g., account deleted, Render deactivated), you're starting fresh. Skip to Phase 3 and run Django migrations to rebuild the schema. Document this in your migration notes.

---

## Phase 3: Deploy

**Goal:** App is running on target and connecting to migrated data.

1. **Trigger deploy** on target provider (GitHub push, `railway up`, `fly deploy`, etc.)
2. **Run schema migrations** if needed (`python manage.py migrate`, `rails db:migrate`)
3. **Check deploy logs** for startup errors — DB connection failures are the most common
4. **Hit the health endpoint** — expect 200

```bash
# After deploy, quick health check:
curl -I https://your-new-domain.railway.app/health/
```

5. **Deploy frontend** — update the backend URL env var to point at the new backend, then rebuild and redeploy:
   - Cloudflare Pages: update env var in dashboard → trigger new deployment
   - Vercel: `vercel env add VITE_BACKEND_URL` → `vercel --prod`
   - Netlify: update env var in dashboard → trigger deploy
   - If URLs were hardcoded in source: fix them, commit, push

```bash
# Example: build frontend locally with new backend URL
VITE_BACKEND_URL=https://new-backend.fly.dev npm run build
# Then deploy the dist/ folder to your static host
```

Common issues:
- `DATABASE_URL` not set or wrong format → check env vars, check service references
- ASGI vs WSGI misconfiguration (Django) → check Procfile and gunicorn command
- Missing `PORT` binding → app must listen on `0.0.0.0:$PORT`
- Frontend still hitting old backend → check build-time env vars were set before the build (not after)
- Hardcoded backend URLs in source → grep for old provider domains, fix before building

---

## Phase 4: Verify Parity

**Goal:** Confirm data migrated correctly and app is healthy.

Read `references/phase-verify.md` only if you need the full parity SQL checklist.

Minimum checks:
1. **Row counts** — compare source and target for top 10 tables
2. **Spot checks** — verify 2-3 specific records you know exist
3. **Auth** — can you log in? Does a user you know exist?
4. **Key API endpoints** — hit `/api/v1/...` and check responses
5. **Admin panel** — accessible and showing data
6. **Background workers** — are they running? Check task queues
7. **Integrations** — Sentry, PostHog, webhooks pointed at new domain?
8. **Frontend** — load the frontend URL in a browser, open DevTools Network tab, confirm API calls are hitting the new backend URL (not the old one). Check for CORS errors. Test a full user flow end-to-end (login, load data, key actions).

Don't cut over DNS until this passes.

---

## Phase 5: DNS Cutover

**Goal:** Traffic moves to new provider.

Read `references/phase-dns.md` only if you need TTL strategy details beyond the safe cutover sequence below.

**Safe cutover sequence:**
1. Lower DNS TTL to 60s **24 hours before** cutover (so rollback is fast)
2. Verify new environment passes all Phase 4 checks
3. Update backend CNAME/A record to new provider
4. **Update frontend** — if frontend has its own domain, update its DNS too. If frontend is already pointing at new backend via env var, just confirm the deployment is live.
5. Monitor logs on both old and new for 15-30 minutes
6. Confirm SSL provisioned on new provider (both backend and frontend domains)
7. Keep old environment alive for 48h (confidence window)
8. Decommission old environment after 48h with no issues

```
# Railway custom domain:
railway domain api.myapp.com
# Prints: CNAME → <hash>.up.railway.app
# Update your DNS registrar to point api.myapp.com CNAME to that target
```

---

## Phase 6: Cleanup

After the 48-hour confidence window:

1. **Remove old provider services** — don't leave them running (costs money, security risk)
2. **Remove test services on target** — any scratch/test services you created
3. **Rotate secrets** — the old provider saw all your secrets; rotate critical ones
4. **Update documentation** — internal docs, runbooks, team wikis
5. **Archive migration notes** — keep the dump file and audit notes for 30 days

---

## Common Failure Modes

| Problem | Cause | Fix |
|---------|-------|-----|
| App won't start | Wrong PORT binding | Ensure `0.0.0.0:$PORT` not unix socket |
| DB connection refused | Wrong URL format | Use public proxy URL for external access |
| pg_restore errors on roles | Role mismatch | Add `--no-owner --no-privileges` |
| Redis data missing | RDB restore not flushed | `FLUSHALL` before restore |
| 502 on new domain | Deploy not healthy yet | Check deploy logs, wait for health check |
| DNS not propagating | TTL too high | Check TTL was lowered beforehand |
| Frontend hitting old backend | Env var not set at build time | Rebuild frontend with correct `VITE_BACKEND_URL` / `NEXT_PUBLIC_API_URL` |
| CORS errors on new backend | New domain not in ALLOWED_HOSTS or CORS config | Add new backend domain to CORS whitelist and `ALLOWED_HOSTS` |
| Frontend loads but data is wrong | Frontend cached old API responses | Hard refresh, clear service worker, check CDN cache |

---

## Provider Quick Reference

See `references/providers.md` for the full matrix of MCP availability, CLI tools, and connection string formats per provider.

| Migration | MCP | CLI | Notes |
|-----------|-----|-----|-------|
| Render → Railway | ❌ → ✅ | API only → `railway` | Most common. pg URL from Render dashboard |
| Heroku → Railway | ❌ → ✅ | `heroku` → `railway` | `heroku pg:backups:capture` for DB dump |
| Railway → Fly.io | ✅ → ✅ | `railway` → `flyctl` | Fly.io MCP: `flyctl mcp server` (built-in). Fly volumes for persistent storage. |
| Render → Fly.io | ❌ → ✅ | API → `flyctl` | Fly.io MCP built-in via `flyctl mcp server` |
