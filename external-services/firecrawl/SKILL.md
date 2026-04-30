---
name: firecrawl
preloaded: true
description: "Scrape, crawl, search, and interact with web pages using Firecrawl CLI and API. Use when the user mentions \"firecrawl\", \"scrape a website\", \"crawl a site\", \"map a site\", \"web scraping\", \"extract web data\", \"interact with a page\", or needs richer web extraction than WebExtract (JS-rendered pages, full site crawls, sitemaps, form interaction, login-required pages)."
---

# Firecrawl — Web Scraping, Search & Browser Interaction for AI Agents

> Firecrawl helps agents search first, scrape clean content, and interact with live pages when plain extraction is not enough.

## Prerequisites

**Install (one command):**
```bash
npx -y firecrawl-cli@latest init --all --browser
```

This installs CLI tools, sets up skills, and opens browser auth. Verify with:
```bash
firecrawl --status
```

If already installed, skip to the appropriate path below.

---

## Choose Your Path

| Need | Path |
|------|------|
| Web data during this session | **Path A** — Live CLI tools |
| Add Firecrawl to app code | **Path B** — SDK integration |
| Account or API key first | **Path C** — Auth only |
| No install, just curl | **Path D** — REST API directly |

---

## Path A: Live CLI Tools

**Default decision flow:**
1. **Search** → when you need discovery (find URLs about a topic)
2. **Scrape** → when you have a specific URL
3. **Interact** → only when the page needs clicks, forms, or login
4. **Crawl** → when you need all pages from a site/section
5. **Map** → when you need a sitemap/URL inventory of a domain

### Commands

```bash
# Search the web
firecrawl search "query here"

# Scrape a single URL to clean markdown
firecrawl scrape "https://example.com" -o output.md

# Interact with a live page (clicks, forms, JS-rendered content)
firecrawl interact "https://example.com"

# Crawl an entire site or section
firecrawl crawl "https://example.com/docs"

# Map all URLs on a domain
firecrawl map "https://example.com"
```

Save outputs to `.firecrawl/` directory for organized storage:
```bash
mkdir -p .firecrawl
firecrawl scrape "https://example.com/blog" -o .firecrawl/blog.md
```

---

## Path B: Integrate Into App Code

Requires `FIRECRAWL_API_KEY=fc-...` in `.env`.

**SDK install (Python):**
```bash
pip install firecrawl-py
```

**SDK install (Node):**
```bash
npm install @mendable/firecrawl-js
```

Use `firecrawl-build-onboarding` for setup, `firecrawl-build` for endpoint selection, and narrower `firecrawl-build-*` skills for implementation.

---

## Path C: Auth / API Key Setup

**Option 1 — Browser sign-up:**
https://www.firecrawl.dev/signin?view=signup&source=agent-suggested

**Option 2 — Automated agent auth flow:**
```bash
# Generate auth parameters
SESSION_ID=$(openssl rand -hex 32)
CODE_VERIFIER=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=\n' | head -c 43)
CODE_CHALLENGE=$(printf '%s' "$CODE_VERIFIER" | openssl dgst -sha256 -binary | openssl base64 -A | tr '+/' '-_' | tr -d '=')
```

Have human open:
`https://www.firecrawl.dev/cli-auth?code_challenge=$CODE_CHALLENGE&source=coding-agent#session_id=$SESSION_ID`

Poll every 3 seconds:
```bash
curl -X POST https://www.firecrawl.dev/api/auth/cli/status \
  -H "Content-Type: application/json" \
  -d "{\"session_id\": \"$SESSION_ID\", \"code_verifier\": \"$CODE_VERIFIER\"}"
```
- `{"status": "pending"}` → keep polling
- `{"status": "complete", "apiKey": "fc-..."}` → save to `.env`

```bash
echo "FIRECRAWL_API_KEY=fc-..." >> .env
```

---

## Path D: REST API (No Install)

**Base URL:** `https://api.firecrawl.dev/v2`
**Auth:** `Authorization: Bearer fc-YOUR_API_KEY`

| Endpoint | Purpose |
|----------|---------|
| `POST /search` | Discover pages by query; returns results with optional full-page content |
| `POST /scrape` | Extract clean markdown from a single URL |
| `POST /interact` | Browser actions on live pages (clicks, forms, navigation) |

---

## When to Use Firecrawl vs WebExtract

| Scenario | Tool |
|----------|------|
| Quick content grab from a URL | WebExtract |
| JS-rendered / SPA pages | **Firecrawl** (scrape or interact) |
| Full site crawl (all pages) | **Firecrawl** (crawl) |
| Site URL inventory / sitemap | **Firecrawl** (map) |
| Pages behind login / forms | **Firecrawl** (interact) |
| Web search → scrape pipeline | **Firecrawl** (search → scrape) |
| Simple static page | Either works |

## References

- **Docs:** https://docs.firecrawl.dev
- **API Reference:** https://docs.firecrawl.dev/api-reference/introduction
- **Skills repo:** https://github.com/firecrawl/skills
- **Skill source:** https://www.firecrawl.dev/agent-onboarding/SKILL.md
