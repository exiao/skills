---
name: Apple Search Ads
slug: apple-search-ads
version: 2.0.0
homepage: https://clawic.com/skills/apple-search-ads
description: Create, optimize, and scale Apple Search Ads campaigns with API automation, attribution integration, and bid strategy recommendations.
metadata: {"openclaw":{"emoji":"🍎","requires":{"bins":["curl","jq","python3","bc"],"env":["ASA_CLIENT_ID","ASA_TEAM_ID","ASA_KEY_ID","ASA_ORG_ID","ASA_PRIVATE_KEY_PATH"]},"os":["linux","darwin"]}}
---

# Apple Search Ads 🍎

Executable toolkit for Apple Search Ads Campaign Management API v5. Shell scripts for campaign management, keyword optimization, search term mining, and bid automation.

## Quick Start

### Prerequisites

1. **Python JWT library:** `pip install pyjwt[crypto]`
2. **ASA API credentials** (see [Account Setup](#account-setup))
3. **Environment variables** in gateway config:

```bash
ASA_CLIENT_ID="SEARCHADS.xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
ASA_TEAM_ID="SEARCHADS.xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
ASA_KEY_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
ASA_ORG_ID="123456"
ASA_PRIVATE_KEY_PATH="/path/to/asa-private-key.pem"
```

### Run a Command

All scripts live in `scripts/`. Run them directly:

```bash
# List campaigns
./scripts/campaigns.sh list

# Get keyword report
./scripts/reports.sh keywords 12345 --start 2026-03-01 --end 2026-03-15

# Find wasted spend
./scripts/reports.sh wasted-spend --start 2026-03-01 --end 2026-03-15
```

Or call the agent with natural language: "show me ASA campaign performance for last week."

## Contents

1. [CLI Reference](#cli-reference)
2. [Account Setup](#account-setup)
3. [Campaign Structure](#campaign-structure)
4. [Strategy Playbook](#strategy-playbook)
5. [Attribution Guide](#attribution-guide)
6. [Common Traps](#common-traps)

---

## CLI Reference

### campaigns.sh

Campaign CRUD operations.

| Command | Description |
|---------|-------------|
| `campaigns.sh list [--status ENABLED\|PAUSED]` | List all campaigns |
| `campaigns.sh get <id>` | Get campaign details (JSON) |
| `campaigns.sh create --name NAME --app-id ID --countries US,GB [--budget AMT] [--daily-budget AMT] [--supply-source SRC]` | Create campaign |
| `campaigns.sh update <id> [--status S] [--daily-budget AMT] [--name N]` | Update campaign |
| `campaigns.sh pause <id>` | Pause campaign |
| `campaigns.sh enable <id>` | Enable campaign |
| `campaigns.sh setup-structure --app-id ID --countries US --daily-budget AMT` | Create recommended 4-campaign structure (Brand/Category/Competitor/Discovery) |

Supply source values: `APPSTORE_SEARCH_RESULTS`, `APPSTORE_SEARCH_TAB`, `APPSTORE_TODAY_TAB`, `APPSTORE_PRODUCT_PAGES_BROWSE`

### keywords.sh

Keyword management for targeting keywords within ad groups.

| Command | Description |
|---------|-------------|
| `keywords.sh list <cid> <agid> [--status ACTIVE\|PAUSED]` | List keywords |
| `keywords.sh add <cid> <agid> --text "keyword" --match EXACT\|BROAD [--bid 1.50]` | Add single keyword |
| `keywords.sh add-bulk <cid> <agid> --file keywords.csv` | Bulk add from CSV (`text,matchType,bid`) |
| `keywords.sh bid <cid> <agid> <kwid> --amount 2.00` | Update keyword bid |
| `keywords.sh pause <cid> <agid> <kwid>` | Pause keyword |
| `keywords.sh enable <cid> <agid> <kwid>` | Enable keyword |

### negatives.sh

Negative keyword management at campaign and ad group level.

| Command | Description |
|---------|-------------|
| `negatives.sh list-campaign <cid>` | List campaign negatives |
| `negatives.sh list-adgroup <cid> <agid>` | List ad group negatives |
| `negatives.sh add-campaign <cid> --text TEXT [--match EXACT\|BROAD]` | Add campaign negative |
| `negatives.sh add-adgroup <cid> <agid> --text TEXT [--match EXACT\|BROAD]` | Add ad group negative |
| `negatives.sh add-bulk-campaign <cid> --file negatives.csv` | Bulk add from CSV (`text,matchType`) |
| `negatives.sh delete-campaign <cid> <kwid>` | Delete campaign negative |
| `negatives.sh delete-adgroup <cid> <agid> <kwid>` | Delete ad group negative |

### reports.sh

Performance reporting with formatted tables.

| Command | Description |
|---------|-------------|
| `reports.sh campaigns --start DATE --end DATE [--granularity DAILY\|WEEKLY\|MONTHLY]` | Campaign summary |
| `reports.sh keywords <cid> --start DATE --end DATE [--sort FIELD] [--limit N]` | Keyword performance |
| `reports.sh search-terms <cid> --start DATE --end DATE [--min-impressions N]` | Search term report |
| `reports.sh adgroups <cid> --start DATE --end DATE` | Ad group performance |
| `reports.sh wasted-spend --start DATE --end DATE [--min-spend AMT] [--max-installs N]` | Keywords spending without converting |

### search-terms.sh

Search term mining and automated harvesting.

| Command | Description |
|---------|-------------|
| `search-terms.sh report <cid> --start DATE --end DATE` | Raw search term data |
| `search-terms.sh winners <cid> --start DATE --end DATE [--min-installs 3] [--max-cpa 5.00]` | Converting terms (promote to exact) |
| `search-terms.sh losers <cid> --start DATE --end DATE [--min-spend 20] [--max-installs 0]` | Wasteful terms (add as negatives) |
| `search-terms.sh harvest <discovery_cid> --target-campaign ID --target-adgroup ID --start DATE --end DATE [--cpa-threshold AMT] [--dry-run]` | Auto-promote winners + negate losers |

### optimize.sh

CPA-based bid optimization with guardrails.

| Command | Description |
|---------|-------------|
| `optimize.sh audit <cid> --start DATE --end DATE` | Full audit: high CPA, zero installs, low TTR, top performers |
| `optimize.sh bids <cid> --start DATE --end DATE --target-cpa AMT` | Suggest bid changes per keyword |
| `optimize.sh auto-bid <cid> --start DATE --end DATE --target-cpa AMT [--max-bid AMT] [--min-bid AMT] [--dry-run]` | Apply bid adjustments automatically |

Auto-bid logic:
- Calculates ideal CPT from target CPA and conversion rate
- Dampens adjustment (moves 50% toward ideal to avoid oscillation)
- Clamps to min/max bid bounds
- Only adjusts if change > 10% from current
- Always use `--dry-run` first

### asa-api.sh

Low-level API caller (used by all other scripts, also available directly).

```bash
# Source it for the asa_api function
source scripts/asa-api.sh

asa_api GET /campaigns
asa_api POST /reports/campaigns "$json_body"
asa_api PUT "/campaigns/$id" "$json_body"
asa_api DELETE "/campaigns/$id"

# Paginated fetch
asa_api_all /campaigns
```

Features: auto-auth via asa-auth.sh, token caching (1hr TTL), exponential backoff on 429s, auto-refresh on 401.

---

## Account Setup

ASA uses its own OAuth, completely separate from App Store Connect. The existing ASC API key cannot be reused.

### Steps

1. Sign in at https://ads.apple.com
2. Go to Account Settings > API tab
3. Generate an EC P-256 key pair:
   ```bash
   openssl ecparam -genkey -name prime256v1 -noout -out asa-private-key.pem
   openssl ec -in asa-private-key.pem -pubout -out asa-public-key.pem
   ```
4. Upload `asa-public-key.pem` in the API tab
5. Record the `clientId`, `teamId`, `keyId` values shown
6. Find your `orgId` in Account Settings
7. Store the private key securely and set env vars

### Auth Flow

The scripts handle this automatically. Under the hood:

1. `asa-auth.sh` generates an ES256 JWT (via Python pyjwt) with 1-hour expiry
2. Exchanges the JWT for an access token at `https://appleid.apple.com/auth/oauth2/token`
3. Caches the token in `/tmp/.asa-access-token` with expiry tracking
4. `asa-api.sh` sources auth, injects `Authorization: Bearer` and `X-AP-Context: orgId=` headers

Token lifetime: 1 hour. Cache auto-refreshes when < 5 minutes remain.

---

## Campaign Structure

### Hierarchy

```
Organization (orgId)
└── Campaign (budget, countries, supply source)
    └── Ad Group (bid settings, targeting, Search Match toggle)
        ├── Targeting Keywords (text, match type, bid)
        ├── Negative Keywords
        └── Ads (default or Custom Product Pages)
```

### Recommended 4-Campaign Structure

Use `campaigns.sh setup-structure` to create this automatically.

| Campaign | Keywords | Match Type | Search Match | Purpose |
|----------|----------|------------|--------------|---------|
| **Brand** | Your app/company name | EXACT | OFF | Defend brand searches |
| **Category** | Genre/category terms | EXACT | OFF | Capture high-intent users |
| **Competitor** | Competitor app names | EXACT | OFF | Conquest competitor traffic |
| **Discovery** | All keywords from above + Search Match | BROAD + Search Match | ON | Find new terms |

Discovery campaign rules:
- Add all exact keywords from other campaigns as **negative exact keywords** here
- Keep bids low (you're exploring, not converting)
- Mine search terms weekly and promote winners to exact campaigns

### Budget Allocation

| Stage | Brand | Category | Competitor | Discovery |
|-------|-------|----------|------------|-----------|
| Launch | 40% | 40% | 10% | 10% |
| Growth | 20% | 50% | 20% | 10% |
| Scale | 10% | 60% | 25% | 5% |

### Bidding Strategies (API v5.5)

| Strategy | Description |
|----------|-------------|
| **Max CPT Bid** | Manual: you set max cost-per-tap per keyword. Full control. |
| **Maximize Conversions** | NEW: Apple's AI sets optimal bids per query. You set target CPA + daily budget. Needs 2+ weeks to learn. |

Apple is deprecating the old CPA Goal in favor of Maximize Conversions. For new campaigns with sufficient budget, try Maximize Conversions. For tight budgets or when you need control, use manual CPT bids.

---

## Strategy Playbook

### Weekly Optimization Ritual

1. **Pull search term report** (`search-terms.sh report`)
2. **Promote winners** to exact campaigns (`search-terms.sh winners`)
3. **Negate losers** (`search-terms.sh losers`)
4. **Run audit** for problem keywords (`optimize.sh audit`)
5. **Adjust bids** toward target CPA (`optimize.sh bids` or `auto-bid --dry-run`)
6. **Check wasted spend** (`reports.sh wasted-spend`)

Or automate steps 2-3 with `search-terms.sh harvest --dry-run` (review first, then without `--dry-run`).

### Bid Optimization Loop

```
Week 1: Set baseline bids ($1-2 for generic, higher for brand)
Week 2: Review search terms. Raise bids 20% on low-CPA winners, lower 30% on high-CPA.
Week 3+: Repeat. Target CPA within 20% of goal. Pause anything > 2x target.
```

### Match Type Rules

| Type | When | Bid Level |
|------|------|-----------|
| EXACT | Proven converters, brand terms | Highest |
| BROAD | Discovery, expansion | Low |
| Search Match | New apps, keyword research | Lowest |

### Multi-Country Expansion

1. Start: US, UK, Canada, Australia (English)
2. Expand: Germany, France, Japan, South Korea (localize first)
3. Test: Brazil, Mexico, India (high volume, lower CPT)

Always create separate campaigns per country. Mixing makes bid optimization impossible.

### Custom Product Pages (CPPs) — Attribution Hack

CPPs are the cleanest attribution signal for paid mobile ads. Assign a unique CPP to each ad/campaign, then check revenue per CPP in App Store Connect analytics. This gives you exact revenue per ad with zero SDK complexity.

**Why this works:** App Store Connect shows downloads and proceeds per CPP. Unlike MMP attribution (which breaks with ATT opt-outs), CPP attribution is deterministic. Apple tracks it server-side.

**The 30% rule:** CPP revenue undercounts by ~30%. People see your ad, don't tap it, then search the App Store directly. Factor this in when calculating true ROAS.

**Limits:** 35 CPPs per app. Use them for:
- Each ASA campaign/keyword theme (investing terms vs competitor terms vs brand)
- Each Meta/TikTok/YouTube ad set
- Each influencer or channel

Create CPPs in App Store Connect > Custom Product Pages. Each gets a unique URL you use as the ad destination.

---

## Attribution Guide

### Custom Product Pages (Simplest, Most Reliable)

No SDK needed. Create a CPP per ad/campaign in App Store Connect, use it as your ad link, then read proceeds per CPP in ASC analytics. Deterministic, server-side, works regardless of ATT consent. Undercounts by ~30% (view-through users who search directly). See [Strategy Playbook > CPPs](#custom-product-pages-cpps--attribution-hack) for details.

### AdServices Framework (iOS 14.3+)

Modern attribution without user tracking.

```swift
import AdServices

func trackAttribution() async {
    do {
        let token = try AAAttribution.attributionToken()
        var request = URLRequest(url: URL(string: "https://api-adservices.apple.com/api/v1/")!)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = token.data(using: .utf8)
        let (data, _) = try await URLSession.shared.data(for: request)
        let attribution = try JSONDecoder().decode(Attribution.self, from: data)
        // attribution contains: campaignId, adGroupId, keywordId, conversionType, clickDate
    } catch {
        // Not from Apple Search Ads
    }
}
```

### SKAdNetwork 4.0

Privacy-focused aggregated attribution. Configure conversion values (0-63) to represent user actions:

| Value Range | Meaning |
|-------------|---------|
| 0 | Install only |
| 1-10 | Engagement (sessions, time) |
| 11-30 | Feature usage |
| 31-50 | Monetization signal (trial, content) |
| 51-63 | Revenue (purchase completed) |

### MMP Integration

If using AppsFlyer, Adjust, or similar: they handle AdServices and SKAdNetwork. Initialize MMP SDK first, configure conversion values in their dashboard, and link your ASA account for cost data.

---

## Common Traps

| Trap | Why It Hurts | Fix |
|------|-------------|-----|
| Mixing match types in one ad group | Can't isolate what's working | Separate ad groups per match type |
| No negative keywords | Wasting budget on irrelevant searches | Review search terms weekly |
| Same bid across all keywords | Brand terms worth more than generic | Bid by keyword value |
| No attribution in the app | Optimizing blind, can't measure real CPA | Implement AdServices |
| Launching ASA without ASO | Low App Store conversion rate kills ROI | Fix ASO first |
| Scaling budget too fast | CPA spikes when scaling | Increase budget 20-30% at a time |
| Multiple countries in one campaign | Can't optimize bids per market | One country per campaign |
| Ignoring Search Tab / Today Tab | Missing cheaper discovery placements | Test with small budgets |
| Not using Custom Product Pages | Missing easy conversion wins AND the best attribution signal | Create one CPP per campaign/ad set, read revenue per CPP in ASC |
| Report timezone mismatch | Data misalignment | Search term reports only support ORTZ timezone |
| Complex MMP setup when CPPs would suffice | Over-engineering attribution | Start with CPP-based attribution, add MMP only if you need cross-platform deduplication |

---

## API Reference

Base URL: `https://api.searchads.apple.com/api/v5`

### Campaigns

| Method | Endpoint |
|--------|----------|
| GET | `/campaigns` |
| GET | `/campaigns/{id}` |
| POST | `/campaigns` |
| PUT | `/campaigns/{id}` |
| DELETE | `/campaigns/{id}` |
| POST | `/campaigns/find` |

### Ad Groups

| Method | Endpoint |
|--------|----------|
| GET | `/campaigns/{id}/adgroups` |
| POST | `/campaigns/{id}/adgroups` |
| PUT | `/campaigns/{id}/adgroups/{id}` |
| DELETE | `/campaigns/{id}/adgroups/{id}` |

### Targeting Keywords

| Method | Endpoint |
|--------|----------|
| GET | `/campaigns/{cId}/adgroups/{aId}/targetingkeywords` |
| POST | `/campaigns/{cId}/adgroups/{aId}/targetingkeywords` |
| PUT | `/campaigns/{cId}/adgroups/{aId}/targetingkeywords` |
| POST | `/campaigns/{cId}/adgroups/{aId}/targetingkeywords/find` |

### Negative Keywords

| Method | Endpoint |
|--------|----------|
| GET/POST/PUT/DELETE | `/campaigns/{id}/negativekeywords[/{id}]` |
| GET/POST/PUT/DELETE | `/campaigns/{cId}/adgroups/{aId}/negativekeywords[/{id}]` |

### Reporting

| Method | Endpoint |
|--------|----------|
| POST | `/reports/campaigns` |
| POST | `/reports/campaigns/{id}/adgroups` |
| POST | `/reports/campaigns/{id}/keywords` |
| POST | `/reports/campaigns/{id}/searchterms` |
| POST | `/reports/campaigns/{id}/adgroups/{id}/keywords` |
| POST | `/reports/campaigns/{id}/adgroups/{id}/searchterms` |

### Key Metrics

| Metric | Description | Good Range |
|--------|-------------|------------|
| TTR | Tap-through rate | 5-10%+ |
| CVR | Conversion rate (installs/taps) | 30-60% |
| CPA | Cost per acquisition | < LTV/3 |
| CPT | Cost per tap | $0.50-3.00 |

### Rate Limits

Apple doesn't publish exact numbers. Implement exponential backoff (the scripts do this automatically). Community reports suggest 20-100 req/s.

---

## Templates

JSON templates in `templates/` for common operations:

| Template | Use |
|----------|-----|
| `campaign-create.json` | Base campaign object |
| `adgroup-create.json` | Base ad group with targeting |
| `keyword-create.json` | Keyword array format |
| `report-request.json` | Report request with selector |

---

## External Endpoints

| Endpoint | Purpose |
|----------|---------|
| `https://appleid.apple.com/auth/oauth2/token` | OAuth token exchange |
| `https://api.searchads.apple.com/api/v5/*` | Campaign management API |
| `https://api-adservices.apple.com/api/v1/` | Attribution (iOS app-side) |

## Related Skills

- `app-store-connect` — App releases and metadata
- `aso` — App Store Optimization (keyword research feeds into ASA)
- `appfigures` — Download/revenue analytics
