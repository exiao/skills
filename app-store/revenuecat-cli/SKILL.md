---
name: revenuecat-cli
description: Use when querying RevenueCat for projects, apps, products, entitlements, offerings, packages, customers, subscriptions, purchases, webhooks, or overview metrics via mcporter. Triggers on "revenuecat", "RC project", "list RC products", "check customer entitlement", "RC offering", "subscription status for user X", "RC overview metrics", "MRR", "active subscribers".
---

# RevenueCat CLI (via mcporter)

Read-only access to the RevenueCat API v2 through the public RC MCP, called via `mcporter`. Replaces the `mcp_revenuecat_*` MCP tools.

**Read-only.** The current public RC MCP at `https://mcp.revenuecat.ai/mcp` exposes only `get-*` and `list-*` operations. For writes (create/update products, attach entitlements, modify offerings) use the RevenueCat REST API directly with curl, or the RevenueCat dashboard.

## Setup

The `REVENUECAT_API_KEY` variable must be present in the agent environment. The mcporter server config at `~/.mcporter/mcporter.json` references it via `${REVENUECAT_API_KEY}`. Auto-loaded by Hermes at startup.

Verify connection:

```bash
mcporter list revenuecat 2>&1 | grep -c "^  function"   # should print 23
```

## Calling pattern (always)

```bash
mkdir -p /tmp/revenuecat
mcporter call revenuecat.<tool> key=value key2:5 --output json > /tmp/revenuecat/<file>.json
```

Then `jq` the output. Tool names use **dashes**, not underscores: `list-products`, `get-customer`, etc.

**Argument syntax:**
- `key=value` for strings: `project_id=$REVENUECAT_PROJECT_ID`
- `key:value` for numbers: `limit:50`
- For nested: `--args '{"expand": ["product"]}'`

## Tools (23 total, all read-only)

### Projects & apps
| Tool | Use |
|------|-----|
| `list-projects` | All RC projects on the account |
| `list-apps` | Apps within a project. `project_id` required |
| `get-app` | App details. `project_id`, `app_id` required |
| `list-app-public-api-keys` | Public SDK keys. `project_id`, `app_id` required |

### Catalog: products / entitlements / offerings
| Tool | Use |
|------|-----|
| `list-products` | All products in project. `project_id` required, optional `app_id` |
| `get-product` | Single product. `project_id`, `product_id` required |
| `list-product-prices` | Prices for a product across stores |
| `get-product-store-state` | Current store sync state for a product |
| `get-product-store-state-operation` | Status of a store-sync operation |
| `list-entitlements` | All entitlements in project |
| `get-entitlement` | Single entitlement. Optional `expand=["product"]` |
| `get-products-from-entitlement` | Products attached to an entitlement |
| `list-offerings` | All offerings in project |
| `get-offering` | Single offering. Optional `expand=["package", "package.product"]` |
| `list-packages` | Packages in an offering. `offering_id` required |

### Customers, subscriptions, purchases
| Tool | Use |
|------|-----|
| `get-customer` | Customer profile by RC `customer_id`. Optional `expand=["attributes"]` |
| `list-subscriptions` | Subscriptions for a customer. Optional `environment=sandbox\|production` |
| `get-subscription` | Single subscription by `subscription_id` |
| `list-purchases` | One-time purchases for a customer |
| `list-virtual-currencies-balances` | VC balances for a customer |

### Webhooks & metrics
| Tool | Use |
|------|-----|
| `list-webhook-integrations` | All webhooks in project |
| `get-webhook-integration` | Single webhook by `webhook_integration_id` |
| `get-overview-metrics` | MRR, active subs, revenue. `project_id` required, optional `currency` (USD/EUR/etc.) |

## Patterns

### Find your project ID
```bash
mkdir -p /tmp/revenuecat
mcporter call revenuecat.list-projects --output json > /tmp/revenuecat/projects.json
jq -r '.content[0].text' /tmp/revenuecat/projects.json
# Project ID is `$REVENUECAT_PROJECT_ID`
```

### Pull MRR + overview metrics
```bash
mcporter call revenuecat.get-overview-metrics project_id=$REVENUECAT_PROJECT_ID currency=USD --output json \
  > /tmp/revenuecat/metrics.json
jq -r '.content[0].text' /tmp/revenuecat/metrics.json
```

### Check a customer's subscription status
```bash
# Get customer profile
mcporter call revenuecat.get-customer \
  project_id=$REVENUECAT_PROJECT_ID \
  customer_id="user_12345" \
  --output json > /tmp/revenuecat/customer.json

# Get their active subs
mcporter call revenuecat.list-subscriptions \
  project_id=$REVENUECAT_PROJECT_ID \
  customer_id="user_12345" \
  environment=production \
  --output json > /tmp/revenuecat/subs.json
```

### List all products in the project
```bash
mcporter call revenuecat.list-products project_id=$REVENUECAT_PROJECT_ID limit:100 --output json \
  > /tmp/revenuecat/products.json
jq -r '.content[0].text' /tmp/revenuecat/products.json
```

### Audit entitlement attachments (catalog drift check)
```bash
# List entitlements
mcporter call revenuecat.list-entitlements project_id=$REVENUECAT_PROJECT_ID --output json \
  > /tmp/revenuecat/entitlements.json

# For each entitlement, see what's attached
ENT_ID=premium
mcporter call revenuecat.get-products-from-entitlement \
  project_id=$REVENUECAT_PROJECT_ID \
  entitlement_id=$ENT_ID \
  --output json > /tmp/revenuecat/products-for-$ENT_ID.json
```

### Inspect an offering with all packages and products expanded
```bash
mcporter call revenuecat.get-offering \
  project_id=$REVENUECAT_PROJECT_ID \
  offering_id=default \
  --args '{"expand": ["package", "package.product"]}' \
  --output json > /tmp/revenuecat/offering.json
```

## Limitations (important — read before planning analysis)

The RC v2 API has significant gaps for analytics. See `references/api-limitations.md` for full details.

- **No country-level revenue.** Cannot group revenue, subs, or trials by country via API. Dashboard only: Charts > Revenue > Group by Country.
- **No chart/trend data.** `/v2/.../charts` doesn't exist. Daily/weekly/monthly time series are dashboard-only.
- **No bulk customer listing.** Need specific `customer_id` to query. Cannot sample or enumerate.
- **No transactions endpoint.** `/v2/.../transactions` returns 404.

When asked to analyze revenue by geography, immediately flag that this requires the RC Dashboard and ask the user to export or check manually. Don't waste time trying API endpoints that don't exist.

## Writes (not in MCP — use REST API)

For create/update/delete operations, use the v2 REST API directly. Requires a v2 secret API key (write-enabled):

```bash
# Example: create a product (NOT available via MCP)
curl -X POST https://api.revenuecat.com/v2/projects/$REVENUECAT_PROJECT_ID/products \
  -H "Authorization: Bearer $REVENUECAT_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"store_identifier": "com.bloom.premium.monthly", "type": "subscription", "app_id": "app123"}'
```

API reference: https://www.revenuecat.com/reference/api-v2-overview

## Notes

- **Output is JS-object syntax, NOT strict JSON.** mcporter's `--output json` prints unquoted keys and single-quoted strings (`{ content: [{ type: 'text', text: '...' }] }`). To parse: pipe through `node -e` or grep the `text` field directly. Example: `grep -oE "text: '[^']*'" /tmp/revenuecat/foo.json | head -1`.
- For raw API responses, use direct REST curl with `$REVENUECAT_API_KEY` instead of mcporter.
- Pagination: pass `limit` and `starting_after` (cursor from previous page).
- `environment` defaults to all; specify `production` or `sandbox` to filter.
- RevenueCat project ID: `$REVENUECAT_PROJECT_ID`.
- This skill is the recommended interface to RevenueCat reads. The native `mcp_revenuecat_*` MCP tools have been deactivated.
- For Apple Retention Messaging API setup (cancel-flow offers via RC), see `references/retention-messaging-api.md`.
