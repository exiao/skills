# RevenueCat Web Purchase Links, offerings, and hosted selectors

Session note from BloomBot paywall cleanup.

## Key behavior

- A RevenueCat Web Purchase Link without `package_id` shows a hosted package selector generated from the linked offering/packages.
- If no RevenueCat Paywall object exists for the project, the hosted page is a generic package selector. Do not expect rich value props or custom marketing sections to appear from API config alone.
- To show only one plan in the hosted selector, remove the other packages from the relevant offering. This does not delete products, subscriptions, transactions, or entitlements. It only changes what that offering presents.
- To skip the selector and deep-link to a specific plan, append `package_id=<package_lookup_key>` to the Web Purchase Link URL.

## Useful read calls

```bash
mcporter call revenuecat.list-offerings project_id=proj2cab6270 --output json > /tmp/revenuecat/offerings.txt
mcporter call revenuecat.get-offering \
  project_id=proj2cab6270 \
  offering_id=<offering_id> \
  --args '{"expand": ["package", "package.product"]}' \
  --output json > /tmp/revenuecat/offering.txt
```

For BloomBot Web Billing, the relevant offering found in this session was `default_web` (`ofrng1a7c334354`) with packages including discounted annual onboarding, weekly, and normal annual. Re-check before editing because RC config can drift.

## Writes and permissions

The public RC MCP exposed through `mcporter` is read-only. Direct REST API v2 supports package changes, but the API key must include write permissions.

Endpoints discovered from RevenueCat OpenAPI:

```http
POST   /v2/projects/{project_id}/packages/{package_id}
DELETE /v2/projects/{project_id}/packages/{package_id}
POST   /v2/projects/{project_id}/offerings/{offering_id}/packages
POST   /v2/projects/{project_id}/packages/{package_id}/actions/attach_products
POST   /v2/projects/{project_id}/packages/{package_id}/actions/detach_products
```

Updating a package display name requires:

```json
{"display_name":"Annual, first year","position":1}
```

If the API returns:

```text
403 The API key needs at least the project_configuration:packages:read_write permission defined
```

then stop and use the dashboard or ask for a v2 secret key with `project_configuration:packages:read_write`.

## BloomBot recommendation

For a WhatsApp upsell, avoid a generic RC selector with multiple similar plans. Use one short subscribe link:

1. `$APP_DOMAIN/subscribe` pre-checkout page shows value props.
2. Redirect directly to the discounted annual onboarding package with `package_id=bloombot_yearly_onboarding`.
3. Keep RevenueCat hosted checkout for payment, but move marketing copy/value props into Bloom-owned HTML where it can be edited and tested.

Good value props:

- Ask about any stock
- Get valuation, risk, and chart checks
- Compare stocks side by side
- Daily market context in WhatsApp

Avoid entitlement copy like “access to assistant”. Name plans by cadence/outcome: `BloomBot Annual, first year`, `BloomBot Annual`, `BloomBot Weekly`.
