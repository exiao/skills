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

When this skill is invoked from a single code-review webhook/event, apply the event-level filter before doing any setup:

- Exit with exactly `No action needed` if the triggering review state is `approved`.
- Exit with exactly `No action needed` if the webhook action is `dismissed`.
- Exit with exactly `No action needed` if the triggering review state is `commented` and the review body is empty.
- Otherwise, treat the review as actionable and run the babysit loop, even if the PR's current aggregate `reviewDecision` is already `APPROVED`. A PR can be approved overall while a later `COMMENTED` review contains a real inline fix request.

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

# Create worktree or clone directly to worktree path
BRANCH=$(gh pr view $PR --repo $REPO --json headRefName -q '.headRefName')
WORKTREE="/tmp/${REPO_DIR}-pr-${PR}"

if [ -n "$LOCAL_DIR" ]; then
  # Use existing clone to create a worktree
  git -C "$LOCAL_DIR" fetch origin "$BRANCH"
  git -C "$LOCAL_DIR" worktree add "$WORKTREE" "origin/$BRANCH" 2>/dev/null || \
    git -C "$LOCAL_DIR" worktree add --detach "$WORKTREE" "origin/$BRANCH"
  cd "$WORKTREE"
  git checkout -B "$BRANCH" "origin/$BRANCH" || true
else
  # No local clone found — clone directly to the worktree path
  git clone --branch "$BRANCH" "git@github.com:$REPO.git" "$WORKTREE"
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

**Before declaring ready, run the automated review final sweep.** If CI is green but GitHub still shows `CHANGES_REQUESTED`, `BLOCKED`, a latest top-level bot comment with `Must Fix` items, or unresolved non-outdated GraphQL threads, keep working. Load `references/automated-review-final-sweep.md` for the exact commands and decision rules.

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

- **Python mock failures in xdist.** String-based `patch("pkg.submod.func")` can silently fail in pytest-xdist workers if the submodule isn't explicitly imported. Use `patch.object(imported_mod, "func")` instead. See `references/delegation-and-git-pitfalls.md` for the full diagnosis checklist.
- **Delegation toolsets.** When delegating to a sub-agent, you MUST pass `toolsets=["terminal", "file", "web", "memory", "skills"]`. The toolset name is `"terminal"`, NOT `"ShellExec"` or `"mcp_terminal"`. Without it the sub-agent has no shell and fails immediately.
- **Force-push is blocked.** The git wrapper blocks all force pushes. Never amend commits; make a new fixup commit on top instead. See references for the recovery pattern if you already diverged.
- **Batch thread resolution.** When resolving 5+ threads, loop in a single shell command (array of "ID:message" pairs) rather than one tool call per thread. See references for the pattern.
- **Supply chain scanner false positives.** The "Scan PR for critical supply chain risks" CI check sometimes flags files (e.g. `setup.py`) that exist on the base branch and are NOT in the PR's diff. Verify with `gh pr diff $PR --repo $REPO --name-only | grep <flagged-file>`. If the file isn't in the diff, report as false positive and don't attempt to fix. This CI failure alone does not block "ready to merge" status.
- **Read CLAUDE.md/AGENTS.md first.** Every repo has different lint, test, and build commands. Never assume.
- **Stale review comments:** `original_commit_id` on inline comments refers to the commit when the comment was made. If HEAD has moved past it, the issue may already be fixed.
- **claude-review sticky comments:** These appear as issue comments from the `claude` user. They re-run on every push. Don't try to "fix" informational observations.
- **GitHub Actions GITHUB_TOKEN suppression:** Pushes from inside a GitHub Actions job using the default `GITHUB_TOKEN` don't trigger other workflow runs. This does NOT apply to local `gh` CLI pushes.
- **Worktree branch conflicts:** `git worktree add` fails if the branch is already checked out somewhere. The Setup uses `origin/$BRANCH` to avoid this. However, if an existing worktree for the same branch already exists (e.g. at `~/projects/_worktrees/$BRANCH`), **just use it** — fetch + pull there instead of creating a second worktree. Check with `git -C "$LOCAL_DIR" worktree list | grep "$BRANCH"`.
- **Prior agent's partial fix:** When a fix commit already exists for a review, don't assume it addressed ALL items. Read the review body line-by-line and verify each requested change is present in the current code. Prior agents frequently fix 3 of 4 items and miss one.
- **Remote may already have bot fixes.** Before coding review fixes, run `git fetch origin $BRANCH` and inspect `origin/$BRANCH` commits. Automated reviewers/agents may have pushed contract decisions already (for example frontend changed to `watch.alerts` while backend kept `{alerts, drift_available, drift_note}`). Rebase onto remote before committing unless you intentionally need to supersede it. Don't "fix" one side of an API by changing the backend contract if remote/frontend/CLI already converged on the other shape.
- **Remote can advance while you are fixing.** If `git fetch origin $BRANCH` shows a new commit that appears to address the same review, compare `git diff origin/$BRANCH..HEAD` and `git diff HEAD`. If there is no remaining local diff or `git commit` says nothing to commit, assume the fix is already on the branch, skip the duplicate commit, and continue with CI/thread verification on the new HEAD. Do not push an empty or redundant fix.
- **Review-body-only feedback (no inline threads):** Some reviewers (especially claude[bot]) put all feedback in the review body rather than inline threads. The GraphQL `reviewThreads` query will return empty. You still need to parse the review body text, identify each requested change, and verify/fix them. These won't have thread IDs to resolve — the review state updates when the reviewer re-reviews or the PR author dismisses.
- **"Changes requested" but already fixed:** claude[bot] sometimes submits `CHANGES_REQUESTED` reviews where the body documents bugs that were already fixed in a later commit within the same PR (e.g. "Bug fixed: X (commit abc123)"). The review state looks blocking but there's nothing to fix. Read the review body carefully before assuming work is needed. If every issue listed says "fixed in <sha>" and concludes "no other issues found," the only action is to wait for CI and let the reviewer re-approve on the next push. Don't skip CI checks though; formatting or test failures may still exist independent of the review.
- **Formatter CI failures in worktrees:** When CI fails on prettier/eslint formatting, you need `bun install` (or `npm install`) in the frontend directory before running the formatter. Use `--frozen-lockfile` to avoid modifying lockfiles. Then run the formatter on only the flagged file(s), not the whole project. Verify the diff is pure whitespace/formatting before committing.
- **Avoid formatter-driven scope creep in review fixes.** If a repo has broad pre-existing lint/format violations, running `black`, `prettier`, or `eslint --fix` on entire files can create noisy diffs unrelated to the reviewer comment. Prefer syntax checks (`python -m py_compile`, `git diff --check`) and narrow behavioral probes first. If you accidentally reformat unrelated code, restore from `HEAD` and reapply only the minimal logical patch before committing.
- **Python environment mismatch in worktrees.** `uv venv` may pick the newest local Python (for example 3.14), causing dependency resolution failures for packages without wheels (`torch`, `onnxruntime`, `chromadb`). If repo docs specify Python 3.11, create the env explicitly: `uv venv --python /usr/local/bin/python3.11` (or the repo-documented interpreter), then `uv pip install -r requirements.txt`.
- **Private clone fallback.** `git clone git@github.com:$REPO.git` can fail with `Permission denied (publickey)` even when `gh` is authenticated. If SSH clone fails, retry with `gh repo clone $REPO $WORKTREE -- --branch $BRANCH` so the GitHub CLI uses its configured auth.
- **`gh pr checks --json` fields vary by installed `gh` version.** Some versions do not expose `conclusion` for `gh pr checks --json`; valid fields may be only `bucket`, `state`, `name`, `link`, etc. Prefer `bucket` for polling (`pass`, `pending`, `fail`, `skipping`) and treat `skipping` as non-blocking. If JSON output is empty or missing fields while the plain table shows checks, fall back to `gh pr view --json statusCheckRollup,mergeStateStatus,reviewDecision`.
- **Avoid `set -e` swallowing CI polling decisions.** If a Python/JQ classifier exits non-zero to signal “pending,” a surrounding `set -e` shell will exit before you can capture `$?`. Either omit `set -e` in polling loops, wrap the classifier in an `if`, or append `|| code=$?` before branching.
- **Verify shell snippets against comments/templates, not just happy-path entries.** For documentation-only fixes that show extraction commands, test the default/template file too. Example: `watchlist.md` had ticker-looking examples inside an HTML comment; matching only `^[A-Z]{1,5} —` still extracted `SWBI` and `ANF`. The verified fix used an `awk` state machine to skip `<!-- ... -->` blocks and require the `SYMBOL — reason` format.
- **Use each package's native test command exactly.** Don't add runner-specific flags unless the project already documents them. Example: Bloom CLI uses Vitest via `npm test`; `npm test -- --runInBand` fails because Vitest doesn't support Jest's `--runInBand`. If you accidentally use an unsupported flag, rerun the documented command and don't treat the first failure as code-related.
- **Sentry upload flakes in frontend builds.** Bloom frontend builds can succeed but exit non-zero because Sentry release/source-map upload returns a transient 504. If Vite says `✓ built` and the only failure is `sentry-cli releases new ... gateway timeout`, rerun verification with `SENTRY_ALLOW_FAILURE=true NODE_OPTIONS=--max-old-space-size=4096 bun run build` and report it as a Sentry upload flake, not a code build failure.
- **Detached HEAD + remote divergence:** When the worktree is in detached-HEAD state and remote has new commits, `git pull --rebase` won't work directly. Instead: `git fetch origin $BRANCH && git rebase origin/$BRANCH`. This replays your local commit(s) on top of the new remote commits, then `git push origin HEAD:$BRANCH` works cleanly. Don't try `git checkout $BRANCH` — it will fail if another worktree has that branch checked out.
- **npm install artifacts in worktrees:** Running `npm install` or `bun install` in a CLI subdirectory to verify builds generates `node_modules/` and sometimes modifies lockfiles. Always stage only the files you changed (`git add <specific-file>`) rather than `git add -A`, or unstage with `git reset HEAD package-lock.json bun.lockb`.
- **Sub-agents can introduce unintended refactors.** Always diff `$BRANCH` against `origin/$BRANCH` before pushing to confirm only the intended fix is included.
- **Subagent timeout after push is an incomplete handoff, not a terminal state.** If a child reports or likely pushed a fix but timed out before CI polling or thread resolution, the parent should verify the PR directly, poll CI if feasible, and resolve only the fixed bot thread with the commit SHA. Do this before the final digest so the user gets current state rather than a stale "needs follow-up" caveat.
- **Frontend lint may auto-fix unrelated files.** Run lint only on the files you changed, not the whole project.
- **Check ALL three comment sources.** `gh pr view --json reviews` only shows formal review submissions. Automated reviewers often post as issue comments.
- **Outdated bot threads can still show unresolved.** After pushing reviewer fixes, fetch GraphQL review threads again. If unresolved threads are `isOutdated: true` and the latest review/check approves the fix, reply with the fixing commit SHA and resolve them. `reviewDecision: APPROVED` plus unresolved outdated threads means the PR is functionally clean, but leaving threads open creates noise for the user.
- **Thread replies/resolution can trigger more automation.** After replying to or resolving a review thread, do one more final sweep of `gh pr view --json headRefOid,statusCheckRollup,reviewDecision,mergeStateStatus,commits` and unresolved GraphQL threads. Bots or user-side automation may push a tiny follow-up commit after your fix, and your final report should reflect the actual latest HEAD, not the SHA you expected.
- **Do not resolve intent or follow-up comments just because CI is green.** Bot reviewers often approve while leaving non-blocking notes like "confirm this behavior is intentional" or "pre-existing inconsistency worth a follow-up." Treat those as non-blocking, mention them in the final report, and leave the thread unresolved unless you actually fixed it or have explicit user intent. Resolve only the specific addressed bug threads, with the fixing commit SHA.
- **Review verdict history can look contradictory.** GitHub keeps older `CHANGES_REQUESTED` reviews in the API even after a later approval. Trust `gh pr view --json reviewDecision,mergeStateStatus,statusCheckRollup` for current block status, then read latest reviews/comments to confirm no new actionable issues.
- **Resolving threads creates empty COMMENTED reviews.** Each `addPullRequestReviewThreadReply` may show up in `gh api pulls/<PR>/reviews` as an empty `COMMENTED` review by the actor. Ignore these as non-substantive, but still do the final sweep of unresolved GraphQL threads, issue comments, and current `reviewDecision`.
- **Line suggestions can understate broader review asks.** Bot reviews often include a narrow code suggestion plus text like “also handle this in middleware/DRF exception handler” or “add observability.” Apply the specific suggestion, then read the full comment body and verify any broader stated coverage already exists or is included in the same small fix.
- **`gh pr create` has no `--json` flag in some installed versions.** Create the PR with plain `gh pr create ... --body-file /tmp/pr-body.md`, then run `gh pr view <number> --json ...` after creation if structured output is needed.
- **Scope check is not optional.** Even if the caller says "just fix CI," run the scope check. Catching drift early prevents wasted cycles fixing code that shouldn't be in the PR.
- **Consolidation that exceeds 500 lines is a regression.** When a PR deletes a `references/` file and inlines its content into `SKILL.md`, verify the result stays under 500 lines. If it goes over, the correct fix is to restore the reference file and keep SKILL.md as the short entry point. This is the most common structural violation in cleanup PRs.
- **Stash + checkout fails with untracked file conflicts.** When switching branches where `origin/main` has files that exist untracked locally, `git stash` won't help (it doesn't stash untracked by default, and even `--include-untracked` can conflict). The reliable pattern: commit everything to a preservation branch (`git checkout -b wip/preserve && git add -A && git commit`), then checkout main cleanly.

## Do NOT

- Post top-level PR comments (triggers claude-review re-runs, wastes tokens). Replying to existing review threads in step 2b is fine — those don't trigger CI.
- Merge the PR (the repo owner merges)
- Force push or rewrite history
- Make changes unrelated to the PR's purpose
- Fix more than one issue per commit
- Retry the same fix approach twice
- Auto-fix scope drift (always escalate it)
