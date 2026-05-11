---
name: skills-cleanup
description: How to clean up duplicate/untracked skills in the skills repo
tags: [skills, maintenance, cleanup]
---

## Skills Repo Cleanup

### Key Facts
- Skills repo: `~/.hermes/skills/` (git: `$SKILLS_REPO`)
- Automated skill creation nudge is **disabled** (`creation_nudge_interval: 0` in config.yaml)
- Agent scans `~/.hermes/skills/` and `skills.external_dirs` (currently empty) — nothing else
- Archive of removed duplicates/untracked skills: `~/.hermes/skills-archive/`

### How Duplicates Happen
- The agent's automated skill creator places new skills in `~/.hermes/skills/<category>/<name>/`
- It picks category based on the LLM's judgment — no strict enumeration of valid categories
- This creates duplicates when skills already exist under a different canonical category in the git repo

### Cleanup Workflow
1. Compare local untracked files (`git status`) against remote (`git ls-tree -r --name-only origin/main`)
2. Identify duplicates (same skill name, different category) and local-only skills
3. Move duplicates to `~/.hermes/skills-archive/` (recoverable)
4. For genuinely new local-only skills worth keeping: branch, commit, PR
5. The repo owner merges — never push to main directly

### Preserving Dirty Runtime Checkout Before Switching Branches

The runtime checkout (`~/.hermes/skills`) often has a mix of tracked modifications and untracked new files. `git stash` fails when untracked files conflict with files on the target branch. Use this pattern:

```bash
cd ~/.hermes/skills
# Commit ALL changes (tracked + untracked) to a preservation branch
git checkout -b wip/preserve-$(date +%Y%m%d)
git add -A
git commit -m "WIP: preserve all local changes"
# Now switch to main cleanly
git checkout main && git pull origin main
```

To create a clean PR from the preserved changes:
```bash
# Create fresh branch from main
git worktree add ~/projects/_worktrees/skills-cleanup -b chore/cleanup origin/main
# Generate a patch of the delta (excluding generated state)
git diff origin/main..wip/preserve-YYYYMMDD -- ':!.curator_backups' ':!.hub' ':!.usage.json' ':!*.moved' > /tmp/cleanup.patch
# Apply to the clean branch
cd ~/projects/_worktrees/skills-cleanup && git apply /tmp/cleanup.patch
```

### Public Repo Review Checklist (for cleanup PRs)

Before pushing, scan for violations (this repo is PUBLIC):
```bash
grep -rn '@gmail\|@promptpm\|exiao3\|Eric Xiao\|286685\|srv-[a-z0-9]\{10,\}\|evg-[a-z0-9]\{10,\}\|AuthKey_[A-Z0-9]\|+1[0-9]\{10\}\|password in' --include="*.md" --include="*.py" --include="*.sh" .
```

Critical rules:
- **500-line limit**: Never delete a `references/` file and inline into SKILL.md if result exceeds 500 lines. Restore the reference file.
- **No README.md** inside skill directories (per AGENTS.md)
- **Env var placeholders**: Use `$VAR_NAME` for all account-specific values. See `babysit-pr/references/public-repo-redaction.md` for the full list.
- **Product domains are OK**: `getbloom.app` as the app URL is fine. Personal emails, account IDs, infra IDs are not.

### Categories That Were Full Duplicates (removed 2026-05-01)
github/, autonomous-ai-agents/, software-development/, mlops/, media/, mcp/, leisure/, red-teaming/, note-taking/, email/, smart-home/, gaming/, analytics/, diagramming/, domain/, feeds/, gifs/, inference-sh/, dogfood/
