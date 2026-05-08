---
name: ops-center-reference
description: "Fintary ops-center v2 architecture, API proxy pattern, infrastructure, env vars, and related repos. Read before any ops-center work."
---

# Fintary Ops-Center Reference

## Architecture (v2 - May 2026)
- **Stack**: FastAPI + Jinja2 + HTMX, Python backend
- **Hosting**: Render (service ID: `$RENDER_SERVICE_ID`)
- **Deploy URL**: `$OPS_CENTER_URL`
- **Auth**: Firebase (`env-configured` project), env vars for config (not hardcoded)
- **No database**: All data from Fintary OpenAPI (`$FINTARY_API_HOST`)
- **Repo**: `$OPS_CENTER_REPO`

## API Proxy Pattern
- Frontend calls `/api/fintary/*` (same-origin, no CORS)
- `app/api/proxy.py` forwards GET requests to `$FINTARY_API_HOST` server-side
- Same pattern as `$CS_SOLUTIONS_REPO` agent portal
- GET only, path allowlisted (`/openapi/*`, `/api/admin/analytics/*`), Firebase Bearer token forwarded
- Module-level httpx client with connection pooling, lifespan shutdown cleanup

## Fintary API Infrastructure
- `$FINTARY_API_HOST`: Cloud Run, deployed via Cloud Build
- `$FINTARY_APP_HOST`: React (Vite + MUI) on Firebase Hosting
- Database: AlloyDB (managed PostgreSQL)
- Secrets: GCP Secret Manager
- 3 Cloud Run services: `api`, `task-worker`, `commission-worker`
- CORS: `api/lib/middlewares/cors.ts` — only `$FINTARY_APP_HOST` by default, `CORS_ALLOWED_ORIGINS` env var override available

## Env Vars on Render
- See .env.example for required environment variables

## Key PRs (all merged unless noted)
- PR #65: v2 rewrite
- PR #66: Firebase login fix
- PR #67: API proxy
- PR #68: claude-code-review.yml cleanup (open)

## Related Repos
- `$FINTARY_REPO`: Main app (Next.js monorepo, api/ + web/)
- `$CS_SOLUTIONS_REPO`: Agent portal (proxy pattern reference)
