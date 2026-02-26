---
name: dataforseo
description: Use when doing keyword research (volume, difficulty, ideas), checking App Store or Google Play rankings for Bloom or competitors, or looking up Google SERP rankings for content/landing pages. Also use when building ASO keyword lists or finding App Store competitors.
---

# DataForSEO Skill

SEO and ASO data via the DataForSEO API. Covers keyword volume, difficulty, App Store rankings, SERP rankings, and keyword suggestions.

## Auth

All requests use HTTP Basic auth. Always use this header pair:

```bash
-H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5"
-H "Content-Type: application/json"
```

Base URL: `https://api.dataforseo.com/v3`
Dashboard: `https://app.dataforseo.com` (socials@promptpm.ai)

## Key IDs

| App | Store | ID |
|-----|-------|----|
| Bloom: AI for Investing | App Store | `1436348671` |
| Bloom | Google Play | TBD |

## API Patterns

**Live APIs** (instant): Keywords Data, SERP, DataForSEO Labs  
**Task-based APIs** (async): App Data (App Store/Play)

Task pattern:
1. POST `*/task_post` → save `id`
2. GET `*/tasks_ready` → wait for task to appear
3. GET `*/task_get/advanced/<id>` → fetch results

---

## Endpoints

### 1. Keyword Search Volume

**Endpoint:** POST `/keywords_data/google_ads/search_volume/live`  
**Use for:** Getting US search volume, CPC, competition for known keywords.  
**Cost:** $0.075/request (up to 700 keywords per call)

```bash
curl -s -X POST "https://api.dataforseo.com/v3/keywords_data/google_ads/search_volume/live" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"keywords": ["ai investing app", "portfolio tracker"], "location_code": 2840, "language_code": "en"}]'
```

**Returns:** Per keyword: `search_volume`, `competition` (LOW/MEDIUM/HIGH), `competition_index` (0–100), `cpc`, `monthly_searches` (12 months)  
**Parse:** `data['tasks'][0]['result']` → flat list of keyword objects

---

### 2. Keyword Ideas / Suggestions

**Endpoint:** POST `/keywords_data/google_ads/keywords_for_keywords/live`  
**Use for:** Expanding seed keywords into 1000+ related terms with volume data.  
**Cost:** $0.075/request

```bash
curl -s -X POST "https://api.dataforseo.com/v3/keywords_data/google_ads/keywords_for_keywords/live" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"keywords": ["stock research", "ai investing"], "location_code": 2840, "language_code": "en", "limit": 100}]'
```

**Returns:** Flat list of keyword objects in `result[]` (not nested under `items`). Same fields as search volume. Can return 1000+ results across seed keywords.

---

### 3. Keyword Difficulty

**Endpoint:** POST `/dataforseo_labs/google/bulk_keyword_difficulty/live`  
**Use for:** SEO difficulty scores (0–100) to prioritize content targets.  
**Cost:** ~$0.003/keyword

```bash
curl -s -X POST "https://api.dataforseo.com/v3/dataforseo_labs/google/bulk_keyword_difficulty/live" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"keywords": ["ai investing app", "stock research app"], "location_code": 2840, "language_code": "en"}]'
```

**Returns:** `keyword`, `keyword_difficulty` (0–100, higher = harder to rank)  
**Parse:** `result[0]['items']` list

---

### 4. Google SERP Rankings

**Endpoint:** POST `/serp/google/organic/live/advanced`  
**Use for:** Checking who ranks on Google for a keyword; whether Bloom's site appears.  
**Cost:** $0.002/keyword

```bash
curl -s -X POST "https://api.dataforseo.com/v3/serp/google/organic/live/advanced" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"keyword": "ai investing app", "location_code": 2840, "language_code": "en", "device": "desktop", "depth": 10}]'
```

**Returns:** Items list with `type` field. Filter `type == "organic"` for organic results. Each has: `rank_absolute`, `domain`, `title`, `url`, `description`

---

### 5. App Store Search (Apple)

**Use for:** Checking which apps rank for an App Store keyword; Bloom's position.  
**Cost:** $0.0012/keyword

**Step 1 — Post task:**
```bash
curl -s -X POST "https://api.dataforseo.com/v3/app_data/apple/app_searches/task_post" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"keyword": "stock research app", "location_code": 2840, "language_code": "en"}]'
```

**Step 2 — Check ready (poll until task appears):**
```bash
curl -s "https://api.dataforseo.com/v3/app_data/apple/app_searches/tasks_ready" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5"
```
Gives back `endpoint_advanced` URL to use in step 3.

**Step 3 — Fetch results:**
```bash
curl -s "https://api.dataforseo.com/v3/app_data/apple/app_searches/task_get/advanced/<TASK_ID>" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5"
```

**Returns:** `result[0]['items']` list. Each item: `app_id`, `title`, `developer_name`, `rating` (object with `value`), `reviews_count`. Position = index + 1.

**To find Bloom's rank:** Search `items` for `app_id == "1436348671"`.

---

### 6. Google Play App Search

Same as endpoint 5 but replace `/app_data/apple/` with `/app_data/google/`.  
Use `app_id` in format `com.example.app` for Play Store.

---

### 7. App Info (ratings, metadata)

**Endpoint:** `/app_data/apple/app_info/task_post` (same task pattern)  
**Use for:** Getting full app metadata: rating, reviews count, description, screenshots info.

```bash
curl -s -X POST "https://api.dataforseo.com/v3/app_data/apple/app_info/task_post" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"app_id": "1436348671", "language_code": "en", "location_code": 2840}]'
```

---

### 8. Ranked Keywords for a Domain (Google)

**Endpoint:** POST `/dataforseo_labs/google/ranked_keywords/live`  
**Use for:** What keywords a domain currently ranks for on Google, with positions. Use on investwithbloom.com to see organic presence, or on competitors to spy their rankings.  
**Cost:** ~$0.011/domain

```bash
curl -s -X POST "https://api.dataforseo.com/v3/dataforseo_labs/google/ranked_keywords/live" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"target": "investwithbloom.com", "location_code": 2840, "language_code": "en", "limit": 50}]'
```

**Returns:** `result[0]['total_count']` = total keywords ranked. Items: `keyword_data.keyword`, `keyword_data.keyword_info.search_volume`, `ranked_serp_element.serp_item.rank_absolute` (position).

**Note:** investwithbloom.com currently ranks for 12 keywords, all brand-name queries. Use on competitor domains to find their traffic-driving terms.

---

### 9. Competitor Domains (Google)

**Endpoint:** POST `/dataforseo_labs/google/competitors_domain/live`  
**Use for:** Which domains compete with a target domain for the same keywords. Reveals SEO competitors you might not know about.  
**Cost:** ~$0.011/domain

```bash
curl -s -X POST "https://api.dataforseo.com/v3/dataforseo_labs/google/competitors_domain/live" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"target": "investwithbloom.com", "location_code": 2840, "language_code": "en", "limit": 20}]'
```

**Returns:** `items` list with `domain`, `intersections` (shared keyword count), `avg_position`.

---

### 10. App Store Keywords for an App

**Endpoint:** POST `/dataforseo_labs/apple/keywords_for_app/live`  
**Use for:** All App Store keywords a specific app ranks for, with positions and Google search volume. Essential for ASO audits.  
**Cost:** ~$0.012/app

```bash
curl -s -X POST "https://api.dataforseo.com/v3/dataforseo_labs/apple/keywords_for_app/live" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"app_id": "1436348671", "location_code": 2840, "language_code": "en", "limit": 100}]'
```

**Returns:** `result[0]['total_count']` = total ranked keywords. Items: `keyword_data.keyword`, `keyword_data.keyword_info.search_volume`, `ranked_serp_element.serp_item.rank_absolute` (App Store position).

**Bloom data:** Ranks for 2,663 App Store keywords. Appears at position 47 for "yahoo finance", 47 for "robinhood" — showing up in big-brand tail searches.

---

### 11. App Store Competitor Apps

**Endpoint:** POST `/dataforseo_labs/apple/app_competitors/live`  
**Use for:** Apps that compete with a target app for the same App Store keywords. Returns 13,000+ apps ranked by keyword overlap and average position.  
**Cost:** ~$0.011/app

```bash
curl -s -X POST "https://api.dataforseo.com/v3/dataforseo_labs/apple/app_competitors/live" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"app_id": "1436348671", "location_code": 2840, "language_code": "en", "limit": 20}]'
```

**Returns:** `result[0]['total_count']` = total competitors. Items: `app_id`, `title`, `avg_position` (their average rank across shared keywords).

**Bloom data:** 13,645 competitor apps. Bloom avg position: 61.5 vs Yahoo Finance: 4.8 — shows the gap to close.

---

### 12. AI Search Volume (queries made in AI tools)

**Endpoint:** POST `/ai_optimization/ai_keyword_data/keywords_search_volume/live`  
**Use for:** How often people ask AI tools (ChatGPT, Perplexity, etc.) about a topic. Different from Google volume — separate data set with 12-month trend.  
**Cost:** ~$0.003/keyword

```bash
curl -s -X POST "https://api.dataforseo.com/v3/ai_optimization/ai_keyword_data/keywords_search_volume/live" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"keywords": ["ai investing app", "stock research app"], "location_code": 2840, "language_code": "en"}]'
```

**Returns:** `result[0]['items']` list. Each item: `keyword`, `ai_search_volume` (current month), `ai_monthly_searches` (12 months).

**Interpretation:** AI volume is much lower than Google volume (135 vs 1,900 for "ai investing app") but growing fast — "ai investing app" grew +187% in a year. Use alongside Google volume to prioritize GEO content.

---

### 13. On-Page SEO Audit (content evaluator)

**Endpoint:** POST `/on_page/task_post` → GET `/on_page/summary` and `/on_page/pages`  
**Use for:** After publishing content — audit a URL or entire domain for on-page SEO issues: missing/weak title tags, meta descriptions, heading structure, keyword density, broken links, Core Web Vitals.  
**Cost:** ~$0.003/page crawled (+ extras for JS rendering, CWV)  
**Pattern:** Task-based (async). POST to queue, GET results after crawl completes.

**Step 1 — Queue crawl:**
```bash
curl -s -X POST "https://api.dataforseo.com/v3/on_page/task_post" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{
    "target": "https://mycrystalball.substack.com/p/your-article-slug",
    "max_crawl_pages": 1,
    "calculate_keyword_density": true,
    "enable_browser_rendering": true
  }]'
```

Save the task `id`.

**Step 2 — Get summary (once crawl finishes):**
```bash
curl -s -X GET "https://api.dataforseo.com/v3/on_page/summary/<TASK_ID>" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5"
```

**Step 3 — Get page-level details:**
```bash
curl -s -X POST "https://api.dataforseo.com/v3/on_page/pages" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"id": "<TASK_ID>", "limit": 10}]'
```

**Returns:** Per-page `checks` object with pass/fail on: title tag, meta description, H1 presence, duplicate content signals, broken links, image alt text, page speed, keyword density. Use as pre-publish or post-publish SEO checklist.

**Workflow:** Use after writing an article to confirm on-page fundamentals before or after publishing. Can also audit the full getbloom.app site by setting `target: "getbloom.app"` and `max_crawl_pages: 50`.

---

## Common Workflows

### "What's the search volume for these ASO keywords?"
→ Endpoint 1. Batch up to 700 keywords per call.

### "Find keyword ideas around [topic]"
→ Endpoint 2. Use 2–5 seed terms. Sort results by `search_volume` desc.

### "How hard is this keyword to rank for?"
→ Endpoint 3. Score <30 = easy, 30–60 = medium, >60 = hard.

### "Where does Bloom rank on Google for [keyword]?"
→ Endpoint 4. Search results for `getbloom.app` in `domain` field.

### "Where does Bloom rank in the App Store for [keyword]?"
→ Endpoint 5. Look for `app_id == "1436348671"` in results.

### "Who are Bloom's App Store competitors for [keyword]?"
→ Endpoint 5. Collect all `app_id` + `title` from results.

### "Build a keyword priority list for ASO"
→ Run endpoints 1 + 3. Cross-reference volume with difficulty. Target: high volume + low difficulty.

### "What keywords does investwithbloom.com rank for on Google?"
→ Endpoint 8 with `target: "investwithbloom.com"`. Currently 12 keywords, all brand-name.

### "What keywords is [competitor domain] ranking for?"
→ Endpoint 8 with their domain. Pull their top traffic terms to find content gaps.

### "Who are investwithbloom.com's SEO competitors?"
→ Endpoint 9 with `target: "investwithbloom.com"`. Returns domains with keyword overlap.

### "What App Store keywords does Bloom rank for?"
→ Endpoint 10 with `app_id: "1436348671"`. 2,663 keywords — sort by `rank_absolute` to see best positions.

### "Who are Bloom's App Store competitors?"
→ Endpoint 11. Returns apps by keyword overlap, sorted by avg position (lower = stronger competitor).

### "Evaluate the SEO of this article/page"
→ Endpoint 13. Pass the live URL. Checks title, meta, H1, keyword density, CWV, broken links. Use after publishing or as a pre-publish audit if the content is live on a staging URL.

### "Audit getbloom.app for technical SEO issues"
→ Endpoint 13 with `target: "getbloom.app"` and `max_crawl_pages: 50`. Get full site health report.

### "What's the AI search volume for these keywords?"
→ Endpoint 8. Compare `ai_search_volume` vs Google `search_volume` to find keywords gaining traction in AI tools ahead of Google. Growing AI volume = content opportunity before competition heats up.

---

## Cost Reference

| Operation | Cost |
|-----------|------|
| Keyword search volume (batch ≤700) | $0.075 |
| Keyword ideas | $0.075 |
| Keyword difficulty (per keyword) | ~$0.003 |
| Google SERP results | $0.002 |
| App Store search | $0.0012 |
| App info lookup | ~$0.001 |
| Ranked keywords for domain | ~$0.011 |
| Competitor domains (Google) | ~$0.011 |
| App Store keywords for app | ~$0.012 |
| App Store competitor apps | ~$0.011 |
| On-page audit (per page crawled) | ~$0.003 |
| AI search volume (per keyword) | ~$0.003 |

Current balance: ~$0.83. Top up at app.dataforseo.com → Add Funds.

## Common Mistakes

- **Wrong parse for keyword ideas:** result is a flat list — use `task['result']`, NOT `task['result'][0]['items']`
- **App Data uses task-based only** — no live endpoints. Must POST then GET.
- **Task GET URL format:** use `task_get/advanced/<id>`, not just `task_get/<id>`
- **tasks_ready returns endpoint_advanced path** — use that path directly for step 3
