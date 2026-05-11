# Meta Ads Run Pitfalls

Reusable lessons from scheduled Meta Ads runs.

## Meta Ad Library API auth failure

Observed response when querying `ads_archive`:

```json
{
  "error": {
    "message": "Application does not have permission for this action",
    "type": "OAuthException",
    "code": 10,
    "error_subcode": 2332002,
    "error_user_title": "Authorization and login needed"
  }
}
```

Handling:
- Treat this like a 403 for the workflow.
- Do not attempt browser login unless the user explicitly asks.
- Fall back to public web search or approved scraping tools.
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
- Do not continue uploading into sibling ad sets if the same account cleanup is required.
- Log whether image uploads or creative objects were already created.
- Ask the account owner to archive old ads or create fresh ad sets.

## Text-safe creative generation

The robust pattern for static Meta ads:
1. Use image models to generate mostly text-free backgrounds.
2. Render final headline, CTA, disclaimer, card UI, and logo deterministically with SVG or canvas.
3. Use `rsvg-convert -w 1080 -h 1080 input.svg -o output.png` when Pillow is unavailable.
4. Run visual QA on final PNGs.

This avoids model misspellings and garbled logos while preserving varied backgrounds.
