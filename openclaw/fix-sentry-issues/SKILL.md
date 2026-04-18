---
name: fix-sentry-issues
description: Use when scanning Sentry issues for Bloom and creating fix PRs.
---

# Fix Sentry Issues

Scan recent Sentry issues for Bloom (last 24h, all statuses), analyze root causes, and create PRs to fix them.

## Prerequisites

- Sentry MCP configured via mcporter (org: `getbloom`, region: `https://us.sentry.io`)
- GitHub CLI (`gh`) authenticated with Bloom-Invest org access
- Git worktrees for isolated branches

## Workflow

### 1. Fetch recent issues (last 24h, all statuses)

```bash
# Get all issues from the last 24h sorted by frequency (includes resolved, ignored, etc.)
mcporter call sentry.list_issues \
  organizationSlug=getbloom \
  query='last_seen:+24h' \
  sort=freq \
  limit=15 \
  regionUrl='https://us.sentry.io'
```

Note: We fetch ALL issues (not just unresolved) to catch regressions, recently resolved issues that may have resurfaced, and issues that were auto-resolved but still occurring.

### 2. Triage issues

For each issue, get details and assess fixability:

```bash
# Get full issue details with stack trace
mcporter call sentry.get_issue_details \
  organizationSlug=getbloom \
  issueId=<ISSUE_ID> \
  regionUrl='https://us.sentry.io'
```

**Fix if:**
- Clear stack trace pointing to app code
- Root cause is identifiable (null reference, missing error handling, bad state, etc.)
- Fix is contained (doesn't require infra/backend/external changes)
- High frequency or high severity

**Skip if:**
- Issue is in third-party code or native layer
- Requires infrastructure or backend-only changes (not in bloom frontend/backend repo)
- Root cause is unclear or speculative
- Requires major architecture changes
- Issue is a duplicate of an already-fixed or in-progress issue

### 3. Create fixes

For each fixable issue, use a **git worktree**:

```bash
# Create worktree for the fix
cd ~/bloom
git fetch origin master
git worktree add /tmp/bloom-worktrees/sentry-<SHORT_ID> -b fix/sentry-<SHORT_ID> origin/master
cd /tmp/bloom-worktrees/sentry-<SHORT_ID>
```

**Fix guidelines:**
- Address the **root cause**, not just the symptom
- Add proper error handling / null checks / type guards
- If it's a crash, make it a graceful degradation instead
- Run lint and tests before committing:
  ```bash
  # Backend
  cd bloom_backend && uv run black . && uv run python -m pytest
  
  # Frontend
  cd frontend && bun run lint && bun run test
  ```

### 4. Create PRs

```bash
cd /tmp/bloom-worktrees/sentry-<SHORT_ID>
git add -A
git commit -m "fix: <brief description> (<SENTRY_ISSUE_ID>)"
git push origin fix/sentry-<SHORT_ID>

gh pr create \
  --repo Bloom-Invest/bloom \
  --title "fix: <brief description> (<SENTRY_ISSUE_ID>)" \
  --body "## Sentry Issue
- **Issue:** <SENTRY_ISSUE_ID>
- **Error:** <error message>
- **Frequency:** <events/users count>
- **Link:** https://getbloom.sentry.io/issues/<ISSUE_NUMBER>/

## Root Cause
<explanation of why this error occurs>

## Fix
<what was changed and why>

## Testing
- [ ] Lint passes
- [ ] Tests pass
- [ ] Manually verified the fix addresses the stack trace"
```

### 5. Clean up worktrees

```bash
cd ~/bloom
git worktree remove /tmp/bloom-worktrees/sentry-<SHORT_ID>
```

### 6. Report summary

After processing all issues, provide a summary:
- Issues analyzed (count + IDs)
- PRs created (with links)
- Issues skipped (with reasons)

## Spawning sub-agents

For multiple fixes, spawn sub-agents per issue to work in parallel:

```
sessions_spawn with label "sentry-fix-<SHORT_ID>"
task: "Fix Sentry issue <ID> in worktree /tmp/bloom-worktrees/sentry-<SHORT_ID>. 
       Issue details: <paste details>. Create a PR with the fix."
```

## Noise Reduction Patterns

When issues aren't code bugs but create Sentry noise, apply these patterns:

| Pattern | When | Fix |
|---------|------|-----|
| **Downgrade logger.error → logger.warning** | Expected failures (429 rate limits, timeouts on health checks) that return graceful defaults | Change log level; Sentry captures errors but not warnings by default |
| **Remove capture_exception/capture_message** | Caller already handles error gracefully (e.g., returns default data to user) | Remove the explicit Sentry call; keep the warning log |
| **Fix double-reporting** | Inner function calls capture_exception AND outer caller catches + reports | Remove from inner function; let caller decide |
| **Add to before_send filter** | Worker signals (SIGABRT, SIGTERM), known infra noise | Add string match in `bloom_backend/settings.py` `before_send` |
| **Frontend beforeSend filter** | Timeouts, network errors in `src/lib/sentry.ts` | Add to `beforeSend` callback to drop event |

**Principle:** All failures still log at warning level for debugging — only Sentry issue creation is suppressed. True errors continue reporting normally.

## Key Bloom Files

- **Backend Sentry config:** `bloom_backend/settings.py` (has `before_send` filter)
- **Frontend Sentry config:** `src/lib/sentry.ts` (has `beforeSend` + `ignoreErrors`)
- **FMP client:** `bloom_backend/third-partys/fmp_client.py`
- **Cerebras:** `bloom_backend/third-partys/cerebras.py` (uses Instructor for structured output)
- **Content translator:** `bloom_backend/content_translator.py`
- **Firecrawl:** `bloom_backend/third-partys/firecrawl_client.py`
- **Fetch URL tool:** `bloom_backend/tools/fetch_url_tool.py`
- **API tester:** `bloom_backend/management/commands/api_tester.py`

## Available LLM Models (Cerebras)

- `LLAMA_31_8B_MODEL` — too weak for structured JSON via Instructor
- `QWEN3_32B_MODEL` — reliable for Instructor structured output (default in `create_llm_response`)

## Constraints

- **Max 10 issues per run** (unless user specifies otherwise)
- **Never push to master** — always branch + PR
- **Don't make speculative changes** — only fix what you can trace to the stack trace
- Prioritize by frequency × severity
- Check if a PR already exists for the same issue before creating a duplicate
