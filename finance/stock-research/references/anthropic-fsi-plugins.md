# Anthropic Financial Services Plugins — Local Reference

Cloned from GitHub, available locally for reference material and prompt patterns.

## Repos

| Repo | Local path | Notes |
|------|-----------|-------|
| anthropics/financial-services-plugins | ~/projects/financial-services-plugins/ | Primary. Agent plugins, vertical plugins, managed agent cookbooks. |
| anthropics/financial-services | ~/projects/financial-services/ | Duplicate of above. Can be trashed. |
| anthropics/knowledge-work-plugins | ~/projects/knowledge-work-plugins/ | General knowledge work (product-management, marketing, data, finance, sales, etc.) |

## Most Useful Skills (paths relative to ~/projects/financial-services-plugins/)

### Equity Research Vertical
- `plugins/vertical-plugins/equity-research/skills/earnings-analysis/SKILL.md` — Institutional earnings update reports (8-12 pages). Good prompt patterns for beat/miss analysis, estimate revisions, and thesis impact.
- `plugins/vertical-plugins/equity-research/skills/idea-generation/SKILL.md` — Systematic stock screening (value, growth, quality, special situation). Quantitative screen criteria.
- `plugins/vertical-plugins/equity-research/skills/thesis-tracker/SKILL.md` — Investment thesis scorecards with pillar tracking, conviction levels, and action triggers.
- `plugins/vertical-plugins/equity-research/skills/sector-overview/SKILL.md` — Industry landscape reports: TAM, structure, key trends, competitive positioning.
- `plugins/vertical-plugins/equity-research/skills/catalyst-calendar/SKILL.md` — Upcoming catalyst tracking for portfolio positions.
- `plugins/vertical-plugins/equity-research/skills/morning-note/SKILL.md` — Morning research note format.

### Financial Analysis Vertical
- `plugins/vertical-plugins/financial-analysis/skills/comps-analysis/SKILL.md` — Institutional comps tables with statistical benchmarking. MCP data source hierarchy pattern.
- `plugins/vertical-plugins/financial-analysis/skills/competitive-analysis/SKILL.md` — Competitive landscape deck framework (two-phase: scope then build).
- `plugins/vertical-plugins/financial-analysis/skills/dcf-model/SKILL.md` — DCF model builder with Excel/openpyxl patterns, sensitivity tables, and Office JS pitfalls.

### Agent Plugins (full agent prompts with sub-agent orchestration)
- `plugins/agent-plugins/market-researcher/` — Sector primers with comps spread and ideas shortlist.
- `plugins/agent-plugins/earnings-reviewer/` — Post-earnings workflow: transcript, model update, note draft.
- `plugins/agent-plugins/model-builder/` — DCF, LBO, 3-statement models from scratch.

### Knowledge Work (~/projects/knowledge-work-plugins/)
- `product-management/skills/` — write-spec, competitive-brief, metrics-review, roadmap-update, sprint-planning.
- `marketing/skills/` — campaign-plan, content-creation, seo-audit, email-sequence, performance-report.
- `data/skills/` — analyze, build-dashboard, create-viz, sql-queries, statistical-analysis.

## How to Use

These are reference material, not skills we run directly. They assume MCP connections to CapIQ, FactSet, Daloopa, etc. that we don't have. The value is in their:
1. **Prompt patterns** — how they structure analysis (thesis scorecards, pillar tracking, conviction levels)
2. **Workflow sequences** — what steps institutional analysts follow
3. **Output templates** — tables, formats, and section structures
4. **Guardrails** — cite every number, flag unsourced data, stop for review

When doing stock research, earnings analysis, or comps work, consult the relevant SKILL.md for institutional-grade framing. Adapt for our tools (Serper, Firecrawl, Bloom CLI) instead of their MCPs.
