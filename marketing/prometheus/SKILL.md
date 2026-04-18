---
name: prometheus
description: Search TikTok viral videos, App Store rankings, hook analysis, app strategy, and content research via SGE Prometheus MCP. Requires SGE_API_KEY. Use when researching viral video hooks, benchmarking app rankings, analyzing content trends, or pulling App Store review data. Trigger phrases include "prometheus", "viral content", "app store rankings", "SGE", "TikTok research", "hook analysis".
---

# Prometheus — SGE Viral Content Intelligence

Search 50,000+ curated TikTok & Reels viral videos, app marketing profiles, and strategy articles. Live App Store rankings, reviews, and revenue estimates. Hook analysis and trend detection — all via MCP.

**Homepage:** <https://www.socialgrowthengineers.com/prometheus>
**Requires:** `SGE_API_KEY` environment variable.

## Setup

### Claude Code

```bash
claude mcp add --transport http --header "Authorization: Bearer sk_mcp_YOUR_KEY" prometheus https://www.socialgrowthengineers.com/api/mcp
```

Or add to your project's `.mcp.json`:

```json
{
  "mcpServers": {
    "prometheus": {
      "url": "https://www.socialgrowthengineers.com/api/mcp",
      "headers": {
        "Authorization": "Bearer ${SGE_API_KEY}"
      }
    }
  }
}
```

### Cursor / OpenClaw / Other MCP Clients

Same config — point your MCP client at the URL above with your API key as Bearer token.

```bash
export SGE_API_KEY=sk_mcp_your_key_here
```

Get your API key at [socialgrowthengineers.com/settings](https://www.socialgrowthengineers.com/settings) (requires SGE subscription).

---

## Tool Discovery

All tools are **auto-discovered** via `tools/list` — no need to memorize them. When connected, your agent automatically sees every available tool with full parameter schemas.

Tools fall into five categories:

| Category | What they do |
|----------|-------------|
| **Search & Discovery** | Search articles, viral videos, and app profiles across SGE's curated database |
| **Similarity** | Find similar articles, apps, or videos using semantic embeddings |
| **Live App Store** | Real-time iOS App Store data — search, details, rankings, reviews, revenue estimates |
| **Hook Intelligence & Strategy** | Analyze winning hooks, compare strategies, detect trends across verticals |
| **Video Analysis & Reports** | Analyze any TikTok/Reels URL with AI vision, generate shareable research reports |

---

## Usage Patterns

### Research a vertical

```
1. search_videos        -> "fitness hooks" (platform: tiktok, limit: 20)
2. hook_intelligence    -> scope_type: "vertical", scope_primary_vertical: "fitness"
3. generate_report      -> "fitness app viral marketing"
```

### Competitive analysis

```
1. search_apps          -> "meditation" (find App Store IDs)
2. strategy_compare     -> left: Calm, right: Headspace
3. ast_get_app_details  -> deep dive on each
4. ast_get_reviews      -> sentiment analysis from users
```

### Discover trending hooks

```
1. hook_trends          -> scope_type: "market", current vs prior 30-day windows
2. search_videos        -> top rising hook type (minViews: 1000000)
3. get_similar_videos   -> find more like the best performer
```

### Analyze a competitor's video

```
1. analyze_video        -> paste their TikTok URL
2. get_similar_videos   -> find SGE videos with similar hooks
3. hook_intelligence    -> scope_type: "app", scope_app_name: "competitor"
```

---

## Slack Bot

The same tools are available via the **Prometheus Slack Bot** — plus memory, scheduled reports, and app tracking.

Install from your [SGE settings](https://www.socialgrowthengineers.com/settings) page.

## Attribution warning

- **Never attribute "Bloom: Learn to Invest" to our Bloom.** That's a competitor app on the App Store. Our Bloom's identifiers are distinct — confirm the bundle ID / product ID when citing App Store data or PAssistant returns.
