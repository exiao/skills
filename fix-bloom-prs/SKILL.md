---
name: fix-bloom-prs
description: Use when fixing CI failures, reviewing code, or addressing review comments on open PRs. Scans all tracked repos (Bloom, investing-log, skills), not just Bloom.
---

# Fix PRs

Scan open PRs across all tracked repos for CI failures, review comments, and merge conflicts. Fix only when confident; comment when not.

## Tracked Repos

| Repo | Local path | Conventions file |
|------|-----------|-----------------|
| `bloom-invest/bloom` | `~/bloom` | `CLAUDE.md` |
| `bloom-invest/investing-log` | `~/clawd/investing-log` | `CLAUDE.md` or `AGENTS.md` |
| `exiao/skills` | `~/clawd/skills` | n/a |

The cron preflight script scans all tracked repos.

## Core Principle: Don't Loop

The #1 failure mode is pushing speculative fixes that trigger new CI runs, new review comments, and more speculative fixes, ballooning PRs to 50+ commits. Every push must be intentional and correct.

## Auto-Fix vs Comment Decision

**Auto-fix ONLY when ALL of these are true:**
1. You understand the root cause (not just the symptom)
2. The fix is unambiguous (only one correct way to resolve it)
3. You can verify the fix locally (run the test, check the lint, confirm the logic)
4. The fix is small and surgical (not a refactor or design change)

**Examples of auto-fixable issues:**
- Clear bugs with obvious fixes (typos, off-by-one, null checks)
- Missing or unused imports
- Lint/formatting failures (`uv run black`, `bun run lint --fix`)
- Simple logic errors with unambiguous corrections
- Security issues with straightforward fixes
- Merge conflicts where the resolution is clear from the PR's intent

**Skip (report to Eric instead) when:**
- The fix requires understanding intended behavior you're not sure about
- Multiple valid approaches exist and you'd be guessing which one
- It's a design decision, API change, or architectural issue
- It requires new dependencies or configuration changes
- It requires database migrations or schema changes
- The CI failure is flaky or environment-specific (note it, don't "fix" it)
- You already pushed a fix for this PR on a previous run and it didn't work
- The review comment is subjective or stylistic

**Do NOT post PR comments.** PR comments trigger claude-review re-runs and waste tokens. Instead, include anything you can't fix in your Signal summary message to Eric.

## Circuit Breakers

**Commit count:** If a PR already has 15+ commits, DO NOT push more fixes. Comment only. The PR needs a squash or human attention, not more automated commits.

**Repeat fix detection:** Before fixing, check if the last commit on the PR was from a previous cron run (author = "claude" or commit message matches cron fix patterns). If the cron already pushed a fix and the issue persists, the fix didn't work. Comment explaining what you tried and what's still broken. Do not retry the same approach.

**CI-only failures:** If the only issue is a CI failure that looks infrastructure-related (timeout, runner error, network issue, flaky test), re-request the check run instead of pushing code. Use: `gh api repos/$REPO/actions/runs/{run_id}/rerun-failed-jobs -X POST`

## Workflow

### 1. Preflight

When run via cron, the preflight script (`bash ~/clawd/scripts/pr-preflight.sh`) handles PR discovery. If no output, stop. Otherwise proceed with the flagged PRs.

> **Note:** `pr-preflight.sh` is a workspace-specific script (not included in this repo). It scans tracked repos for PRs needing attention and outputs a `repo` field for each flagged PR.

When run manually:
```bash
bash ~/clawd/scripts/pr-preflight.sh
```
Output includes `repo` field for each PR needing attention.

### 2. Triage each PR

For each PR, gather context before deciding to fix or comment:

```bash
PR=<number>
REPO=<repo>  # use the repo value from preflight output, e.g. bloom-invest/bloom

# Commit count (circuit breaker check)
gh api "repos/$REPO/pulls/$PR/commits?per_page=100" --jq 'length'

# CI status
gh pr checks $PR --repo $REPO

# Current HEAD
gh pr view $PR --repo $REPO --json headRefOid -q '.headRefOid'

# Review comments (check staleness via original_commit_id vs HEAD)
gh api --paginate "repos/$REPO/pulls/$PR/comments" | \
  jq '.[] | {author: .user.login, commit: .original_commit_id, path: .path, line: .line, body: .body[0:300]}'

# Claude-review sticky comment
gh api --paginate "repos/$REPO/issues/$PR/comments" | \
  jq '[.[] | select(.user.login == "claude")] | last | .body[0:500]'

# Last commit author (repeat fix detection)
gh api "repos/$REPO/pulls/$PR/commits?per_page=1&page=$(gh api repos/$REPO/pulls/$PR/commits?per_page=100 --jq 'length')" \
  --jq '.[0] | {author: .commit.author.name, message: .commit.message[0:200]}'
```

**Critical staleness check:** Compare `original_commit_id` on each comment against the PR's current HEAD. If they differ, verify the issue still exists in the latest code before acting.

### 3. Fix or comment

For each PR, make a deliberate decision:

**If fixing:**
1. Use a git worktree (never the main checkout)
2. Read the repo's conventions file (see Tracked Repos table) if one exists
3. Make the minimal, targeted fix
4. Verify locally: run the specific test, check lint, confirm logic
5. Single commit with a clear message explaining what was fixed and why
6. Push

**If skipping (can't fix with confidence):**
1. Note the issue for the Signal summary message
2. **MUST run** to suppress future cron noise until something changes:
   ```bash
   bash ~/clawd/scripts/pr-mark-skip.sh <PR_NUM> "<reason>"
   ```
   > **Note:** `pr-mark-skip.sh` is a machine-local script (not in this repo). It marks a PR as skipped so the cron doesn't re-flag it.

   Example reasons: `"stale bot threads"`, `"architecture decision needed"`, `"design change required"`
   The cron will re-flag the PR automatically if HEAD or updatedAt changes (new commit or comment).
3. Do NOT post PR comments (they trigger claude-review re-runs and waste tokens)

**Spawn sub-agents** for multiple PRs, but each sub-agent must follow these same rules.

### 4. Post-push verification

After pushing a fix, check that CI starts. Do NOT wait for CI to complete and push another fix in the same run. One fix per PR per cron run. If CI fails again, the next cron run will pick it up with the context of what was already tried.

## Common fixes

- **Backend Lint** → `uv run black <file>`
- **Frontend Lint** → `cd frontend && bun run lint --fix`
- **Bugbot/Seer** → Read the comment, understand the root cause, fix if confident
- **claude-review** → Usually informational. Fix only clear bugs; comment on the rest

## Fixing Merge Conflicts

When a PR has merge conflicts:

1. **Check if the branch diverged far from main** (5+ commits ahead of main, especially if some were already merged into main separately):
   ```bash
   git log --oneline origin/main..origin/<branch> | wc -l
   git diff origin/main origin/<branch> --stat | tail -1
   ```

2. **If the branch has old merged commits causing conflicts** (rebase would be painful):
   - Create a fresh branch from `origin/main`
   - Apply only the unique diff: `git diff origin/main origin/<branch> -- . | git apply --3way`
   - If a file was deleted on main, exclude it from the diff:
     ```bash
     # Replace path/to/deleted-file with the actual path of the file deleted on main
     git diff origin/main origin/<branch> -- . ':!path/to/deleted-file' | git apply --3way
     ```
   - If `git apply` fails, manually apply the changes
   - Commit, push new branch, create new PR referencing the old one
   - Close old PR with "Superseded by #XX (clean rebase from main)"

3. **If the branch is recent with a simple conflict** (few commits ahead):
   - Rebase onto main: `git rebase origin/main`
   - Resolve conflicts, `git add`, `git rebase --continue`
   - Force push: `git push --force-with-lease`

Always prefer the fresh-branch approach when `git log origin/main..origin/<branch>` shows commits already merged into main (these cause painful rebase conflicts regardless of count).

## Excluding PRs

Skip PRs that:
- Are tagged [CLASS]
- Have 15+ commits (comment only)
- Have fundamental architecture issues requiring Eric's input
- Are drafts or WIP

Ask Eric before fixing PRs by other authors.

---

# Review PR

Review a PR with the same criteria as the GitHub Actions `claude-code-review.yml`.

## Inputs

- PR number or URL (ask if not provided)
- Repo (ask if not provided; see Tracked Repos table for valid repos)

## Setup

Use a worktree for isolated review — never switch branches in the main checkout:

```bash
REPO=<repo>        # e.g. bloom-invest/bloom, exiao/skills
LOCAL=<local-path>  # e.g. ~/bloom, ~/clawd/skills (see Tracked Repos table)
PR_NUM=<number>
cd "$LOCAL"
git fetch origin pull/${PR_NUM}/head:pr-${PR_NUM}
git worktree add /tmp/review-worktrees/review-${PR_NUM} pr-${PR_NUM}
cd /tmp/review-worktrees/review-${PR_NUM}
```

## Review Criteria

**Flag these:**
- Correctness — does it implement the feature spec properly?
- Bugs or logic errors that produce wrong results
- Security risks
- Reliability issues that cause crashes or failures
- Performance or latency issues
- Complexity that makes code actively misleading or error-prone
- Missing test coverage

**Do NOT flag:**
- Style, naming, or structural preferences
- Missing error handling for unlikely multi-condition scenarios
- "This could be slightly better" suggestions
- Linting, formatting, or type annotation issues
- Premature optimizations

## Steps

1. **Read PR metadata and diff:**
   ```bash
   gh pr view ${PR_NUM} --repo $REPO --json title,body,files,author,labels
   gh pr diff ${PR_NUM} --repo $REPO
   ```

2. **Understand context** — read the changed files in full, not just the diff.

3. **Check CI status:**
   ```bash
   gh pr checks ${PR_NUM} --repo $REPO
   ```

4. **Read existing review comments:**
   ```bash
   gh api --paginate "repos/$REPO/pulls/${PR_NUM}/comments" | \
     jq '.[] | {author: .user.login, path: .path, line: .line, body: .body[0:300]}'
   gh api --paginate "repos/$REPO/pulls/${PR_NUM}/reviews" | \
     jq '.[] | {author: .user.login, state: .state, body: .body[0:500]}'
   ```

5. **Review the code** against the criteria above.

6. **If issues found** — 1-2 sentences each: problem, fix, location.

7. **If no issues** — "LGTM" + one sentence of what you reviewed.

## Auto-fix Policy

**May auto-fix (commit + push):** Clear bugs, typos, null checks, missing imports, simple logic errors, security issues with obvious fixes.

**Do NOT auto-fix:** Behavior clarifications, design decisions, API changes, DB migrations, architecture changes, new dependencies.

## Output

```bash
gh pr comment ${PR_NUM} --repo $REPO --body "<review>"
```

## Cleanup

```bash
cd "$LOCAL"
git worktree remove /tmp/review-worktrees/review-${PR_NUM}
git branch -D pr-${PR_NUM} 2>/dev/null
```