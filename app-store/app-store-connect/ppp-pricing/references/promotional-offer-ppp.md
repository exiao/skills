# Promotional Offer PPP Pricing

When creating promotional offers (e.g., for Apple Retention Messaging API), Apple's equalization handles PPP automatically. Set one USA price point and Apple maps it to equivalent local prices in all territories.

## Workflow
1. Find the target discounted price point for USA: paginate through `GET /v1/subscriptions/{SUB_ID}/pricePoints?filter[territory]=USA` following cursor links (50 per page, 800 total)
2. Create the promotional offer via raw API (the `asc` CLI `--prices` flag is broken as of 2026-05)
3. For PAY_AS_YOU_GO: include `subscriptionPricePoint` in the price relationship
4. For FREE_TRIAL: omit `subscriptionPricePoint`, include `territory` instead
5. Apple auto-equalizes the single price point across all territories — verify with the equalizations endpoint

## Verifying Equalization
```bash
TOKEN=$(asc auth token --confirm)
curl -s "https://api.appstoreconnect.apple.com/v1/subscriptionPricePoints/PRICE_POINT_ID/equalizations?limit=200" \
  -H "Authorization: Bearer $TOKEN"
```
Prices are in LOCAL currencies (INR 1499, JPY 2200, MXN 299). The floor is Apple's own minimum tier.

## Key Pitfalls
- Offer codes must be unique across the entire subscription **group**, not per subscription
- Deleted offer codes/names cannot be reused (Apple caches them permanently)
- Product display names in ASC may not reflect current prices (e.g., "Monthly $10" may actually be $20 now)
- Always verify: `asc subscriptions pricing summary --subscription-id SUB_ID --territory USA`
- Price point IDs are base64-encoded JSON: `{"s":"SUB_ID","t":"TERRITORY","p":"PRICE_INDEX"}`

## Full API examples
See `revenuecat-cli` skill's `references/retention-messaging-api.md` for complete curl examples.
