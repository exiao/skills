# Security & Permissions

**What this skill does:**
- Sends search queries to OpenAI's Responses API (`api.openai.com`) for Reddit discovery
- Sends search queries to Twitter's GraphQL API (via browser cookie auth) or xAI's API (`api.x.ai`) for X search
- Runs `yt-dlp` locally for YouTube search and transcript extraction (no API key, public data)
- Optionally sends search queries to Brave Search API, Parallel AI API, or OpenRouter API for web search
- Fetches public Reddit thread data from `reddit.com` for engagement metrics
- Stores research findings in local SQLite database (watchlist mode only)

**What this skill does NOT do:**
- Does not post, like, or modify content on any platform
- Does not access your Reddit, X, or YouTube accounts
- Does not share API keys between providers (OpenAI key only goes to api.openai.com, etc.)
- Does not log, cache, or write API keys to output files
- Does not send data to any endpoint not listed above
- Cannot be invoked autonomously by the agent (`disable-model-invocation: true`)

**Bundled scripts:** `scripts/last30days.py` (main research engine), `scripts/lib/` (search, enrichment, rendering modules), `scripts/lib/vendor/bird-search/` (vendored X search client, MIT licensed)

Review scripts before first use to verify behavior.
