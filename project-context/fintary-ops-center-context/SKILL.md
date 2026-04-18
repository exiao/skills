---
name: fintary-ops-center-context
category: project-context
description: Context and backlog for Fintary ops-center project
---

# Fintary Ops Center Project Context

## Repo
- GitHub: fintary/ops-center
- Stack: FastAPI + Jinja2 + Alpine.js + PiccoloORM + Postgres
- Tests: pytest, 178 tests as of 2026-04-12
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

## Remaining Backlog
- P1: Data Management CRUD modal forms (create/edit/delete for carriers, products, commission_types)
- P4: Test coverage for CRUD routes, export endpoints, payout actions
- P5: Empty state improvements (analytics guidance, agent portal $0 data)
- P6: Reconciliation auto-match suggestions, bulk resolve
- P7: Upload inline extraction review editing

## Important Notes
- ALWAYS run server with `background=true` to avoid blocking
- Browser tool requires Chrome version 1208; symlink workaround if newer installed
- App runs on localhost:8000 by default
- Common CI test failure: PiccoloORM `.select().where().run()` calls fail without Postgres in CI — must mock ALL DB models referenced in test paths (Agent, AgentHierarchy, CompProfile, PolicyAgent, Customer, etc.)
- When babysitting multiple PRs with independent branches, each branch needs its own fixes even if root cause is the same
- CI workflow should restrict push trigger to `main` branch only