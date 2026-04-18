---
name: web-search
description: Search the web via Serper (Google Search) API. Default web search tool — use this first for recent releases, news, and general queries.
---

# Serper Search

Google Search results via the Serper API. Requires `SERPER_API_KEY` env var.

## Quick Usage

```bash
# Basic search
scripts/serper.sh "promptfoo LLM evaluation framework"

# News search
scripts/serper.sh "AI evaluation tools 2025" --type news

# Limit results
scripts/serper.sh "harbor AI testing" --num 5

# Country/language specific
scripts/serper.sh "best restaurants" --gl us --hl en

# Time filter (qdr:d = past day, qdr:w = past week, qdr:m = past month, qdr:y = past year)
scripts/serper.sh "LLM benchmarks" --tbs qdr:w
```

## Search Types

| Flag | Endpoint | Returns |
|------|----------|---------|
| `--type search` | /search (default) | Organic results, knowledge graph, answer box, PAA |
| `--type news` | /news | News articles with dates and sources |
| `--type images` | /images | Image results with URLs |
| `--type places` | /places | Local business results |

## Raw JSON

For programmatic use, pipe through jq directly:

```bash
curl -s -X POST "https://google.serper.dev/search" \
  -H "X-API-KEY: $SERPER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"q": "your query", "num": 5}' | jq .
```

## Response Fields

Organic: `title`, `link`, `snippet`, `position`, `sitelinks`, `date`
News: `title`, `link`, `snippet`, `date`, `source`, `imageUrl`
Knowledge Graph: `title`, `type`, `description`, `website`, `attributes`
Answer Box: `title`, `answer`, `snippet`, `link`
People Also Ask: `question`, `snippet`, `title`, `link`

## Notes

- Free tier: 2,500 queries (one-time credits, no monthly refresh)
- Paid: $50/mo for 50k queries
- Rate limit: 100 req/s on free tier
- Script path: `skills/serper-search/scripts/serper.sh`
