---
name: fintary-ops-center-context
category: project-context
description: Context and backlog for Fintary ops-center project
---

# Fintary Ops Center Project Context

## Repo
- GitHub: fintary/ops-center
- Stack: FastAPI + Jinja2 + Alpine.js + PiccoloORM + Postgres
- Tests: pytest, 569 tests as of 2026-04-18 (PR #42 added +8 tests for comp-profile CRUD, full suite ~4.4s)
- CI: GitHub Actions — ruff lint + pytest + claude-review
- Uses `uv sync --frozen` for dependency install in CI

## Key Structure
- `app/routes/` — all page routes
- `app/templates/` — Jinja2 templates with Alpine.js
- `specs/` — 7 spec docs: PRODUCT_VISION, REBUILD_SPEC, PRODUCT_DECISIONS, DATA_MODELS, QA_SESSION, DOGFOOD_REPORT
- `plans/` — audit and planning docs

## Completed Work (PR #40)
- Fixed sidebar active states across all 17 page routes
- Humanized agent type enum display

## Completed Work (PRs #37-39, babysit session)
- PR #37: refactor addressing PR #35 review comments — LGTM, no fixes needed
- PR #38: Added CI workflow (ruff lint + pytest) — fixed 4 test failures (missing mock patches for Agent, AgentHierarchy, CompProfile, PolicyAgent), fixed ruff formatting on app/pages.py, applied uv sync --frozen, restricted push trigger to main
- PR #39: Visual identity doc + CSS design system — fixed VISUAL-IDENTITY.md (token names --orange-* → --cta-*, corrected color values, aligned table tokens with CSS), fixed same test/lint/CI issues as PR #38

## Completed Work (PR #41, extended-test-coverage branch)
- Round 1: 9 extended service test files (96 tests) — ops_center, ingest, reconcile, calculate, pay, report, customer, grid, audit
- Round 2: `test_chat_extended.py` (29) + `test_cli_helpers.py` (14)
- Round 3: `test_api_extended.py` (52 router tests) + `test_cli_commands.py` (27) + `test_page_data.py` (26) + `test_models_validation.py` (67)
- Total: 270 → 442 passing (+172), all DB/network-free
- Patterns documented in skill: `fastapi-piccolo-typer-testing`

## Completed Work (PR #42) — P1 Data Management CRUD
- Added **Commission Profiles** tab to `/ops/data` (4th tab alongside carriers/agents/policies)
- 3 new cookie-auth page routes in `app/pages.py`: create, edit, delete — manager-role-guarded with audit logging
- New `page_data.get_data_management_comp_profiles()` with agent+carrier name enrichment
- Add modal: agent×carrier dropdowns + product_type + commission/override rates + effective/end dates
- Edit modal: rates + dates only (composite key is immutable — agent/carrier/product shown as read-only context)
- Delete uses form-POST with new `deleteMode: 'form'` branch in shared confirm modal (cookie-auth path instead of Firebase bearer)
- Tests: 5 in test_crud.py (happy paths + unauth + RBAC), 3 in test_page_data.py (empty/enriched/missing-name)
- Full suite: 442 → 569 passing

## Remaining Backlog
- P5: Empty state improvements (analytics guidance, agent portal $0 data)
- P6: Reconciliation auto-match suggestions, bulk resolve
- P7: Upload inline extraction review editing

## Important Notes
- ALWAYS run server with `background=true` to avoid blocking
- Browser tool requires Chrome version 1208; symlink workaround if newer installed
- App runs on localhost:8000 by default
- Common CI test failure: PiccoloORM `.select().where().run()` calls fail without Postgres in CI — must mock ALL DB models referenced in test paths (Agent, AgentHierarchy, CompProfile, PolicyAgent, Customer, etc.)
- **Page-handler tests patch `app.pages.page_data`** (not individual tables). When adding a new `get_data_management_*` helper used by `/ops/data`, update the mock in `tests/test_pages.py::TestOpsDataPage` or CI will fail with `MagicMock can't be used in 'await' expression`.
- When babysitting multiple PRs with independent branches, each branch needs its own fixes even if root cause is the same
- CI workflow should restrict push trigger to `main` branch only
- Full-suite verification: `uv run pytest tests/ -q` (569 tests, ~4.4s; no DB or network needed)
- User id in auth-override fixtures must be `str(uuid4())` not raw UUID
- Piccolo ORM: `col._meta.params["default"]` (NOT `col._meta.default`)
- Data page (`/ops/data`) uses a mixed delete pattern: API delete (carriers/agents/policies) via Firebase bearer, form-POST delete (comp-profiles) via cookie auth — `deleteMode` param on `confirmDelete()` selects which path
