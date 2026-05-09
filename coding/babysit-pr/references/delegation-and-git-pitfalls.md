# Babysit-PR: Delegation & Git Pitfalls

## Delegation Toolsets

When delegating babysit-pr to a sub-agent via `delegate_task`, you MUST include `"terminal"` in the toolsets array.

**The toolset name is `"terminal"`, NOT `"mcp_terminal"`.**

Without terminal access the sub-agent has no shell and will immediately fail. This has caused 3+ wasted spawns in a single session.

Recommended toolsets:
```python
toolsets=["terminal", "file", "web", "memory", "skills"]
```

## Force-Push is Blocked

The `~/.local/bin/git` wrapper blocks ALL force pushes, including `--force-with-lease`. The `HERMES_BACKUP_BYPASS=1` env var does NOT bypass this for non-backup operations.

**Workaround when you've already amended and diverged from remote:**
1. `git reset --soft HEAD~1` to undo the amend
2. `git stash` the changes
3. `git cherry-pick <original-remote-sha>` to restore the original commit
4. `git stash pop` and apply changes as a new commit on top
5. `git push origin <branch>` (non-force, fast-forward)

**Better approach:** Never amend. Always make a new fixup commit.

## Batch Thread Resolution

When many review threads need resolving (10+), loop in a single shell command:

```bash
THREADS=(
"THREAD_ID_1:Resolved: fixed in abc1234."
"THREAD_ID_2:Resolved: replaced hardcoded value with env var."
)

for entry in "${THREADS[@]}"; do
  TID="${entry%%:*}"
  MSG="${entry#*:}"
  gh api graphql -f query='mutation($t: ID!, $b: String!) { addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $t, body: $b}) { comment { id } } }' -f t="$TID" -f b="$MSG" --silent
  gh api graphql -f query='mutation($t: ID!) { resolveReviewThread(input: {threadId: $t}) { thread { isResolved } } }' -f t="$TID" --silent
done
```

This avoids 2 tool calls per thread and handles 17 threads in one shot.

## Check Remote Before Fixing

Before making a local fix commit, always `git fetch origin $BRANCH` and check if someone (or a prior agent cycle) already pushed a fix for the same issue. Compare `git log origin/$BRANCH` against the review comments. If the fix already exists on remote, skip the local commit entirely. This avoids redundant commits and push rejections (non-fast-forward).

Pattern:
```bash
git fetch origin $BRANCH
git log --oneline origin/$BRANCH -5
# Compare HEAD against remote — if remote is ahead, the issue may already be fixed
git show origin/$BRANCH:path/to/flagged/file | sed -n '<line_range>p'
```

## Worktree Detached HEAD

When `git worktree add` uses `origin/$BRANCH` (because the branch is already checked out elsewhere), it creates a detached HEAD. Commits on detached HEAD can push but only via `git push origin HEAD:$BRANCH`, and will fail if remote is ahead. The Setup step in the skill tries `git checkout -B $BRANCH` to fix this, but it can still end up detached if the branch is locked by another worktree.

**Mitigation:** After creating the worktree, verify you're on the branch: `git symbolic-ref --short HEAD 2>/dev/null || echo "DETACHED"`. If detached, the safest approach is to work from the detached state but always fetch+compare remote before committing.

## Sibling Agent Conflicts

When multiple agents work on the same PR branch simultaneously (e.g., this agent + a claude-review auto-fix agent), their commits can interleave and create conflict markers that get pushed. Watch for:

1. **Between your commit and push:** Always `git fetch origin $BRANCH && git log --oneline origin/$BRANCH -3` before pushing. If remote moved ahead, rebase or merge first.
2. **After push:** If CI fails with "Cannot parse: <<<<<<< HEAD", a sibling agent pushed conflicting changes. Fix: `git fetch`, check if the conflict is already resolved by a subsequent commit, otherwise pull and resolve manually.
3. **git add -A danger:** After setup commands or sibling agent activity, unrelated files may appear in the worktree. Always review `git diff --cached --stat` before committing. Unstage anything not part of your fix.

## Python Mock Failures in pytest-xdist (CI passes locally, fails in CI)

A common CI-only test failure pattern: `patch("package.submodule.function")` works locally but fails in xdist parallel workers (Python 3.11 especially). Root causes:

1. **Submodule not imported into package namespace.** If `package/__init__.py` doesn't import `submodule`, then `patch("package.submodule.function")` may fail with `AttributeError: module 'package' has no attribute 'submodule'` in xdist workers where import order differs.

2. **Fix: Use `patch.object` with explicit imports.** Instead of string-based patch targets:
   ```python
   # FRAGILE — depends on import order
   with patch("myapp.analytics.risk.analyze_portfolio", ...):
   
   # ROBUST — explicit import guarantees the module is loaded
   from myapp.analytics import risk as risk_mod
   with patch.object(risk_mod, "analyze_portfolio", ...):
   ```

3. **Order-dependent failures.** If test A runs first and imports/exercises the module, test B's mock may work because the submodule is already in `sys.modules`. But under xdist's `LoadScopeScheduling`, worker assignment changes, so mocks that relied on side-effect imports from other tests will break.

4. **Diagnosis checklist when CI mocks don't apply:**
   - Check if the patch target's parent module explicitly imports the submodule in `__init__.py`
   - Check Python version difference (CI 3.11 vs local 3.13 may have different import resolution)
   - Check if tests pass in reverse order locally (`pytest --reverse` or run the failing test first)
   - Convert to `patch.object()` with an explicit import at test file top

5. **Django async views + sync test client + SQLite = pain.** When a sync view wraps async compute with `async_to_sync(_compute)(args)`, mocking `_compute` alone often fails because:
   - `async_to_sync` creates a new event loop that conflicts with SQLite's single-writer lock in test transactions
   - `asyncio.run()` in a mock also hits the same SQLite locking issue
   
   **Working pattern:** Patch `async_to_sync` itself to return a sync function with canned results:
   ```python
   from myapp.views import portfolio_analytics as pa_view
   
   canned = {"summary": {...}, "risk": {...}, ...}
   with patch.object(pa_view, "async_to_sync", return_value=lambda args: canned):
       resp = client.post("/endpoint/", ...)
   ```
   This completely bypasses the async boundary. The sync lambda runs inline with no event loop creation, no thread spawning, no SQLite locking conflicts. Use this for endpoint-level tests that verify response shape and caching; test the async compute layer separately with `pytest.mark.asyncio` tests that mock at the DB/external-call level.

## Automated Reviewer False Positives

Gemini Code Assist (gemini-code-assist[bot]) sometimes flags issues that aren't real:
- **Command name mismatches** when the registration name differs from the filename (e.g., `options.ts` registers `options-history` command, gemini flags this as a mismatch but it's intentional)
- **Unsupported option** warnings when the option IS defined but gemini missed it in its scan
- **Performance suggestions** (values_list, SHA-256 for cache keys, async views) that are valid optimizations but not bugs. These can be acknowledged and resolved without fixing unless they represent actual correctness issues.

Always verify automated reviewer claims by reading the actual source code before acting. Don't trust the bot's code interpretation over what the file actually says.

## Gemini Code Assist Thread Handling

Gemini-code-assist threads are medium-priority suggestions, not blocking issues. When triaging:
- **Security-medium** (e.g., MD5 for cache keys): Acknowledge but don't fix unless there's actual security exposure. Cache key derivation has no collision attack surface.
- **Performance** (values_list, async views): Valid follow-ups but scope creep for a fix cycle.
- **Reply template for Gemini suggestions:** `"Acknowledged -- valid optimization, can be applied in a follow-up. [brief reason current approach is fine for now]"`
- Always resolve these after acknowledging. They don't block "ready to merge" status.
