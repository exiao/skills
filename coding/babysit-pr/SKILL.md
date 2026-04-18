---
name: babysit-pr
description: "Monitor a PR until it's ready to merge. Watches CI, reads reviews, checks scope, fixes issues, and repeats. Use when: babysit this PR, watch this PR, monitor PR, fix and watch PR, keep this PR green."
---

# Babysit PR

Monitor a single PR through its full lifecycle: check scope, wait for CI, read reviews, fix issues, push, repeat. Stop when the PR is clean (CI green, no unaddressed comments, scope is tight) or when you hit a wall that needs human input.

## Inputs

- **PR number** (required)
- **Repo** (optional, defaults to current repo via `gh repo view --json nameWithOwner -q '.nameWithOwner'`)
- **Parent session key** (optional, for sending progress updates to the parent agent via `send_to_task`)
- **Max cycles** (optional, default 10. Each cycle = one CI wait + fix attempt)

## Spawning

When spawning this skill as a sub-agent, use `streamTo: "parent"` so the parent receives real-time progress. Also pass the parent session key so the sub-agent can send structured status updates at key milestones.

```
sessions_spawn({
  task: "Use the babysit-pr skill. PR #<number>, repo <owner/repo>. Parent session: <session_key>. ...",
  streamTo: "parent",
  run_timeout_seconds: 1800
})
```

## Setup

```bash
PR=<number>
REPO=<owner/repo>

# Read repo conventions
REPO_DIR=$(echo "$REPO" | cut -d/ -f2)
for DIR in ~/$REPO_DIR ~/clawd/$REPO_DIR /tmp/$REPO_DIR; do
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
git -C "$LOCAL_DIR" worktree add "$WORKTREE" "origin/$BRANCH" 2>/dev/null || \
  git -C "$LOCAL_DIR" worktree add --detach "$WORKTREE" "origin/$BRANCH"
cd "$WORKTREE"
git checkout -B "$BRANCH" "origin/$BRANCH" || true
```

## Scope Check (runs once, before the loop)

Before fixing anything, verify the PR's changes match its stated purpose. This catches accidental commits, formatting noise, and scope creep.

```bash
# Get PR metadata
gh pr view $PR --repo $REPO --json title,body,commits --jq '{title: .title, body: .body, commits: [.commits[].messageHeadline]}'

# Get changed files with stats
gh pr diff $PR --repo $REPO --stat

# Get individual commit messages and their file lists
for SHA in $(gh api "repos/$REPO/pulls/$PR/commits" --jq '.[].sha'); do
  echo "--- Commit ${SHA:0:8} ---"
  gh api "repos/$REPO/commits/$SHA" --jq '.commit.message'
  gh api "repos/$REPO/commits/$SHA" --jq '[.files[].filename] | join(", ")'
done
```

**Evaluate:**

1. **File relevance:** Do all changed files relate to the PR title/description? Flag files that seem unrelated (e.g., a "fix login" PR that also reformats unrelated templates).
2. **Commit coherence:** Does each commit message align with the PR's purpose? Flag commits that introduce unrelated work.
3. **Formatting noise:** Flag bulk formatting changes (ruff, prettier, eslint --fix) applied beyond the files the PR actually needs to touch.
4. **Scope creep:** Multiple distinct features or fixes bundled into one PR. Each PR should do one thing.

**If scope issues found:**

Report them with specifics (which files, which commits) and classify:
- **MINOR**: A stray formatting commit or one unrelated file. Note it but continue babysitting.
- **MAJOR**: The PR bundles multiple unrelated changes, has bulk formatting noise, or commits that contradict the description. **ESCALATE.** Do not auto-fix. Report what should be split out or reverted.

Include scope findings in every status report so the parent/user sees them.

## The Loop

Repeat up to `max_cycles` times:

### 1. Wait for CI

Poll CI status every 60 seconds until all checks complete or 20 minutes pass (whichever comes first).

```bash
cd "$WORKTREE"
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
cd "$WORKTREE"

# 1. Inline review comments (on specific lines of code)
gh api --paginate "repos/$REPO/pulls/$PR/comments" | \
  jq '.[] | {author: .user.login, path: .path, line: .line, body: .body, commit: .original_commit_id, created: .created_at}'

# 2. Issue comments (automated reviewers post here)
gh api --paginate "repos/$REPO/issues/$PR/comments" | \
  jq '.[] | {author: .user.login, body: .body, created: .created_at}'

# 3. Review verdicts
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

1. Pull latest: `cd "$WORKTREE" && git pull origin $BRANCH`
2. Read the relevant files in full (not just the diff)
3. Make the minimal, targeted fix
4. Verify locally using whatever lint/test commands the project's CLAUDE.md or AGENTS.md specifies. Run the specific failing test if identifiable.
5. Single commit: `cd "$WORKTREE" && git commit -am "fix: <description>"`
6. Push: `cd "$WORKTREE" && git push origin HEAD:$BRANCH`

**One commit per cycle.** Don't stack multiple speculative fixes.

### 5. Loop or Stop

After pushing (or deciding not to):

**Continue looping if:**
- You just pushed a fix (need to wait for new CI run)
- There are still issues you plan to address next cycle

**Stop and report if:**
- PR is clean (CI green, no unaddressed comments, scope is tight)
- You hit max_cycles
- All remaining issues need human input (escalate)
- You pushed a fix for the same issue twice and it still fails (circuit breaker)
- Scope check found MAJOR issues (escalate immediately, don't try to fix)

## Reporting

Send progress updates to the parent agent via `send_to_task`. Do NOT try to send messages to Signal/Slack/etc directly (sub-agents don't have channel access). The parent agent handles delivery to the user.

If a parent session key was provided, use:
```
send_to_task(sessionKey="<parent_session_key>", message="<status update>")
```

If no parent session key was provided, include status in your final output text (the auto-announce will deliver it).

**When to report:**
- After scope check (always, even if clean)
- After each fix push (brief: what was fixed)
- When escalating (what needs human input and why)
- When the PR is ready (final status)

**Format:**

```
🔧 PR #{number} ({repo}) — Cycle {N}/{max}

Scope: ✅ clean | ⚠️ minor (details) | 🚫 major (details)
Fixed: <what you fixed>
Waiting: <what CI is running>
Needs attention: <what you can't fix and why>
Status: <monitoring | ready | blocked | scope-drift>
```

**When PR is ready:**
```
✅ PR #{number} ({repo}) — Ready to merge

Scope: ✅ changes match description
CI: all green
Reviews: all addressed
Commits: {count}
```

**When scope drift detected:**
```
⚠️ PR #{number} ({repo}) — Scope Drift

Description says: <what PR claims to do>
Actually includes:
- <unrelated file/commit 1>
- <unrelated file/commit 2>
Recommendation: <split into N PRs | revert commits X,Y | remove files A,B>
```

## Cleanup

When done (success or giving up):

```bash
cd ~
git -C "$LOCAL_DIR" worktree remove "$WORKTREE" --force 2>/dev/null
```

## Gotchas

- **Read CLAUDE.md/AGENTS.md first.** Every repo has different lint, test, and build commands. Never assume.
- **Stale review comments:** `original_commit_id` on inline comments refers to the commit when the comment was made. If HEAD has moved past it, the issue may already be fixed.
- **claude-review sticky comments:** These appear as issue comments from the `claude` user. They re-run on every push. Don't try to "fix" informational observations.
- **GitHub Actions GITHUB_TOKEN suppression:** Pushes from inside a GitHub Actions job using the default `GITHUB_TOKEN` don't trigger other workflow runs. This does NOT apply to local `gh` CLI pushes.
- **Worktree branch conflicts:** `git worktree add` fails if the branch is already checked out somewhere. The Setup uses `origin/$BRANCH` to avoid this.
- **Sub-agents can introduce unintended refactors.** Always diff `$BRANCH` against `origin/$BRANCH` before pushing to confirm only the intended fix is included.
- **Frontend lint may auto-fix unrelated files.** Run lint only on the files you changed, not the whole project.
- **Check ALL three comment sources.** `gh pr view --json reviews` only shows formal review submissions. Automated reviewers often post as issue comments.
- **Scope check is not optional.** Even if the caller says "just fix CI," run the scope check. Catching drift early prevents wasted cycles fixing code that shouldn't be in the PR.

## Do NOT

- Post PR comments (triggers claude-review re-runs, wastes tokens)
- Merge the PR (the repo owner merges)
- Force push or rewrite history
- Make changes unrelated to the PR's purpose
- Fix more than one issue per commit
- Retry the same fix approach twice
- Auto-fix scope drift (always escalate it)
