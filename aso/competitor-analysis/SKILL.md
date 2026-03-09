---
name: competitor-analysis
description: When the user wants to analyze competitors' App Store strategy, find keyword gaps, or understand competitive positioning. Also use when the user mentions "competitor analysis", "competitive research", "keyword gap", "what are my competitors doing", or "compare my app to". For keyword-specific research, see keyword-research. For metadata writing, see metadata-optimization.
metadata:
  version: 1.1.0
---

# Competitor Analysis

You are an expert in competitive intelligence for mobile apps. Your goal is to perform a thorough analysis of the user's competitors and identify actionable opportunities to outperform them.

## Initial Assessment

1. Check for `app-marketing-context.md` — read it for known competitors
2. Ask for the **user's App ID** — Bloom's is `$BLOOM_APP_STORE_ID`
3. Ask for **competitor App IDs** (or help identify competitors using DataForSEO)
4. Ask for **target country** (default: US)
5. Ask what they want to learn: keyword gaps, creative strategy, positioning, or all

## Competitor Identification

Use DataForSEO to find and analyze competitors. Auth header for every call:
`-H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5"`

**Step 1 — Find Bloom's top App Store competitors:**
```bash
curl -s -X POST "https://api.dataforseo.com/v3/dataforseo_labs/apple/app_competitors/live" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"app_id": "$BLOOM_APP_STORE_ID", "location_code": 2840, "language_code": "en", "limit": 20}]'
```
Returns: competitor `app_id`s + titles + `avg_position` (lower avg_position = stronger competitor).
Parse: `result[0]['items']`.

**Bloom's known position:** avg rank 61.5 vs Yahoo Finance at 4.8 — that's the gap to close. Bloom ranks for 2,663 App Store keywords. Best positions: #47 for "yahoo finance", #47 for "robinhood".

**Step 2 — For each competitor, fetch their keyword footprint:**
```bash
curl -s -X POST "https://api.dataforseo.com/v3/dataforseo_labs/apple/keywords_for_app/live" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"app_id": "<competitor_id>", "location_code": 2840, "language_code": "en", "limit": 100}]'
```
Compare with Bloom's keyword list (run same endpoint with `app_id: "$BLOOM_APP_STORE_ID"`) to find gaps.

**Step 3 — Fetch competitor metadata (async):**

Post task:
```bash
curl -s -X POST "https://api.dataforseo.com/v3/app_data/apple/app_info/task_post" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"app_id": "<competitor_id>", "language_code": "en", "location_code": 2840}]'
```
Poll tasks_ready, then GET `task_get/advanced/<id>`. Returns: title, subtitle, description, rating, reviews count.

Analyze 3-5 competitors: 2 direct, 1-2 aspirational (larger players like Yahoo Finance, Robinhood), 1 emerging.

## Analysis Framework

### 1. Metadata Comparison

| Element | Bloom | Competitor 1 | Competitor 2 | Competitor 3 |
|---------|-------|-------------|-------------|-------------|
| Title | | | | |
| Subtitle | | | | |
| Title keywords | | | | |
| Char usage (title) | /30 | /30 | /30 | /30 |
| Char usage (subtitle) | /30 | /30 | /30 | /30 |
| Description hook | | | | |

**Analyze:**
- What keywords do competitors prioritize in their title?
- How do they balance brand vs keywords?
- What positioning angle does each take?
- What's their description hook strategy?

### 2. Keyword Gap Analysis

**Keywords only competitors rank for (Bloom doesn't):**

| Keyword | Volume | Difficulty | Comp 1 Rank | Comp 2 Rank | Bloom Rank | Priority |
|---------|--------|------------|-------------|-------------|------------|----------|

**Keywords Bloom ranks for but competitors don't:**

These are Bloom's unique advantages — protect them.

**Keywords where Bloom is outranked:**

| Keyword | Bloom Rank | Best Competitor Rank | Gap | Effort to Close |
|---------|------------|---------------------|-----|-----------------|

### 3. Creative Strategy

**Screenshots:**
- How many do they use? (target: 10)
- What's their first screenshot? (hook)
- Do they use text overlays?
- What features do they highlight first?
- Design style: dark/light, device frames, lifestyle?
- Portrait or landscape?

**App Preview Video:**
- Do they have one?
- What's the hook?
- How long is it?

**Icon:**
- Color scheme and style
- How does it stand out in search results?

### 4. Ratings & Reviews

| Metric | Bloom | Comp 1 | Comp 2 | Comp 3 |
|--------|-------|--------|--------|--------|
| Rating | | | | |
| Total reviews | | | | |
| Recent trend | | | | |
| Top complaint | | | | |
| Top praise | | | | |
| Dev responds? | | | | |

**Analyze:**
- What do users love about competitors? (feature opportunities)
- What do users hate? (Bloom's advantage if it solves those pain points)
- How do competitors handle negative reviews?

### 5. Growth Signals

| Signal | Bloom | Comp 1 | Comp 2 | Comp 3 |
|--------|-------|--------|--------|--------|
| Chart position | | | | |
| Downloads/mo (est) | | | | |
| Revenue/mo (est) | | | | |
| Update frequency | | | | |
| In-app events? | | | | |
| Custom pages? | | | | |
| Apple Search Ads? | | | | |

### 6. Monetization Comparison

| Aspect | Bloom | Comp 1 | Comp 2 | Comp 3 |
|--------|-------|--------|--------|--------|
| Price model | | | | |
| Subscription price | | | | |
| Free trial length | | | | |
| IAP count | | | | |
| Paywall timing | | | | |

## Output Format

### Executive Summary

2-3 paragraphs summarizing the competitive landscape, Bloom's position, and the biggest opportunities.

### Competitive Position Map

```
                    HIGH VISIBILITY
                         │
            Comp 1 ●     │     ● Comp 2
                         │
   LOW ──────────────────┼────────────────── HIGH
   RATINGS               │               RATINGS
                         │
                Bloom ●  │
                         │
                    LOW VISIBILITY
```

### Top Opportunities

1. **Quick Win:** [something actionable this week]
2. **Keyword Gap:** [specific keywords to target]
3. **Creative Edge:** [screenshot/video improvement]
4. **Feature Gap:** [what users want that competitors don't offer]
5. **Market Gap:** [underserved segment or country]

### Threats to Monitor

- [competitor moves to watch]
- [market trends that could shift dynamics]

## Related Skills

- `keyword-research` — Deep dive into keyword gaps identified
- `metadata-optimization` — Implement competitive insights into your metadata
- `screenshot-optimization` — Redesign based on competitive creative analysis
- `aso-audit` — Audit your own listing with competitive context
- `ua-campaign` — Competitive paid acquisition strategy
