---
name: babysit-pr
preloaded: true
description: "Monitor a PR until it's ready to merge. Watches CI, reads reviews, checks scope, fixes issues, and repeats. Use when: babysit this PR, watch this PR, monitor PR, fix and watch PR, keep this PR green."
---

# Babysit PR

Monitor a single PR through its full lifecycle: check scope, wait for CI, read reviews, fix issues, push, repeat. Stop when the PR is clean (CI green, no unaddressed comments, scope is tight) or when you hit a wall that needs human input.

## Inputs

- **PR number** (required)
- **Repo** (optional, defaults to current repo via `gh repo view --json nameWithOwner -q '.nameWithOwner'`)
- **Parent session key** (optional, for sending progress updates to the parent agent via `send_to_task`)
- **Max cycles** (optional, default 10. Each cycle = one CI wait + fix attempt)

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
BRANCH=$(gh pr view $PR --repo $REPO --json headRefName -q '.headRefName')
WORKTREE="$HOME/projects/_worktrees/$BRANCH"
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
gh pr diff $PR --repo $REPO --name-only

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

**Resolve handled comments:** After triaging, resolve any review threads that are outdated or already addressed. See step 2b.

**Before declaring ready, run the automated review final sweep.** If CI is green but GitHub still shows `CHANGES_REQUESTED`, `BLOCKED`, a latest top-level bot comment with `Must Fix` items, or unresolved non-outdated GraphQL threads, keep working. Load `references/automated-review-final-sweep.md` for exact commands and decision rules.

**If CI green + no actionable unaddressed findings + no unresolved non-outdated actionable threads → PR is ready. Report success and stop.**

**If there are actionable findings → go to step 3.**

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
3. **Not applicable:** The comment was informational, a question that's been answered, or a suggestion that was intentionally declined.
4. **Still open:** The issue persists in the current code. Leave unresolved and either auto-fix (step 3) or escalate.

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
- Keep replies concise. One sentence with the commit SHA or evidence.

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

1. Pull latest and check if already fixed: `cd "$WORKTREE" && git fetch origin $BRANCH && git log --oneline origin/$BRANCH -5`. If remote is ahead of your local HEAD, inspect the new commits — someone (or a prior agent run) may have already fixed the issue. Verify by reading the flagged file at `origin/$BRANCH`. If already fixed, skip to step 5.
1b. Rebase onto remote: `git pull --rebase origin $BRANCH` (or merge if rebase isn't clean)
2. Read the relevant files in full (not just the diff)
3. Make the minimal, targeted fix
4. Verify locally using whatever lint/test commands the project's CLAUDE.md or AGENTS.md specifies. Run the specific failing test if identifiable.
5. Stage carefully: `cd "$WORKTREE" && git add -A && git diff --cached --stat` — review the staged file list. Setup commands (`make setup-worktree`, `uv sync`, `bun install`) can generate untracked files (e.g. `config/mcporter.json`, `.env`, `node_modules/` artifacts) that `git add -A` will pick up. Unstage anything not part of your fix: `git reset HEAD <file>`.
6. Single commit: `cd "$WORKTREE" && git commit -m "fix: <description>"`
7. Push: `cd "$WORKTREE" && git push origin HEAD:$BRANCH`

**One commit per cycle.** Don't stack multiple speculative fixes.

### 5. Loop or Stop

After pushing (or deciding not to):

**Continue looping if:**
- You just pushed a fix (need to wait for new CI run and any reviewer re-run)
- A reviewer bot is still running, even if prior CI/checks were green
- A fresh reviewer run surfaced new actionable findings after earlier fixes. Treat that as the next cycle, not as churn to ignore
- There are still issues you plan to address next cycle

**Stop and report if:**
- PR is clean (latest CI green, latest reviewer run completed, no unaddressed comments, scope is tight)
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

**Signal/chat discipline:**
- Do not stream raw scratchpad, grep results, or "let me check" narration into Signal/Slack. Users read those as confusing status leaks.
- Send only milestone updates: scope result, fix pushed, CI status, blocker, ready. If you need to think aloud, keep it internal and finish the tool cycle before messaging.

**Format:**

```
🔧 PR #{number} ({repo}) — Cycle {N}/{max}

Scope: ✅ clean | ⚠️ minor (details) | 🚫 major (details)
Fixed: <what you fixed>
Resolved: <N threads resolved with reasons>
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

## Multi-PR Babysitting

When asked to babysit multiple PRs interactively, **do the work directly in the parent agent** rather than spawning sub-agents. Sub-agent delegation for babysit-pr has a high failure rate (toolset mismatches, context loss, wasted tokens). Even with correct toolsets, sub-agents often fail on the skill-loading chain. Work through PRs sequentially:

1. Check CI + reviews on all PRs first (quick `gh pr checks` loop + mergeable status)
2. Triage: which need fixes vs. which are clean vs. which are already merged
3. Fix each PR in order, push, move to next
4. Circle back if any need a second cycle after CI re-runs

This is faster and more reliable than parallel sub-agents for 2-5 PRs.

**Shared-failure shortcut:** Before diving into per-PR fixes, check if all PRs share the same CI failure (e.g., rate-limited reviewer bot, expired token, infra flake). If so, diagnose once, report the common cause, and skip redundant per-PR analysis. Common patterns: Claude Code Review rate limits ("You've hit your limit"), GitHub App auth failures, shared secret expiry.

For scheduled "babysit all open PRs" cron jobs, load `references/daily-open-pr-babysitter.md`. If the prompt explicitly asks for parallel delegation, batch according to the runtime's real concurrency cap, then run a parent-agent verification sweep before the digest. Child summaries are not enough: subagents often time out after pushing useful fixes or leave resolvable bot threads open.

## Quick Fix Mode (no full babysit loop)

When the user says "fix comments on PR X" or "fix merge conflicts on PR X", skip the full babysit loop. Just:

1. Read the latest review comments/threads
2. Check if issues are already fixed in current code (grep the worktree, don't assume)
3. Fix what's actionable, commit, push
4. Resolve addressed threads in bulk
5. Report what was fixed and what needs attention

This is the common case: user already knows what's wrong, just wants it done.

## Gotchas

See also:
- `references/delegation-and-git-pitfalls.md` — force-push recovery, batch thread resolution, toolset names
- `references/public-repo-redaction.md` — stripping hardcoded values from public repos and adding env vars
- `references/branch-preservation-and-ci-auth.md` — preserving dirty branches via commit+patch pattern, CI 401 auth retry protocol, public repo redaction checklist
- `references/automated-review-final-sweep.md` — final reconciliation of CI, formal reviews, issue comments, and unresolved GraphQL threads before calling a PR clean
- `references/investing-log-validation-prs.md` — Bloom-Invest/investing-log validation-failure issue triage, sector snapshot gates, and local pytest environment quirks

- **Python mock failures in xdist.** String-based `patch("pkg.submod.func")` can silently fail in pytest-xdist workers if the submodule isn't explicitly imported. Use `patch.object(imported_mod, "func")` instead. Also patch the import site that the view/code under test actually calls, not the original service module, when functions are imported with `from service import func`; otherwise xdist/order-dependent tests can leak stubs or miss the patch. See `references/delegation-and-git-pitfalls.md` for the full diagnosis checklist.
- **caplog can be flaky under full-suite xdist.** If CI fails with `caplog.text == ""` even though a focused local test passes, don't keep tweaking logger levels. Two proven alternatives:
  1. **Mock the logger methods** when the test promises specific log content: `mock_warning = Mock(); monkeypatch.setattr(module.logger, "warning", mock_warning)`, then assert `any("expected substring" in str(call) for call in mock_warning.call_args_list)`.
  2. **Side-effect list** when the test only needs to confirm the graceful-skip path ran (not the exact message): `close_calls = []; monkeypatch.setattr(module, "close_old_connections", lambda: close_calls.append("closed"))`, then assert `close_calls`.
  Choose (1) for tests named `*_treats_X_as_Y` or `*_downgrades_X`; choose (2) for simpler "did it skip or raise" assertions. Use a mixed/uppercase fixture message when the fix is case-insensitive string matching, so the regression test actually proves `.lower()` is used.
- **MagicMock + `hasattr` can create fake attributes.** In tests that use `MagicMock` as a stand-in object, `hasattr(mock, "_exception")` may return true because `MagicMock.__getattr__` creates a child mock. This can turn a thread-exception mock into `raise <MagicMock>`, producing `TypeError: exceptions must derive from BaseException` in CI. Check `"_exception" in mock.__dict__` or initialize the attribute explicitly instead.
- **Thread exception propagation for Huey tasks.** If reviewer feedback asks for exceptions from child threads to trigger Huey retries, don't re-raise inside the child thread. Capture the exception in a nonlocal/container, let the child thread return cleanly to avoid `threading.excepthook`/Sentry noise, then after `join()` re-raise on the main Huey task thread. Add focused tests that assert both the pool-exhaustion path re-raises to Huey and the thread mock doesn't synthesize fake exceptions.
- **Delegation toolsets.** When delegating to a sub-agent, you MUST pass `toolsets=["terminal", "file", "web", "memory", "skills"]`. The toolset name is `"terminal"`, NOT `"ShellExec"` or `"mcp_terminal"`. Without it the sub-agent has no shell and fails immediately.
- **Force-push is blocked.** The git wrapper blocks all force pushes. Never amend commits; make a new fixup commit on top instead. See references for the recovery pattern if you already diverged.
- **Batch thread resolution.** When resolving 5+ threads, loop in a single shell command (array of "ID:message" pairs) rather than one tool call per thread. See references for the pattern.
- **Supply chain scanner false positives.** The "Scan PR for critical supply chain risks" CI check sometimes flags files (e.g. `setup.py`) that exist on the base branch and are NOT in the PR's diff. Verify with `gh pr diff $PR --repo $REPO --name-only | grep <flagged-file>`. If the file isn't in the diff, report as false positive and don't attempt to fix. This CI failure alone does not block "ready to merge" status.
- **Read CLAUDE.md/AGENTS.md first.** Every repo has different lint, test, and build commands. Never assume.
- **Stale review comments:** `original_commit_id` on inline comments refers to the commit when the comment was made. If HEAD has moved past it, the issue may already be fixed.
- **Reviewer re-runs can reveal new redaction issues after every push.** Claude-review and similar bots often approve one pass, then flag newly noticed public-repo leaks in the next run. Do not report "ready" while a reviewer run is still in progress, and do not rely on an older approval after pushing another fix. Wait for the latest run for the current HEAD, then read its issue comment, review body, and inline threads.
- **GitHub Actions GITHUB_TOKEN suppression:** Pushes from inside a GitHub Actions job using the default `GITHUB_TOKEN` don't trigger other workflow runs. This does NOT apply to local `gh` CLI pushes.
- **Worktree branch conflicts:** `git worktree add` fails if the branch is already checked out somewhere. The Setup uses `origin/$BRANCH` to avoid this. However, if an existing worktree for the same branch already exists (e.g. at `~/projects/_worktrees/$BRANCH`), **just use it** — fetch + pull there instead of creating a second worktree. Check with `git -C "$LOCAL_DIR" worktree list | grep "$BRANCH"`.
- **Broken worktree gitdir link.** A worktree's `.git` file is a pointer (`gitdir: /path/to/parent/.git/worktrees/name`). If the parent repo directory was renamed, moved, or its `.git/worktrees/` metadata was cleaned, the worktree becomes unusable (`fatal: not a git repository`). Recovery: `trash` the broken worktree directory and `gh repo clone $REPO $WORKTREE -- --branch $BRANCH` to get a fresh standalone clone at that path. This is faster than trying to repair the gitdir link.
- **Reviewer flag suggestions can be backwards.** When a reviewer says "flag X should be Y to match existing usage," verify against the actual CLI/library source code before applying. The reviewer may have the direction of the fix inverted (e.g., the existing usage is wrong and the new code is correct). Always `grep` the source for the definitive flag name before changing anything.
- **Existing worktree path may belong to another clone.** Repo discovery can pick `~/repo` while the existing shared worktree was created from `~/projects/repo`, so `git -C "$LOCAL_DIR" worktree list` will not show it even though `~/projects/_worktrees/$BRANCH` is a valid git worktree. Before `git worktree add`, test `[ -d "$WORKTREE/.git" ] || git -C "$WORKTREE" rev-parse --is-inside-work-tree`. If it is a repo, `cd "$WORKTREE"`, `git fetch origin "$BRANCH"`, compare `HEAD` to `origin/$BRANCH`, and rebase or fast-forward as needed. Do not trash or overwrite the directory.
- **Prior agent's partial fix:** When a fix commit already exists for a review, don't assume it addressed ALL items. Read the review body line-by-line and verify each requested change is present in the current code. Prior agents frequently fix 3 of 4 items and miss one.
- **Remote may already have bot fixes.** Before coding review fixes, run `git fetch origin $BRANCH` and inspect `origin/$BRANCH` commits. Automated reviewers/agents may have pushed contract decisions already (for example frontend changed to `watch.alerts` while backend kept `{alerts, drift_available, drift_note}`). Rebase onto remote before committing unless you intentionally need to supersede it. Don't "fix" one side of an API by changing the backend contract if remote/frontend/CLI already converged on the other shape.
- **Reviewer bots can push after you push.** After your fix push, CI/reviewer bots may push their own follow-up commit while checks are still running. Before final verification, always `git fetch origin $BRANCH`, compare `git rev-parse HEAD` to `git rev-parse origin/$BRANCH`, and rebase if remote moved. Inspect any bot-added commit for scope, verify its files, and include it in the final report. Never report your local HEAD as ready if the PR head has advanced remotely.
- **Review-body-only feedback (no inline threads):** Some reviewers (especially claude[bot] and gemini-code-assist[bot]) put all feedback in the review body rather than inline threads. The GraphQL `reviewThreads` query will return empty. You still need to parse the review body text, identify each requested change, and verify/fix them. These won't have thread IDs to resolve — the review state updates when the reviewer re-reviews or the PR author dismisses.
- **"Changes requested" but already fixed:** claude[bot] sometimes submits `CHANGES_REQUESTED` reviews where the body documents bugs that were already fixed in a later commit within the same PR (e.g. "Bug fixed: X (commit abc123)"). The review state looks blocking but there's nothing to fix. Read the review body carefully before assuming work is needed. If every issue listed says "fixed in <sha>" and concludes "no other issues found," the only action is to wait for CI and let the reviewer re-approve on the next push. Don't skip CI checks though; formatting or test failures may still exist independent of the review.
- **Formatter CI failures in worktrees:** When CI fails on prettier/eslint formatting, you need `bun install` (or `npm install`) in the frontend directory before running the formatter. Use `--frozen-lockfile` to avoid modifying lockfiles. Then run the formatter on only the flagged file(s), not the whole project. Verify the diff is pure whitespace/formatting before committing.
- **Backend black in Bloom worktrees:** `uv run ...` may create a local `.venv/` inside the worktree. If you mirror CI locally, include CI's exclude (`uv run black . --check --extend-exclude '\.venv|\.git|frontend'`) or target only changed files. Plain `black . --check` can scan `.venv/site-packages`, produce huge misleading output, and waste minutes without indicating a PR problem. For Bloom backend verification, prefer `uv run --all-extras --python 3.13 ...`; without `--all-extras`, imports can fail on optional packages like `currency_symbols`/`sqlparse`. If `uv` switched interpreters and left a broken `.venv`, use `trash .venv` and recreate it with the exact command. When Black warns that Python 3.13 cannot parse code formatted for Python 3.14, run Black with `--target-version py313` rather than switching to Python 3.14, because Bloom deps such as `psycopg-binary` may not have 3.14 wheels. Local full-suite pytest on macOS/Python 3.13 can diverge from CI's Linux/Python 3.11 plugin set (for example async tests failing because `pytest-asyncio` is unavailable locally); trust focused local tests plus CI logs over unrelated local environment failures.
- **Merge state can be dirty even after all checks pass.** If `gh pr view --json mergeStateStatus` shows `DIRTY` while CI/reviews are clean, fetch the base branch and merge it into the PR branch with a normal merge commit, then push and wait for a fresh CI/reviewer run. Before pushing, inspect `git diff origin/$BRANCH..HEAD --stat` so the merge only brings expected base-branch changes plus conflict resolutions. Do not report ready until `mergeStateStatus: CLEAN` on the latest remote head.
- **Skill-repo merge conflict resolution.** For broad `exiao/skills` snapshot PRs, resolve conflicts by preserving public-repo cleanup from `main` unless the PR intentionally improves it: keep two-field skill frontmatter (`name`, `description` only), prefer generic placeholders/examples from `main` over self-referential env values, and avoid resurrecting deleted private/generated files. For modify/delete conflicts where the PR deleted a skill but `main` has since reintroduced a cleaned canonical version (for example root-level `video-production/clipify`, `creative/design-md`, `yuanbao`), keep the `main` version rather than preserving the deletion, then make sure README points at the actual path.
- **Skills repo count-review false positives.** Reviewers may compare README table counts to visible table rows instead of actual `SKILL.md` files, especially after internal/private skill removals. Before changing counts, verify with `python - <<'PY'` / `Path(category).glob('**/SKILL.md')` or `find <category> -name SKILL.md | wc -l`. If disk count matches README and the reviewer is counting rows, leave the count intact, reply with the verified count, and resolve the thread as a false positive.
- **Conflict-marker scans need false-positive filtering.** After resolving conflicts, run an exact marker scan for `<<<<<<< ` / `>>>>>>> ` across text files, but ignore known intentional documentation snippets and binary/font files. `ripgrep` for `=======` alone is too noisy because many files use separator comments.
- **`UNSTABLE` is not necessarily still conflicted.** After pushing a merge-conflict fix, `mergeable: MERGEABLE` with `mergeStateStatus: UNSTABLE` usually means required checks are pending. Verify `mergeable`, `statusCheckRollup`, and `gh pr checks` before claiming conflicts remain.
- **Transient/stale check state after pushes:** `gh pr checks` can briefly show a failed check while the workflow/run is still settling or a rerun of the same job is in progress. Before coding a second fix, inspect the latest run/job logs (`gh run view ... --log`) and the PR rollup (`gh pr view --json statusCheckRollup`). If logs say the job actually passed, continue polling rather than changing code.
- **Claude-review infrastructure failures are blockers, not code issues.** `claude-review` can fail for auth reasons (`GitHub App authentication failed`, OIDC 401s), usage caps (`You've hit your org's monthly usage limit`), or generic crashes (`Claude encountered an error` with no review output). In all cases: confirm no actionable code feedback was posted, rerun the failed job once (`gh run rerun <id> --repo $REPO --failed`), and if it fails again, stop as blocked. `mergeStateStatus` will show `UNSTABLE` from the failing required check. See `references/claude-review-infra-failures.md` for diagnosis commands and known failure patterns (5 documented patterns including stuck "working" comments). **Watch for status disagreement:** the job API can show `in_progress` while an issue comment already says "Claude encountered an error" or is stuck at "Claude Code is working…" with the job already concluded as `failure`. Before polling for 10+ minutes, check issue comments (`gh api repos/$REPO/issues/$PR/comments --jq '.[] | select(.user.login == "claude[bot]") | .body'`) for error announcements or stale "working" status. If the bot posted an error OR the comment says "working" but the job is done, treat the check as failed immediately rather than waiting for the job status to catch up.
- **Avoid formatter-driven scope creep in review fixes.** If a repo has broad pre-existing lint/format violations, running `black`, `prettier`, or `eslint --fix` on entire files can create noisy diffs unrelated to the reviewer comment. Prefer syntax checks (`python -m py_compile`, `git diff --check`) and narrow behavioral probes first. If you accidentally reformat unrelated code, reverse only your working-tree diff with a patch (`git diff | git apply -R`) instead of banned restore/reset commands, then reapply only the minimal logical patch before committing.
- **Project lint can be broader than PR readiness.** Some repos have `make lint` that fails on pre-existing or broad formatting issues even when required CI and reviewer checks are green. Do not push formatting-only churn just to satisfy a local broad lint command during babysitting. Record the lint result, run focused verification on touched files or syntax checks, ensure `git diff --check` passes, and only commit if the fix is directly tied to an actionable CI/review failure.
- **Python environment mismatch in worktrees.** `uv venv` may pick the newest local Python (for example 3.14), causing dependency resolution failures for packages without wheels (`torch`, `onnxruntime`, `chromadb`). If repo docs specify Python 3.11, create the env explicitly: `uv venv --python /usr/local/bin/python3.11` (or the repo-documented interpreter), then `uv pip install -r requirements.txt`.
- **Hermes-agent shared venv can run pytest even when `scripts/run_tests.sh` fails.** In `exiao/hermes-agent` worktrees, `scripts/run_tests.sh` may try to install `pytest-split` into `$HOME/.hermes/hermes-agent/venv` and fail because that shared venv has no `pip` (`No module named pip`). For focused verification, rerun the exact test nodes directly with `$HOME/.hermes/hermes-agent/venv/bin/python -m pytest ...`; do not treat the harness install failure as a code failure if direct pytest passes.
- **Private clone fallback.** `git clone git@github.com:$REPO.git` can fail with `Permission denied (publickey)` even when `gh` is authenticated. If SSH clone fails, retry with `gh repo clone $REPO $WORKTREE -- --branch $BRANCH` so the GitHub CLI uses its configured auth.
- **Fine-grained PAT 403 on checks endpoints.** If `gh pr checks`, `gh pr view --json statusCheckRollup`, `gh api repos/$REPO/commits/$SHA/check-runs`, and `gh api repos/$REPO/commits/$SHA/status` all return 403, the PAT lacks `checks:read`. The ONLY reliable fallback is `gh run list --repo $REPO --branch "$BRANCH" --limit 5 --json name,status,conclusion`. See `references/alternate-github-accounts.md`.
- **`gh pr checks --json` fields vary by installed `gh` version.** Some versions do not expose `conclusion` for `gh pr checks --json`; valid fields may be only `bucket`, `state`, `name`, `link`, etc. Prefer `bucket` for polling (`pass`, `pending`, `fail`, `skipping`) and treat `skipping` as non-blocking. If `gh pr checks --json ...` returns `[]`, missing fields, or parse errors while the plain table shows checks, do **not** classify that as green. Immediately fall back to `gh pr view --json statusCheckRollup,mergeStateStatus,reviewDecision` and classify from the rollup. Empty JSON means the CLI field request failed or this gh build cannot expose those fields; only treat it as “no checks configured” when both `gh pr checks` plainly says no checks and `statusCheckRollup` is empty.
- **Avoid `set -e` swallowing CI polling decisions.** If a Python/JQ classifier exits non-zero to signal “pending,” a surrounding `set -e` shell will exit before you can capture `$?`. Either omit `set -e` in polling loops, wrap the classifier in an `if`, or append `|| code=$?` before branching.
- **Keep foreground CI polling under terminal timeout caps.** In this runtime, foreground terminal calls over 600s are rejected before they run. For PR babysitting, either cap each polling command below 600s (for example 9 one-minute polls) or run longer 20-minute waits as a background command with notifications. If a polling command is rejected for timeout length, retry with a shorter foreground loop instead of changing code.
- **Verify shell snippets against comments/templates, not just happy-path entries.** For documentation-only fixes that show extraction commands, test the default/template file too. Example: `watchlist.md` had ticker-looking examples inside an HTML comment; matching only `^[A-Z]{1,5} —` still extracted `SWBI` and `ANF`. The verified fix used an `awk` state machine to skip `<!-- ... -->` blocks and require the `SYMBOL — reason` format.
- **Use each package's native test command exactly.** Don't add runner-specific flags unless the project already documents them. Example: Bloom CLI uses Vitest via `npm test`; `npm test -- --runInBand` fails because Vitest doesn't support Jest's `--runInBand`. If you accidentally use an unsupported flag, rerun the documented command and don't treat the first failure as code-related.
- **Sentry upload flakes in frontend builds.** Bloom frontend builds can succeed but exit non-zero because Sentry release/source-map upload returns a transient 504. If Vite says `✓ built` and the only failure is `sentry-cli releases new ... gateway timeout`, rerun verification with `SENTRY_ALLOW_FAILURE=true NODE_OPTIONS=--max-old-space-size=4096 bun run build` and report it as a Sentry upload flake, not a code build failure.
- **Local frontend build OOM (SIGABRT).** Vite/Rollup builds in Bloom worktrees can OOM on machines with limited memory, crashing with `SIGABRT` and V8 `AllocateRawWithRetryOrFailSlowPath` stack traces. This is not a code error. Retry with `NODE_OPTIONS=--max-old-space-size=4096 bun run build`. Combine with `SENTRY_ALLOW_FAILURE=true` if Sentry upload isn't needed for local verification.
- **Detached HEAD + remote divergence:** When the worktree is in detached-HEAD state and remote has new commits, `git pull --rebase` won't work directly. Instead: `git fetch origin $BRANCH && git rebase origin/$BRANCH`. This replays your local commit(s) on top of the new remote commits, then `git push origin HEAD:$BRANCH` works cleanly. Don't try `git checkout $BRANCH` — it will fail if another worktree has that branch checked out.
- **npm install artifacts in worktrees:** Running `npm install` or `bun install` in a CLI subdirectory to verify builds generates `node_modules/` and sometimes modifies lockfiles. Always stage only the files you changed (`git add <specific-file>`) rather than `git add -A`, or unstage with `git reset HEAD package-lock.json bun.lockb`.
- **Sub-agents can introduce unintended refactors.** Always diff `$BRANCH` against `origin/$BRANCH` before pushing to confirm only the intended fix is included.
- **Subagent timeout after push is an incomplete handoff, not a terminal state.** If a child reports or likely pushed a fix but timed out before CI polling or thread resolution, the parent should verify the PR directly, poll CI if feasible, and resolve only the fixed bot thread with the commit SHA. Do this before the final digest so the user gets current state rather than a stale "needs follow-up" caveat.
- **Frontend lint may auto-fix unrelated files.** Run lint only on the files you changed, not the whole project.
- **Check ALL three comment sources.** `gh pr view --json reviews` only shows formal review submissions. Automated reviewers often post as issue comments.
- **Outdated bot threads can still show unresolved.** After pushing reviewer fixes, fetch GraphQL review threads again. If unresolved threads are `isOutdated: true` and the latest review/check approves the fix, reply with the fixing commit SHA and resolve them. `reviewDecision: APPROVED` plus unresolved outdated threads means the PR is functionally clean, but leaving threads open creates noise for the user.
- **Addressed threads are not always marked outdated.** A bot thread can remain `isOutdated: false` when the commented line still exists, even though a later commit fixed the requested behavior nearby. Verify against current HEAD, cite the fixing commit in a thread reply, then resolve it if the requested change is demonstrably present. Do not wait for `isOutdated: true` as the only resolution signal.
- **Approval can clear `reviewDecision` instead of setting it to `APPROVED`.** Some repos show `reviewDecision: ""` after a bot approval when branch protection does not require reviews. Treat `mergeStateStatus: CLEAN`, all real checks green, latest review body approved/LGTM, and zero unresolved threads as ready even if `reviewDecision` is blank. Do not downgrade a clean PR just because older `CHANGES_REQUESTED` reviews remain in the review history.
- **No checks configured is green after review sweep.** If `gh pr checks` says no checks reported and `statusCheckRollup` is empty, treat CI as non-blocking once scope is clean, merge state is `CLEAN`, and all review/comment/thread sources are addressed. Do not invent a CI wait for repos without configured checks.
- **`mergeStateStatus: UNKNOWN` can be transient after pushes or thread resolution.** Poll `gh pr view --json mergeStateStatus,statusCheckRollup,headRefOid` a few times before classifying it as blocked. If it settles to `CLEAN`, checks are empty/green/skipped, and unresolved threads are zero, report ready.
- **Aggregate `CHANGES_REQUESTED` can persist after thread cleanup.** If you resolve all actionable threads and final verification shows CI green, `mergeStateStatus: CLEAN`, and zero unresolved threads, but `reviewDecision` still says `CHANGES_REQUESTED`, the PR is functionally ready but the stale blocking review is gating merge. Bot reviewers (claude[bot], gemini-code-assist[bot]) often submit several `CHANGES_REQUESTED` reviews across cycles and never auto-dismiss them when their later review is `COMMENTED`/approving. **Dismiss the stale blocking reviews so the decision clears.** First confirm each blocking review's concerns are demonstrably fixed (read the review body, verify against current HEAD, check the bot's own latest review confirms resolution). Then dismiss every stale `CHANGES_REQUESTED` review from that reviewer:
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
- **Terminal wrappers may misclassify `gh api graphql` mutations as long-lived processes.** If a concise `gh api graphql` command for `addPullRequestReviewThreadReply`/`resolveReviewThread` is blocked by the foreground-process heuristic, use a small Python `urllib.request` GraphQL helper via `execute_code` instead. Read the token from `gh auth token` at runtime inside the script or from a short-lived temp file, never paste tokens into logs or skill text.
- **Gemini “use specific exception classes” comments may be partly auto-fixable.** If the code under review converts structured responses into generic exceptions internally (for example after checking `response.status_code`), do not invent an upstream exception class or refactor the whole flow. Add a concise comment explaining why no upstream exception type is available at that classification point, make string matching more robust if suggested (usually `.lower()` plus lowercase markers), add focused test coverage for mixed/uppercase message variants, then resolve the now-outdated bot thread with the fixing commit SHA.
- **Gemini test-placement comments are usually auto-fixable.** When Gemini says a pure utility/unit test lives under an expensive or marker-gated test class (for example `@pytest.mark.ai` / `@pytest.mark.streaming`), move only that test to the existing utility/unit test class, run the focused test by fully-qualified node id, and check formatter/lint on the touched file. After pushing, reply to and resolve the Gemini thread with the commit SHA, then wait for CI plus the latest reviewer run.
- **Self-resolution inline comments are not actionable.** When filtering a `COMMENTED` webhook with empty body, the skill correctly checks for inline comments before skipping. But if all inline comments from the reviewer follow the self-resolution pattern (`"Resolved -- fixed in <sha>: ..."`) rather than requesting new changes, treat the review as non-actionable. Read the comment bodies before classifying them as action items. Self-resolution comments mean the author documented their own fix, not that they want you to do something.
- **Empty author `COMMENTED` reviews can be thread-reply artifacts.** Replying to a review thread may create an empty `COMMENTED` review by the PR author/current actor on the latest commit. Treat it as non-blocking if the body is empty, there are no unresolved threads, and the latest substantive reviewer/checks are clean.
- **Do not resolve intent, follow-up, or praise-only comments just because CI is green.** Bot reviewers often approve while leaving non-blocking notes like "confirm this behavior is intentional" or "pre-existing inconsistency worth a follow-up." Human reviewers may also leave approval/praise inline, which can remain as an unresolved outdated thread after later commits. Treat these as non-blocking, mention only if useful in the final evidence, and leave the thread unresolved unless you actually fixed it or have explicit user intent. Resolve only the specific addressed bug threads, with the fixing commit SHA.
- **Review verdict history can look contradictory.** GitHub keeps older `CHANGES_REQUESTED` reviews in the API even after a later approval. Trust `gh pr view --json reviewDecision,mergeStateStatus,statusCheckRollup` for current block status, then read latest reviews/comments to confirm no new actionable issues.
- **PR-level approval does not override a specific actionable comment.** Webhook/invocation payloads may cite a `COMMENTED` review while the PR's aggregate `reviewDecision` is already `APPROVED` because another reviewer approved. Apply filtering rules to the triggering review's state/body, not only to `reviewDecision`. If the triggering review has a substantive body or inline thread, read and triage it even when the aggregate PR status says approved.
- **Merged PR branch reuse.** If a branch was already merged and later gets more commits, `git push origin HEAD` updates the branch but not the old merged PR. Always check `gh pr view --json state,headRefOid` after pushing. If the intended PR is `MERGED`, create a new PR from the same branch for the new commits.
- **Making a stacked PR independent.** If the user asks to make a PR independent or mergeable into main/master, change the base with `gh pr edit <PR> --base <default-branch>` and update the PR body so it no longer says it is stacked. Then check `mergeStateStatus`. If it is `DIRTY`, merge the default branch into the PR branch (do not rebase or force-push), resolve conflicts, commit the merge, push, and wait for fresh CI plus reviewer re-runs. Verify final state with `gh pr view --json baseRefName,mergeStateStatus,statusCheckRollup,reviewDecision` and read inline/issue/review comments again.
- **Public checkout/link tokens are not always secrets.** Static payment pages may intentionally embed public checkout URLs or link tokens (for example RevenueCat Web Purchase Links). If a reviewer flags one as a hardcoded secret, verify whether it is a public link token versus a private API key. If public and production, add a concise code comment documenting that fact, do not invent env-var plumbing for a static page unless the repo already has a build system.
- **`gh pr create` has no `--json` flag in some installed versions.** Create the PR with plain `gh pr create ... --body-file /tmp/pr-body.md`, then run `gh pr view <number> --json ...` after creation if structured output is needed.
- **Scope check is not optional.** Even if the caller says "just fix CI," run the scope check. Catching drift early prevents wasted cycles fixing code that shouldn't be in the PR.
- **Cron issue-fix prompts still need duplicate-PR avoidance.** If a scheduled job asks to diagnose open issues and open PRs, list open PRs before creating a branch. When an existing PR already fixes the root cause class, extend that PR with the missing targeted fix and update its body with all `Fixes #...` references instead of opening a duplicate. For investing-log validation failures, see `references/investing-log-validation-prs.md`.
- **investing-log sector snapshots need deterministic data gates.** Wrong-direction sector performance is a validation bug, not a model-style issue. Compare `research/<model>/<date>_sector_snapshot.json` against Bloom's pulled `/tmp/pipeline/macro/sectors-1m.json` before commit, fail on wrong sign or >1pp drift, and cover it with regression tests.

## Do NOT

- Post top-level PR comments (triggers claude-review re-runs, wastes tokens). Replying to existing review threads in step 2b is fine — those don't trigger CI.
- Merge the PR (the repo owner merges)
- Force push or rewrite history
- Make changes unrelated to the PR's purpose
- Fix more than one issue per commit
- Retry the same fix approach twice
- Auto-fix scope drift (always escalate it)
