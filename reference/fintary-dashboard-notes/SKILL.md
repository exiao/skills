---
name: fintary-dashboard-notes
description: "Reference notes for Fintary ops-center dashboard rebuild — Alpine.js x-if bug fix, subagent pitfalls, and PR context."
---

# Fintary Dashboard Rebuild Notes

## First-Load Bug Pattern (Alpine.js + Chart.js)
**Root cause:** `<template x-if>` removes canvas elements from DOM. When `loading` flips to `false`, Alpine hasn't re-inserted canvases yet, so Chart.js `getElementById()` returns null. Clicking Refresh works because DOM is stable by then.
**Fix:** Replace `<template x-if>` with `<div x-show="..." x-cloak>`. Add `[x-cloak] { display:none !important; }` CSS. Use double `$nextTick` after `loading = false`.

## Subagent Pitfalls for Large Files
- Subagents delegated to write files >1000 lines consistently fail — they recurse into their own delegation loops.
- For large rewrites, patch incrementally with FilePatch (old_string → new_string) rather than rewriting entire files.

## Reference Files (Google Drive)
- `business_insights_dashboard.html` — 7 tabs, hardcoded data (MONTHLY, AGENTS, CARRIERS, CB, COMP, GROUPS, HIER)
- `agent_dashboard-10.html` — 6 agent sub-tabs, hardcoded data
- Map raw OpenAPI report rows → pre-aggregated structures via DataAggregator class.

## PR #N (2026-04-30) — merged
- Branch: `fix/dashboard-match-reference`, repo: $OPS_CENTER_REPO
- 8 business tabs + 7 agent sub-tabs implemented
- Plan: `$PLAN_PATH`

## PR #N (2026-05-01) — merged
- Chart rendering fixes: ReportClassifier now scans column names (not just report names), fallback searches ALL loaded reports when classified groups are empty, wider NUMERIC_TYPES set, debug logging throughout
- Plan: `$PLAN_PATH`

## PR #N (2026-05-01) — merged
- Date label formatting: `fmtDateLabel()` converts raw BigQuery dates (YYYY-MM-DD, ISO timestamps) to "Jan '24" style short labels
- Chart.js x-axis: `autoSkip: true`, `maxTicksLimit: 12` (was showing every label at 45° rotation)
- Firebase auth race fix: `getFirebaseToken()` now waits for `onAuthStateChanged` instead of checking `currentUser` immediately (was null on page load, causing silent API failures requiring manual Refresh click)

## PR #N — closed (stale, superseded by later PRs)

## PR #N (2026-05-01) — open
- 30 JS unit tests (vitest) for analytics utils: fmtDateLabel, fmtMonth, fmtCurrency, fmtCompact, escHtml, findCol, ReportClassifier, NUMERIC_TYPES, DATE_TYPES
- `make test` now runs both Python (pytest) and JS (vitest)

## Key Patterns Learned
- **Firebase auth race condition**: `firebase.auth().currentUser` is null until `onAuthStateChanged` fires (~100-200ms after page load). Always wrap in a listener or Promise.
- **Silent chart failures**: Chart.js + the analytics code has many `if (!x) return` paths with zero logging. Always add `console.debug` at decision points.
- **Column-aware classification**: Report names from BigQuery are often generic. Scanning column names (e.g., "agent_name", "carrier", "revenue") dramatically improves classification accuracy.