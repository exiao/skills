---
name: ops-center-codebase-review
version: 1
category: ops-center
description: Reference notes from full ops-center codebase review (2026-04-30)
---

# Ops-Center Codebase Review (2026-04-30)

## Summary
Full codebase review of github.com/Fintary/ops-center completed. PR #64 updated all docs.

## Actual Counts (verified from source)
- **19 tables** + **10 enums** in app/models/tables.py
- **80 API routes** across 17 route files in app/api/
- **60 page routes** in app/pages.py (1845 lines)
- **140 total routes**
- **11 service files** with 56+ public functions in app/services/
- **33 CLI commands** across 9 modules in app/cli/
- **20 data helper functions** in app/page_data.py (872 lines)

## Pre-existing Security Bug
DELETE /api/agent-hierarchy/{hierarchy_id} doesn't filter by account_id — cross-tenant deletion risk. Flagged for separate fix.

## Key Architecture Notes
- Feature flags: RECONCILE_BULK, RECONCILE_SUGGESTIONS
- Chat has 12 tool definitions
- Ops center has 6 queue types and 6 bulk actions
- Auth: Firebase-based, roles are manager/ops/agent
