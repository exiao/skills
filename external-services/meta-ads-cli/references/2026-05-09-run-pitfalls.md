# Meta Ads Run Pitfalls — 2026-05-09

Reusable lessons from the 2026-05-09 scheduled run.

## Meta Ad Library API auth failure

Observed response when querying `ads_archive`:

```json
{
  "error": {
    "message": "Application does not have permission for this action",
    "type": "OAuthException",
    "code": 10,
    "error_subcode": 2332002,
    "error_user_title": "Authorization and login needed",
    "error_user_msg": "To access the API, you'll need to follow the steps at facebook.com/ads/library/api."
  }
}
```

Treat this like a 403 for the cron workflow:
- Do not open Facebook or attempt browser login.
- Fall back to public web search / Firecrawl.
- Save a competitor research file that clearly says API access was unavailable.

## Meta max-ad limit during upload

Observed when creating a new ad:

```json
{
  "error": {
    "code": 100,
    "error_subcode": 1487809,
    "error_user_title": "Too Many Ads",
    "error_user_msg": "Each ad set can contain a maximum of 50 ads. This includes paused / inactive / turned off ads."
  }
}
```

Handling:
- Stop uploads immediately.
- Do not continue with Android if iOS failed, or vice versa.
- Log whether image uploads or ad creative objects were already created.
- Report that Eric needs to clean old ads or create fresh ad sets.

## Text-safe creative generation

The robust pattern for static Meta ads:
1. Use Nano Banana / gpt-image-2 / Higgsfield to generate mostly text-free backgrounds.
2. Render final headline, CTA, disclaimer, card UI, and Bloom logo deterministically with SVG or canvas.
3. Use `rsvg-convert -w 1080 -h 1080 input.svg -o output.png` when Pillow is unavailable.
4. Run vision QA on final PNGs.

This avoids model misspellings and garbled logos while preserving varied backgrounds.
