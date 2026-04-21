---
name: prometheus
description: Use when researching App Store competitors, viral hooks, TikTok/Instagram video trends, app strategy, hook intelligence, creator accounts, app rankings, reviews, or Social Growth Engineers (SGE) articles. Triggers on "prometheus", "SGE", "social growth engineers", "hook trends for app", "viral videos for app", "App Store rankings", "compare app strategies", "what hooks are working for [app]", "creator accounts for [app]", "analyze TikTok video for ASO".
---

# Passistant (Social Growth Engineers)

App Store + UGC intelligence. Powered by SGE's MCP server, accessed via `mcporter`.

Three data layers:

- **SGE content** — articles, videos, content analytics from socialgrowthengineers.com.
- **AST (App Store Tracker)** — live App Store data: rankings, reviews, similar apps, ranking history.
- **Hook intelligence** — viral hook patterns from TikTok/Instagram, scoped by app, vertical, or market.

## Setup

The `SGE_API_KEY` variable must be present in the agent environment. The mcporter server config at `~/.mcporter/mcporter.json` references it via `${SGE_API_KEY}`. In Hermes the key is auto-loaded at startup — no manual export needed.

Verify connection:

```bash
mcporter list prometheus 2>&1 | grep -c "^  function"   # should print 25
```

If that prints `0`, the key is missing or the server is down. Run `mcporter call prometheus.search_apps query=test --output json` to see the full error.

## Calling pattern (always)

```bash
mkdir -p /tmp/prometheus
mcporter call prometheus.<tool> key=value key2:5 --output json > /tmp/prometheus/<file>.json
```

Then `jq` the output. Always download to file — responses are large (especially `hook_intelligence`, `app_strategy`, `generate_report`).

**Argument syntax:**
- `key=value` for strings: `query="duolingo"`
- `key:value` for numbers/bools: `limit:10`, `app_store_id:570060128`
- For deeply nested args: `--args '{"key": "value"}'`

## Tools

### App Store Tracker (live App Store)

| Tool | Use |
|------|-----|
| `ast_search_apps` | Find apps by query. `query` required, optional `country`, `category_id`, `limit` |
| `ast_get_app_details` | Full metadata for an app. `app_id` required |
| `ast_get_rankings` | Top charts. Optional `country`, `category_id`, `limit` (1-200) |
| `ast_get_similar_apps` | Apple's "similar to" list. `app_id` required |
| `ast_get_reviews` | Recent reviews. `app_id` required, optional `limit` (1-50) |
| `ast_get_categories` | List all App Store category IDs |
| `ast_get_ranking_history` | Daily rank history. `app_id` required, optional `days` (1-90) |

### SGE content

| Tool | Use |
|------|-----|
| `search_articles` | Hybrid semantic+lexical article search. `query` required |
| `search_apps` | Search SGE's app coverage. `query` required (≥2 chars) |
| `get_article` | Full article by `slug`. Optional `includeRelated` |
| `list_articles` | Paginated list. Use `cursor` for next page |
| `list_apps` | Paginated app list, optional `category` |
| `get_categories` | All SGE category names |
| `get_similar_articles` | By article `slug` |
| `get_similar_apps` | By `appStoreId` (uses v2 embeddings) |
| `get_content_analytics` | Article performance. Optional `slug`, `dateFrom`, `dateTo`, `limit` |

### Video / hook intelligence (the high-value tools)

| Tool | Use |
|------|-----|
| `search_videos` | Find UGC. `query` required + filters: `platform`, `author`, `minViews:N`, `dateFrom`, `appStoreId:N` |
| `get_similar_videos` | By `videoId` (UUID) |
| `analyze_video` | Single TikTok/IG URL → hook breakdown |
| `app_accounts` | Creator accounts posting about an app. `app_store_id` required |
| `hook_intelligence` | Top hooks for a scope. `scope_type` ∈ `app`/`vertical`/`market` (required) |
| `hook_trends` | Trend deltas between two date windows. Same scope args + `current_date_from/to` and `compare_date_from/to` |
| `strategy_compare` | A/B compare two apps or verticals. Set `left_*` and `right_*` scope args |
| `app_strategy` | Full UGC strategy for an app. `app_store_id` or `app_name` |
| `generate_report` | Long-form research report. `query` required |

## Patterns

### Find an app's App Store ID
```bash
mkdir -p /tmp/prometheus
mcporter call prometheus.ast_search_apps query="Bloom investing" limit:5 --output json \
  > /tmp/prometheus/search.json
jq '._data[]? // .content' /tmp/prometheus/search.json
```

### Hook intelligence for a specific app (the killer feature)
```bash
mcporter call prometheus.hook_intelligence \
  scope_type=app \
  scope_app_store_id:1573446144 \
  objective=virality \
  limit:50 \
  --output json > /tmp/prometheus/hooks.json

# Pull just the top hook patterns
jq -r '.content[0].text' /tmp/prometheus/hooks.json | head -100
```

### Compare two apps
```bash
mcporter call prometheus.strategy_compare \
  left_scope_type=app left_app_store_id:1573446144 left_label="Bloom" \
  right_scope_type=app right_app_store_id:1175706108 right_label="Public" \
  --output json > /tmp/prometheus/compare.json
```

### Trending hooks in a vertical (last 14d vs prior 14d)
```bash
mcporter call prometheus.hook_trends \
  scope_type=vertical \
  scope_primary_vertical=finance \
  current_date_from=2026-04-05 current_date_to=2026-04-19 \
  compare_date_from=2026-03-22 compare_date_to=2026-04-04 \
  --output json > /tmp/prometheus/trends.json
```

### Pull viral videos for an app
```bash
mcporter call prometheus.search_videos \
  query="*" appStoreId:1573446144 minViews:100000 limit:25 \
  --output json > /tmp/prometheus/videos.json

jq '._data[] | {author, views, url, hook: .transcript[0:120]}' /tmp/prometheus/videos.json
```

### Analyze a single TikTok URL
```bash
mcporter call prometheus.analyze_video url="https://www.tiktok.com/@user/video/123456" --output json
```

### Find creators posting about an app
```bash
mcporter call prometheus.app_accounts app_store_id:1573446144 platform=tiktok limit:50 --output json
```

## Notes

- Output structure: `{ content: [{ type: 'text', text: '...' }], _data: [...] }`. The `text` field is human-readable summary; `_data` is structured. Prefer `_data` for piping.
- `hook_intelligence` and `app_strategy` are 5K-50K tokens — always pipe to file, then narrow with `jq`.
- For pagination on `search_videos`/`search_articles`: increment `offset` by `limit`.
- Country codes are ISO-3166 two-letter (`us`, `gb`, `de`, etc.).
- App Store category IDs: call `ast_get_categories` once and cache.
- Scope args for hook tools: pick **one** of `scope_app_store_id`, `scope_app_name`, or `scope_primary_vertical` per call.
- This skill is the recommended interface to Passistant. Once verified, the user can disable the `mcp_prometheus_*` native MCP tools to free context tokens.
