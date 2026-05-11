---
name: fix-sentry-issues
description: Use when scanning Sentry issues for Bloom and creating fix PRs.
preloaded: true
---

# Fix Sentry Issues

Scan recent Sentry issues for Bloom (last 24h, all statuses), analyze root causes, and create PRs to fix them.

## Prerequisites

- Official Sentry CLI (`sentry`) authenticated via `$SENTRY_AUTH_TOKEN` (org: `$SENTRY_ORG`, project: `$SENTRY_PROJECT`)
- GitHub CLI (`gh`) authenticated with $GITHUB_ORG access
- Git worktrees for isolated branches

## Workflow

### 1. Check for existing Sentry fix PRs (do this FIRST)

Before analyzing issues, check what's already in flight:

```bash
cd ~/projects/bloom
gh pr list --state open --search "sentry" --json number,title,headRefName,url
gh pr list --state open --search "fix:" --json number,title,headRefName,url
```

Track these PR numbers. When analyzing issues in step 2, cross-reference each issue's culprit/error against existing PRs to avoid duplicate work. This often eliminates most or all issues from the fix queue. If `$BLOOM_REPO` is unset, derive it with `gh repo view --json nameWithOwner -q .nameWithOwner` before creating PRs or reading review comments.

### 1b. Fetch recent issues (last 12h, most recent 10)

Use the official `sentry` CLI. Do not use `mcporter` or Sentry MCP tools for this workflow.

```bash
sentry issue list $SENTRY_ORG/$SENTRY_PROJECT --limit 10 -t 12h --json > /tmp/sentry_recent.json
jq -r '.data[] | [.shortId,.title,.status,.culprit] | @tsv' /tmp/sentry_recent.json
```

Note: We fetch ALL issues (not just unresolved) to catch regressions, recently resolved issues that may have resurfaced, and issues that were auto-resolved but still occurring.

### 1c. Verify recently resolved issues

Also fetch issues resolved in the last 7 days to verify fixes are real:

```bash
# Get recently resolved issues
sentry issue list $SENTRY_ORG/$SENTRY_PROJECT --limit 10 -t 7d --query 'is:resolved' --json > /tmp/sentry_resolved.json
jq -r '.data[] | [.shortId,.title,.status,.culprit] | @tsv' /tmp/sentry_resolved.json
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

For EACH of the 10 issues, get full details and latest event payloads with the official `sentry` CLI only. Do not call `mcporter sentry.get_issue_details`, `mcporter sentry.get_latest_event`, or any Sentry MCP tools.

Use short IDs like `INVEST-5V0`:

```bash
mkdir -p /tmp/sentry_details /tmp/sentry_cli_events
sentry issue view <ISSUE_SHORT_ID> --json > /tmp/sentry_details/<ISSUE_SHORT_ID>.json
sentry issue events <ISSUE_SHORT_ID> --json > /tmp/sentry_cli_events/<ISSUE_SHORT_ID>.json
```

If `sentry issue events` returns multiple events, use the first/latest event for stack trace analysis and keep the full JSON artifact for citation. The Sentry CLI JSON shape is usually `{ "data": [...] }`, not a bare array, so parse `.data[]`. `sentry issue events` may omit full `entries`; `sentry issue view <ID> --json` often embeds the latest full event under `.event.entries`, including exception frames and message payloads.

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
cd ~/projects/bloom
git fetch origin master
git worktree add ~/projects/_worktrees/fix-sentry-<SHORT_ID> -b fix/sentry-<SHORT_ID> origin/master
cd ~/projects/_worktrees/fix-sentry-<SHORT_ID>
```

**Fix guidelines:**
- Address the **root cause**, not just the symptom
- Add proper error handling / null checks / type guards
- If it's a crash, make it a graceful degradation instead
- For DB pool exhaustion specifically, prefer shared helpers (`bloom_backend/middleware/connection_pool.py`) and return 503 + `Retry-After` without explicit Sentry capture from catch-all handlers. Use warning logs for expected transient exhaustion, keep error logs for unexpected failures. For per-item/background loops that already degrade by skipping an item, downgrade only recognized pool exhaustion to `logger.warning(...)` and continue. See `references/2026-05-crypto-db-pool-noise.md` for a concrete crypto price example and deterministic test pattern.
- When testing log-level routing under the full xdist backend suite, `caplog` may be empty or flaky for patched/module loggers. Prefer patching the module logger directly (e.g. `with patch("bloom_backend.investment_utils.logger") as mock_logger:`) and asserting `mock_logger.warning` was called while `mock_logger.error` was not.
- When writing backend tests for individual view modules, avoid `from bloom_backend.views import ...` if it triggers heavy package imports (`backtest`/`bt`/`matplotlib`) or duplicate native module registration. Prefer `importlib.import_module("bloom_backend.views.<module>")` only after the package is already loaded, or load simple leaf modules with `importlib.util.spec_from_file_location` when safe.
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
- **Link:** https://$SENTRY_ORG.sentry.io/issues/<ISSUE_NUMBER>/

## Root Cause
<explanation of why this error occurs>

## Fix
<what was changed and why>

## Testing
- [ ] Lint passes
- [ ] Tests pass
- [ ] Manually verified the fix addresses the stack trace"
```

### 5b. Babysit PR review and CI before reporting done

After opening the PR:

```bash
gh pr checks <PR_NUMBER> --watch --interval 10
gh pr view <PR_NUMBER> --json reviews
gh api repos/$BLOOM_REPO/issues/<PR_NUMBER>/comments
gh api repos/$BLOOM_REPO/pulls/<PR_NUMBER>/comments
```

Fix actionable review comments, especially bot comments from Gemini/Claude. Do not rely on `gh pr view --json reviews` alone because inline review comments and issue comments are separate APIs. If you need to add commits after review, push normal follow-up commits. Do not amend and force-push because the git wrapper blocks force-pushes and rewriting PR history is against workflow.

### 6. Archive the plan, leave worktrees alone

Move the completed plan to `~/.hermes/plans/archive/` after fixes and PR checks finish. Do not remove worktrees or delete branches unless the user explicitly asks for cleanup; parallel agents may still depend on local state and the global git workflow prefers preserving worktrees.

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

For a concrete DB pool exhaustion catch-all example, see `references/2026-05-db-pool-catchalls.md`. For per-item crypto/background loop handling plus deterministic logger tests, see `references/2026-05-crypto-db-pool-noise.md`.

When issues aren't code bugs but create Sentry noise, apply these patterns:

| Pattern | When | Fix |
|---------|------|-----|
| **Downgrade logger.error → logger.warning** | Expected failures (429 rate limits, timeouts on health checks, bot-blocked fetches) that return graceful defaults | Change app logging to warning and do not call Sentry explicitly |
| **Remove capture_exception/capture_message** | Caller already handles error gracefully (e.g., returns default data/tool error to user) | Remove the explicit Sentry call; keep the warning log |
| **Fix double-reporting** | Inner function calls capture_exception AND outer caller catches + reports | Remove from inner function; let caller decide |
| **Add to before_send filter** | Worker signals (SIGABRT, SIGTERM), known infra noise | Add string match in `bloom_backend/settings.py` `before_send` |
| **Frontend beforeSend filter** | Timeouts, network errors in `src/lib/sentry.ts` | Add to `beforeSend` callback to drop event |

**Important:** `sentry_sdk.capture_message(..., level="warning")` still creates Sentry events/issues. For legitimate expected failures, log with `logger.warning(...)` only. Keep `capture_exception` for unexpected failures.

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
