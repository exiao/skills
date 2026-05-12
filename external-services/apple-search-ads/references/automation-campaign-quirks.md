# Automation Campaign (Search Match Only) Quirks

Discovered 2026-05-12 during daily optimization pass.

## Default bid = $0 still spends money

The Automation campaign (Search Match only, no targeting keywords) may show `defaultBidAmount: "0"` on its ad group yet still spend money. Apple's Search Match uses its own internal bidding when the default bid is $0.

To check:
```bash
asa_api GET "/campaigns/$cid/adgroups" | jq '[.data[]? | {id, name, defaultBid: .defaultBidAmount.amount, searchMatch: .automatedKeywordsOptIn}]'
```

## Optimization levers (limited)

Since there are no targeting keywords, keyword-level bid changes and pauses are impossible. The only levers:
- **Budget reduction** -- reduce daily budget to control total spend
- **Set explicit defaultBidAmount** -- on the ad group to cap CPTs
- **Search term negatives** -- mine search terms and negate losers at campaign level

## Keyword reports return empty

This is expected, not an error. The campaign uses only Search Match. Keyword reports return `[]`. Search term reports still work and show traffic mapped to `keyword: null`.

## CPI context

At $10/day budget but approximately $0.94/day actual spend (observed 2026-05-12), the budget is not the constraint. Apple's matching algorithm just does not find many relevant queries. CPI was $2.20 over 7 days (3 installs from 8 taps). This campaign tends to be a high-CPI black box.