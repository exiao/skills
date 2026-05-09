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
- `key=value` for strings: `project_id=proj2cab6270`
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
# Bloom is proj2cab6270
```

### Pull MRR + overview metrics
```bash
mcporter call revenuecat.get-overview-metrics project_id=proj2cab6270 currency=USD --output json \
  > /tmp/revenuecat/metrics.json
jq -r '.content[0].text' /tmp/revenuecat/metrics.json
```

### Check a customer's subscription status
```bash
# Get customer profile
mcporter call revenuecat.get-customer \
  project_id=proj2cab6270 \
  customer_id="user_12345" \
  --output json > /tmp/revenuecat/customer.json

# Get their active subs
mcporter call revenuecat.list-subscriptions \
  project_id=proj2cab6270 \
  customer_id="user_12345" \
  environment=production \
  --output json > /tmp/revenuecat/subs.json
```

### List all products in the project
```bash
mcporter call revenuecat.list-products project_id=proj2cab6270 limit:100 --output json \
  > /tmp/revenuecat/products.json
jq -r '.content[0].text' /tmp/revenuecat/products.json
```

### Get package products and prices for a hosted checkout page
Use this when a Bloom-owned pre-checkout page needs to show prices before redirecting to a RevenueCat Web Purchase Link.

```bash
# Find the offering. BloomBot v2 currently uses lookup_key bloombot_v2_default.
mcporter call revenuecat.list-offerings project_id=proj2cab6270 --output json \
  > /tmp/revenuecat/offerings.json

# Inspect packages and expanded products by offering ID, not lookup_key.
mcporter call revenuecat.get-offering \
  project_id=proj2cab6270 \
  offering_id=ofrngf31a090110 \
  --args '{"expand":["package","package.product"]}' \
  --output json > /tmp/revenuecat/offering-bloombot-v2.json

# Then fetch prices by product IDs returned from the offering.
mcporter call revenuecat.list-product-prices \
  project_id=proj2cab6270 \
  product_id=prodb632b58f8a \
  --output json > /tmp/revenuecat/prices-yearly-onboarding.json
mcporter call revenuecat.list-product-prices \
  project_id=proj2cab6270 \
  product_id=prodab96bc979a \
  --output json > /tmp/revenuecat/prices-weekly.json
```

RevenueCat returns `amount` in cents for USD in this MCP output. Example: `7800` means `$78.00`, `500` means `$5.00`.

Pitfall: `get-offering` expects the opaque offering ID (`ofrng...`), not the lookup key (`default`, `bloombot_v2_default`). Calling it with the lookup key can return 404.

### Audit entitlement attachments (catalog drift check)
```bash
# List entitlements
mcporter call revenuecat.list-entitlements project_id=proj2cab6270 --output json \
  > /tmp/revenuecat/entitlements.json

# For each entitlement, see what's attached
ENT_ID=premium
mcporter call revenuecat.get-products-from-entitlement \
  project_id=proj2cab6270 \
  entitlement_id=$ENT_ID \
  --output json > /tmp/revenuecat/products-for-$ENT_ID.json
```

### Inspect an offering with all packages and products expanded
```bash
mcporter call revenuecat.get-offering \
  project_id=proj2cab6270 \
  offering_id=default \
  --args '{"expand": ["package", "package.product"]}' \
  --output json > /tmp/revenuecat/offering.json
```

### Web Purchase Links and hosted package selectors

When debugging RevenueCat Web Purchase Links or hosted plan selectors, read `references/web-purchase-links-and-offerings.md`. Key points:

- A Web Purchase Link without `package_id` can show a generic hosted selector based on the linked offering's packages.
- If there is no RC Paywall object, value props and marketing copy may not be configurable through the hosted selector. Use a Bloom-owned pre-checkout page for richer value props, then redirect to a specific package.
- To show only one plan, remove other packages from the relevant offering. This does not delete products or entitlements.
- Direct REST package edits require `project_configuration:packages:read_write`; the MCP is read-only and will not perform writes.

### Product prices and units

`list-product-prices` returns text like:

```text
[1]{amount,amount_micros,currency}:
  7800,78000000,USD
```

For USD, `amount` is cents and `amount_micros` is micro-units. Convert `amount / 100` for display copy, so `7800` is `$78.00` and `500` is `$5.00`. Do not infer price from product or package names. Always call `list-product-prices` for the product attached to the package you will link to.

### BloomBot subscribe prices found in May 2026

BloomBot v2 offering lookup key: `bloombot_v2_default`.

Packages:
- `bloombot_yearly_onboarding` -> product `prodb632b58f8a` -> `7800 USD` -> `$78/year`
- `$rc_weekly` -> product `prodab96bc979a` -> `500 USD` -> `$5/week`
- `$rc_annual` -> product `prodf010147771` -> `10400 USD` -> `$104/year`

Verify again before changing user-facing price copy.

## Writes (not in MCP — use REST API)

For create/update/delete operations, use the v2 REST API directly. Requires a v2 secret API key (write-enabled):

```bash
# Example: create a product (NOT available via MCP)
curl -X POST https://api.revenuecat.com/v2/projects/proj2cab6270/products \
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
- Bloom's project ID: `proj2cab6270` (cached here so we don't need to look it up every time).
- This skill is the recommended interface to RevenueCat reads. The native `mcp_revenuecat_*` MCP tools have been deactivated.
- For Apple Retention Messaging API setup (cancel-flow offers via RC), see `references/retention-messaging-api.md`.
