# Applying a Stash to a Different Worktree

When a git stash was created in the main repo checkout but you need to apply
it to a clean worktree (e.g., to PR the changes properly), `git stash pop`
won't work from the worktree since stashes live on the main repo.

## Pattern

```bash
# 1. Create a clean worktree from main
cd ~/projects/<repo>
git worktree add ~/projects/_worktrees/<branch> -b <branch> origin/main

# 2. Pipe the stash patch from the main repo into the worktree
cd ~/projects/<repo>
git stash show -p stash@{0} | (cd ~/projects/_worktrees/<branch> && git apply --3way -)

# 3. Resolve any conflicts (--3way creates <<<< markers instead of failing)
# 4. Commit, push, PR from the worktree
```

## Why --3way

`git apply` without `--3way` fails completely on any hunk that doesn't match.
With `--3way`, it falls back to a 3-way merge and leaves conflict markers you
can resolve, just like a normal merge conflict. This is important when the
stash was created on a different branch (e.g., `initial-harness`) but you're
applying to `main` where some lines have changed.

## Pitfalls

- **Don't `git stash pop` from the worktree.** Stashes belong to the repo, not
  the worktree. Running `pop` from a worktree applies the stash in the worktree's
  index but if there are conflicts, the stash is NOT dropped and the worktree
  ends up in a messy state with staged + unmerged files. Use the pipe pattern.
- **Check for no-op diffs.** If the stash includes changes that are already in
  main (e.g., a `quiet_mode=True` that was merged separately), those hunks will
  apply cleanly but produce no diff. `git diff --cached --stat` after staging
  shows only the net-new changes.
- **Don't drop the stash until the PR is merged.** Keep it as insurance.
