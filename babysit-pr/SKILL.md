---
name: babysit-pr
description: "Monitor a PR until it's ready to merge. Watches CI, reads reviews, fixes issues, and repeats. Use when: babysit this PR, watch this PR, monitor PR, fix and watch PR, keep this PR green."
---

# Babysit PR

Monitor a single PR through its full lifecycle: wait for CI, read reviews, fix issues, push, repeat. Stop when the PR is clean (CI green, no unaddressed comments) or when you hit a wall that needs human input.

## Inputs

- **PR number** (required)
- **Repo** (optional, defaults to `Bloom-Invest/bloom`)
- **Max cycles** (optional, default 10. Each cycle = one CI wait + fix attempt)

## Setup

```bash
PR=<number>
REPO=<owner/repo>

# Read repo conventions
REPO_DIR=$(echo "$REPO" | cut -d/ -f2)
for DIR in ~/bloom ~/clawd/$REPO_DIR ~/$REPO_DIR /tmp/$REPO_DIR; do
  [ -d "$DIR/.git" ] && LOCAL_DIR="$DIR" && break
done

# Clone if not found locally
if [ -z "$LOCAL_DIR" ]; then
  git clone "git@github.com:$REPO.git" "/tmp/$REPO_DIR"
  LOCAL_DIR="/tmp/$REPO_DIR"
fi

# Read project rules
for F in CLAUDE.md AGENTS.md; do
  [ -f "$LOCAL_DIR/$F" ] && cat "$LOCAL_DIR/$F"
done

# Create worktree
BRANCH=$(gh pr view $PR --repo $REPO --json headRefName -q '.headRefName')
WORKTREE="/tmp/${REPO_DIR}-pr-${PR}"
git -C "$LOCAL_DIR" fetch origin "$BRANCH"
git -C "$LOCAL_DIR" worktree add "$WORKTREE" "$BRANCH" 2>/dev/null || \
  git -C "$LOCAL_DIR" worktree add --detach "$WORKTREE" "origin/$BRANCH"
cd "$WORKTREE"
git checkout "$BRANCH" 2>/dev/null
```

## The Loop

Repeat up to `max_cycles` times:

### 1. Wait for CI

Poll CI status every 60 seconds until all checks complete or 20 minutes pass (whichever comes first).

```bash
# Check CI status
gh pr checks $PR --repo $REPO
```

States:
- **All green** → go to step 2 (check reviews)
- **Failures** → go to step 3 (analyze and fix)
- **Still running after 20 min** → report status, continue waiting (reset timer)
- **No checks at all** → go to step 2

### 2. Check Reviews

**Always read ALL comments and reviews, even when CI is green.** Automated reviewers (claude-review, Seer, Bugbot) post findings as issue comments or review bodies that may flag real issues despite passing CI.

```bash
# Review comments (inline)
gh api --paginate "repos/$REPO/pulls/$PR/comments" | \
  jq '.[] | {author: .user.login, path: .path, line: .line, body: .body, commit: .original_commit_id, created: .created_at}'

# Issue comments — read FULL body, not truncated. Automated reviewers put findings here.
gh api --paginate "repos/$REPO/issues/$PR/comments" | \
  jq '.[] | {author: .user.login, body: .body, created: .created_at}'

# Review verdicts — read FULL body. claude-review puts its analysis in the review body.
gh api --paginate "repos/$REPO/pulls/$PR/reviews" | \
  jq '.[] | {author: .user.login, state: .state, body: .body}'

# Current HEAD for staleness check
HEAD=$(gh pr view $PR --repo $REPO --json headRefOid -q '.headRefOid')
```

**Staleness check:** Compare each comment's `original_commit_id` (or `created_at`) against HEAD. If a comment was made on an older commit, verify the issue still exists in the latest code before acting.

**Triage review findings:** For each actionable issue flagged by reviewers (human or automated), classify it as AUTO-FIX or ESCALATE per step 3. Informational observations or style suggestions that don't affect correctness can be noted but don't block the PR.

**If CI green + no actionable unaddressed findings → PR is ready. Report success and stop.**

**If there are actionable findings → go to step 3.**

### 3. Analyze and Decide

For each issue (CI failure or review comment), classify it:

**AUTO-FIX** (all must be true):
- Root cause is clear (not just the symptom)
- Fix is unambiguous (one correct approach)
- Fix is small and surgical (not a refactor or design change)
- You can verify it locally (run the test, check the lint)

Examples: typos, missing imports, lint failures, simple logic bugs, null checks, formatting.

**ESCALATE** (any of these):
- Multiple valid approaches; you'd be guessing
- Design decision, API change, or architectural issue
- Requires new dependencies, config changes, or DB migrations
- Flaky/infrastructure CI failure (retry the run instead of pushing code)
- You already tried to fix this exact issue in a previous cycle and it didn't work

### 4. Fix

If auto-fixable issues exist:

1. Pull latest: `git pull origin $BRANCH`
2. Read the relevant files in full (not just the diff)
3. Make the minimal, targeted fix
4. Verify locally:
   - Backend: `cd $WORKTREE && uv run black <file> && uv run ruff check <file>`
   - Frontend: `cd $WORKTREE/frontend && bun run lint --fix && bun run typecheck`
   - Run the specific failing test if identifiable
5. Single commit: `git commit -am "fix: <description> (#$PR)"`
6. Push: `git push origin $BRANCH`

**One commit per cycle.** Don't stack multiple speculative fixes.

### 5. Loop or Stop

After pushing (or deciding not to):

**Continue looping if:**
- You just pushed a fix (need to wait for new CI run)
- There are still issues you plan to address next cycle

**Stop and report if:**
- PR is clean (CI green, no unaddressed comments)
- You hit max_cycles
- All remaining issues need human input (escalate)
- You pushed a fix for the same issue twice and it still fails (circuit breaker)

## Reporting

Send status updates to this Signal group (`group:iGrccZxHzYtMPu5SlxMgYYEQNKRi019TIICdcHVMDsY=`) via the message tool (channel=signal).

**When to report:**
- After each fix push (brief: what was fixed)
- When escalating (what needs human input and why)
- When the PR is ready (final status)

**Format:**

```
🔧 PR #{number} ({repo}) — Cycle {N}/{max}

Fixed: <what you fixed>
Waiting: <what CI is running>
Needs attention: <what you can't fix and why>
Status: <monitoring | ready | blocked>
```

**When PR is ready:**
```
✅ PR #{number} ({repo}) — Ready to merge

CI: all green
Reviews: all addressed
Commits: {count}
```

## Cleanup

When done (success or giving up):

```bash
cd ~
git -C "$LOCAL_DIR" worktree remove "$WORKTREE" --force 2>/dev/null
```

## Gotchas

- **Stale review comments:** `original_commit_id` on inline comments refers to the commit when the comment was made. If HEAD has moved past it, the issue may already be fixed. Always check the current code before acting.
- **claude-review sticky comments:** These appear as issue comments from the `claude` user. They re-run on every push. Don't try to "fix" informational observations.
- **GitHub Actions GITHUB_TOKEN suppression:** Pushes via `gh` CLI with the default token don't trigger workflow runs. If CI doesn't start after your push, the repo may need a personal SSH key or a close+reopen to kick off checks.
- **Worktree branch conflicts:** `git worktree add` fails if the branch is already checked out somewhere. Use `--detach` and then `git checkout` inside the worktree.
- **Sub-agents can introduce unintended refactors.** Always diff `$BRANCH` against `origin/$BRANCH~1` before pushing to confirm only the intended fix is included.
- **`uv run` requires `--python 3.13`** for Bloom backend. psycopg-binary wheels don't support 3.14.
- **Frontend lint may auto-fix unrelated files.** Run lint only on the files you changed, not the whole project.

## Do NOT

- Post PR comments (triggers claude-review re-runs, wastes tokens)
- Merge the PR (Eric merges)
- Force push or rewrite history
- Make changes unrelated to the PR's purpose
- Fix more than one issue per commit
- Retry the same fix approach twice
