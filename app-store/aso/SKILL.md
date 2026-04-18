---
name: aso
description: ASO skills for Bloom — keyword research, audits, metadata optimization, competitor analysis using DataForSEO. Use when the user asks about App Store Optimization, improving Bloom's App Store ranking, keyword strategy, metadata, or competitor analysis for mobile apps.
---

# ASO Skill Router

You have access to four specialized ASO sub-skills. Based on the user's request, load the appropriate sub-skill from this directory.

## Sub-Skills

| Request type | Load |
|---|---|
| Full ASO audit, overall health check, "why am I not ranking", ASO score | `aso/aso-audit/SKILL.md` |
| Keyword discovery, search volume, keyword ideas, "what keywords should I target" | `aso/keyword-research/SKILL.md` |
| Writing/optimizing title, subtitle, keyword field, description, metadata copy | `aso/metadata-optimization/SKILL.md` |
| Competitor research, keyword gaps, competitive positioning, "what are competitors doing" | `aso/competitor-analysis/SKILL.md` |

## Context

- **App:** Bloom: AI for Investing
- **App Store ID:** `$BLOOM_APP_STORE_ID`
- **Data source:** DataForSEO API (see `dataforseo/SKILL.md` for full reference)
- **Known stats:** Bloom ranks for 2,663 App Store keywords. Avg position: 61.5. Best positions: #47 for "yahoo finance", #47 for "robinhood".

## How to Route

1. Read the user's request carefully.
2. If it's clearly one skill area, load that sub-skill immediately.
3. If it spans multiple (e.g., "audit + write new metadata"), start with the audit, then chain to metadata-optimization.
4. If ambiguous, ask: "Would you like a full audit, keyword research, metadata copy, or competitor analysis?"

Always check for `app-marketing-context.md` in the workspace — it has Bloom's positioning, audience, and goals.
