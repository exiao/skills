---
name: fix-sentry-issues
description: Use when scanning Sentry issues for Bloom and creating fix PRs.
preloaded: true
---

# Fix Sentry Issues

Scan recent Sentry issues for Bloom (last 24h, all statuses), analyze root causes, and create PRs to fix them.

## Prerequisites

- Official Sentry CLI (`sentry`) authenticated via `SENTRY_AUTH_TOKEN`
- `$SENTRY_ORG` and `$SENTRY_PROJECT` set for Bloom backend Sentry access
- GitHub CLI (`gh`) authenticated with Bloom-Invest org access
- Git worktrees for isolated branches
- If Sentry CLI auth or env vars are missing, stop and report the exact missing prerequisite. Do not fall back to mcporter/MCP.
- If this runs as cron, read `references/cron-safety.md` before changing attached skills or toolsets. The cron scanner can block execution based on loaded skill documentation, not just the task prompt.

## Notes from prior runs

- See `references/2026-05-08-sentry-cron-lessons.md` for Sentry CLI/MCP quirks, resolved-issue audit gotchas, and Bloom-specific triage examples discovered during an actual cron run.
- See `references/2026-05-09-sentry-cron-lessons.md` for the `sentry.list_issues` MCP fallback, resolved-issue unrelated-commit handling, OpenAI Agents trace ID fix pattern, Capacitor Badge Android guard, and focused test command pitfalls.
- See `references/2026-05-11-sentry-cron-lessons.md` for the official Sentry CLI-only workflow, stale Django/PostgreSQL connection retry pattern, Huey KeyError symptom triage, and Benzinga interpreter-shutdown noise handling.
- See `references/2026-05-db-pool-catchalls.md` for a concrete DB pool exhaustion catch-all example.
- See `references/2026-05-crypto-db-pool-noise.md` for per-item crypto/background loop handling plus deterministic logger tests.
- See `references/2026-05-11-optional-refresh-db-pool.md` for the optional investment refresh pool-exhaustion pattern: call `close_old_connections()`, log a warning with lazy interpolation, and do not re-raise into Huey retries.

## Workflow

### 1. Fetch recent issues (last 12h, most recent 10)

```bash
sentry issue list $SENTRY_ORG/$SENTRY_PROJECT --limit 10 -t 12h --json \
  | jq '{data:[.data[] | {id,shortId,title,culprit,permalink,status,count,userCount,firstSeen,lastSeen,level,logger,type,issueType,metadata}]}'
```

Use the official Sentry CLI for Sentry data in cron runs. Do not call Sentry MCP tools such as `sentry.get_issue_details` or `sentry.get_latest_event`; configured MCP servers may not expose them consistently.

Note: We fetch ALL issues (not just unresolved) to catch regressions, recently resolved issues that may have resurfaced, and issues that were auto-resolved but still occurring.

### 1b. Verify recently resolved issues

```bash
# Keep output compact because raw JSON includes huge commit/PR bodies.
sentry issue list $SENTRY_ORG/$SENTRY_PROJECT --limit 10 -t 7d --query 'is:resolved' --json \
  | jq '{data:[.data[] | {id,shortId,title,culprit,permalink,status,statusDetails,metadata,type,issueType,level,logger,project}]}'
```

For each resolved issue:
1. Check `statusDetails.inCommit` or `statusDetails.inRelease` to find the resolving commit/PR
2. Read the actual diff of the resolving commit — does it fix the root cause or just suppress Sentry noise? Do not trust `statusDetails.inCommit` blindly; it can point to unrelated commits. If unrelated, label it `NOISE_SUPPRESSION / unrelated resolution`, then decide whether the current issue is real and hot enough to reopen.
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

For EACH of the 10 issues, get full details with the official CLI:

```bash
sentry issue view <ISSUE_SHORT_ID> --json > /tmp/sentry_details/<ISSUE_SHORT_ID>.json
sentry issue events <ISSUE_SHORT_ID> --json > /tmp/sentry_cli_events/<ISSUE_SHORT_ID>.json
```

Use `sentry issue view` as the primary issue metadata source and `sentry issue events` for latest event stack frames, tags, breadcrumbs, and request context. Save raw JSON artifacts under `/tmp/sentry_details/` and `/tmp/sentry_cli_events/` when they help compare clustered issues or preserve evidence for the plan.

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
# Bloom currently uses master as the default branch. If origin/main exists, use it;
# otherwise fall back to origin/master.
git fetch origin main || git fetch origin master
BASE_REF=$(git show-ref --verify --quiet refs/remotes/origin/main && echo origin/main || echo origin/master)
git worktree add ~/projects/_worktrees/sentry-<SHORT_ID> -b fix/sentry-<SHORT_ID> "$BASE_REF"
cd ~/projects/_worktrees/sentry-<SHORT_ID>
```

**Fix guidelines:**
- Address the **root cause**, not just the symptom
- Add proper error handling / null checks / type guards
- If it's a crash, make it a graceful degradation instead
- For OpenAI Agents tracing errors saying `Expected an ID that begins with 'trace_'`, generate IDs as `trace_` + `uuid.uuid4().hex`, not short UUID fragments. See `references/2026-05-09-sentry-cron-lessons.md`.
- For optional background refreshes that fail because the PostgreSQL pool is exhausted, call `close_old_connections()`, log a warning with lazy `%s` interpolation, and return without re-raising so Huey does not retry into pool pressure. Keep non-pool exceptions on the existing error path. See `references/2026-05-11-optional-refresh-db-pool.md`.
- Run lint and tests before committing:
  ```bash
  # Backend
  cd bloom_backend && uv run black . && uv run python -m pytest
  
  # Frontend
  cd frontend && bun run lint && bun run test
  ```

### 5. Create PRs

```bash
cd ~/projects/_worktrees/sentry-<SHORT_ID>
git add -A
git commit -m "fix: <brief description> (<SENTRY_ISSUE_ID>)"
git push origin fix/sentry-<SHORT_ID>

cat > /tmp/sentry-pr-body.md <<'EOF'
## Sentry Issue
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
- [ ] Manually verified the fix addresses the stack trace
EOF

gh pr create \
  --repo Bloom-Invest/bloom \
  --title "fix: <brief description> (<SENTRY_ISSUE_ID>)" \
  --body-file /tmp/sentry-pr-body.md
```

### 6. Leave worktrees intact

Do not remove worktrees or branches after opening the PR unless the user explicitly asks. Other agents or future babysit runs may need the branch state.

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
task: "Fix Sentry issue <ID> in worktree ~/projects/_worktrees/sentry-<SHORT_ID>.
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
- **Frontend Sentry config:** `frontend/src/utils/sentryConfig.ts` (has `beforeSend` + `ignoreErrors`)
- **AlphaVantage client:** `bloom_backend/externals/alphavantage.py`
- **AlphaVantage retry/errors:** `bloom_backend/http_retry.py`
- **Symbol validation:** `bloom_backend/functions/is_valid_symbol.py`
- **Fetch URL tool:** `bloom_backend/views/fetch_url_tool.py`
- **Firecrawl fallback:** `bloom_backend/views/firecrawl_client.py`
- **Phoenix tracing:** `bloom_backend/phoenix_otel.py`
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
- If existing async pytest tests fail locally with `async def functions are not natively supported`, do not waste the run fighting pytest plugin config. Add sync focused tests where possible, run `compileall`/lint, and document the local async-test blocker in the PR.
- For frontend changed-file verification, prefer direct local binaries after `bun install` (`./node_modules/.bin/prettier --check <file>` and `./node_modules/.bin/eslint --ext=ts,tsx <file>`) when `bun run lint -- <file>` expands to the whole `src` tree or cannot find dependencies.
