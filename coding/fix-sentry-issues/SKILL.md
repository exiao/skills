---
name: fix-sentry-issues
description: Use when scanning Sentry issues and creating fix PRs. Trigger phrases include "sentry scan", "fix sentry", "scan errors", "what's crashing".
---

# Fix Sentry Issues

Scan recent Sentry issues, analyze root causes, and create PRs to fix them.

## Prerequisites

- Official Sentry CLI (`sentry`) authenticated via `SENTRY_AUTH_TOKEN`
- `$SENTRY_ORG` and `$SENTRY_PROJECT` set
- GitHub CLI (`gh`) authenticated
- Git worktrees for isolated branches

## Workflow

### 1. Fetch recent issues (last 12h, most recent 10)

```bash
sentry issue list $SENTRY_ORG/$SENTRY_PROJECT --limit 10 -t 12h --json \
  | jq '{data:[.data[] | {id,shortId,title,culprit,permalink,status,count,userCount,firstSeen,lastSeen,level,logger,type,issueType,metadata}]}'
```

Use the official Sentry CLI. Do not fall back to MCP tools; configured MCP servers may not expose them consistently.

Note: Fetch ALL issues (not just unresolved) to catch regressions and issues that were auto-resolved but still occurring.

### 1b. Verify recently resolved issues

```bash
sentry issue list $SENTRY_ORG/$SENTRY_PROJECT --limit 10 -t 7d --query 'is:resolved' --json \
  | jq '{data:[.data[] | {id,shortId,title,culprit,permalink,status,statusDetails,metadata,type,issueType,level,logger,project}]}'
```

For each resolved issue:
1. Check `statusDetails.inCommit` or `statusDetails.inRelease` for the resolving commit/PR
2. Read the actual diff. Does it fix root cause or just suppress Sentry noise?
3. **Noise-only fixes to flag:** adding to `ignoreErrors`, `beforeSend` filters, downgrading log levels, or removing `capture_exception` WITHOUT fixing the underlying bug
4. If the "fix" was noise suppression and the underlying issue is a real code bug, mark it FIX

Add a "Resolved Issue Audit" section to the plan:
```markdown
## Resolved Issue Audit
### ISSUE_SHORT_ID — <title>
- **Resolved by:** <commit hash / PR link>
- **Fix type:** ROOT_CAUSE / NOISE_SUPPRESSION / LEGITIMATE_NOISE
- **Assessment:** <Is the underlying issue actually fixed?>
- **Action needed:** NONE / REOPEN_AND_FIX
```

### 2. Deep-analyze every issue

```bash
sentry issue view <ISSUE_SHORT_ID> --json > /tmp/sentry_details/<ISSUE_SHORT_ID>.json
sentry issue events <ISSUE_SHORT_ID> --json > /tmp/sentry_cli_events/<ISSUE_SHORT_ID>.json
```

### 3. Write plan file

Create `~/.hermes/plans/sentry-fix-YYYY-MM-DD-HH.md`:

```markdown
# Sentry Fix Plan — YYYY-MM-DD HH:00

## Summary
- Issues analyzed: N
- Fixable: N
- Noise-only "fixes" reopened: N
- Skipped: N

## Issues

### 1. ISSUE_SHORT_ID — <title>
- **Events (24h):** N | **Users affected:** N
- **Status:** unresolved/resolved/ignored
- **Stack trace summary:** <key frames>
- **Root cause:** <analysis>
- **Proposed fix:** <specific code changes>
- **Verdict:** FIX / SKIP (reason)
```

**FIX if:** clear stack trace in app code, identifiable root cause, contained fix, high frequency/severity, or prior "fix" was noise suppression.

**SKIP if:** third-party code, unclear root cause, requires major architecture changes, duplicate of existing fix, PR already exists, or genuinely fixed.

### 4. Create fixes

For each fixable issue, use a git worktree:

```bash
cd ~/projects/<repo>
git fetch origin
BASE_REF=$(git show-ref --verify --quiet refs/remotes/origin/main && echo origin/main || echo origin/master)
git worktree add ~/projects/_worktrees/sentry-<SHORT_ID> -b fix/sentry-<SHORT_ID> "$BASE_REF"
```

**Fix guidelines:**
- Address the root cause, not just the symptom
- Add proper error handling / null checks / type guards
- If it's a crash, make it a graceful degradation
- Run lint and tests before committing

### 5. Create PRs

```bash
cat > /tmp/sentry-pr-body.md <<'EOF'
## Sentry Issue
- **Issue:** <SENTRY_ISSUE_ID>
- **Error:** <error message>
- **Frequency:** <events/users count>

## Root Cause
<explanation>

## Fix
<what was changed and why>

## Testing
- [ ] Lint passes
- [ ] Tests pass
- [ ] Fix addresses the stack trace
EOF

gh pr create --title "fix: <description> (<SENTRY_ISSUE_ID>)" --body-file /tmp/sentry-pr-body.md
```

### 6. Leave worktrees intact

Do not remove worktrees or branches after opening the PR.

### 7. Report summary

After processing all issues, provide:
- Issues analyzed (count + IDs)
- PRs created (with links)
- Issues skipped (with reasons)
- Plan file location

Move completed plan to `~/.hermes/plans/archive/`.

## Noise Reduction Patterns

When issues aren't code bugs but create Sentry noise:

| Pattern | When | Fix |
|---------|------|-----|
| **Downgrade error → warning** | Expected failures (rate limits, health check timeouts) | Change log level |
| **Remove capture_exception** | Caller already handles error gracefully | Remove explicit Sentry call; keep warning log |
| **Fix double-reporting** | Inner + outer both report | Remove from inner; let caller decide |
| **Add to before_send filter** | Worker signals, known infra noise | Add string match in `before_send` |
| **Frontend beforeSend** | Timeouts, network errors | Drop event in `beforeSend` callback |

**Principle:** All failures still log at warning level for debugging. Only Sentry issue creation is suppressed. True errors continue reporting normally.

## Constraints

- **10 most recent issues per run**
- **Never push to main/master** — always branch + PR
- **Don't make speculative changes** — only fix what you can trace to the stack trace
- Prioritize by frequency x severity
- Check for existing PRs before creating duplicates
- **Always write the plan file first**
