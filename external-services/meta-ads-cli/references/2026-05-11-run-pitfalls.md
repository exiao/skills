# Meta Ads Run Pitfalls — 2026-05-11

Reusable lessons from the 2026-05-11 scheduled run.

## Preflight capacity before creative generation

Observed state: 39 active target ads, but Meta returned `1487809 Too Many Ads` on the first new ad create. The active count was misleading because Meta's limit includes paused/inactive ads at the campaign/ad set/account level.

Do not wait until after expensive creative generation to discover this. Before Step 5 image generation, count existing ads by target ad set from the **account-level** ad listing, including active, paused, inactive, pending, and other non-archived statuses.

Recommended logic:

1. Pull account-level ads with `fields=id,name,status,effective_status,adset_id,created_time` and `limit=500`.
2. Filter by `adset_id in {ADSET_IOS, ADSET_ANDROID}`.
3. Treat any ad whose `status` is not `ARCHIVED` as consuming capacity.
4. Calculate available slots per ad set before generating creatives.
5. If either ad set has fewer than 6 free slots, stop before generating images and report that cleanup/fresh ad sets are needed.

Why: if one platform has no capacity, the run cannot safely create paired iOS + Android ads. Partial rollout is explicitly disallowed.

## Orphaned creative objects on 1487809

In this run, the upload script uploaded image 1 and created two ad creative objects before the first `ads` create call failed with `1487809`:

- iOS creative object: `1524563342596952`
- Android creative object: `1234631541881769`
- No ad objects were created

Future runs should log this exact distinction: image uploaded, creative objects created, ad objects created. If ad creation fails, do not claim "nothing was created" unless checked against `/adcreatives` or the local upload log.

## Wrong Bloom logo is a hard QA fail

The 2026-05-11 generated creatives used incorrect Bloom logos. Treat logo accuracy as part of visual QA, not a nice-to-have.

Rules:

- Compare any visible logo to `assets/bloom-logo.png`.
- Correct mark: exactly three teal circles, medium teal left, large light-teal top-right, small dark-teal bottom-right.
- Hard fail: feather/leaf/checkmark, four circles, garbled blob, off-brand geometry, competitor logo, or any model-invented teal mark.
- Preferred fix: do not ask image models to draw the logo. Generate the background, then composite the real logo deterministically with PIL/SVG/canvas.
- Missing logo is acceptable when the format does not need branding. Wrong logo is never acceptable.
- If a canonical logo composite is too small or ambiguous for vision QA to confidently verify, remove the mark and use plain text `Bloom` branding. A tiny teal blob is still a logo QA failure.

## Correcting a failed creative pack

When a generated pack has wrong or garbled logos, repair or remove the failing assets before any upload:

1. Locate the latest `ads/iteration/creatives/<date-or-campaign>/` folder and inspect `contact-sheet.png` plus `manifest.md`.
2. Move stale alternate exports to trash if they still contain the bad logo, especially `01-...png`, matching `.svg` files, and old secondary zips. Upload scripts should only see the corrected `creative-N-<slug>.png` files.
3. Re-render uploadable files deterministically at the platform target size, usually 1080×1080 for square Meta placements.
4. If the Bloom logo is not essential, remove all logo-like marks and use plain text `Bloom` in the header. This is safer than shipping an ambiguous or wrong mark.
5. Rebuild `contact-sheet.png`, `manifest.md`, `ad-copy.csv`, the upload zip, and a `visual-qa.md` note documenting pass/fail.
6. Run vision QA on the final contact sheet with a prompt that asks whether any logo-like marks remain. Only ship if it lists zero failing filenames.

## Deterministic overlay fallback works

All six 2026-05-11 creatives were rendered with deterministic PIL text/logo overlays and passed visual QA. This is a reliable fallback when image models are slow, unavailable, or text-heavy prompts risk misspellings.

Use it as a valid execution path, not a last-resort hack:

- Use image models for backgrounds or stylistic assets when time/capacity allows.
- Render all important words and Bloom logo with PIL/SVG/canvas.
- QA the final PNG with vision before upload.

## Report capacity blocks explicitly

When `1487809` occurs, final report should include:

- The exact error code/subcode and message.
- Whether any image uploads, ad creative objects, or ad objects were created.
- That the owner must archive/clean old ads or create fresh ad sets.
- The generated creatives as attachments if they passed QA, even though upload failed.
