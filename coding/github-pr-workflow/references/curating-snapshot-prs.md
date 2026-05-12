# Curating broad snapshot PRs

Use this when a PR was created from a runtime/local snapshot and contains a mix of useful lessons, stale generated changes, private operational data, and regressions.

## Goal

Turn the raw dump into a mergeable curation PR. Do not merge the snapshot wholesale.

For runtime checkout stash triage after a user applies a stash on `main`, see `references/runtime-stash-triage.md`. It gives the KEEP / DISCARD / CONFLICTS reporting shape and commands for staged diffs, unmerged index entries, generated runtime files, and orphan category stubs.

## Workflow

0. Preserve the live source checkout before curating.
   If the snapshot came from a runtime directory such as `~/.hermes/skills`, treat that checkout as user state, not a disposable work area. Do not clean, reset, or drop stashes there. If it has uncommitted changes, first preserve them on a branch or stash that can be reapplied, then do all curation in a dedicated worktree under `~/projects/_worktrees/`.

1. Inspect PR metadata, mergeability, and changed files.
   ```bash
   gh pr view <PR> --json headRefName,baseRefName,title,url,isDraft,mergeStateStatus,reviewDecision
   git diff --name-status origin/main...HEAD
   git diff --stat origin/main...HEAD
   ```

2. Classify files before editing.
   - KEEP: durable lessons, reusable scripts, generic references, new class-level skills.
   - MAIN: generated index churn, stale docs, duplicated inline docs, downgrades, private snapshots.
   - CHERRY: files with a few reusable lines mixed with private or stale content.

3. Revert MAIN files from base without destructive checkout/reset commands.
   Prefer writing the base copy explicitly:
   ```bash
   git show origin/main:path/to/file.md > path/to/file.md
   git add path/to/file.md
   ```
   For files added only by the snapshot and not wanted, remove them from the index/worktree with `git rm` only inside the disposable worktree, never in the user's live checkout.

   If the user wants a changed skill preserved locally but dropped from the public PR, keep or copy it under the gitignored local-only category. In `exiao/skills`, `internal/` is ignored for this purpose. Example for a local-only runtime skill that already lives under `internal/`:
   ```bash
   git -C ~/.hermes/skills check-ignore -v internal/hermes-agent/SKILL.md

   # In the disposable PR worktree, remove the public copy instead of publishing local runtime notes.
   git rm -r ai-tools/hermes-agent
   git add -A README.md ai-tools
   ```
   Verify `gh pr diff <PR> --name-only | grep -i '<skill-name>'` returns nothing before reporting that the skill was dropped from the PR.

4. Redact CHERRY/KEEP content.
   Replace private domains, account IDs, cron IDs, Render/Railway IDs, Typefully IDs, local paths, org names, personal owner wording, and operational metrics with env vars or generic placeholders.

5. Avoid moving strategy into operational skills.
   If a CLI skill grew with creative or business strategy, keep the CLI skill operational and route strategy to the existing class-level skills.

6. Preserve modularization.
   If main already moved long docs into `references/`, do not re-inline thousands of lines into `SKILL.md`.

7. Update indexes only for retained additions.
   README/CLAUDE category counts and skill rows should reflect the final curated diff, not the raw snapshot.

8. Validate before pushing.
   Use an independent review pass for broad curation PRs. A subagent or reviewer should look specifically for public-repo leaks, stale references, hardcoded local paths/product IDs, accidental strategy drift into operational skills, and regressions against `origin/main`.
   ```bash
   # Changed SKILL.md frontmatter only
   python3 - <<'PY'
from pathlib import Path
import re, subprocess, sys
files=[Path(f) for f in subprocess.check_output(['git','diff','--name-only','origin/main']).decode().splitlines() if f.endswith('SKILL.md')]
bad=[]
for p in files:
    if not p.exists():
        continue
    txt=p.read_text(errors='ignore')
    if not txt.startswith('---\n'):
        bad.append((str(p),'missing frontmatter'))
        continue
    end=txt.find('\n---',4)
    if end == -1:
        bad.append((str(p),'unclosed frontmatter'))
        continue
    fm=txt[4:end]
    if not re.search(r'^name:\s*\S+', fm, re.M):
        bad.append((str(p),'missing name'))
    if not re.search(r'^description:\s*.+', fm, re.M):
        bad.append((str(p),'missing description'))
for item in bad:
    print(*item, sep=': ')
print('changed_skill_frontmatter_bad', len(bad))
sys.exit(1 if bad else 0)
PY

   # Private/local pattern scan for changed files. Tune patterns to the repo.
   python3 - <<'PY'
import re, subprocess, pathlib, sys
patterns=[
  r'/Users/[^/\s]+', r'example-private-domain\.com', r'\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b',
  r'srv-[a-z0-9]+', r'mn[0-9a-z]{20,}', r'\bts[0-9a-z]{20,}\b'
]
hits=[]
files=subprocess.check_output(['git','diff','--name-only','origin/main']).decode().splitlines()
for f in files:
    p=pathlib.Path(f)
    if not p.exists() or not p.is_file():
        continue
    try:
        txt=p.read_text()
    except Exception:
        continue
    found=[pat for pat in patterns if re.search(pat, txt, re.I)]
    if found:
        hits.append((f, found))
for f, found in hits:
    print(f, found)
print('private_scan_hits', len(hits))
sys.exit(1 if hits else 0)
PY
   ```

9. Commit as a curation commit and push normally. Do not force-push.

10. Rewrite the PR title/body to describe the curation, not the raw snapshot.
    Prefer REST patch if `gh pr edit` is unreliable:
    ```bash
    gh api -X PATCH /repos/$OWNER/$REPO/pulls/$PR_NUMBER \
      -f title='chore: curate runtime skill snapshot' \
      -F body=@/tmp/pr-body.md
    ```

11. Re-check CI, mergeability, and review status.
    A curation PR is not done until GitHub reports it as mergeable and reviewer feedback is either addressed or explicitly out of scope:
    ```bash
    gh pr view <PR> --json mergeStateStatus,reviewDecision,statusCheckRollup,isDraft
    gh pr checks <PR>
    ```
    Check all comment sources, not just formal reviews. Automated reviewers often leave issue comments or inline review threads. If local `gh` lacks modern JSON flags such as `--slurp`, pipe paginated output through `jq -s 'add | ...'` instead.

## Common removals

- Private analytics snapshots.
- Generated README/CLAUDE regressions.
- Stale category counts.
- Hardcoded private domains, orgs, account IDs, cron IDs, Render/Railway service IDs, Typefully IDs.
- Duplicate skill locations caused by category moves.
- Script downgrades that replace a richer endpoint with a less capable fallback.

## Good final PR body shape

- Summary of what was kept.
- Summary of what was reverted/redacted.
- Validation results, including frontmatter and private-scan pass.
- Note that the PR is broad but curated, if it remains broad.
