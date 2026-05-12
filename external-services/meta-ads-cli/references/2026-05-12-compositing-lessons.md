# Compositing Lessons — 2026-05-12

Reusable lessons from the 2026-05-12 creative regeneration session.

## NEVER ship pure PIL/deterministic flat cards

Pure PIL-rendered cards with solid color backgrounds look like programmer art. Eric explicitly rejected them ("these are HORRIBLE"). They are not acceptable as ad creatives even as a fallback.

Correct workflow:
1. Generate a rich AI background with the assigned model. Prompt should include "No text, no logos, no words" to get a clean background.
2. Composite text, CTA buttons, and the real Bloom logo deterministically on top using PIL/SVG/canvas.
3. Vision-QA the final composite.

If all three image models (Nano Banana Pro, gpt-image-2, Higgsfield) are unavailable, report that creative generation is blocked rather than shipping flat cards.

## Gradient overlay opacity kills AI backgrounds

When compositing text over AI-generated backgrounds, dark gradient overlays wash out the background imagery. This was the most time-consuming bug in this session — required 4 iterations to get right.

Rules:
- Start with very low overlay opacity: alpha 40-80, not 140-200.
- Dark AI backgrounds (navy/charcoal with glowing elements) are especially vulnerable. Even alpha=120 makes them look like solid black.
- For already-dark backgrounds, use `ImageEnhance.Brightness(img).enhance(1.2-1.3)` instead of a gradient overlay. This brightens the glowing elements without adding a dark wash.
- Place text on semi-opaque card elements (alpha 200-220) for readability rather than darkening the entire image.
- Vision-check after compositing: "is the AI background visible?" If it reads as solid black, reduce opacity or skip the overlay entirely.

## Higgsfield JSON output is a JSON array, not JSONL

`higgsfield generate create ... --wait --json` outputs a JSON array `[{...}]`, not one JSON object per line. Parsing with `json.loads(line)` on the first `{` character fails because the first character is `[`. Use `json.load(f)` on the full file and index `[0]` to get the result object. The `result_url` key contains the download URL.

## GEMINI_API_KEY location

The openclaw.json lookup for `GEMINI_API_KEY` often returns empty. The key lives in `~/.hermes/.env`. Always `set -a; source ~/.hermes/.env; set +a` before running Nano Banana Pro or gpt-image-2 via curl.

## CTWA campaign prerequisite: WABA phone number

Click-to-WhatsApp ads require a production WhatsApp Business phone number registered in Meta's WABA and linked to the ad account. Before attempting to create a CTWA campaign:

1. Query the business's WABAs: `GET /{business_id}/owned_whatsapp_business_accounts`
2. For each WABA, query phone numbers: `GET /{waba_id}/phone_numbers`
3. Verify a production (non-test) phone number exists with `status=CONNECTED`
4. If no production number exists, stop and report the blocker — do not attempt to create the campaign

The Bloom Business ID is 1428255340673915. As of 2026-05-12, the Bloom WABA (110591981930436) had zero production phone numbers. The only number found was a test number (+1 555-098-6539) on a separate test WABA.

## Baileys breaks under WhatsApp Coexistence

Registering a WhatsApp Business App number in a WABA via Meta's "Coexistence" mode disables end-to-end encryption. Baileys relies on Signal protocol E2E encryption to function. Per WhiskeySockets/Baileys#2152: after coexistence onboarding, Baileys can connect but cannot send messages. No fix exists.

BloomBot's number (+1 929-326-2783) runs on Baileys. Do NOT register it in Meta's WABA.

Workaround: use a Traffic campaign with `wa.me` deep links as the destination URL instead of native CTWA. See `references/click-to-whatsapp-bloombot.md` for the full setup.

## Bloom logo compositing via PIL with transparent background

The canonical logo at `assets/bloom-logo.png` has a white background. To composite it onto a non-white image:

1. Open as RGBA.
2. Walk pixels: any (r>240, g>240, b>240) -> set alpha to 0.
3. `getbbox()` + `crop()` to remove whitespace.
4. `thumbnail((size, size))` to scale.
5. `img.alpha_composite(logo, (x, y))` onto the target.

At small sizes (<60px), the three circles become ambiguous and look like garbled marks in vision QA. Either use 70px+ or skip the logo entirely (missing logo is acceptable).
