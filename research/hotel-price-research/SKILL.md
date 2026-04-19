---
name: hotel-price-research
description: Research hotel pricing across OTAs for a booking decision. Use when the user is comparing hotels for specific dates and wants real prices (not fabricated). Covers known OTA blockers (Trip.com, IHG.com, Google Hotels) and the Booking.com interactive-form workflow that actually works. Trigger on "hotel price", "compare hotels", "check rates", "what's <hotel> cost on <dates>", or multi-hotel shortlist research.
---

# Hotel Price Research

## When to use
User is evaluating hotels for real dates and wants real prices. Often a $500+ decision — do **not** fabricate numbers. If you can't get a price, say so.

## Known dead ends (don't retry these)
- **Trip.com** — sign-in wall blocks direct URL scraping even with pre-filled `checkIn`/`checkOut` params. WebExtract returns the login page.
- **IHG.com** — bot detection blocks scraping. Member rates, award nights, and promo eligibility (e.g. "Stay 3 Pay 2") are not retrievable programmatically.
- **Google Hotels** — URL date params (`checkin`/`checkout`) are ignored; picker defaults to ~1 month out. Snapshot often empty after date clicks.
- **DuckDuckGo / Google Search** — CAPTCHA walls.
- **browser_vision** — temperature param deprecated (as of this skill's creation).

## Working channel: Booking.com

Booking.com accepts interactive form filling via the browser tool. URL params are unreliable, so drive the form:

1. `browser_navigate` to `https://www.booking.com/`
2. `browser_snapshot` to find the search input ref
3. `browser_type` the hotel name into the search box
4. `browser_snapshot` — autocomplete panel appears
5. `browser_click` the matching autocomplete option (not just the search button)
6. `browser_click` the date field → calendar opens
7. `browser_snapshot` → find check-in day ref, `browser_click` it
8. `browser_snapshot` → find check-out day ref, `browser_click` it (calendar re-renders after each click, so always re-snapshot)
9. Adjust occupancy if needed (default is 2 adults)
10. `browser_click` Search
11. Results page shows room types + total price for the stay + refundable vs non-refundable variants

## What Booking.com **won't** give you
- IHG member rates (IHG One Rewards)
- IHG award nights (points pricing)
- IHG promo eligibility (Stay 3 Pay 2, seasonal deals)
- Hotel-direct discounts
- Club-tier / suite-upgrade pricing on some brands

If the user specifically wants a loyalty rate or promo, be honest: explain those are only on the brand site, which is blocked to scraping, and offer to prep a checklist they can run manually while signed in.

## Output format for multi-hotel comparison
For each hotel, capture:
- **Total for stay** (all nights, in displayed currency)
- **Nightly rate** (total ÷ nights)
- **Room type** (standard, club, suite)
- **Refundable?** (yes/no)
- **Source** (Booking.com, rate family, date pulled)

Present as a bullet list, not a markdown table (Signal/plain-text friendly). If the user is on desktop and asked for a table explicitly, use one.

## Honesty rule
If OTAs are all blocked for a given hotel, say so and suggest:
1. The user check manually while signed in (they can get member rates you can't).
2. A direct-dial to the hotel's reservations desk for complex requests (club-tier, award, promo combo).
3. Trying again from a different IP / fresh session.

Never invent prices. Never extrapolate from an old data point with different dates or guest counts — flag it as stale.

## Trip.com URL pattern (user-provided shortcut)
Users sometimes paste Trip.com hotel URLs with `?checkIn=YYYY-MM-DD&checkOut=YYYY-MM-DD`. These will still hit the sign-in wall when scraped, but the URL itself is a useful reference for the user to click manually. Keep the links in the output for their convenience; extract pricing via Booking.com in parallel.
