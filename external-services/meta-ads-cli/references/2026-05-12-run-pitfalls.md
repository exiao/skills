# Meta Ads Run Pitfalls — 2026-05-12

Reusable lessons from the 2026-05-12 scheduled run.

## gpt-image-2 (OpenAI) consistently times out

The OpenAI Images API (`/v1/images/generations` with `model: gpt-image-2`) has timed out in multiple runs now (2026-05-10, 2026-05-12). Even with `--max-time 240` on curl, the request returns an empty response body.

**Workaround:** When gpt-image-2 times out, immediately fall back to either:
- **Nano Banana Pro** for text-heavy formats (notes, tickets, receipts, cards)
- **Higgsfield gpt_image_2** for photorealistic/complex scenes

Do not retry gpt-image-2 more than once per run. The Higgsfield `gpt_image_2` model uses the same underlying OpenAI model but routes through Higgsfield's infrastructure, which handles the timeout/polling internally via `--wait`.

**Model assignment strategy when gpt-image-2 is unreliable:**
- Nano Banana Pro: 4 of 6 creatives (best for text-heavy parody formats)
- Higgsfield gpt_image_2: 2 of 6 creatives (photorealistic scenes)
- OpenAI gpt-image-2 direct: attempt first, fall back immediately on timeout

## Archiving old ads to free capacity

When both ad sets are at 50/50 (including paused), archive the oldest paused ads:

```bash
# Find oldest paused ads per ad set, then archive
curl -s -X POST "$GRAPH_URL/$AD_ID" -F "status=ARCHIVED" -F "access_token=$TOKEN"
```

Key rules:
- Archive 6+ per ad set to make room for a full 6-creative batch
- Target the oldest paused ads first (April-era before May-era)
- DISAPPROVED ads count toward the limit and can be archived
- Verify capacity after archiving before generating creatives

## Already-archived ads cannot be paused

If a kill target returns error 1885088 ("Archived Ads Can't Be Edited"), it's already archived. Log it and move on. Only `name` can be edited on archived ads.

## May 10 batch showing 0 impressions

All 12 May 10 ads showed 0 impressions after 2+ days. Flag zero-impression ads older than 48h in the daily report for manual investigation. Possible causes: approval queue delay, creative policy review for novel formats, or ad set budget exhaustion across too many active ads.

## "Official document parody" format category

New format family tested: parking-ticket, report-card, speed-camera, portfolio-test, missing-poster, prescription-label. All share the "realistic official document repurposed for investing humor" concept.

Track as a category. If several outperform, mine more document types (jury summons, warranty card, insurance claim, inspection sticker, diploma, etc.).
