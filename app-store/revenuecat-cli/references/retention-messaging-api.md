# Apple Retention Messaging API (via RevenueCat)

Setup guide for configuring Apple's cancel-flow retention offers through RevenueCat.

## Prerequisites
- Apple must approve your access (request at https://developer.apple.com/contact/request/retention-messaging-api/)
- Need: App Name, Apple ID (numeric, e.g. 1436348671), endpoint URL from RevenueCat
- Only account holder can submit the form
- Approval timing is unpredictable (weeks to months)

## Promotional Offers in App Store Connect

Before configuring messages in RevenueCat, create promotional offers in ASC for each subscription product.

### Creating via raw API (asc CLI has bugs)
The `asc subscriptions offers promotional create` command fails with "Missing a required include subscriptionPricePoint". Use the raw API:

```bash
TOKEN=$(asc auth token --confirm)

# PAY_AS_YOU_GO (e.g., 30% off)
curl -s -X POST "https://api.appstoreconnect.apple.com/v1/subscriptionPromotionalOffers" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "type": "subscriptionPromotionalOffers",
      "attributes": {
        "name": "OFFER_NAME",
        "offerCode": "OFFER_CODE",
        "duration": "ONE_MONTH",
        "offerMode": "PAY_AS_YOU_GO",
        "numberOfPeriods": 1
      },
      "relationships": {
        "subscription": { "data": {"type": "subscriptions", "id": "SUB_ID"} },
        "prices": { "data": [{"type": "subscriptionPromotionalOfferPrices", "id": "${price1}"}] }
      }
    },
    "included": [{
      "type": "subscriptionPromotionalOfferPrices",
      "id": "${price1}",
      "relationships": {
        "subscriptionPricePoint": { "data": {"type": "subscriptionPricePoints", "id": "PRICE_POINT_ID"} }
      }
    }]
  }'

# FREE_TRIAL: subscriptionPricePoint must be OMITTED, territory must be INCLUDED
# Same structure but replace the included block's relationships with:
#   "territory": { "data": {"type": "territories", "id": "USA"} }
```

### Finding Price Points
Price points are paginated (50/page, 800 total). Follow cursor-based pagination from `links.next`. Price point IDs are base64 JSON: `{"s":"SUB_ID","t":"TERRITORY","p":"PRICE_INDEX"}`.

### PPP via Equalization
Apple handles PPP automatically. A single USA price point auto-maps to local prices globally. Verify via:
```
GET /v1/subscriptionPricePoints/{ID}/equalizations?limit=200
```
Equalized prices are in LOCAL currencies (INR 1499, JPY 2200, etc.), not USD.

### Pitfalls
- Offer codes must be unique across the entire subscription GROUP
- Deleted offer codes cannot be reused — use new codes
- Product names in ASC may not reflect current prices (verify with `asc subscriptions pricing summary`)
- `asc subscriptions offers promotional create --prices` flag is broken — use raw curl

## RevenueCat Dashboard Setup (Lifecycle > Retention)

1. **Sandbox URL**: RevenueCat prompts to configure
2. **Performance Test**: Needs active sandbox/TestFlight subscription (not StoreKit files). Up to 1 hour.
3. **Default Message**: Required first. Title ≤66 chars, subtitle ≤144 chars. Auto-translate from English.
4. **Promotional Messages**: Map Active product → Offered product → Promotion identifier. Eligibility rules (e.g., first seen >14 days).
5. **Production**: After perf test passes, connect prod URL, recreate messages. Apple reviews per locale.

## Browser Automation Notes
- Grid cells: double-click to activate input
- React controlled components: use native value setter + dispatch 'input' event
- Press Tab to commit
- Combobox dropdowns cascade (active → offered → promo ID)
