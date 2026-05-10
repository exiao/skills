# Apple Retention Messaging API (via RevenueCat)

Setup guide for configuring Apple's cancel-flow retention offers through RevenueCat.

## Prerequisites
- Apple must approve your access (request at https://developer.apple.com/contact/request/retention-messaging-api/)
- Need: App Name, Apple ID (numeric, e.g. 1436348671), endpoint URL from RevenueCat
- Only account holder can submit the form
- Approval timing is unpredictable (weeks to months)

## Bloom-Specific: Existing Custom Endpoint (PITFALL)

Bloom has a custom retention endpoint at `$BLOOM_API_DOMAIN/retention-api/` (code: `bloom_backend/views/retention.py`). This was built before the RevenueCat integration and is a **stub** that returns a hardcoded dummy `messageId`. If Apple's notification URL is pointed here instead of RevenueCat's URL, retention messaging silently fails because:

1. Apple sends the cancellation request to your backend
2. Your backend returns `"default-retention-message-id"` (not a real message)
3. No retention offer is shown to the user
4. RevenueCat never sees the request (can't verify setup or track saves)

**Resolution**: Ensure Apple's notification URL points to RevenueCat's endpoint (provided in Lifecycle > Retention setup wizard, step 1). The custom endpoint can be kept as a fallback or removed.

The same file also contains a Google Play RTDN webhook (`google_play_rtdn_webhook`) for tracking subscription lifecycle events via PostHog. Win-back notifications for Android are stubbed out (TODO).

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

## Offers Created for Bloom (May 2026)

| Product | Offer Code | Type | Details |
|---------|-----------|------|---------|
| monthly_10 ($19.99) | m_30_off_ppp | 30% off, PPP-equalized | PAY_AS_YOU_GO, 1 period |
| monthly_10 ($19.99) | retain_free_monthly | 1 month free | FREE_TRIAL |
| annual_60 ($104.99) | a_30_off_ppp | 30% off, PPP-equalized | PAY_AS_YOU_GO, 1 period |
| annual_60 ($104.99) | retain_free_annual | 1 month free | FREE_TRIAL |
| weekly_5 ($4.99) | retain_30_weekly | 30% off, PPP-equalized | PAY_AS_YOU_GO, 1 period |
| weekly_5 ($4.99) | retain_free_weekly | 1 week free | FREE_TRIAL |

RevenueCat messages configured:
- **Default**: "Don't go!" (all products, all locales, Active/Approved)
- **Promotional**: "30% Off Retention" (monthly/annual/weekly, eligibility: first seen >14 days)

## Remaining Setup Steps

1. Verify Apple's notification URL points to RevenueCat (not `$BLOOM_API_DOMAIN/retention-api/`)
2. Make a sandbox purchase to complete step 3 of 4 in RC wizard
3. Pass the performance test (~1 hour)
4. Connect production URL, recreate messages for production
5. Apple reviews production messages per locale

## Browser Automation Notes
- Grid cells: double-click to activate input
- React controlled components: use native value setter + dispatch 'input' event
- Press Tab to commit
- Combobox dropdowns cascade (active → offered → promo ID)
