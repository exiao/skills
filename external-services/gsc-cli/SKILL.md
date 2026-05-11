---
name: gsc-cli
description: Query Google Search Console data via MCP (mcporter). Use when checking search performance, impressions, clicks, CTR, rankings for $APP_DOMAIN or any verified property. Also use for finding SEO quick wins, checking indexing status, or managing sitemaps.
---

# gsc-cli — Google Search Console via MCP

Query Google Search Console performance data using mcporter's `gsc` server.

## Available Tools (8)

| Tool | Purpose |
|------|---------|
| `list_sites` | List all sites visible to the authenticated Google identity |
| `search_analytics` | Basic search performance data |
| `enhanced_search_analytics` | Up to 25K rows, regex filters, quick wins detection |
| `detect_quick_wins` | Dedicated quick wins finder with ROI estimation |
| `index_inspect` | Check if a URL is indexed or indexable |
| `list_sitemaps` | List sitemaps for a site |
| `get_sitemap` | Get details of a specific sitemap |
| `submit_sitemap` | Submit a new sitemap |

## Setup

### Prerequisites
1. Google credential file at `~/.config/gsc-credentials.json`
2. Search Console API enabled in Google Cloud Console
3. The authenticated Google identity has access to the GSC property

### Recommended auth: user's Google account OAuth

Use OAuth when the user already owns the GSC properties. The MCP server's `GoogleAuth({ keyFile })` accepts `authorized_user` credential JSON, even though the package docs only mention service accounts.

Fast path with gcloud:
```bash
gcloud auth application-default login \
  --scopes=https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/webmasters.readonly

# Copy or symlink ADC to the file mcporter expects
cp ~/.config/gcloud/application_default_credentials.json ~/.config/gsc-credentials.json
```

Then edit `~/.config/gsc-credentials.json` and ensure it contains a quota project:
```json
{
  "type": "authorized_user",
  "client_id": "...",
  "client_secret": "...",
  "refresh_token": "...",
  "quota_project_id": "<google-cloud-project-id>"
}
```

If `quota_project_id` is missing, `mcporter call gsc.list_sites` fails with:
`searchconsole.googleapis.com API requires a quota project`.

### Alternate auth: service account

Service accounts work poorly with GSC because the web UI may reject service account emails with `email not found`. If OAuth is available, prefer OAuth.

If service account auth is still required:
1. Go to console.cloud.google.com/iam-admin/serviceaccounts
2. Pick or create a project
3. Create Service Account (no IAM roles needed; GSC permissions are separate)
4. Keys tab -> Add Key -> JSON
5. Save to `~/.config/gsc-credentials.json`
6. Enable Search Console API for the project
7. Try adding the service account in GSC Settings -> Users and permissions. If the UI rejects it, switch to OAuth instead. The API self-registration workaround can leave the service account as `siteUnverifiedUser`, which still cannot query analytics.

Verify access:
```bash
mcporter call gsc.list_sites --output json
```

OAuth/auth troubleshooting details are in `references/oauth-auth.md`.

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
  siteUrl="sc-domain:$APP_DOMAIN" \
  startDate="2026-04-09" \
  endDate="2026-05-07" \
  dimensions="query" \
  rowLimit:1000 \
  --output json

# Page-level performance
mcporter call gsc.search_analytics \
  siteUrl="sc-domain:$APP_DOMAIN" \
  startDate="2026-04-09" \
  endDate="2026-05-07" \
  dimensions="page" \
  --output json
```

### Multi-dimension analysis
```bash
# Query + page breakdown (which queries land on which pages)
mcporter call gsc.search_analytics \
  siteUrl="sc-domain:$APP_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  dimensions="query,page" \
  rowLimit:5000 \
  --output json

# Device breakdown
mcporter call gsc.search_analytics \
  siteUrl="sc-domain:$APP_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  dimensions="query,device" \
  --output json

# Daily trend for a specific query
mcporter call gsc.search_analytics \
  siteUrl="sc-domain:$APP_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  dimensions="date" \
  queryFilter="bloom investing app" \
  --output json
```

### Enhanced search analytics (up to 25K rows, regex)
```bash
mcporter call gsc.enhanced_search_analytics \
  siteUrl="sc-domain:$APP_DOMAIN" \
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
  siteUrl="sc-domain:$APP_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  dimensions="query" \
  pageFilter="$APP_DOMAIN/subscribe" \
  --output json

# Regex filter for related queries
mcporter call gsc.search_analytics \
  siteUrl="sc-domain:$APP_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  dimensions="query" \
  queryFilter="regex:(invest|stock|portfolio)" \
  filterOperator="includingRegex" \
  --output json

# Mobile only
mcporter call gsc.search_analytics \
  siteUrl="sc-domain:$APP_DOMAIN" \
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
  siteUrl="sc-domain:$APP_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  minImpressions:50 \
  maxCtr:2 \
  positionRangeMin:4 \
  positionRangeMax:20 \
  --output json

# Or use enhanced_search_analytics with inline quick wins
mcporter call gsc.enhanced_search_analytics \
  siteUrl="sc-domain:$APP_DOMAIN" \
  startDate="2026-04-01" \
  endDate="2026-05-01" \
  dimensions="query,page" \
  enableQuickWins:true \
  --output json
```

### URL Indexing Inspection
```bash
mcporter call gsc.index_inspect \
  siteUrl="sc-domain:$APP_DOMAIN" \
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

- Domain property: `sc-domain:$APP_DOMAIN` (covers all subdomains and protocols)
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

- **Prefer OAuth user credentials over service accounts** for personal/company GSC properties. Service accounts often cannot be added through the GSC UI, while OAuth immediately inherits the user's existing properties.
- `authorized_user` JSON works as `GOOGLE_APPLICATION_CREDENTIALS` for this MCP server because it uses GoogleAuth `keyFile` under the hood.
- OAuth ADC needs `quota_project_id`; without it, Search Console returns a 403 quota project error.
- GSC data has a **2-3 day lag**. Don't query today's date.
- `dataState="all"` includes preliminary data that may change.
- Max 25,000 rows per request. For high-volume sites, use filters to segment.
- No Google Cloud IAM role is needed for GSC access. GSC permissions are separate from Cloud IAM.
