---
name: skill-preloading
description: Reference for the two-tier skill loading system — preloaded vs category-gated skills, how to add/remove preloaded skills, and the external-services category layout.
---

# Skill Preloading System

## How It Works
- `preloaded: true` in SKILL.md frontmatter → skill appears in system prompt with full description
- Without `preloaded: true` → skill hidden, browsable via `skills_list(category=...)`
- Category descriptions come from each folder's `DESCRIPTION.md` (frontmatter `description:` field)
- Description truncation was removed from `agent/skill_utils.py`

## Current Preloaded Skills (26)
recall, writer, plan, skill-creator, render-cli, fix-sentry-issues, grok-search, mcporter, babysit-pr, ralph-mode, firecrawl, stably-cli, porkbun-cli, copilot-money-cli, higgsfield, appfigures-cli, bird-twitter, apple-search-ads, dataforseo-cli, google-ads-cli, meta-ads-cli, prometheus-cli, last30days, dogfood

## To Add a New Preloaded Skill
Add `preloaded: true` to the SKILL.md frontmatter:
```yaml
---
name: my-skill
preloaded: true
description: What this skill does
---
```

## External Services Category
All CLI-based third-party service skills live in `external-services/`. Renamed: copilot-money→copilot-money-cli, appfigures→appfigures-cli, dataforseo→dataforseo-cli, google-ads→google-ads-cli, meta-ads→meta-ads-cli, prometheus→prometheus-cli, porkbun→porkbun-cli (merged 6 sub-skills).

## Implementation
- Runtime: `agent/prompt_builder.py` on `live-config` branch (exiao/hermes-agent#6)
- Skills: `main` branch (exiao/skills#115)
