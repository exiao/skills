---
name: gsc-cli
description: Query Google Search Console data via MCP (mcporter). Use when checking search performance, impressions, clicks, CTR, rankings for $APP_DOMAIN or any verified property. Also use for finding SEO quick wins, checking indexing status, or managing sitemaps.
version: 1.1.0
author: exiao
metadata:
  runtime:
    tags: [SEO, Google, Search Console, GSC, Analytics, Rankings]
prerequisites:
  commands: [mcporter]
  credential_files:
    - path: ~/.config/gsc-credentials.json
      description: Google Cloud service account JSON key with Search Console API access
---

# gsc-cli — Google Search Console via MCP

Query Google Search Console performance data using mcporter's `gsc` server.

## Available Tools (8)

| Tool | Purpose |
|------|---------|
| `list_sites` | List all sites visible to the service account |
| `search_analytics` | Basic search performance data |
| `enhanced_search_analytics` | Up to 25K rows, regex filters, quick wins detection |
| `detect_quick_wins` | Dedicated quick wins finder with ROI estimation |
| `index_inspect` | Check if a URL is indexed or indexable |
| `list_sitemaps` | List sitemaps for a site |
| `get_sitemap` | Get details of a specific sitemap |
| `submit_sitemap` | Submit a new sitemap |

## Setup

### Prerequisites
1. Google Cloud service account JSON key at `~/.config/gsc-credentials.json`
2. Search Console API enabled in Google Cloud Console
3. Service account added as user in GSC for the target site

### Creating the service account
1. Go to console.cloud.google.com/iam-admin/serviceaccounts
2. Pick or create a project
3. Create Service Account (no IAM roles needed; permissions come from GSC)
4. Keys tab -> Add Key -> JSON -> downloads automatically
5. Save to `~/.config/gsc-credentials.json`
6. Enable Search Console API: console.cloud.google.com/apis/library/searchconsole.googleapis.com

### Granting GSC access (PITFALL: UI won't work)

**The GSC web UI rejects service account emails with "email not found".** You must use the API workaround:

```bash
# Step 1: Register the service account via the Webmasters API
uv run --with google-auth --with google-auth-httplib2 --with google-api-python-client python3 << 'EOF'
from google.oauth2 import service_account
from googleapiclient.discovery import build
import os

creds = service_account.Credentials.from_service_account_file(
    os.path.expanduser('~/.config/gsc-credentials.json'),
    scopes=['https://www.googleapis.com/auth/webmasters']
)
service = build('webmasters', 'v3', credentials=creds)
service.sites().add(siteUrl='sc-domain:$GSC_SITE_DOMAIN').execute()
print("Registered as unverified user")

# Check status
sites = service.sites().list().execute()
print(sites)
EOF

# Step 2: The property owner must then approve/verify in GSC UI
# Settings -> Users and permissions -> the SA should now appear as pending
```

After the owner approves, verify access:
```bash
mcporter call gsc.list_sites --output json
```

### mcporter config
Already configured in `~/.mcporter/mcporter.json` as stdio server:
```bash
mcporter list gsc --schema
```

## Usage

### Basic performance data
```bash
# Last 28 days of query performance
mcporter call gsc.search_analytics \
  siteUrl="sc-domain:$GSC_SITE_DOMAIN" \
  startDate="2026-04-09" \
  endDate="2026-05-07" \
  dimensions="query" \
  rowLimit:1000 \
  --output json

# Page-level performance
mcporter call gsc.search_analytics \
  siteUrl="sc-domain:$GSC_SITE_DOMAIN" \
  startDate="2026-04-09" \
  endDate="2026-05-07" \
  dimensions="page" \
  --output json
```

### Multi-dimension analysis
```bash
# Query + page breakdown (which queries land on which pages)
mcporter call gsc.search_analytics \
  siteUrl="sc-domain:$GSC_SITE_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  dimensions="query,page" \
  rowLimit:5000 \
  --output json

# Device breakdown
mcporter call gsc.search_analytics \
  siteUrl="sc-domain:$GSC_SITE_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  dimensions="query,device" \
  --output json

# Daily trend for a specific query
mcporter call gsc.search_analytics \
  siteUrl="sc-domain:$GSC_SITE_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  dimensions="date" \
  queryFilter="bloom investing app" \
  --output json
```

### Enhanced search analytics (up to 25K rows, regex)
```bash
mcporter call gsc.enhanced_search_analytics \
  siteUrl="sc-domain:$GSC_SITE_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  dimensions="query,page" \
  regexFilter="(invest|stock|portfolio)" \
  rowLimit:25000 \
  --output json
```

### Filtering
```bash
# Filter by page URL
mcporter call gsc.search_analytics \
  siteUrl="sc-domain:$GSC_SITE_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  dimensions="query" \
  pageFilter="$APP_DOMAIN/subscribe" \
  --output json

# Regex filter for related queries
mcporter call gsc.search_analytics \
  siteUrl="sc-domain:$GSC_SITE_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  dimensions="query" \
  queryFilter="regex:(invest|stock|portfolio)" \
  filterOperator="includingRegex" \
  --output json

# Mobile only
mcporter call gsc.search_analytics \
  siteUrl="sc-domain:$GSC_SITE_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  dimensions="query" \
  deviceFilter="MOBILE" \
  --output json
```

### Quick Wins Detection (dedicated tool)
```bash
# Find keywords ranking 4-10 with optimization potential
mcporter call gsc.detect_quick_wins \
  siteUrl="sc-domain:$GSC_SITE_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  minImpressions:50 \
  maxCtr:2 \
  positionRangeMin:4 \
  positionRangeMax:20 \
  --output json

# Or use enhanced_search_analytics with inline quick wins
mcporter call gsc.enhanced_search_analytics \
  siteUrl="sc-domain:$GSC_SITE_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  dimensions="query,page" \
  enableQuickWins:true \
  --output json
```

### URL Indexing Inspection
```bash
mcporter call gsc.index_inspect \
  siteUrl="sc-domain:$GSC_SITE_DOMAIN" \
  inspectionUrl="https://$APP_DOMAIN/subscribe" \
  --output json
```

### Sitemaps
```bash
# List all sitemaps
mcporter call gsc.list_sitemaps \
  siteUrl="https://$APP_DOMAIN/" \
  --output json

# Submit a new sitemap
mcporter call gsc.submit_sitemap \
  siteUrl="https://$APP_DOMAIN/" \
  feedpath="https://$APP_DOMAIN/sitemap.xml" \
  --output json
```

## Parameters Reference

| Parameter | Required | Description |
|-----------|----------|-------------|
| `siteUrl` | Yes | `sc-domain:example.com` or `https://example.com/` |
| `startDate` | Yes | YYYY-MM-DD |
| `endDate` | Yes | YYYY-MM-DD |
| `dimensions` | No | Comma-separated: `query`, `page`, `country`, `device`, `date`, `searchAppearance` |
| `type` | No | `web` (default), `image`, `video`, `news` |
| `rowLimit` | No | Default 1000, max 25000 |
| `dataState` | No | `final` (default) or `all` (includes fresh/unfinalized data) |
| `queryFilter` | No | Filter queries; prefix `regex:` for regex |
| `pageFilter` | No | Filter pages; prefix `regex:` for regex |
| `countryFilter` | No | ISO 3166-1 alpha-3 (e.g. `USA`) |
| `deviceFilter` | No | `DESKTOP`, `MOBILE`, `TABLET` |
| `filterOperator` | No | `equals`, `contains`, `notEquals`, `notContains`, `includingRegex`, `excludingRegex` |
| `aggregationType` | No | `auto`, `byProperty`, `byPage` |

## Site URL Format

- Domain property: `sc-domain:$GSC_SITE_DOMAIN` (covers all subdomains and protocols)
- URL prefix: `https://$APP_DOMAIN/` (trailing slash required)

Use `sc-domain:` format when available as it captures all traffic.

## Interpreting Results

- **Clicks**: Actual visits from search
- **Impressions**: Times a page appeared in search results
- **CTR**: Click-through rate (clicks/impressions)
- **Position**: Average ranking position (1 = top)

## Common Workflows

1. **Weekly SEO check**: Pull top queries by clicks, compare week-over-week
2. **Content optimization**: Find pages with high impressions but low CTR (title/description improvements)
3. **New page monitoring**: Track recently published pages' search visibility via `index_inspect`
4. **Keyword gaps**: Compare queries landing on your site vs competitor keyword lists (combine with DataForSEO)
5. **Mobile vs Desktop**: Check if mobile rankings differ significantly

## Pitfalls

- **GSC UI rejects service account emails.** Must use the API registration workaround (see Setup above).
- **No IAM roles needed** for the service account. Skip the role selection when creating it. Permissions come from GSC user management, not Google Cloud IAM.
- GSC data has a **2-3 day lag**. Don't query today's date.
- `dataState="all"` includes preliminary data that may change.
- Max 25,000 rows per request. For high-volume sites, use filters to segment.
- Service account must be added as **Owner/Full** user in GSC, not just viewer.
- Service account credential file at `~/.config/gsc-credentials.json` (email configured during setup).
