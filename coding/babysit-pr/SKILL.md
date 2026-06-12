---
name: babysit-pr
preloaded: true
description: "Monitor a PR until it's ready to merge. Watches CI, reads reviews, checks scope, fixes blocking issues, opens follow-up PRs for low-priority comments, and repeats. Use when: babysit this PR, watch this PR, monitor PR, fix and watch PR, keep this PR green."
---

# Babysit PR

Monitor a single PR through its full lifecycle: check scope, wait for CI, read reviews, fix blocking issues, open follow-up PRs for low-priority review comments, push, repeat. Stop when the PR is ready to merge (CI green, no blocking unaddressed comments, scope is tight) or when you hit a wall that needs human input.

## Inputs

- **PR number** (required)
- **Repo** (optional, defaults to current repo via `gh repo view --json nameWithOwner -q '.nameWithOwner'`)
- **Parent session key** (optional, for sending progress updates to the parent agent via `send_to_task`)
- **Max cycles** (optional, default 10. Each cycle = one CI wait + fix attempt)

> CI status when `gh pr checks` / `statusCheckRollup` returns 403 (the token
> lacks Checks-read): query the Actions runs API keyed by the PR head SHA
> (`gh api "repos/$REPO/actions/runs?head_sha=$SHA&per_page=50"`) and collapse to
> the latest run per workflow. Do NOT switch GitHub accounts or declare CI broken.

## Webhook Review Event Filtering

When invoked from a single code-review webhook/event, apply the event-level filter before setup:

- Exit with exactly `No action needed` if the triggering review state is `approved`.
- Exit with exactly `No action needed` if the webhook action is `dismissed`.
- Exit with exactly `No action needed` if the triggering review state is `commented`, the review body is empty, and the event payload has no inline comments or review thread references. Empty-body commented reviews can still carry actionable inline comments, so inspect thread/comment payloads before skipping.
- Otherwise, treat the review as actionable and run the babysit loop, even if the PR's aggregate `reviewDecision` is already `APPROVED`. A PR can be approved overall while a later `COMMENTED` review contains a real inline fix request.

## Spawning

When spawning this skill as a sub-agent, use `streamTo: "parent"` so the parent receives real-time progress. Also pass the parent session key so the sub-agent can send structured status updates at key milestones.

```
sessions_spawn({
  task: "Use the babysit-pr skill. PR #<number>, repo <owner/repo>. Parent session: <session_key>. ...",
  streamTo: "parent",
  run_timeout_seconds: 1800
})
```

If delegating through `delegate_task`, toolset names must be exact. Use `toolsets=["terminal", "file", "web"]` at minimum. Invalid names like `ShellExec` or `mcp_terminal` silently leave the subagent without shell access, which makes PR babysitting impossible. If the user says not to delegate, run the whole babysitting loop directly in the parent session.

## Setup

```bash
PR=<number>
REPO=<owner/repo>

# Read repo conventions
REPO_DIR=$(echo "$REPO" | cut -d/ -f2)
for DIR in ~/$REPO_DIR ~/projects/$REPO_DIR ~/.hermes/$REPO_DIR ~/clawd/$REPO_DIR /tmp/$REPO_DIR; do
  [ -d "$DIR/.git" ] && LOCAL_DIR="$DIR" && break
done

# Create worktree under the shared worktree directory, never /tmp.
# This keeps work discoverable and avoids losing state between sessions.
# Prefer a repo+PR-specific path so babysit jobs don't collide with branch-named
# worktrees from other repos or follow-up PRs.
BRANCH=$(gh pr view $PR --repo $REPO --json headRefName -q '.headRefName')
WORKTREE="$HOME/projects/_worktrees/${REPO_DIR}-pr-${PR}"
mkdir -p "$HOME/projects/_worktrees"

if [ -d "$WORKTREE" ] && git -C "$WORKTREE" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # Shared worktree already exists. It may have been created from a different local clone,
  # so do not rely only on LOCAL_DIR's worktree list.
  cd "$WORKTREE"
elif [ -n "$LOCAL_DIR" ]; then
  # If this branch already has a worktree in this clone, use it instead of creating a second one.
  EXISTING=$(git -C "$LOCAL_DIR" worktree list --porcelain | awk -v branch="refs/heads/$BRANCH" '
    /^worktree / { wt=$2 }
    $0 == "branch " branch { print wt }
  ' | head -1)
  if [ -n "$EXISTING" ]; then
    WORKTREE="$EXISTING"
  else
    git -C "$LOCAL_DIR" fetch origin "$BRANCH"
    git -C "$LOCAL_DIR" worktree add "$WORKTREE" "origin/$BRANCH" 2>/dev/null || \
      git -C "$LOCAL_DIR" worktree add --detach "$WORKTREE" "origin/$BRANCH"
  fi
  cd "$WORKTREE"
else
  # No local clone found — clone directly to the worktree path using gh auth fallback.
  gh repo clone "$REPO" "$WORKTREE" -- --branch "$BRANCH"
  LOCAL_DIR="$WORKTREE"
  cd "$WORKTREE"
fi

# Read project rules
for F in CLAUDE.md AGENTS.md; do
  [ -f "$WORKTREE/$F" ] && cat "$WORKTREE/$F"
done
```

## Scope Check (runs once, before the loop)

Before fixing anything, verify the PR's changes match its stated purpose. This catches accidental commits, formatting noise, and scope creep.

```bash
# Get PR metadata
gh pr view $PR --repo $REPO --json title,body,commits --jq '{title: .title, body: .body, commits: [.commits[].messageHeadline]}'

# Get changed files (--stat is not a valid gh flag; use --name-only)
# For very large PRs, GitHub may return HTTP 406 because the diff exceeds its file cap
# (often ~300 files). In that case, use the Pull Request Files API (paginated) or a
# local git diff in the isolated worktree.
gh pr diff $PR --repo $REPO --name-only || \
  gh api --paginate "repos/$REPO/pulls/$PR/files?per_page=100" --jq '.[].filename'

# Local fallback when you need authoritative file status for large PRs:
# BASE=$(gh pr view $PR --repo $REPO --json baseRefName -q '.baseRefName')
# git -C "$WORKTREE" fetch origin "$BASE"
# git -C "$WORKTREE" diff --name-status "origin/$BASE...HEAD"

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

**Triage review findings:** For each issue flagged by reviewers (human or automated), classify it as BLOCKING, DEFERABLE, ADDRESSED, or HUMAN-INTENT per step 3. Blocking issues are fixed on the current PR. Deferable issues do not block the current PR, but they must become real follow-up PRs so they are not forgotten.

**Resolve handled comments:** After triaging, resolve any review threads that are outdated or already addressed. See step 2b.

**Before declaring ready, run the automated review final sweep.** If CI is green but GitHub still shows `CHANGES_REQUESTED`, `BLOCKED`, a latest top-level bot comment with `Must Fix` items, or unresolved non-outdated GraphQL threads, keep working unless every remaining thread is deferable and has a linked follow-up PR. Load `references/automated-review-final-sweep.md` for exact commands and decision rules.

**If CI green + no blocking unaddressed findings + no unresolved non-outdated blocking threads + every deferable thread has an opened follow-up PR → PR is ready. Report success and stop.**

**If there are blocking or deferable findings → go to step 3.**

### 2b. Resolve Outdated / Addressed Comments

After reading all comments, check each unresolved review thread to determine if it's been addressed by subsequent commits or is no longer applicable. Use the GraphQL API to fetch threads and resolve them.

```bash
# Fetch all unresolved review threads with their comments
gh api graphql \
  -f query='query($owner: String!, $name: String!, $number: Int!) {
    repository(owner: $owner, name: $name) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            isOutdated
            path
            line
            comments(last: 50) {
              nodes {
                body
                author { login }
                createdAt
                originalCommit { oid }
              }
            }
          }
        }
      }
    }
  }' \
  -f owner="$(echo $REPO | cut -d/ -f1)" \
  -f name="$(echo $REPO | cut -d/ -f2)" \
  -F number=$PR
```

Note: `first: 100` covers the vast majority of PRs. For exceptionally large PRs with 100+ threads, add `pageInfo { hasNextPage endCursor }` and paginate with `after:` cursor.

**For each unresolved thread, evaluate:**

1. **Already fixed:** The issue raised in the comment has been addressed by a subsequent commit. Read the current file at that path/line and confirm the fix is present.
2. **Outdated by refactor:** The file or lines the comment refers to no longer exist or have been substantially rewritten.
3. **Deferable:** The issue is a low-priority non-bug: style, naming, docs, test ergonomics, small cleanup/refactor, dedupe, logging polish, non-critical perf, or an improvement that does not affect correctness.
4. **Human-intent:** The thread asks a product/design/API question or presents multiple valid approaches.
5. **Still blocking:** The issue persists and could affect correctness, security/privacy, data integrity, deployability, tests, or API contracts. Leave unresolved and either auto-fix (step 3) or escalate.

For automated-reviewer threads that an author already declined or explained, verify against live PR HEAD before editing. Read the referenced current lines and adjacent implementation, run the narrowest relevant test/probe if useful, and decide whether the finding is still actionable. If live code supports the author's explanation, do **not** push a cosmetic/no-op change just to appease the bot. Reply with the HEAD SHA and concrete evidence, then resolve the thread via GraphQL (`addPullRequestReviewThreadReply` + `resolveReviewThread`). After resolving, re-query `reviewThreads` and checks to prove `unresolved=0`, CI/status rollup is success, review decision/merge state are clean, and the worktree stayed unmodified.

Pitfall: if a shell pipeline that pipes `gh api graphql` into `python - <<'PY'` fails because the heredoc consumes stdin, retry using `gh api --jq` for simple thread counts instead of treating the API result as unavailable.

**For threads that are addressed or outdated:**

1. Reply to the thread explaining why it's resolved (be specific, cite the commit or line change):
```bash
# Reply to the review thread
gh api graphql \
  -f query='mutation($threadId: ID!, $body: String!) {
    addPullRequestReviewThreadReply(input: {
      pullRequestReviewThreadId: $threadId,
      body: $body
    }) {
      comment { id }
    }
  }' \
  -f threadId="<THREAD_ID>" \
  -f body="Resolved: <brief explanation of what changed>"
```

2. Resolve the thread:
```bash
# Resolve the review thread
gh api graphql \
  -f query='mutation($threadId: ID!) {
    resolveReviewThread(input: {
      threadId: $threadId
    }) {
      thread { isResolved }
    }
  }' \
  -f threadId="<THREAD_ID>"
```

**Reply templates:**
- Fixed by commit: `"Resolved -- fixed in {short_sha}: {what changed}"`
- Outdated by refactor: `"Resolved -- this code was refactored/removed in {short_sha}"`
- Informational/acknowledged: `"Acknowledged -- {brief response to the observation}"`
- Already correct: `"Resolved -- verified this is already handled: {evidence}"`

**Rules for resolving:**
- Only resolve threads where you have high confidence the issue is addressed. When in doubt, leave it open.
- Never resolve threads from human reviewers that are asking questions. Those need a human answer.
- Always reply before resolving so there's a paper trail of why it was closed.
- Bot/automated reviewer threads (claude-review, Seer, Bugbot, etc.) can be resolved freely if the issue is demonstrably fixed.
- **Deferable bot threads may be replied to and resolved only after you have opened a concrete follow-up PR and can link it. Reply: `Deferred to follow-up PR #{n}: {what it fixes}`.
- If the prompt says an existing follow-up PR may cover deferable threads, verify it against the actual unresolved thread bodies and the follow-up diff before linking/resolving. Titles and PR bodies can be stale or only partially overlapping. If the existing follow-up does not address every cited behavior, create a new focused stacked follow-up from the source PR head, prove the regression red/green, link that new PR in the relevant threads, then resolve them.
- **Deferable human threads should get a reply with the follow-up PR link. Resolve them only if the reviewer clearly framed it as non-blocking (`nit`, `optional`, `follow-up`, approval/praise) or the user explicitly told you to resolve it.
- Keep replies concise. One sentence with the commit SHA, evidence, or follow-up PR link.

### 3. Analyze and Decide

For each issue (CI failure or review comment), classify it:

**BLOCKING AUTO-FIX** (all must be true):
- Root cause is clear (not just the symptom)
- Fix is unambiguous (one correct approach)
- Fix is small and surgical (not a refactor or design change)
- You can verify it locally (run the test, check the lint)

Examples: typos, missing imports, lint failures, simple logic bugs, null checks, formatting.

**DEFERABLE FOLLOW-UP PR** (all must be true):
- The current PR is safe to merge without it
- The comment is low priority: style, naming, docs, test ergonomics, small cleanup/refactor, dedupe, logging polish, non-critical perf, or nice-to-have improvement
- The fix can be made as a separate PR without changing the correctness of the current PR
- The follow-up can be described in one coherent PR title/body

Do not merely list deferable items. Open the follow-up PR so it is tracked.

**ESCALATE** (any of these):
- Multiple valid approaches; you'd be guessing
- Design decision, API change, or architectural issue
- Requires new dependencies, config changes, or DB migrations
- Flaky/infrastructure CI failure (retry the run instead of pushing code)
- You already tried to fix this exact issue in a previous cycle and it didn't work

### 3b. Open Follow-up PRs for Deferable Comments

When only low-priority non-bug review comments remain, do not fix them on the current PR. Create one or more follow-up PRs and link them back to the original review threads.

Grouping rule: one follow-up PR per coherent change. Group related nits together (for example docs wording), but do not bundle unrelated cleanup with unrelated test ergonomics.

Base/branch rule:
- If the original PR is still open, its code is not on the default branch yet, and the PR head branch lives in the base repository, branch from the original PR HEAD and open a stacked follow-up PR with `--base ORIGINAL_PR_BRANCH`. This keeps the current PR unchanged while making the follow-up impossible to forget.
- If the original PR is from a fork, do not assume `headRefName` exists on the base repo's `origin`. Branch from the default branch unless you explicitly have write access to the fork and can create the follow-up with `--head OWNER:BRANCH`.
- If the original PR is already merged or the default branch already contains the relevant code, branch from the default branch and open the follow-up PR against the default branch.
- Never push follow-up fixes onto the current PR branch unless the user explicitly asks to fix the current PR instead.

Procedure:
```bash
# Original PR metadata
BRANCH=$(gh pr view $PR --repo $REPO --json headRefName -q '.headRefName')
HEAD_OWNER=$(gh pr view $PR --repo $REPO --json headRepositoryOwner -q '.headRepositoryOwner.login')
BASE_OWNER=$(echo "$REPO" | cut -d/ -f1)
DEFAULT=$(gh repo view $REPO --json defaultBranchRef -q '.defaultBranchRef.name')
STATE=$(gh pr view $PR --repo $REPO --json state -q '.state')

# Choose base. Stack only when the source branch is on the base repo; fork heads
# are named OWNER:BRANCH for PR creation and are not fetchable as origin/BRANCH.
BASE="$BRANCH"
if [ "$STATE" = "MERGED" ] || [ "$HEAD_OWNER" != "$BASE_OWNER" ]; then
  BASE="$DEFAULT"
fi

# Create a new worktree for the follow-up branch
FOLLOW="followup-pr-$PR-SHORT_TOPIC"
git fetch origin "$BASE"
git worktree add "$HOME/projects/_worktrees/$FOLLOW" -b "$FOLLOW" "origin/$BASE"
cd "$HOME/projects/_worktrees/$FOLLOW"

# Apply the deferable cleanup, verify, commit, push
git add FILES
git commit -m "followup: <short topic>"
git push origin HEAD:"$FOLLOW"

# Open the follow-up PR. Write body to a file, never inline long markdown.
gh pr create --repo "$REPO" --base "$BASE" --head "$FOLLOW" \
  --title "Follow up to #$PR: <short topic>" \
  --body-file /tmp/followup-pr-$PR-SHORT_TOPIC.md
```

Follow-up PR body must include:
- `Follow-up to #<original PR>`
- Links or quoted summaries for the deferred review comments
- Why it was safe to keep the original PR moving
- Verification run for the follow-up PR

After creating the follow-up PR, reply to each deferred thread with the PR link:
`Deferred to follow-up PR #<n>: <one-line summary>. This is non-blocking for the current PR because <reason>.`

### 4. Fix

If blocking auto-fixable issues exist:

1. Pull latest and check if already fixed: `cd "$WORKTREE" && git fetch origin $BRANCH && git log --oneline origin/$BRANCH -5`. If remote is ahead of your local HEAD, inspect the new commits — someone (or a prior agent run) may have already fixed the issue. Verify by reading the flagged file at `origin/$BRANCH`. If already fixed, skip to step 5.
1b. Rebase onto remote: `git pull --rebase origin $BRANCH` (or merge if rebase isn't clean)
2. Read the relevant files in full (not just the diff)
3. Make the minimal, targeted fix
4. Verify locally using whatever lint/test commands the project's CLAUDE.md or AGENTS.md specifies. Run the specific failing test if identifiable. If local pytest fails before collection because the repo's `addopts` references an unavailable plugin (for example `-n auto` without `pytest-xdist`), rerun the targeted test with an explicit override such as `python -m pytest -o addopts='' <test>` and report both the local tooling limitation and the successful targeted command; still rely on live CI for the full configured command.
5. Stage carefully: `cd "$WORKTREE" && git add -A && git diff --cached --stat` — review the staged file list. Setup commands (`make setup-worktree`, `uv sync`, `bun install`) can generate untracked files (e.g. `config/mcporter.json`, `.env`, `node_modules/` artifacts) that `git add -A` will pick up. Unstage anything not part of your fix: `git reset HEAD <file>`.
6. Single commit: `cd "$WORKTREE" && git commit -m "fix: <description>"`
7. Push: `cd "$WORKTREE" && git push origin HEAD:$BRANCH`

**One commit per cycle.** Don't stack multiple speculative fixes.

### 5. Loop or Stop

After pushing (or deciding not to):

**Continue looping if:**
- You just pushed a fix (need to wait for new CI run and any reviewer re-run)
- You just opened a follow-up PR for deferable comments and still need to reply/link/resolve the original threads
- A reviewer bot is still running, even if prior CI/checks were green
- A fresh reviewer run surfaced new actionable findings after earlier fixes. Treat that as the next cycle, not as churn to ignore
- There are still issues you plan to address next cycle

**Stop and report if:**
- PR is ready (latest CI green, latest reviewer run completed, no blocking unaddressed comments, deferable comments have opened follow-up PRs, scope is tight)
- You hit max_cycles
- All remaining issues need human input (escalate)
- You pushed a fix for the same issue twice and it still fails (circuit breaker)
- Scope check found MAJOR issues (escalate immediately, don't try to fix)

## Reporting

Send progress updates to the parent agent via `send_to_task`. Do NOT try to send messages to Signal/Slack/etc directly (sub-agents don't have channel access). The parent agent handles delivery to the user.

If no code change was needed, explicitly report `Pushed commit SHA(s): none` plus already-clean evidence: live head SHA, aggregate PR state, checks, latest substantive review/comment, unresolved non-outdated thread count, and worktree path. Do not invent a pushed SHA or create empty commits just to satisfy a SHA request.

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

**Signal/chat discipline:**
- Do not stream raw scratchpad, grep results, or "let me check" narration into Signal/Slack. Users read those as confusing status leaks.
- Send only milestone updates: scope result, fix pushed, CI status, blocker, ready. If you need to think aloud, keep it internal and finish the tool cycle before messaging.

**Format:**

```
🔧 PR #{number} ({repo}) — Cycle {N}/{max}

Scope: ✅ clean | ⚠️ minor (details) | 🚫 major (details)
Fixed: <what you fixed>
Resolved: <N threads resolved with reasons>
Follow-ups: <opened PR links for deferable comments, or none>
Waiting: <what CI is running>
Needs attention: <what you can't fix and why>
Status: <monitoring | ready | blocked | scope-drift>
```

**When PR is ready:**
```
✅ PR #{number} ({repo}) — Ready to merge

Scope: ✅ changes match description
CI: all green
Reviews: no blocking findings
Commits: {count}
Follow-ups: <none | #follow-up-pr links>
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

## Multi-PR Babysitting

When asked to babysit multiple PRs interactively, **do the work directly in the parent agent** rather than spawning sub-agents. Sub-agent delegation for babysit-pr has a high failure rate (toolset mismatches, context loss, wasted tokens). Even with correct toolsets, sub-agents often fail on the skill-loading chain. Work through PRs sequentially:

1. Check CI + reviews on all PRs first (quick `gh pr checks` loop + mergeable status)
2. Triage: which need blocking fixes vs. which only need follow-up PRs vs. which are already merged
3. Fix blocking issues in each PR in order, push, move to next
4. For deferable comments, open stacked follow-up PRs (or default-branch follow-ups if the source PR is merged), link them in the original threads, then move on
5. Circle back if any need a second cycle after CI re-runs

This is faster and more reliable than parallel sub-agents for 2-5 PRs.

**Shared-failure shortcut:** Before diving into per-PR fixes, check if all PRs share the same CI failure (e.g., rate-limited reviewer bot, expired token, infra flake). If so, diagnose once, report the common cause, and skip redundant per-PR analysis. Common patterns: reviewer-bot rate limits ("You've hit your limit"), GitHub App auth failures, shared secret expiry.

For scheduled "babysit all open PRs" cron jobs, load `references/daily-open-pr-babysitter.md`. If the prompt explicitly asks for parallel delegation, batch according to the runtime's real concurrency cap, then run a parent-agent verification sweep before the digest. Child summaries are not enough: subagents often time out after pushing useful fixes or leave resolvable bot threads open.

**Cron mass-babysit handoff protocol:** In large scheduled runs, treat each delegation batch as a partial transaction, not a terminal verdict. After every batch, rerun the collector, compare pre/post head SHAs, inspect subagent worktrees for local commits or dirty files, push verified local fixes yourself if a child timed out, resolve fixed bot threads while the SHA is fresh, and only then continue. For scheduled "fix all open PRs" jobs, `0 need attention` is not done if the collector still reports `ready_with_followups` or any `clean:false` entry. Follow-up PRs opened during babysitting are part of the same transaction and must be babysat to clean/approved/green before final reporting.

## Quick Fix Mode (no full babysit loop)

When the user says "fix comments on PR X" or "fix merge conflicts on PR X", skip the full babysit loop. Just:

1. Check the PR state first (`gh pr view --json state,mergedAt,headRefOid`). If it is already merged, do not push more commits expecting that PR to update. Treat actionable unresolved threads as follow-up work on a fresh branch from current base.
2. Read every latest review source, including GraphQL review threads. Merged/approved PRs can still have unresolved non-outdated bot threads from a later review pass.
3. Check if issues are already fixed in current code (grep the worktree, don't assume)
4. Fix what's actionable, commit, push
5. If the original PR is merged, open a new follow-up PR and reply/resolve the original threads with the follow-up PR link. If it is open, resolve addressed threads in bulk on that PR.
6. Report what was fixed and what needs attention

This is the common case: user already knows what's wrong, just wants it done. The trap is assuming "approved" or "merged" means there are no actionable comments left; verify the thread list anyway.

## Gotchas

See also:
- `references/delegation-and-git-pitfalls.md` — force-push recovery, batch thread resolution, toolset names
- `references/public-repo-redaction.md` — stripping hardcoded values from public repos and adding env vars
- `references/branch-preservation-and-ci-auth.md` — preserving dirty branches via commit+patch pattern, CI 401 auth retry protocol, public repo redaction checklist
- `references/automated-review-final-sweep.md` — final reconciliation of CI, formal reviews, issue comments, and unresolved GraphQL threads before calling a PR clean
- `references/deferable-comments-followup-prs.md` — policy for low-priority review comments: open real follow-up PRs and link them, never leave recommendations as TODOs

- **Python mock failures in xdist.** String-based `patch("pkg.submod.func")` can silently fail in pytest-xdist workers if the submodule isn't explicitly imported. Use `patch.object(imported_mod, "func")` instead. Also patch the import site that the view/code under test actually calls, not the original service module, when functions are imported with `from service import func`; otherwise xdist/order-dependent tests can leak stubs or miss the patch. See `references/delegation-and-git-pitfalls.md` for the full diagnosis checklist.
- **caplog can be flaky under full-suite xdist.** If CI fails with `caplog.text == ""` even though a focused local test passes, don't keep tweaking logger levels. Two proven alternatives:
  1. **Mock the logger methods** when the test promises specific log content: `mock_warning = Mock(); monkeypatch.setattr(module.logger, "warning", mock_warning)`, then assert `any("expected substring" in str(call) for call in mock_warning.call_args_list)`.
  2. **Side-effect list** when the test only needs to confirm the graceful-skip path ran (not the exact message): `close_calls = []; monkeypatch.setattr(module, "close_old_connections", lambda: close_calls.append("closed"))`, then assert `close_calls`.
  Choose (1) for tests named `*_treats_X_as_Y` or `*_downgrades_X`; choose (2) for simpler "did it skip or raise" assertions. Use a mixed/uppercase fixture message when the fix is case-insensitive string matching, so the regression test actually proves `.lower()` is used.
- **MagicMock + `hasattr` can create fake attributes.** In tests that use `MagicMock` as a stand-in object, `hasattr(mock, "_exception")` may return true because `MagicMock.__getattr__` creates a child mock. This can turn a thread-exception mock into `raise <MagicMock>`, producing `TypeError: exceptions must derive from BaseException` in CI. Check `"_exception" in mock.__dict__` or initialize the attribute explicitly instead.
- **Delegation toolsets.** When delegating to a sub-agent, you MUST pass `toolsets=["terminal", "file", "web", "memory", "skills"]`. The toolset name is `"terminal"`, NOT `"ShellExec"` or `"mcp_terminal"`. Without it the sub-agent has no shell and fails immediately.
- **Force-push is blocked.** The git wrapper blocks all force pushes. Never amend commits; make a new fixup commit on top instead. See references for the recovery pattern if you already diverged.
- **Never `git checkout -- <file>` / `git restore <file>` / `git reset --hard` to undo a stray formatter run.** These discard ALL uncommitted changes on that file, including your real logical edits, not just the formatting noise. Do not pipe the whole file diff through `git apply -R`; that reverses every unstaged hunk in the file and drops the logical edit too. Recovery that preserves your edits: first save a safety patch (`git diff -- path/to/file > /tmp/file.patch`), then either selectively reverse only formatter-only hunks with interactive/manual patch editing, or rebuild from base — `git show <base-ref>:<path> > <path>` — and re-apply ONLY your logical change by hand. Re-run tests + the formatter's `check` (not `format`) after, and confirm `git diff --stat` shows only your intended change.
- **Amended-after-push recovery without force-push.** If you `git commit --amend` (or otherwise rewrote a commit) AFTER it was already pushed, the next `git push` is rejected non-fast-forward and you cannot force-push. Recovery that keeps history append-only: `git fetch origin $BRANCH && git reset --soft origin/$BRANCH` (re-stages your amended changes as uncommitted, discarding the local rewritten commit but NOT the file edits), then `git commit -m "<follow-up msg>"` and a normal `git push origin HEAD:$BRANCH`. (`reset --soft` is allowed because it preserves working-tree content.)
- **Batch thread resolution.** When resolving 5+ threads, loop in a single shell command (array of "ID:message" pairs) rather than one tool call per thread. See references for the pattern.
- **Supply chain scanner false positives.** A "Scan PR for critical supply chain risks" CI check sometimes flags files (e.g. `setup.py`) that exist on the base branch and are NOT in the PR's diff. Verify with `gh pr diff $PR --repo $REPO --name-only | grep <flagged-file>`. If the file isn't in the diff, report as false positive and don't attempt to fix. This CI failure alone does not block "ready to merge" status.
- **Read CLAUDE.md/AGENTS.md first.** Every repo has different lint, test, and build commands. Never assume.
- **Do not print git remotes.** Some worktrees have `origin` URLs with embedded tokens. Avoid `git remote -v` / `git config --get remote.origin.url` in logs during babysitting; if you only need the repo identity, use `gh repo view --json nameWithOwner` or sanitize locally before printing.
- **Stale review comments:** `original_commit_id` on inline comments refers to the commit when the comment was made. If HEAD has moved past it, the issue may already be fixed.
- **Reviewer re-runs can reveal new redaction issues after every push.** Claude-review and similar bots often approve one pass, then flag newly noticed public-repo leaks in the next run. Do not report "ready" while a reviewer run is still in progress, and do not rely on an older approval after pushing another fix. Wait for the latest run for the current HEAD, then read its issue comment, review body, and inline threads.
- **GitHub Actions GITHUB_TOKEN suppression:** Pushes from inside a GitHub Actions job using the default `GITHUB_TOKEN` don't trigger other workflow runs. This does NOT apply to local `gh` CLI pushes.
- **Worktree branch conflicts:** `git worktree add` fails if the branch is already checked out somewhere. The Setup uses `origin/$BRANCH` to avoid this. However, if an existing worktree for the same branch already exists, **just use it** — fetch + pull there instead of creating a second worktree.
- **Broken worktree gitdir link.** A worktree's `.git` file is a pointer (`gitdir: /path/to/parent/.git/worktrees/name`). If the parent repo directory was renamed, moved, or its `.git/worktrees/` metadata was cleaned, the worktree becomes unusable (`fatal: not a git repository`). Recovery: `trash` the broken worktree directory and `gh repo clone $REPO $WORKTREE -- --branch $BRANCH` to get a fresh standalone clone at that path. This is faster than trying to repair the gitdir link.
- **Reviewer flag suggestions can be backwards.** When a reviewer says "flag X should be Y to match existing usage," verify against the actual CLI/library source code before applying. The reviewer may have the direction of the fix inverted. Always `grep` the source for the definitive flag name before changing anything.
- **Existing worktree path may belong to another clone.** Repo discovery can pick `~/repo` while the existing shared worktree was created from `~/projects/repo`, so `git -C "$LOCAL_DIR" worktree list` will not show it even though `~/projects/_worktrees/$BRANCH` is a valid git worktree. Before `git worktree add`, test `[ -d "$WORKTREE/.git" ] || git -C "$WORKTREE" rev-parse --is-inside-work-tree`. If it is a repo, `cd "$WORKTREE"`, `git fetch origin "$BRANCH"`, compare `HEAD` to `origin/$BRANCH`, and rebase or fast-forward as needed. Do not trash or overwrite the directory.
- **Prior agent's partial fix:** When a fix commit already exists for a review, don't assume it addressed ALL items. Read the review body line-by-line and verify each requested change is present in the current code. Prior agents frequently fix 3 of 4 items and miss one.
- **Remote may already have bot fixes.** Before coding review fixes, run `git fetch origin $BRANCH` and inspect `origin/$BRANCH` commits. Automated reviewers/agents may have pushed contract decisions already. Rebase onto remote before committing unless you intentionally need to supersede it. Don't "fix" one side of an API by changing the contract if remote/frontend/CLI already converged on the other shape.
- **Reviewer bots can push after you push.** After your fix push, CI/reviewer bots may push their own follow-up commit while checks are still running. Before final verification, always `git fetch origin $BRANCH`, compare `git rev-parse HEAD` to `git rev-parse origin/$BRANCH`, and rebase if remote moved. Inspect any bot-added commit for scope, verify its files, and include it in the final report. Never report your local HEAD as ready if the PR head has advanced remotely. If the bot push adds new targeted tests or resolves one review item but leaves fresh findings, keep babysitting on top of the new remote head.
- **Review-body-only feedback (no inline threads):** Some reviewers (especially claude[bot] and gemini-code-assist[bot]) put all feedback in the review body rather than inline threads. The GraphQL `reviewThreads` query will return empty. You still need to parse the review body text, identify each requested change, and verify/fix them. These won't have thread IDs to resolve — the review state updates when the reviewer re-reviews or the PR author dismisses.
- **Stale top-level bot issue comments can be minimized after proof.** A bot may post a top-level issue comment (not an inline thread) against an old SHA; collectors may keep treating it as blocking even after the finding is fixed, CI/reviews are green, and no unresolved threads remain. First query the issue comment node to see whether it is already minimized: `gh api graphql -F id='<issue_comment_node_id>' -f query='query($id:ID!){node(id:$id){__typename ... on IssueComment{id isMinimized minimizedReason updatedAt bodyText}}}'`. If it already returns `isMinimized: true` + `minimizedReason: outdated`, do not post or mutate anything; report any remaining collector block as a false positive. If you verified the exact issue is fixed on live HEAD and the old comment references a stale reviewed commit, minimize it with GraphQL instead of posting a new top-level comment: `gh api graphql -f query='mutation($id:ID!){minimizeComment(input:{subjectId:$id,classifier:OUTDATED}){minimizedComment{isMinimized minimizedReason}}}' -F id='<issue_comment_node_id>'`. Only do this for bot comments, never unresolved human intent.
- **"Changes requested" but already fixed:** claude[bot] sometimes submits `CHANGES_REQUESTED` reviews where the body documents bugs that were already fixed in a later commit within the same PR (e.g. "Bug fixed: X (commit abc123)"). The review state looks blocking but there's nothing to fix. Read the review body carefully before assuming work is needed. If every issue listed says "fixed in <sha>" and concludes "no other issues found," the only action is to wait for CI and let the reviewer re-approve on the next push. Don't skip CI checks though; formatting or test failures may still exist independent of the review.
- **Formatter CI failures in worktrees:** When CI fails on prettier/eslint formatting, you need `bun install` (or `npm install`) in the frontend directory before running the formatter. Use `--frozen-lockfile` to avoid modifying lockfiles. Then run the formatter on only the flagged file(s), not the whole project. Verify the diff is pure whitespace/formatting before committing.
- **Match the repo's ACTUAL formatter, and check the base file first.** Don't assume `black`. Grep `pyproject.toml`/`setup.cfg`/`.pre-commit-config.yaml` for `ruff`/`black`/`line-length` and read `.github/workflows/*.yml` to see what CI actually enforces. A repo using `ruff` (e.g. line-length 120) will be mangled by `black`'s 88-col default. If the base branch already fails `<formatter> format --check`, that mismatch is PRE-EXISTING, not yours — only fix it if CI runs `format --check` (many CIs run only `ruff check` lint + pytest, which a hand-matched diff passes without any format run). Verify by running the formatter `--check` against the untouched base file (`git show <base>:<path> > /tmp/base.py`).
- **Merge state can be dirty even after all checks pass.** If `gh pr view --json mergeStateStatus` shows `DIRTY` while CI/reviews are clean, fetch the base branch and merge it into the PR branch with a normal merge commit, then push and wait for a fresh CI/reviewer run. When the conflict is purely additive (the PR and the base each registered a different member of the same enum / choices list / docs enumeration), it is a "keep BOTH" union, not a behavior choice; resolve mechanically with assert-before-write. Before pushing, inspect `git diff origin/$BRANCH..HEAD --stat` so the merge only brings expected base-branch changes plus conflict resolutions. For hot base branches this stat can be huge because it includes all base changes; that is not scope drift by itself. Still keep the manual conflict resolution minimal and preserve the PR's regression test/invariant when the conflict is in tests. Do not report ready until `mergeStateStatus: CLEAN` on the latest remote head.
- **Stacked PRs must be forward-ported before final status.** When a base PR in a stack receives review fixes or bot auto-fix commits, immediately merge/fetch that base into every downstream PR branch, resolve conflicts, run the focused tests for the downstream branch, and push it before saying the stack is ready. If a tool/time limit hits while a downstream branch is mid-merge or has conflict markers, report the stack as incomplete and name the exact branch/conflict.
- **`UNSTABLE` is not necessarily still conflicted.** After pushing a merge-conflict fix, `mergeable: MERGEABLE` with `mergeStateStatus: UNSTABLE` usually means required checks are pending. Verify `mergeable`, `statusCheckRollup`, and `gh pr checks` before claiming conflicts remain.
- **Transient/stale check state after pushes:** `gh pr checks` can briefly show a failed check while the workflow/run is still settling or a rerun of the same job is in progress. Before coding a second fix, inspect the latest run/job logs (`gh run view ... --log`) and the PR rollup (`gh pr view --json statusCheckRollup`). If logs say the job actually passed, continue polling rather than changing code.
- **Reviewer infrastructure failures are blockers, not code issues.** `claude-review` can fail for auth reasons (`GitHub App authentication failed`, OIDC 401s), usage caps (`You've hit your org's monthly usage limit`), or generic crashes (`Claude encountered an error` with no review output). In all cases: confirm no actionable code feedback was posted, rerun the failed job once (`gh run rerun <id> --repo $REPO --failed`), and if it fails again, stop as blocked. `mergeStateStatus` will show `UNSTABLE` from the failing required check. See `references/claude-review-infra-failures.md` for diagnosis commands and known failure patterns. **Watch for status disagreement:** the job API can show `in_progress` while an issue comment already says "Claude encountered an error" or is stuck at "Claude Code is working…" with the job already concluded as `failure`. Before polling for 10+ minutes, check issue comments for error announcements or stale "working" status. If the bot posted an error OR the comment says "working" but the job is done, treat the check as failed immediately.
- **Avoid formatter-driven scope creep in review fixes.** If a repo has broad pre-existing lint/format violations, running `black`, `prettier`, or `eslint --fix` on entire files can create noisy diffs unrelated to the reviewer comment. Prefer syntax checks (`python -m py_compile`, `git diff --check`) and narrow behavioral probes first. If you accidentally reformat unrelated code, do not treat `git diff | git apply -R` as a formatter-only undo: it reverses every unstaged edit in the affected files, including real logical changes. Rebuild from base and reapply the logical patch, or manually/interactive-patch reverse only the formatter hunks before committing.
- **Project lint can be broader than PR readiness.** Some repos have `make lint` that fails on pre-existing or broad formatting issues even when required CI and reviewer checks are green. Do not push formatting-only churn just to satisfy a local broad lint command during babysitting. Record the lint result, run focused verification on touched files or syntax checks, ensure `git diff --check` passes, and only commit if the fix is directly tied to an actionable CI/review failure.
- **Python environment mismatch in worktrees.** `uv venv` may pick the newest local Python (for example 3.14), causing dependency resolution failures for packages without wheels (`torch`, `onnxruntime`, `chromadb`). If repo docs specify Python 3.11, create the env explicitly: `uv venv --python /usr/local/bin/python3.11` (or the repo-documented interpreter), then `uv pip install -r requirements.txt`.
- **Private clone fallback.** `git clone git@github.com:$REPO.git` can fail with `Permission denied (publickey)` even when `gh` is authenticated. If SSH clone fails, retry with `gh repo clone $REPO $WORKTREE -- --branch $BRANCH` so the GitHub CLI uses its configured auth.
- **Fine-grained PAT 403 on checks endpoints.** If `gh pr checks`, `gh pr view --json statusCheckRollup`, `gh api repos/$REPO/commits/$SHA/check-runs`, and `gh api repos/$REPO/commits/$SHA/status` all return 403, the token lacks `checks:read`. Reliable fallbacks: `gh run list --repo $REPO --branch "$BRANCH" --limit 5 --json name,status,conclusion`, or the Actions runs API keyed by head SHA (`gh api "repos/$REPO/actions/runs?head_sha=$HEAD&per_page=50"`). Do not switch GitHub accounts or declare CI broken.
- **`gh pr checks --json` fields vary by installed `gh` version.** Some versions do not expose `conclusion` for `gh pr checks --json`; valid fields may be only `bucket`, `state`, `name`, `link`, etc. Prefer `bucket` for polling (`pass`, `pending`, `fail`, `skipping`) and treat `skipping` as non-blocking. If `gh pr checks --json ...` returns `[]`, missing fields, or parse errors while the plain table shows checks, do **not** classify that as green. Fall back to `gh pr view --json statusCheckRollup,mergeStateStatus,reviewDecision` and classify from the rollup. Only treat it as "no checks configured" when both `gh pr checks` plainly says no checks and `statusCheckRollup` is empty.
- **Avoid `set -e` swallowing CI polling decisions.** If a Python/JQ classifier exits non-zero to signal "pending," a surrounding `set -e` shell will exit before you can capture `$?`. Either omit `set -e` in polling loops, wrap the classifier in an `if`, or append `|| code=$?` before branching.
- **Keep foreground CI polling under terminal timeout caps.** In some runtimes, foreground terminal calls over 600s are rejected before they run. For PR babysitting, either cap each polling command below 600s (for example 9 one-minute polls) or run longer 20-minute waits as a background command with notifications. If a polling command is rejected for timeout length, retry with a shorter foreground loop instead of changing code. Note the ShellExec tool may cap individual `sleep` durations; use `python3 -c "import time; time.sleep(N)"` with an explicit larger tool timeout when waiting on long CI runs.
- **Use each package's native test command exactly.** Don't add runner-specific flags unless the project already documents them. Example: a Vitest project run via `npm test` does not support Jest's `--runInBand`; a Jest config already setting `--maxWorkers=50%` errors on `--runInBand` (`Both --runInBand and --maxWorkers were specified`). If you accidentally use an unsupported/conflicting flag, rerun the documented command and don't treat the first failure as code-related.
- **Sentry upload flakes in frontend builds.** Frontend builds can succeed but exit non-zero because Sentry release/source-map upload returns a transient 504. If the bundler says `✓ built` and the only failure is `sentry-cli releases new ... gateway timeout`, rerun verification with `SENTRY_ALLOW_FAILURE=true NODE_OPTIONS=--max-old-space-size=4096 bun run build` and report it as a Sentry upload flake, not a code build failure.
- **Local frontend build OOM (SIGABRT).** Vite/Rollup builds can OOM on machines with limited memory, crashing with `SIGABRT` and V8 `AllocateRawWithRetryOrFailSlowPath` stack traces. This is not a code error. Retry with `NODE_OPTIONS=--max-old-space-size=4096 bun run build`. Combine with `SENTRY_ALLOW_FAILURE=true` if Sentry upload isn't needed for local verification.
- **Detached HEAD + remote divergence:** When the worktree is in detached-HEAD state and remote has new commits, `git pull --rebase` won't work directly. Instead: `git fetch origin $BRANCH && git rebase origin/$BRANCH`. This replays your local commit(s) on top of the new remote commits, then `git push origin HEAD:$BRANCH` works cleanly. Don't try `git checkout $BRANCH` — it will fail if another worktree has that branch checked out.
- **npm install artifacts in worktrees:** Running `npm install` or `bun install` in a CLI subdirectory to verify builds generates `node_modules/` and sometimes modifies lockfiles. Always stage only the files you changed (`git add <specific-file>`) rather than `git add -A`, or unstage with `git reset HEAD package-lock.json bun.lockb`.
- **Sub-agents can introduce unintended refactors.** Always diff `$BRANCH` against `origin/$BRANCH` before pushing to confirm only the intended fix is included.
- **A sibling agent may have already pushed YOUR exact fix — blind rebase then DUPLICATES content.** When two agents babysit the same PR concurrently and both decide to make the same small fix (classic: adding the same row to a doc table, the same import, the same guard), the other agent's commit lands on the remote between your local commit and your push. Your push is rejected non-fast-forward; you `git rebase origin/$BRANCH`; the rebase succeeds cleanly because the two commits touch nearby-but-not-identical lines, and now the table has the row TWICE. Protocol: (1) before committing or pushing a fix, fetch and inspect `HEAD..origin/$BRANCH`; if remote already contains the fix, save your dirty diff to a patch, reverse only that duplicate local diff with `git apply -R`, then `git merge --ff-only origin/$BRANCH`. (2) if you already made a local commit and the remote commit contains your fix, `git reset --soft origin/$BRANCH` and drop your now-redundant local commit instead of rebasing. (3) AFTER any rebase that replayed your commit onto sibling commits, verify you didn't double-apply: `grep -c "<the unique token you added>" <file>` must be 1, not 2. Never force-push to erase the sibling's commit.
- **Subagent timeout after push is an incomplete handoff, not a terminal state.** If a child reports or likely pushed a fix but timed out before CI polling or thread resolution, the parent should verify the PR directly, poll CI if feasible, and resolve only the fixed bot thread with the commit SHA. Do this before the final digest so the user gets current state rather than a stale "needs follow-up" caveat.
- **Subagent timeout after local commit but before push is a parent handoff, not a restart.** If a child summary says it created a local commit but hit tool/time limits before pushing, go to the child worktree, verify `git status --short`, `git rev-parse HEAD`, `git diff --stat origin/<branch>..HEAD`, and the tests it claimed. If the diff is exactly the intended fix, push `HEAD:<branch>` yourself, then resolve addressed threads and poll CI. Do not spawn a fresh fixer that redoes the same work unless the local commit is missing or the diff is wrong.
- **Frontend lint may auto-fix unrelated files.** Run lint only on the files you changed, not the whole project.
- **Check ALL three comment sources.** `gh pr view --json reviews` only shows formal review submissions. Automated reviewers often post as issue comments.
- **Outdated bot threads can still show unresolved.** After pushing reviewer fixes, fetch GraphQL review threads again. If unresolved threads are `isOutdated: true` and the latest review/check approves the fix, reply with the fixing commit SHA and resolve them. `reviewDecision: APPROVED` plus unresolved outdated threads means the PR is functionally clean, but leaving threads open creates noise for the user.
- **Addressed threads are not always marked outdated.** A bot thread can remain `isOutdated: false` when the commented line still exists, even though a later commit fixed the requested behavior nearby. Verify against current HEAD, cite the fixing commit in a thread reply, then resolve it if the requested change is demonstrably present. Do not wait for `isOutdated: true` as the only resolution signal.
- **Approval can clear `reviewDecision` instead of setting it to `APPROVED`.** Some repos show `reviewDecision: ""` after a bot approval when branch protection does not require reviews. Treat `mergeStateStatus: CLEAN`, all real checks green, latest review body approved/LGTM, and zero unresolved threads as ready even if `reviewDecision` is blank. Do not downgrade a clean PR just because older `CHANGES_REQUESTED` reviews remain in the review history.
- **No checks configured is green after review sweep.** If `gh pr checks` says no checks reported and `statusCheckRollup` is empty, treat CI as non-blocking once scope is clean, merge state is `CLEAN`, and all review/comment/thread sources are addressed. Do not invent a CI wait for repos without configured checks.
- **`mergeStateStatus: UNKNOWN` can be transient after pushes, thread resolution, or merge.** Poll `gh pr view --json state,mergedAt,mergeCommit,mergeStateStatus,statusCheckRollup,headRefOid` a few times before classifying it as blocked. If the collector says `clean:false` but also reports zero unresolved threads and zero bot comments, re-check live GitHub rather than inventing work: run the final aggregate + comments/reviews/GraphQL-thread sweep, verify latest-head checks/runs, and if live state has settled to `CLEAN` with green/skipped checks and no unresolved threads, report the transient false positive as ready with the current head SHA. If the PR becomes `state: MERGED` while polling, stop immediately and report the PR head SHA plus `mergeCommit.oid`/`mergedAt`; GitHub commonly reports `mergeable: UNKNOWN` after merge, which is not a blocker. After merge, the source branch may be deleted and any existing worktree may be stale; do not treat `git fetch origin $BRANCH` failing as a PR problem.
- **Aggregate `CHANGES_REQUESTED` can persist after thread cleanup.** If you resolve all actionable threads and final verification shows CI green, `mergeStateStatus: CLEAN`, and zero unresolved threads, but `reviewDecision` still says `CHANGES_REQUESTED`, the PR is functionally ready but the stale blocking review is gating merge. Bot reviewers often submit several `CHANGES_REQUESTED` reviews across cycles and never auto-dismiss them when their later review is `COMMENTED`/approving. **Dismiss the stale blocking reviews so the decision clears.** First confirm each blocking review's concerns are demonstrably fixed (read the review body, verify against current HEAD, check the bot's own latest review confirms resolution). Then dismiss every stale `CHANGES_REQUESTED` review from that reviewer:
  ```bash
  # List stale blocking reviews from a bot reviewer
  gh api "repos/$REPO/pulls/$PR/reviews?per_page=100" \
    --jq '.[] | select(.user.login=="claude[bot]" and .state=="CHANGES_REQUESTED") | .id'

  # Dismiss each one with a note citing the fix commits
  for RID in <ids>; do
    gh api -X PUT "repos/$REPO/pulls/$PR/reviews/$RID/dismissals" \
      -f message="Resolved in later commits (<shas>). Reviewer's latest review confirms all items addressed; CI green." \
      --jq '.state'
  done

  # Verify the decision cleared
  gh pr view $PR --repo $REPO --json reviewDecision,mergeable,mergeStateStatus
  ```
  Only dismiss reviews where the concerns are genuinely resolved. Never dismiss a human reviewer's `CHANGES_REQUESTED` or any unaddressed concern; for those, report that the PR needs the reviewer to re-review. Dismissing requires push/admin access to the repo; if the API returns 403, fall back to reporting it as needing reviewer re-review/dismissal.
- **Resolving many threads adds lots of skipped bot checks.** Replying/resolving review threads can create one skipped `claude` check per thread. Treat skipped checks as non-blocking noise. Do not restart the babysitting loop unless a real reviewer job is pending, a non-skipped check fails, or a new substantive comment appears.
- **Resolving threads can trigger fresh reviewer runs and base updates.** After resolving outdated threads, poll checks again and re-read the latest review decision. The PR head may advance because an auto-merge/update branch job merged the base branch while you were resolving comments. Fetch remote, compare HEAD to `origin/$BRANCH`, inspect any new merge commit for scope, then wait for the new CI/reviewer run before reporting ready.
- **Terminal wrappers may misclassify `gh api graphql` mutations as long-lived processes.** If a concise `gh api graphql` command for `addPullRequestReviewThreadReply`/`resolveReviewThread` is blocked by the foreground-process heuristic, use a small Python `urllib.request` GraphQL helper instead. Read the token from `gh auth token` at runtime inside the script or from a short-lived temp file, never paste tokens into logs or skill text.
- **Self-resolution inline comments are not actionable.** When filtering a `COMMENTED` webhook with empty body, the skill correctly checks for inline comments before skipping. But if all inline comments from the reviewer follow the self-resolution pattern (`"Resolved -- fixed in <sha>: ..."`) rather than requesting new changes, treat the review as non-actionable. Read the comment bodies before classifying them as action items.
- **Do not resolve intent, follow-up, or praise-only comments just because CI is green.** Bot reviewers often approve while leaving non-blocking notes like "confirm this behavior is intentional" or "pre-existing inconsistency worth a follow-up." Human reviewers may also leave approval/praise inline, which can remain as an unresolved outdated thread after later commits. Treat these as non-blocking, mention only if useful in the final evidence, and leave the thread unresolved unless you actually fixed it or have explicit user intent. Resolve only the specific addressed bug threads, with the fixing commit SHA.
- **Self-authored PRs can be collector false positives.** Some repos show `reviewDecision: ""`/`none` for PRs authored by the same GitHub account used by the babysitter, even when all checks are green, `mergeStateStatus: CLEAN`, and there are no unresolved actionable threads. Do not fabricate work just to satisfy the collector. Verify with `gh pr view --json author,reviewDecision,mergeStateStatus,statusCheckRollup,headRefOid` plus the thread sweep, and read the latest substantive review/issue comment. If the only issue is blank reviewDecision on a self-authored clean PR, report it as a collector/self-review false positive, not blocked.
- **Large PR diffs can exceed GitHub's diff file cap.** `gh pr diff --name-only` may fail with HTTP 406 / `PullRequest.diff too_large` once the PR exceeds GitHub's diff file limit (often ~300 files). This is not a PR failure. Fall back to the Pull Request Files API: `gh api --paginate "repos/$REPO/pulls/$PR/files?per_page=100" --jq '.[].filename'`. Use that for scope counts, then use local `git diff --stat origin/<base>...HEAD` / `git diff --check origin/<base>...HEAD` for final verification.
- **Push immediately after a verified commit, before optional cleanup.** Once a local fix commit has passing focused tests/lint, push it to the PR branch before spending tool budget on broad polling, extra review sweeps, or thread cleanup. If the runtime hits a tool-call/session limit after a local commit but before `git push`, the PR remains unchanged and the babysit run is incomplete. After the push, prioritize resolving the specific addressed bot threads, then do CI/review polling.
- **If tool budget expires after push, hand off honestly.** When you hit the call/iteration ceiling after a verified push but before GraphQL thread cleanup or CI polling, do not imply the PR is ready or that threads were resolved. Final-report the pushed SHA, verification commands/results, live PR state if checked, and exact unresolved thread IDs/bodies still needing cleanup. This makes the next babysitter continue from the pushed fix instead of redoing work.
- **Review verdict history can look contradictory.** GitHub keeps older `CHANGES_REQUESTED` reviews in the API even after a later approval. Trust `gh pr view --json reviewDecision,mergeStateStatus,statusCheckRollup` for current block status, then read latest reviews/comments to confirm no new actionable issues.
- **PR-level approval does not override a specific actionable comment.** Webhook/invocation payloads may cite a `COMMENTED` review while the PR's aggregate `reviewDecision` is already `APPROVED` because another reviewer approved. Apply filtering rules to the triggering review's state/body, not only to `reviewDecision`. If the triggering review has a substantive body or inline thread, read and triage it even when the aggregate PR status says approved.
- **Merged PR branch reuse.** If a branch was already merged and later gets more commits, `git push origin HEAD` updates the branch but not the old merged PR. Always check `gh pr view --json state,headRefOid` after pushing. If the intended PR is `MERGED`, create a new PR from the same branch for the new commits.
- **Squash-merge between turns breaks follow-up pushes onto the same branch.** Iterative UI/tweak sessions are the classic trap: you push tweak #1, open PR, it gets squash-merged into main while you keep working; you then commit tweak #2 on the SAME local branch and `git push` "succeeds" (`* [new branch] HEAD -> branch`) but the merged PR does not update and your commit is invisible. Tell: after the push, `gh pr view <PR> --json state,headRefOid` shows `MERGED` with `headRefOid` NOT equal to your new local HEAD, and `git diff --stat origin/main` shows a huge unrelated diff. Recovery: do NOT force-push or reopen the merged PR. `git fetch origin main`, add a fresh worktree off `origin/main`, `git cherry-pick <your-new-commit>` onto it, verify the clean single-commit `git diff --stat origin/main`, push the new branch, open a new follow-up PR. State plainly that the prior PR already merged so this is a separate PR.
- **Making a stacked PR independent.** If the user asks to make a PR independent or mergeable into main/master, change the base with `gh pr edit <PR> --base <default-branch>` and update the PR body so it no longer says it is stacked. Then check `mergeStateStatus`. If it is `DIRTY`, merge the default branch into the PR branch (do not rebase or force-push), resolve conflicts, commit the merge, push, and wait for fresh CI plus reviewer re-runs.
- **Public checkout/link tokens are not always secrets.** Static payment pages may intentionally embed public checkout URLs or link tokens (for example RevenueCat Web Purchase Links). If a reviewer flags one as a hardcoded secret, verify whether it is a public link token versus a private API key. If public and production, add a concise code comment documenting that fact; do not invent env-var plumbing for a static page unless the repo already has a build system.
- **`gh pr create` has no `--json` flag in some installed versions.** Create the PR with plain `gh pr create ... --body-file /tmp/pr-body.md`, then run `gh pr view <number> --json ...` after creation if structured output is needed.
- **Scope check is not optional.** Even if the caller says "just fix CI," run the scope check. Catching drift early prevents wasted cycles fixing code that shouldn't be in the PR.

## Do NOT

- Post top-level PR comments (triggers claude-review re-runs, wastes tokens). Replying to existing review threads in step 2b is fine — those don't trigger CI.
- Merge the PR (the repo owner merges)
- Force push or rewrite history
- Make changes unrelated to the PR's purpose
- Fix more than one issue per commit
- Retry the same fix approach twice
- Auto-fix scope drift (always escalate it)
