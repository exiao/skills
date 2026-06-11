# Claude-Review Infrastructure Failures

## Problem
`claude-review` CI check can fail for infrastructure reasons unrelated to code quality. When this happens, `mergeStateStatus` shows `UNSTABLE` and the PR appears blocked even though the code is clean.

## Known Failure Patterns

1. **Auth failures**: `GitHub App authentication failed`, `Failed to get GitHub App installation token`, OIDC/app-token exchange 401s
2. **Generic crashes**: Bot posts `"Claude encountered an error"` as an issue comment with a link to the failed job, but no code review feedback. The job log shows the claude-review step failed without producing a review.
3. **Rate limits / usage caps**: `"You've hit your limit"`, `"You've hit your org's monthly usage limit"` — shared across all PRs in the org and not fixable with code
4. **AGENT_TEAMS directory mismatch**: When `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"` is set in the workflow `settings` block, claude-code-action crashes with `Internal error: directory mismatch for directory "/home/runner/work/_actions/anthropics/claude-code-action/v1/tsconfig.json", fd 4`. The review produces no output and the bot posts "Claude encountered an error." Fix: remove the entire `settings` block containing `AGENT_TEAMS` and `ENABLE_TOOL_SEARCH` from the workflow YAML. This is a bug in claude-code-action's agent-teams mode, not in the reviewed code. When this pattern hits multiple repos simultaneously, fix the workflow YAML via PR rather than rerunning.
5. **Stuck "working" comment**: Bot posts `"Claude Code is working…"` as the initial status comment but the job concludes as `failure` without the comment ever being updated to a final review or error. Functionally identical to pattern 2: no code feedback was produced. Diagnose by comparing the job conclusion (`failure`/`cancelled`) against the latest claude[bot] issue comment. If the comment still says "working" but the job is done, treat as infra failure.

## Diagnosis

```bash
# Check what claude[bot] posted
gh api "repos/$REPO/issues/$PR/comments" --jq '.[] | select(.user.login | test("claude|bot"; "i")) | {body: .body[:300], created: .created_at}'

# Check the run
gh run view <run_id> --repo $REPO --json status,conclusion,jobs --jq '{status: .status, conclusion: .conclusion, jobs: [.jobs[] | {name: .name, conclusion: .conclusion}]}'

# Check for AGENT_TEAMS in the workflow (pattern 4)
gh api "repos/$REPO/contents/.github/workflows/claude-code-review.yml" --jq '.content' | base64 -d | grep -c AGENT_TEAMS

# Detect stuck "working" comments (pattern 5) -- compare job status vs comment text
JOB_STATUS=$(gh run view <run_id> --repo $REPO --json conclusion -q '.conclusion')
LATEST_COMMENT=$(gh api "repos/$REPO/issues/$PR/comments" --jq '[.[] | select(.user.login == "claude[bot]")] | last | .body[:50]')
echo "Job: $JOB_STATUS | Comment: $LATEST_COMMENT"
# If job is failure/cancelled but comment says "working", it's pattern 5
```

## Shared-Failure Shortcut

Before diving into per-PR fixes, check if all failing PRs share the same root cause. Common pattern: `AGENT_TEAMS` is set at the workflow level, so ALL PRs in that repo fail identically. Diagnose once by reading the workflow YAML, then fix the workflow itself via PR instead of rerunning each failed check individually.

To identify all affected repos at once:
```bash
for REPO in "$OWNER/$REPO_A" "$OWNER/$REPO_B"; do
  echo "=== $REPO ==="
  gh api "repos/$REPO/contents/.github/workflows/claude-code-review.yml" \
    --jq '.content' 2>/dev/null | base64 -d 2>/dev/null | grep AGENT_TEAMS && echo "  AFFECTED" || echo "  clean"
done
```

## Key Indicators It's Infra, Not Code

- Bot comment says "encountered an error" with no review body
- Bot comment is stuck at "Claude Code is working..." but the job has already concluded as `failure`. The initial status comment never got updated to a final review or error message. No code feedback was produced.
- No inline review comments from claude[bot]
- No `CHANGES_REQUESTED` review from claude[bot]
- Other CI checks (lint, tests, deps) all pass
- The job log shows auth/token/API errors, usage-cap errors, SDK failures, or directory-mismatch internal errors, not code analysis output

## Response

1. Confirm no actionable code feedback was posted (check all 3 comment sources)
2. For pattern 4 (AGENT_TEAMS): fix the workflow YAML via PR, don't rerun
3. For other patterns: rerun the failed job once: `gh run rerun <run_id> --repo $REPO --failed`
4. If rerun also fails, report as blocked on infrastructure
5. Do NOT push code changes or keep rerunning beyond one retry
6. Report: "PR content is clean but `claude-review` needs admin attention or must be made non-blocking"

## Session Examples

- Multiple PRs in one repo: `claude-review` crashed with `Internal error: directory mismatch` due to the `AGENT_TEAMS` setting. All other checks green. Fixed by removing the settings block from the workflow YAML in a single follow-up PR.
- Another repo: same `AGENT_TEAMS` crash. Fixed the same way via a workflow-YAML PR.
- A PR where `claude-review` failed with `You've hit your org's monthly usage limit`. Treat as org/account infrastructure.
- A PR where the `claude-review` job failed but the bot comment stuck at "Claude Code is working..." (pattern 5). Rerun also failed. All other checks green.
