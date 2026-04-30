---
name: dataforseo-cli
preloaded: true
description: Use when doing keyword research (volume, difficulty, ideas), checking App Store or Google Play rankings for Bloom or competitors, or looking up Google SERP rankings for content/landing pages. Also use when building ASO keyword lists or finding App Store competitors.
---

# DataForSEO Skill

SEO and ASO data via the DataForSEO API. Covers keyword volume, difficulty, App Store rankings, SERP rankings, and keyword suggestions.

## Setup

Run once at the start of every session:

```bash
export BASE="https://api.dataforseo.com/v3"
export DFS_AUTH="Authorization: Basic $DATAFORSEO_AUTH_BASE64"
# All POSTs: curl -s -X POST "$BASE/..." -H "$DFS_AUTH" -H "Content-Type: application/json" -d '[...]'
# All GETs:  curl -s "$BASE/..." -H "$DFS_AUTH"
```

Dashboard: `https://app.dataforseo.com`

## Key IDs

| App | Store | ID |
|-----|-------|----|
| Bloom: AI for Investing | App Store | `$BLOOM_APP_STORE_ID` |

## API Patterns

**Live APIs** (instant): Keywords Data, SERP, DataForSEO Labs  
**Task-based APIs** (async): App Data (App Store/Play)

Task pattern:
1. POST `*/task_post` → save `id`
2. GET `*/tasks_ready` → wait for task to appear
3. GET `*/task_get/advanced/<id>` → fetch results

---

## Endpoints

### 1. Keyword Search Volume · $0.075/request (≤700 keywords)

```bash
curl -s -X POST "$BASE/keywords_data/google_ads/search_volume/live" \
  -H "$DFS_AUTH" -H "Content-Type: application/json" \
  -d '[{"keywords": ["ai investing app", "portfolio tracker"], "location_code": 2840, "language_code": "en"}]'
```

**Returns:** `search_volume`, `competition` (LOW/MEDIUM/HIGH), `competition_index` (0–100), `cpc`, `monthly_searches`  
**Parse:** `data['tasks'][0]['result']` → flat list

---

### 2. Keyword Ideas · $0.075/request

```bash
curl -s -X POST "$BASE/keywords_data/google_ads/keywords_for_keywords/live" \
  -H "$DFS_AUTH" -H "Content-Type: application/json" \
  -d '[{"keywords": ["stock research", "ai investing"], "location_code": 2840, "language_code": "en", "limit": 100}]'
```

**Returns:** Flat list in `result[]` (NOT nested under `items`). Can return 1000+ results.

---

### 3. Keyword Difficulty · ~$0.003/keyword

```bash
curl -s -X POST "$BASE/dataforseo_labs/google/bulk_keyword_difficulty/live" \
  -H "$DFS_AUTH" -H "Content-Type: application/json" \
  -d '[{"keywords": ["ai investing app", "stock research app"], "location_code": 2840, "language_code": "en"}]'
```

**Returns:** `keyword`, `keyword_difficulty` (0–100) | **Parse:** `result[0]['items']`  
Score guide: <30 = easy, 30–60 = medium, >60 = hard

---

### 4. Google SERP Rankings · $0.002/keyword

```bash
curl -s -X POST "$BASE/serp/google/organic/live/advanced" \
  -H "$DFS_AUTH" -H "Content-Type: application/json" \
  -d '[{"keyword": "ai investing app", "location_code": 2840, "language_code": "en", "device": "desktop", "depth": 10}]'
```

**Returns:** Items list — filter `type == "organic"`. Fields: `rank_absolute`, `domain`, `title`, `url`

---

### 5. App Store Search (Apple) · $0.0012/keyword

```bash
# Step 1 — Post task
curl -s -X POST "$BASE/app_data/apple/app_searches/task_post" \
  -H "$DFS_AUTH" -H "Content-Type: application/json" \
  -d '[{"keyword": "stock research app", "location_code": 2840, "language_code": "en"}]'

# Step 2 — Poll until ready
curl -s "$BASE/app_data/apple/app_searches/tasks_ready" -H "$DFS_AUTH"
# Returns endpoint_advanced URL — use it in step 3

# Step 3 — Fetch results
curl -s "$BASE/app_data/apple/app_searches/task_get/advanced/<TASK_ID>" -H "$DFS_AUTH"
```

**Returns:** `result[0]['items']` — each item: `app_id`, `title`, `developer_name`, `rating.value`, `reviews_count`. Position = index + 1.  
**Find Bloom:** look for `app_id == "$BLOOM_APP_STORE_ID"`

---

### 6. App Store Keywords for an App · ~$0.012/app

```bash
curl -s -X POST "$BASE/dataforseo_labs/apple/keywords_for_app/live" \
  -H "$DFS_AUTH" -H "Content-Type: application/json" \
  -d '[{"app_id": "$BLOOM_APP_STORE_ID", "location_code": 2840, "language_code": "en", "limit": 100}]'
```

**Returns:** `result[0]['total_count']` + items with `keyword_data.keyword`, `keyword_data.keyword_info.search_volume`, `ranked_serp_element.serp_item.rank_absolute`  
**Bloom:** Ranks for 2,663 App Store keywords. #47 for "yahoo finance", #47 for "robinhood".

---

### 7. App Store Competitor Apps · ~$0.011/app

```bash
curl -s -X POST "$BASE/dataforseo_labs/apple/app_competitors/live" \
  -H "$DFS_AUTH" -H "Content-Type: application/json" \
  -d '[{"app_id": "$BLOOM_APP_STORE_ID", "location_code": 2840, "language_code": "en", "limit": 20}]'
```

**Returns:** Items with `app_id`, `title`, `avg_position`  
**Bloom:** 13,645 competitor apps. Bloom avg position 61.5 vs Yahoo Finance 4.8.

---

### 8. Ranked Keywords for a Domain · ~$0.011/domain

```bash
curl -s -X POST "$BASE/dataforseo_labs/google/ranked_keywords/live" \
  -H "$DFS_AUTH" -H "Content-Type: application/json" \
  -d '[{"target": "investwithbloom.com", "location_code": 2840, "language_code": "en", "limit": 50}]'
```

**Returns:** Items with `keyword_data.keyword`, `keyword_data.keyword_info.search_volume`, `ranked_serp_element.serp_item.rank_absolute`  
**Note:** investwithbloom.com ranks for 12 keywords, all brand-name. Use on competitor domains to find their traffic-driving terms.

---

### 9. AI Search Volume · ~$0.003/keyword

```bash
curl -s -X POST "$BASE/ai_optimization/ai_keyword_data/keywords_search_volume/live" \
  -H "$DFS_AUTH" -H "Content-Type: application/json" \
  -d '[{"keywords": ["ai investing app", "stock research app"], "location_code": 2840, "language_code": "en"}]'
```

**Returns:** `result[0]['items']` — each: `keyword`, `ai_search_volume`, `ai_monthly_searches` (12 months)  
**Context:** AI volume is much lower than Google (135 vs 1,900 for "ai investing app") but growing fast (+187% YoY). Use for GEO content prioritization.

---

### 10. On-Page SEO Audit · ~$0.003/page

```bash
# Step 1 — Queue
curl -s -X POST "$BASE/on_page/task_post" \
  -H "$DFS_AUTH" -H "Content-Type: application/json" \
  -d '[{"target": "https://mycrystalball.substack.com/p/your-slug", "max_crawl_pages": 1, "calculate_keyword_density": true, "enable_browser_rendering": true}]'

# Step 2 — Summary
curl -s "$BASE/on_page/summary/<TASK_ID>" -H "$DFS_AUTH"

# Step 3 — Page details
curl -s -X POST "$BASE/on_page/pages" \
  -H "$DFS_AUTH" -H "Content-Type: application/json" \
  -d '[{"id": "<TASK_ID>", "limit": 10}]'
```

**Returns:** Per-page `checks` — title tag, meta description, H1, broken links, keyword density, CWV.  
For full site: `target: "getbloom.app"`, `max_crawl_pages: 50`

---

## Common Workflows

| Goal | Endpoints |
|------|-----------|
| ASO keyword volume | 1. Batch up to 700 keywords per call |
| Keyword ideas | 2. Use 2–5 seeds, sort by `search_volume` desc |
| SEO difficulty | 3. <30 = easy target |
| Google SERP check | 4. Search for `getbloom.app` in `domain` field |
| App Store rank for keyword | 5. Find `app_id == "$BLOOM_APP_STORE_ID"` |
| All keywords Bloom ranks for | 6. Sort by `rank_absolute` for best positions |
| App Store competitors | 7. Lower `avg_position` = stronger competitor |
| Competitor SEO keywords | 8. Use their domain, find traffic terms |
| GEO content priority | 9. High AI volume + low Google volume = early opportunity |
| Pre/post-publish SEO audit | 10. Pass live URL |
| Build ASO keyword priority list | 1 + 3. Cross-reference volume × difficulty |

---

## Common Mistakes

- **Keyword ideas parse:** `task['result']` not `task['result'][0]['items']` (flat list)
- **App Data is async only** — no live endpoints. Must POST then GET.
- **Task GET format:** `task_get/advanced/<id>` not `task_get/<id>`
- **tasks_ready** returns the `endpoint_advanced` path — use it directly for step 3
