---
name: fix-sentry-issues
description: Use when scanning Sentry issues for Bloom and creating fix PRs.
preloaded: true
---

# Fix Sentry Issues

Scan recent Sentry issues for Bloom (last 24h, all statuses), analyze root causes, and create PRs to fix them.

## Prerequisites

- Sentry MCP configured via mcporter (org: `getbloom`, region: `https://us.sentry.io`)
- GitHub CLI (`gh`) authenticated with Bloom-Invest org access
- Git worktrees for isolated branches

## Workflow

### 1. Fetch recent issues (last 12h, most recent 10)

```bash
# Get 10 most recent issues sorted by frequency
mcporter call sentry.list_issues \
  organizationSlug=getbloom \
  query='last_seen:+12h' \
  sort=freq \
  limit=10 \
  regionUrl='https://us.sentry.io'
```

Note: We fetch ALL issues (not just unresolved) to catch regressions, recently resolved issues that may have resurfaced, and issues that were auto-resolved but still occurring.

### 1b. Verify recently resolved issues

Also fetch issues resolved in the last 7 days to verify fixes are real:

```bash
# Get recently resolved issues
sentry issue list getbloom/invest --limit 10 -t 7d --query 'is:resolved'
```

For each resolved issue:
1. Check `statusDetails.inCommit` or `statusDetails.inRelease` to find the resolving commit/PR
2. Read the actual diff of the resolving commit — does it fix the root cause or just suppress Sentry noise?
3. **Noise-only fixes to flag:** adding to `ignoreErrors`, `beforeSend` filters, downgrading log levels, or removing `capture_exception` calls WITHOUT fixing the underlying bug
4. If the "fix" was noise suppression and the underlying issue is a real code bug (N+1 queries, broken schemas, unhandled errors, data corruption), mark it as FIX with a note that the previous resolution was noise-only

Add a "Resolved Issue Audit" section to the plan file:
```markdown
## Resolved Issue Audit
### ISSUE_SHORT_ID — <title>
- **Resolved by:** <commit hash / PR link>
- **Fix type:** ROOT_CAUSE / NOISE_SUPPRESSION / LEGITIMATE_NOISE
- **Assessment:** <Is the underlying issue actually fixed?>
- **Action needed:** NONE / REOPEN_AND_FIX
```

**LEGITIMATE_NOISE** = the error genuinely isn't a bug (e.g., Firebase SDK race condition, load balancer health check timeouts). Suppression is the correct fix.

**NOISE_SUPPRESSION** = the error IS a real bug but was "fixed" by hiding it from Sentry. These need a real fix PR.

### 2. Deep-analyze every issue

For EACH of the 10 issues, get full details:

```bash
mcporter call sentry.get_issue_details \
  organizationSlug=getbloom \
  issueId=<ISSUE_ID> \
  regionUrl='https://us.sentry.io'
```

Also get latest event for full stack trace context:

```bash
mcporter call sentry.get_latest_event \
  organizationSlug=getbloom \
  issueId=<ISSUE_ID> \
  regionUrl='https://us.sentry.io'
```

### 3. Write plan file

Create `~/.hermes/plans/sentry-fix-YYYY-MM-DD-HH.md` with:

```markdown
# Sentry Fix Plan — YYYY-MM-DD HH:00

## Summary
- Issues analyzed: N
- Fixable: N
- Noise-only "fixes" reopened: N
- Skipped: N

## Issues

### 1. ISSUE_SHORT_ID — <title>
- **Sentry ID:** <id>
- **Events (24h):** N | **Users affected:** N
- **Status:** unresolved/resolved/ignored
- **Stack trace summary:** <key frames>
- **Root cause:** <analysis of why this happens>
- **Proposed fix:** <specific code changes needed, which files, what pattern>
- **Verdict:** FIX / SKIP (reason)

### 2. ...
(repeat for all 10)

## Execution Order
1. <ISSUE_ID> — <one-line fix description>
2. ...
```

**Triage criteria for verdict:**

**FIX if:**
- Clear stack trace pointing to app code
- Root cause is identifiable (null reference, missing error handling, bad state, etc.)
- Fix is contained (doesn't require infra/backend/external changes)
- High frequency or high severity
- A resolved issue where the "fix" was noise suppression but the underlying bug is real

**SKIP if:**
- Issue is in third-party code or native layer
- Requires infrastructure or backend-only changes (not in bloom frontend/backend repo)
- Root cause is unclear or speculative
- Requires major architecture changes
- Issue is a duplicate of an already-fixed or in-progress issue
- A PR already exists for this issue
- Issue is resolved AND the fix genuinely addresses root cause (verified in step 1b)

### 4. Create fixes (execute the plan)

Work through each issue marked FIX in the plan, in execution order. For each fixable issue, use a **git worktree**:

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

### 5. Create PRs

```bash
cd /tmp/bloom-worktrees/sentry-<SHORT_ID>
git add -A
git commit -m "fix: <brief description> (<SENTRY_ISSUE_ID>)"
git push origin fix/sentry-<SHORT_ID>

gh pr create \
  --repo $BLOOM_REPO \
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

### 6. Clean up worktrees

```bash
cd ~/bloom
git worktree remove /tmp/bloom-worktrees/sentry-<SHORT_ID>
```

### 7. Report summary

After processing all issues, provide a summary:
- Issues analyzed (count + IDs)
- PRs created (with links)
- Issues skipped (with reasons)
- Plan file location: `~/.hermes/plans/sentry-fix-YYYY-MM-DD-HH.md`

Move completed plan to `~/.hermes/plans/archive/`.

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

- **10 most recent issues per run** — analyze all 10, fix what's fixable
- **Never push to master** — always branch + PR
- **Don't make speculative changes** — only fix what you can trace to the stack trace
- Prioritize by frequency × severity
- Check if a PR already exists for the same issue before creating a duplicate
- **Always write the plan file first** — never skip straight to fixes
