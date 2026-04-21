---
name: revenuecat-catalog-sync
description: Reconcile App Store Connect subscriptions and in-app purchases with RevenueCat products, entitlements, offerings, and packages using the asc CLI and the revenuecat-cli skill (mcporter). Use when setting up or syncing subscription catalogs across ASC and RevenueCat.
---

# asc RevenueCat catalog sync

Use this skill to keep App Store Connect (ASC) and RevenueCat aligned, including creating missing ASC items and mapping them to RevenueCat resources.

## When to use
- You want to bootstrap RevenueCat from an existing ASC catalog.
- You want to create missing ASC subscriptions/IAPs, then map them into RevenueCat.
- You need a drift audit before release.
- You want deterministic product mapping based on identifiers.

## Preconditions
- `asc` authentication is configured (`asc auth login` or `ASC_*` env vars).
- `mcporter` is installed and the `revenuecat` server is registered in `~/.mcporter/mcporter.json` (see the `revenuecat-cli` skill for setup).
- `REVENUECAT_API_KEY` is set in the agent environment for read operations via mcporter.
- For write operations (create/update), `REVENUECAT_WRITE_API_KEY` (a v2 secret key with write scope) must be set — these go through the REST API directly, not mcporter.
- You know:
  - ASC app ID (`APP_ID`)
  - RevenueCat `project_id` (Bloom = `proj2cab6270`)
  - target RevenueCat app type (`app_store` or `mac_app_store`) and bundle ID for create flows

## Safety defaults
- Start in **audit mode** (read-only).
- Require explicit confirmation before writes.
- Never delete resources in this workflow.
- Continue on per-item failures and report all failures at the end.

## Canonical identifiers
- Primary cross-system key: ASC `productId` == RevenueCat `store_identifier`.
- Keep `productId` stable once products are live.
- Do not use display names as unique identifiers.

## Scope boundary
- The `revenuecat-cli` skill (mcporter) is **read-only**: list/get for projects, apps, products, entitlements, offerings, packages, customers, subscriptions.
- All **writes** (create/update products, attach entitlements, create offerings/packages) go through the RevenueCat v2 REST API directly via `curl`, using `REVENUECAT_WRITE_API_KEY`.
- Use `asc` commands to create missing ASC subscription groups, subscriptions, and IAPs before RevenueCat mapping.

## Modes

### 1) Audit mode (default)
1. Read ASC source catalog.
2. Read RevenueCat target catalog.
3. Build a diff with actions:
   - missing in ASC
   - missing in RevenueCat
   - mapping conflicts (identifier/type/app mismatch)
4. Present a plan and wait for confirmation.

### 2) Apply mode (explicit)
Execute approved actions in this order:
1. Ensure ASC groups/subscriptions/IAP exist.
2. Ensure RevenueCat app/products exist.
3. Ensure entitlements and product attachments.
4. Ensure offerings/packages and package attachments.
5. Verify and print a final reconciliation summary.

## Step-by-step workflow

### Step A - Read current ASC catalog

```bash
asc subscriptions groups list --app "APP_ID" --paginate --output json
asc iap list --app "APP_ID" --paginate --output json
# for each subscription group:
asc subscriptions list --group "GROUP_ID" --paginate --output json
```

### Step B - Read current RevenueCat catalog (mcporter)

Use the `revenuecat-cli` skill via `mcporter call revenuecat.<tool>`. All tool names use **dashes**, not underscores. Pass `project_id` and paginate with `starting_after` where applicable.

```bash
mkdir -p /tmp/revenuecat
mcporter call revenuecat.list-apps         project_id=proj2cab6270 --output json > /tmp/revenuecat/apps.json
mcporter call revenuecat.list-products     project_id=proj2cab6270 limit:100 --output json > /tmp/revenuecat/products.json
mcporter call revenuecat.list-entitlements project_id=proj2cab6270 --output json > /tmp/revenuecat/entitlements.json
mcporter call revenuecat.list-offerings    project_id=proj2cab6270 --output json > /tmp/revenuecat/offerings.json
# packages are per-offering:
mcporter call revenuecat.list-packages     project_id=proj2cab6270 offering_id=default --output json > /tmp/revenuecat/packages.json
```

Note: `list-projects` replaces the old `get_project` for project discovery. There is no `get_project` in the current MCP.

### Step C - Build mapping plan

Map ASC product types to RevenueCat product types:
- ASC subscription -> RevenueCat `subscription`
- ASC IAP `CONSUMABLE` -> RevenueCat `consumable`
- ASC IAP `NON_CONSUMABLE` -> RevenueCat `non_consumable`
- ASC IAP `NON_RENEWING_SUBSCRIPTION` -> RevenueCat `non_renewing_subscription`

Suggested entitlement policy:
- subscriptions: one entitlement per subscription group (or explicit map provided by user)
- non-consumable IAP: one entitlement per product
- consumable IAP: no entitlement by default unless user asks

### Step D - Ensure missing ASC items (if requested)

Create missing ASC resources first, then re-read ASC to capture canonical IDs.

```bash
# create subscription group
asc subscriptions groups create --app "APP_ID" --reference-name "Premium"

# create subscription
asc subscriptions create \
  --group "GROUP_ID" \
  --ref-name "Monthly" \
  --product-id "com.example.premium.monthly" \
  --subscription-period ONE_MONTH

# create iap
asc iap create \
  --app "APP_ID" \
  --type NON_CONSUMABLE \
  --ref-name "Lifetime" \
  --product-id "com.example.lifetime"
```

### Step E - Ensure RevenueCat app and products

The current public RC MCP is read-only — these are write operations and must use the v2 REST API directly via `curl` with a write-scoped key (`REVENUECAT_WRITE_API_KEY`).

```bash
# Create app (if missing)
curl -sS -X POST "https://api.revenuecat.com/v2/projects/proj2cab6270/apps" \
  -H "Authorization: Bearer $REVENUECAT_WRITE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "Bloom iOS", "type": "app_store", "bundle_id": "com.bloom.invest"}'

# Create product (per ASC product)
curl -sS -X POST "https://api.revenuecat.com/v2/projects/proj2cab6270/products" \
  -H "Authorization: Bearer $REVENUECAT_WRITE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "store_identifier": "com.bloom.premium.monthly",
    "type": "subscription",
    "app_id": "<RC_APP_ID>"
  }'
```

After creating, re-read with `mcporter call revenuecat.list-products` to confirm.

### Step F - Ensure entitlements and attachments

Read via mcporter; write via REST API:

```bash
# Read
mcporter call revenuecat.list-entitlements project_id=proj2cab6270 --output json
mcporter call revenuecat.get-products-from-entitlement \
  project_id=proj2cab6270 entitlement_id=premium --output json

# Write: create entitlement
curl -sS -X POST "https://api.revenuecat.com/v2/projects/proj2cab6270/entitlements" \
  -H "Authorization: Bearer $REVENUECAT_WRITE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"lookup_key": "premium", "display_name": "Premium"}'

# Write: attach products to entitlement
curl -sS -X POST "https://api.revenuecat.com/v2/projects/proj2cab6270/entitlements/<ENT_ID>/actions/attach_products" \
  -H "Authorization: Bearer $REVENUECAT_WRITE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"product_ids": ["<RC_PRODUCT_ID>"]}'
```

### Step G - Ensure offerings and packages (optional)

Read via mcporter; write via REST API:

```bash
# Read
mcporter call revenuecat.list-offerings project_id=proj2cab6270 --output json
mcporter call revenuecat.list-packages project_id=proj2cab6270 offering_id=default --output json

# Write: create offering
curl -sS -X POST "https://api.revenuecat.com/v2/projects/proj2cab6270/offerings" \
  -H "Authorization: Bearer $REVENUECAT_WRITE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"lookup_key": "default", "display_name": "Default"}'

# Write: create package
curl -sS -X POST "https://api.revenuecat.com/v2/projects/proj2cab6270/offerings/<OFF_ID>/packages" \
  -H "Authorization: Bearer $REVENUECAT_WRITE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"lookup_key": "$rc_monthly", "display_name": "Monthly", "position": 1}'

# Write: attach products to package
curl -sS -X POST "https://api.revenuecat.com/v2/projects/proj2cab6270/packages/<PKG_ID>/actions/attach_products" \
  -H "Authorization: Bearer $REVENUECAT_WRITE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"products": [{"product_id": "<RC_PRODUCT_ID>", "eligibility_criteria": "all"}]}'

# Write: mark current offering
curl -sS -X POST "https://api.revenuecat.com/v2/projects/proj2cab6270/offerings/<OFF_ID>" \
  -H "Authorization: Bearer $REVENUECAT_WRITE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"is_current": true}'
```

Recommended package keys:
- `ONE_WEEK` -> `$rc_weekly`
- `ONE_MONTH` -> `$rc_monthly`
- `TWO_MONTHS` -> `$rc_two_month`
- `THREE_MONTHS` -> `$rc_three_month`
- `SIX_MONTHS` -> `$rc_six_month`
- `ONE_YEAR` -> `$rc_annual`
- lifetime IAP -> `$rc_lifetime`
- custom -> `$rc_custom_<name>`

## Expected output format

Return a final summary with:
- ASC created counts (groups/subscriptions/IAP)
- RevenueCat created counts (apps/products/entitlements/offerings/packages)
- attachment counts (entitlement-products, package-products)
- skipped existing items
- failed items with actionable errors

Example:

```text
ASC: created groups=1 subscriptions=2 iap=1, skipped=14, failed=0
RC: created apps=0 products=3 entitlements=2 offerings=1 packages=2, skipped=27, failed=1
Attachments: entitlement_products=3 package_products=2
Failures:
- com.example.premium.annual: duplicate store_identifier exists on another RC app
```

## Agent behavior
- Always run audit first, even in apply mode.
- Ask for confirmation before create/update operations.
- Match by `store_identifier` first.
- Use full pagination (`--paginate` for ASC, `starting_after` for RevenueCat tools).
- Continue processing after per-item failures and report all failures together.
- Never auto-delete ASC or RevenueCat resources in this skill.

## Common pitfalls
- Wrong RevenueCat `project_id` or app ID.
- Creating RC products under the wrong platform app.
- Accidentally assigning consumables to entitlements.
- Skipping the post-create ASC re-read step.
- Missing offering/package verification after product creation.

## Additional resources
- Workflow examples: [examples.md](examples.md)
- Source references: [references.md](references.md)
