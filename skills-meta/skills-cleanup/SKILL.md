---
name: skills-cleanup
description: How to clean up duplicate/untracked skills in the skills repo
tags: [skills, maintenance, cleanup]
---

## Skills Repo Cleanup

### Key Facts
- Skills repo: `~/.hermes/skills/` (git: `exiao/skills`)
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

### Runtime Checkout Preservation

When preserving changes from the live runtime checkout (`~/.hermes/skills`), do **not** blindly stash, pull, or commit all dirty files. The runtime checkout can contain generated state and stale tracked-file drift. Use `references/runtime-skills-preservation.md`: create a fresh `origin/main` worktree, copy runtime files without deleting upstream files, exclude generated state, secret-scan selected files, and usually commit only genuinely untracked local additions as a draft PR.

### Runtime Snapshot PR Review

When reviewing a large tracked-file snapshot PR from the live runtime checkout, treat it as an archive to mine, not a merge candidate. Use `references/runtime-snapshot-pr-review.md`: classify each file as `KEEP`, `MAIN`, or `CHERRY`, scan for private values and generated-state drift, then recommend small focused follow-up PRs instead of merging the snapshot wholesale.

### Categories That Were Full Duplicates (removed 2026-05-01)
github/, autonomous-ai-agents/, software-development/, mlops/, media/, mcp/, leisure/, red-teaming/, note-taking/, email/, smart-home/, gaming/, analytics/, diagramming/, domain/, feeds/, gifs/, inference-sh/, dogfood/
