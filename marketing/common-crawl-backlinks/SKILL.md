---
name: common-crawl-backlinks
description: "Use when pulling backlinks for any domain for free using Common Crawl's web graph — instead of paying for Ahrefs/Majestic/SEMrush. Triggers on 'backlinks for', 'who links to', 'backlink check', 'common crawl backlinks', 'free backlinks', or any backlink discovery task. Replaces $hundreds/mo SEO tools with a local DuckDB query."
---

# Common Crawl Backlinks

Pull every domain that links to any target domain — for free — using Common Crawl's hyperlink web graph and DuckDB. Based on [Ben Word's gist](https://gist.github.com/retlehs/cf0ac6c74476e766fba2f14076fff501) (April 2026).

**Why this exists:** Ahrefs/Majestic/SEMrush charge hundreds per month for backlink data. Common Crawl publishes a quarterly domain-level web graph (vertices + edges) for free. With DuckDB you can scan ~16 GB of gzipped edges and get inbound link domains in a few minutes.

---

## When to Use

| Task | Use This |
|------|----------|
| "Who links to roots.io?" | This skill |
| "Backlinks for stripe.com" | This skill |
| "Find competitor backlinks" | This skill (run on competitor domain) |
| "How many domains link to us?" | This skill (count rows in output) |
| Search volume / keyword difficulty | `seo-research` skill |
| SERP rank tracking | `seo-research` skill |

---

## Prerequisites

```bash
# Install duckdb (one-time)
brew install duckdb
```

The script lives at `~/Downloads/backlinks.sh` (or copy from `assets/backlinks.sh` in this skill). It's also reproduced in [the gist](https://gist.github.com/retlehs/cf0ac6c74476e766fba2f14076fff501).

---

## Quick Start

```bash
# Default: example.com
~/Downloads/backlinks.sh

# Specific domain
~/Downloads/backlinks.sh roots.io

# Override Common Crawl release (default: cc-main-2026-jan-feb-mar)
CC_RELEASE=cc-main-2025-oct-nov-dec ~/Downloads/backlinks.sh stripe.com
```

**First run:**
- Downloads ~16 GB of gzipped data into `~/.cache/cc-backlinks/<release>/`
- Query takes several minutes (full edge scan)
- Subsequent queries against cached data are much faster

**Output:** A sorted table of `linking_domain | num_hosts` (more hosts = bigger linking site).

---

## How It Works

1. **Reverse the input domain**: `roots.io` → `io.roots` (Common Crawl stores domains reversed for sort locality)
2. **Download two files** from `data.commoncrawl.org/projects/hyperlinkgraph/<release>/domain/`:
   - `domain-vertices.txt.gz` — `(id, reversed_domain, num_hosts)`
   - `domain-edges.txt.gz` — `(from_id, to_id)`
3. **DuckDB query**:
   - Find the target's vertex ID
   - Filter edges where `to_id = target.id`
   - Join back to vertices to get linking domains
   - Sort by `num_hosts` desc

---

## Common Recipes

### Save output to CSV
```bash
~/Downloads/backlinks.sh stripe.com 2>/dev/null | \
  awk '/^│/ && !/linking_domain/ {gsub(/[│ ]/,""); print}' > stripe-backlinks.csv
```

### Compare against a competitor (gap analysis)
```bash
~/Downloads/backlinks.sh yourdomain.com  > yours.txt
~/Downloads/backlinks.sh competitor.com > theirs.txt
# Domains linking to them but not you:
comm -13 <(sort yours.txt) <(sort theirs.txt)
```

### Batch run multiple domains
```bash
for d in roots.io stripe.com vercel.com; do
  echo "=== $d ===" >> backlinks-report.txt
  ~/Downloads/backlinks.sh "$d" >> backlinks-report.txt
done
```

### Count total linking domains
```bash
~/Downloads/backlinks.sh roots.io 2>/dev/null | grep -c '^│'
```

---

## Caveats

- **Domain-level only.** No URL-level backlinks (no anchor text, no source page). For that, use Common Crawl's WAT/WET files directly — much heavier lift.
- **Coverage gap vs Ahrefs.** Common Crawl misses sites that block its crawler (`CCBot`). Expect ~60-70% of what a paid tool would show.
- **Quarterly release cadence.** Set `CC_RELEASE` to a different quarter for historical comparison. Releases live at https://commoncrawl.org/web-graphs.
- **No nofollow/dofollow distinction.** The graph is link presence, not link quality.
- **Cache is per-release.** Switching `CC_RELEASE` triggers a fresh ~16 GB download.

---

## Available Releases

Check https://commoncrawl.org/web-graphs for the current list. Pattern is `cc-main-YYYY-mon-mon-mon`, e.g.:

- `cc-main-2026-jan-feb-mar` (default)
- `cc-main-2025-oct-nov-dec`
- `cc-main-2025-jul-aug-sep`

---

## Pipeline Position

```
common-crawl-backlinks (find linking domains)
         ↓
seo-research (analyze the linking domains: traffic, topics, contact info)
         ↓
outreach / link-building campaign
```

Or use it standalone for competitive intelligence: which sites link to your competitor that don't link to you?

---

## Reference

- **Original gist:** https://gist.github.com/retlehs/cf0ac6c74476e766fba2f14076fff501
- **Ben Word's tweet:** https://x.com/retlehs/status/2045169132748877992
- **Common Crawl web graphs:** https://commoncrawl.org/web-graphs
- **DuckDB docs:** https://duckdb.org/docs/

---

## Related Skills

- **seo-research** — keyword research, AI search optimization, technical audits
- **dataforseo** — paid keyword/SERP data when you need richer link metrics
- **firecrawl** — scrape the linking pages once you have the domain list
