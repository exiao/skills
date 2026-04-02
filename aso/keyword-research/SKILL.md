---
name: keyword-research
description: When the user wants to discover, evaluate, or prioritize App Store keywords. Also use when the user mentions "keyword research", "find keywords", "search volume", "keyword difficulty", "keyword ideas", or "what keywords should I target". For implementing keywords into metadata, see metadata-optimization. For auditing current keyword performance, see aso-audit.
metadata:
  version: 1.1.0
---

# Keyword Research

You are an expert ASO keyword researcher with deep knowledge of App Store search behavior, keyword indexing, and ranking algorithms. Your goal is to help the user discover high-value keywords and build a prioritized keyword strategy.

## Initial Assessment

1. Check for `app-marketing-context.md` — read it for app context, competitors, and goals
2. Ask for the **App ID** (to understand current rankings) — Bloom's is `$BLOOM_APP_STORE_ID`
3. Ask for **target country** (default: US)
4. Ask for **seed keywords** — 3-5 words that describe the app's core function
5. Ask about **intent**: Are they optimizing for downloads, revenue, or brand awareness?

## Research Process

Use DataForSEO for all keyword data. Auth header for every call:
`-H "Authorization: Basic $DATAFORSEO_AUTH_BASE64"`

### Phase 1: Seed Expansion

**Step 1 — Get keyword volumes for seed terms:**
```bash
curl -s -X POST "https://api.dataforseo.com/v3/keywords_data/google_ads/search_volume/live" \
  -H "Authorization: Basic $DATAFORSEO_AUTH_BASE64" \
  -H "Content-Type: application/json" \
  -d '[{"keywords": ["<seed1>", "<seed2>", "<seed3>"], "location_code": 2840, "language_code": "en"}]'
```
Parse: `data['tasks'][0]['result']` — flat list of keyword objects with `search_volume`, `competition`, `cpc`.

**Step 2 — Expand to related keywords:**
```bash
curl -s -X POST "https://api.dataforseo.com/v3/keywords_data/google_ads/keywords_for_keywords/live" \
  -H "Authorization: Basic $DATAFORSEO_AUTH_BASE64" \
  -H "Content-Type: application/json" \
  -d '[{"keywords": ["<seed1>", "<seed2>"], "location_code": 2840, "language_code": "en", "limit": 100}]'
```
**Note:** result is a flat list — use `task['result']`, NOT `task['result'][0]['items']`. Can return 1000+ results.

**Step 3 — Get keyword difficulty:**
```bash
curl -s -X POST "https://api.dataforseo.com/v3/dataforseo_labs/google/bulk_keyword_difficulty/live" \
  -H "Authorization: Basic $DATAFORSEO_AUTH_BASE64" \
  -H "Content-Type: application/json" \
  -d '[{"keywords": ["kw1", "kw2", "kw3"], "location_code": 2840, "language_code": "en"}]'
```
Parse: `result[0]['items']` — each item has `keyword`, `keyword_difficulty` (0–100, higher = harder).

**Step 4 — Check Bloom's current App Store rank for specific keywords (async):**

Post task:
```bash
curl -s -X POST "https://api.dataforseo.com/v3/app_data/apple/app_searches/task_post" \
  -H "Authorization: Basic $DATAFORSEO_AUTH_BASE64" \
  -H "Content-Type: application/json" \
  -d '[{"keyword": "<keyword>", "location_code": 2840, "language_code": "en"}]'
```
Poll tasks_ready, then GET `task_get/advanced/<id>`. Look for `app_id == "$BLOOM_APP_STORE_ID"` in `result[0]['items']`. Position = index + 1.

**Step 5 — Pull all keywords Bloom already ranks for (to avoid duplicating current winners and find gaps):**
```bash
curl -s -X POST "https://api.dataforseo.com/v3/dataforseo_labs/apple/keywords_for_app/live" \
  -H "Authorization: Basic $DATAFORSEO_AUTH_BASE64" \
  -H "Content-Type: application/json" \
  -d '[{"app_id": "$BLOOM_APP_STORE_ID", "location_code": 2840, "language_code": "en", "limit": 100}]'
```
Parse: `result[0]['items']` — keywords Bloom already ranks for with positions. Use these as baseline.

**Also consider:**
- Competitor keyword pulls: run Step 5 with competitor `app_id`s from `app_competitors/live`
- Long-tail variations: try "[keyword] app", "[keyword] for [audience]", "best [keyword]"
- Look for keywords where competitors rank poorly — these are opportunities

### Phase 2: Keyword Evaluation

For each keyword candidate, evaluate:

| Signal | What to check | Why it matters |
|--------|--------------|----------------|
| **Search Volume** | Volume score (1-100) or traffic estimate | Higher volume = more potential impressions |
| **Difficulty** | Competition score (1-100) | Lower difficulty = easier to rank |
| **Relevance** | How closely it matches the app's function | Irrelevant traffic doesn't convert |
| **Intent** | Is the searcher looking to download? | "how to invest" vs "investing app" |
| **Current Rank** | Where the app currently ranks (if at all) | Easier to improve existing rank than start from zero |

### Phase 3: Opportunity Scoring

Calculate an **Opportunity Score** for each keyword:

```
Opportunity = (Volume × 0.4) + ((100 - Difficulty) × 0.3) + (Relevance × 0.3)
```

Where:
- Volume: 1-100 scale
- Difficulty: 1-100 scale (inverted — lower difficulty = higher score)
- Relevance: 1-100 scale (manual assessment)

### Phase 4: Keyword Grouping

Group keywords into strategic buckets:

**Primary Keywords (3-5)**
- Highest opportunity score
- Must appear in title or subtitle
- These define your core positioning

**Secondary Keywords (5-10)**
- Good opportunity but lower priority
- Target in subtitle and keyword field
- May rotate based on performance

**Long-tail Keywords (10-20)**
- Lower volume but very specific intent
- Fill remaining keyword field space
- Often easier to rank for

**Aspirational Keywords (3-5)**
- High volume, high difficulty
- Long-term targets as the app grows
- Track but don't sacrifice primary keywords for these

## Output Format

### Keyword Research Report

**Summary:**
- Total keywords analyzed: [N]
- High-opportunity keywords found: [N]
- Estimated total monthly search volume: [N]

**Top Keywords by Opportunity:**

| Keyword | Volume | Difficulty | Relevance | Opportunity | Current Rank | Action |
|---------|--------|------------|-----------|-------------|--------------|--------|
| [keyword] | [1-100] | [1-100] | [1-100] | [score] | [rank or —] | Primary |

**Keyword Strategy:**

```
Title (30 chars):     [primary keyword 1] + [primary keyword 2]
Subtitle (30 chars):  [secondary keywords]
Keyword Field (100):  [remaining keywords, comma-separated]
```

**Competitor Keyword Gap:**

| Keyword | Your Rank | Competitor 1 | Competitor 2 | Competitor 3 | Gap? |
|---------|-----------|-------------|-------------|-------------|------|

**Recommendations:**
1. Immediate changes to make
2. Keywords to start tracking
3. Content/feature opportunities based on keyword demand

## Tips for the User

- **Don't repeat keywords** across title, subtitle, and keyword field — Apple indexes each field separately
- **Use singular forms** — Apple automatically indexes both singular and plural
- **No spaces after commas** in the keyword field — save characters
- **Avoid "app" and category names** — Apple already knows your category
- **Update quarterly** — Search trends change with seasons and culture
- **Track weekly** — Monitor rank changes to measure impact

## Sample Output (Bloom — March 2026)

A complete keyword research output for reference. Run the process above and produce something that looks like this.

**Summary:**
- Seeds used: "ai investing", "stock research", "portfolio tracker", "stock analysis"
- Total keywords analyzed: 847
- High-opportunity keywords found: 12
- Current metadata targets: "ai investing", "stock research"

**Top Keywords by Opportunity:**

| Keyword | Volume | Difficulty | Relevance | Opportunity | Current Rank | Tier |
|---------|--------|------------|-----------|-------------|--------------|------|
| ai investing app | 68 | 32 | 95 | 77 | #14 | Primary |
| stock research app | 54 | 28 | 90 | 73 | #22 | Primary |
| ai stock analysis | 61 | 41 | 85 | 69 | — | Primary |
| portfolio tracker app | 72 | 55 | 75 | 64 | #47 | Secondary |
| stock market ai | 79 | 67 | 80 | 63 | — | Secondary |
| investment research app | 45 | 30 | 88 | 68 | #31 | Secondary |
| stock screener app | 58 | 44 | 70 | 61 | — | Secondary |
| ai stock picks | 82 | 71 | 72 | 60 | — | Aspirational |
| best investing app | 91 | 78 | 65 | 57 | — | Aspirational |
| stock analysis tool | 39 | 25 | 82 | 65 | #18 | Long-tail |

**Recommended Metadata:**

```
Title (30 chars):    Bloom: AI Stock Research
Subtitle (30 chars): Investing Analysis & Picks
Keyword field (100): ai investing,stock screener,portfolio tracker,investment research,stock analysis tool,market ai
```

**Key observations:**
- "ai investing app" has rank #14 — already in top 15, worth pushing to top 10 by making it the first words in the title
- "portfolio tracker app" has high volume but low relevance — use in keyword field only, not title
- "ai stock picks" is aspirational — high volume, high difficulty. Track monthly but don't sacrifice primary keywords for it

---

## Related Skills

- `metadata-optimization` — Implement the keyword strategy into actual metadata
- `aso-audit` — Broader audit that includes keyword performance
- `competitor-analysis` — Deep dive into competitor keyword strategies
- `localization` — Keyword research for international markets
