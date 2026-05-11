# Runtime checkout stash triage

Use when a user applies a stash or moves a live runtime checkout, such as `~/.hermes/skills`, back to `main` and asks whether local changes should be kept.

## Triage workflow

1. Inspect state before advising:
   ```bash
   git status --short --branch
   git stash list | head -5
   git diff --stat
   git diff --cached --stat
   git ls-files -u
   ```
2. Separate the state into four buckets:
   - **Conflicts:** files marked `UU`. Read both index sides with `git show :2:path` and `git show :3:path`; do not assume either side wins.
   - **Intentional skill/content changes:** modified `SKILL.md` files and new `references/` files with reusable lessons.
   - **Generated runtime state:** `.usage.json`, locks, curator state, caches, logs, local metrics. These usually stay out of public commits.
   - **Orphan category stubs:** DESCRIPTION-only root folders with no `SKILL.md`. Treat as repo-shape noise unless the user explicitly wants category reorganization.
3. Recommend curation, not direct commit, when changes came from a runtime checkout:
   - preserve useful content on a branch or stash;
   - resolve conflicts by merging compatible lessons;
   - remove generated/local files;
   - run public-repo redaction scans;
   - PR from a clean worktree.
4. Report as `KEEP`, `DISCARD`, and `CONFLICTS` so the user can act quickly.

## Public-repo checks

Before suggesting a commit or PR, scan changed and untracked files for:

- credentials, API keys, tokens, auth headers;
- personal emails, phone numbers, internal URLs;
- hardcoded account IDs, cron IDs, Render/Railway IDs, App Store IDs;
- local absolute paths and operational snapshots.

If scan output includes generic examples like `$API_KEY`, inspect manually before calling it a leak.

## Pitfalls

- `git diff --stat` can hide staged stash-applied changes when conflicts exist. Check both cached and working-tree diffs.
- Conflict markers in a live skill file can break future skill loading. Resolve them promptly, but do not discard either side without reading both index versions.
- Do not clean the live checkout just to make status pretty. Generated junk can be discarded later, but preservation handles come first.
