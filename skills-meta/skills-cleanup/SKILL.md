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

Do not do cleanup or PR work directly in the runtime checkout (`~/.hermes/skills`). Preserve first, then move the review work into a project worktree:

```bash
cd ~/projects/skills
git fetch origin main
BRANCH="wip/preserve-skills-$(date +%Y%m%d)"
git worktree add ~/projects/_worktrees/$BRANCH -b "$BRANCH" origin/main
```

Copy or patch only the intentional skill changes into the worktree. Exclude generated/runtime state (`.usage.json`, `.usage.json.lock`, `.curator_state`, `.curator_backups/`, temporary reports, moved-file markers). Before committing, inspect `git diff --name-status` and stage explicit files rather than blanket-adding the runtime checkout.

For longer cleanup/review checklists, see `references/runtime-skills-preservation.md` and `references/runtime-snapshot-pr-review.md`.

### Public vs Internal Skill Cleanup

When deciding whether public skills should move to `internal/`, be conservative. Default to **sanitize and keep public**. Move a skill internal only when sanitizing would remove the core value of the skill, such as private runbooks, private repo-specific automation, local infra topology, cron delivery routes, or workflows that only function because of Eric's private accounts and machine layout.

For writing/editorial skills, Eric is comfortable keeping his name and intentional personal voice samples public. Do not move `creative/writer`, `creative/article-writer`, `creative/editor-in-chief`, or `creative/evaluate-content` internal just because they mention Eric or include voice examples. Instead, sanitize local paths, account assumptions, private cron/reporting details, and non-public Bloom operations while preserving reusable editorial workflow, quality rubrics, anti-AI-slop guidance, and publication mechanics.

If a private Bloom-specific prompt tuning skill appears as `coding/optimize-prompt`, rename it when moving internal: `internal/optimize-bloom-prompt`. The old name is too generic for a skill that targets Bloom's `CHAT_AGENT_PROMPT`, eval runner, and repo paths.

Decision shorthand:
- **Keep public, sanitize:** generic service CLI usage, API workflows with env vars, ASO mechanics, app analytics mechanics, ad ops patterns, general finance/media workflows, generic creative/video/image workflows, and editorial skills Eric intentionally exposes.
- **Move internal:** private Bloom/Hermes runbooks, private investing-log ops/evals, Bloom content automation cron jobs, and anything whose useful behavior depends on private repo layout or account routing.

### Public Repo Review Checklist (for cleanup PRs)

Before pushing, scan for violations (this repo is PUBLIC):
```bash
grep -rnE '(personal-email@example\.com|PRIVATE_DOMAIN|ACCOUNT_ID|srv-[a-z0-9]{10,}|evg-[a-z0-9]{10,}|AuthKey_[A-Z0-9]+|\+1[0-9]{10}|password in)' --include="*.md" --include="*.py" --include="*.sh" .
```

For client/product-specific content cleanup, do not only scan the files you touched. Run a repo-wide grep for brand names, campaign claims, audience labels, and distinctive phrases, then separately scan the broad owning category. Example pattern from the OpenEd cleanup:
```bash
git grep -n -E 'OpenEd|openEd|open-ed|tuition-free|tuition free|homeschool|homeschooling|public school partnerships|OpenEd Parent|Educational Freedom|Personalized Education|#homeschool|r/homeschool|momtok|specialneeds|#education' -- . ':!devops/training' || true
grep -rnE 'OpenEd|tuition-free|homeschool|public school partnerships|momtok|specialneeds' marketing/ || true
```

When hits remain in marketing/reference files, prefer rewriting the reference into generic reusable templates over a blind string replace. Blind replacements can leave nonsense like "I was terrified to alternative approach." Re-check both exact brand terms and category-residue terms such as audience communities, hashtags, claims, testimonial attributions, and offer mechanics.

Critical rules:
- **500-line limit**: Never delete a `references/` file and inline into SKILL.md if result exceeds 500 lines. Restore the reference file.
- **No README.md** inside skill directories (per AGENTS.md)
- **Env var placeholders**: Use `$VAR_NAME` for all account-specific values. See `../../coding/babysit-pr/references/public-repo-redaction.md` for the full list.
- **Product domains are OK**: public product domains are fine. Personal emails, account IDs, infra IDs, private domains, and operational IDs are not.

### Categories That Were Full Duplicates (removed 2026-05-01)
github/, autonomous-ai-agents/, software-development/, mlops/, media/, mcp/, leisure/, red-teaming/, note-taking/, email/, smart-home/, gaming/, analytics/, diagramming/, domain/, feeds/, gifs/, inference-sh/, dogfood/
