# Runtime Skills Preservation

Use this when `~/.hermes/skills` has many dirty runtime changes and the user wants to preserve local additions without regressing the public `exiao/skills` repo.

## Problem pattern

`~/.hermes/skills` is the live runtime skills checkout. It can contain:

- Generated local state: `.curator_state`, `.hub/`, `.usage.json`, `.usage.json.lock`
- Runtime-only untracked skills or references
- Modified tracked files that are stale relative to `origin/main`
- Deleted files caused by old local branches or prior sync attempts

Blind `git stash`, `git pull`, or `rsync --delete` can hide useful local work or accidentally reintroduce stale versions into a PR.

## Safe preservation workflow

1. Inspect the live checkout, but do not mutate it:
   ```bash
   cd ~/.hermes/skills
   git fetch origin main
   git status --short --branch
   git diff --stat origin/main | tail -40
   ```

2. Create a fresh preservation worktree from current main:
   ```bash
   cd ~/projects/skills
   git worktree add ~/projects/_worktrees/preserve-runtime-skills-$(date +%Y%m%d) \
     -b preserve-runtime-skills-$(date +%Y%m%d) origin/main
   ```

3. Copy runtime files into the preservation worktree without deleting upstream files and excluding generated state:
   ```bash
   rsync -a ~/.hermes/skills/ ~/projects/_worktrees/preserve-runtime-skills-$(date +%Y%m%d)/ \
     --exclude='.git/' \
     --exclude='.curator_state' \
     --exclude='.hub/' \
     --exclude='.usage.json' \
     --exclude='.usage.json.lock' \
     --exclude='*.moved'
   ```

4. Review the diff before staging. Treat tracked-file modifications as suspicious if they remove large amounts of current main content:
   ```bash
   cd ~/projects/_worktrees/preserve-runtime-skills-$(date +%Y%m%d)
   git status --short
   git diff --stat origin/main
   git diff -- README.md | sed -n '1,220p'
   ```

5. Prefer preserving genuinely untracked additions first:
   ```bash
   git ls-files --others --exclude-standard > /tmp/runtime_untracked_files.txt
   wc -l /tmp/runtime_untracked_files.txt
   sed -n '1,160p' /tmp/runtime_untracked_files.txt
   ```

6. Secret-scan the files you intend to commit:
   ```bash
   xargs grep -nE '(sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9_]{20,}|xox[baprs]-|AKIA[0-9A-Z]{16}|-----BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY)' \
     < /tmp/runtime_untracked_files.txt 2>/dev/null | head -20
   ```

7. Stage only selected preservation files, not stale tracked drift:
   ```bash
   git add --pathspec-from-file=/tmp/runtime_untracked_files.txt
   git commit -m "chore: preserve local runtime skill additions"
   git push origin HEAD
   ```

8. Open a draft PR. State explicitly what was included, what was intentionally excluded, and that the PR is a preservation snapshot:
   ```bash
   gh pr create --draft \
     --title "chore: preserve local runtime skill additions" \
     --body-file /tmp/preserve-runtime-skills-pr.md \
     --base main \
     --head <branch>
   ```

## Pitfalls

- Do not treat `~/.hermes/skills` as a clean working repo. It is runtime state.
- Do not `rsync --delete` from runtime into a PR worktree. It can delete files that exist upstream but not locally.
- Do not commit generated local state.
- Do not commit broad tracked-file drift unless each file is intentionally reviewed. README diffs are especially likely to be stale and can undo merged PR category updates.
- Draft PRs are appropriate for preservation snapshots. They prevent local work from being lost while signaling that review is needed before merge.
