# Reviewing runtime snapshot PRs

Use this when a PR preserves many tracked-file changes copied from a live runtime skill checkout into the public skills repo.

## Why snapshot PRs are risky

A live runtime checkout mixes durable skill improvements with generated state, private operational values, stale local drift, and regressions from prior public-redaction work. Treat snapshot PRs as an archive to mine, not something to merge wholesale.

## Review workflow

1. Get the PR file list with additions/deletions:
   ```bash
   gh api --paginate repos/OWNER/REPO/pulls/PR/files \
     --jq '.[] | [.filename,.additions,.deletions] | @tsv'
   ```
2. Work from a clean worktree for the PR branch and diff against `origin/main`:
   ```bash
   git diff --name-only origin/main...HEAD
   git diff --stat origin/main...HEAD
   git diff --unified=2 origin/main...HEAD -- path/to/file
   ```
3. Classify every file into exactly one bucket:
   - `KEEP`: safe, general, reusable skill improvement.
   - `MAIN`: discard runtime version; main is newer, cleaner, more generic, or already modularized.
   - `CHERRY`: keep the idea only after redaction, de-duplication, or moving to the right umbrella/reference.
4. Secret/privacy scan the PR content before recommending any KEEP:
   ```bash
   git grep -nE 'getbloom|investwithbloom|Fintary/|api\.fintary|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}|srv-[a-z0-9]+|mn[0-9a-z]{20,}|ts[0-9a-z]{20,}' -- .
   ```
   Adapt patterns for the repo. The point is to catch domains, account IDs, cron IDs, service IDs, handles, metrics snapshots, and active setup state.
5. Look for structural regressions:
   - generated README/category count drift
   - root convention docs reverting to older product names or deleting newer guidance
   - huge inline docs that main had already moved into `references/`
   - duplicate skills under wrong top-level categories
   - script downgrades that replace a more capable API path with a local fallback
6. Recommend focused follow-up PRs instead of merging the snapshot as-is. Good split:
   - safe runtime lessons
   - creative/growth lessons
   - new skills after redaction
   - private-only notes kept out of the public repo

## Output format

Save a durable review note under `~/.hermes/plans/<task>.md` with:

- high-level verdict: merge as-is vs mine-and-split
- counts by `KEEP`, `MAIN`, `CHERRY`
- file-by-file table: path, decision, short reason
- recommended next PR grouping

Keep the chat reply short. Link the saved plan and summarize the verdict.

## Decision heuristics

Prefer `MAIN` when:
- the runtime change hardcodes user, company, project, account, or service values
- the runtime change makes public docs less generic
- the runtime change deletes categories, counts, or conventions from main
- the runtime change bloats SKILL.md with content that belongs in references

Prefer `CHERRY` when:
- the lesson is useful but examples leak private values
- the idea belongs in another existing umbrella skill
- a block is duplicated and needs cleanup before merge
- the operational fact is stable locally but inappropriate for the public repo

Prefer `KEEP` when:
- the change is generic, reusable, and does not leak private state
- it adds a reference file with a durable troubleshooting pattern
- it improves a class-level workflow rather than recording one session's state
