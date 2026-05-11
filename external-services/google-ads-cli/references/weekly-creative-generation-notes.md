# Weekly Creative Generation Notes

Session-derived notes for report-only Google App Campaign creative refreshes.

## Google Ads API quirks

- If `GoogleAdsClient.load_from_storage()` tries `~/google-ads.yaml` even though config exists at `~/.google-ads.yaml`, pass the path explicitly:
  ```python
  import os
  client = GoogleAdsClient.load_from_storage(os.path.expanduser('~/.google-ads.yaml'))
  ```
- `ad_group_ad_asset_view` is the right view for App Campaign asset reporting, but it is not compatible with `campaign_budget.amount_micros`. Pull budgets from a separate `campaign` query if needed. If included in the asset query, Google Ads returns `PROHIBITED_RESOURCE_TYPE_IN_SELECT_CLAUSE` for `CAMPAIGN_BUDGET`.
- Include `metrics.conversions_value` for tROAS campaigns and rank image/video assets by value and ROAS, not only conversions.

## DataForSEO competitor title lookup

`dataforseo_labs/apple/app_competitors/live` may return app IDs and positions without app titles. Resolve titles with the iTunes lookup API:

```python
import json, urllib.request
ids = ','.join(app_ids)
url = 'https://itunes.apple.com/lookup?id=' + ids + '&country=us'
data = json.load(urllib.request.urlopen(url))
```

## Higgsfield image sizing

`seedream_v5_lite` may not support `--aspect_ratio 2:1`; check the model schema first:

```bash
higgsfield model get seedream_v5_lite --json
```

If only `16:9` is available, generate high-res 16:9 and crop/resize to Google landscape spec:

```bash
higgsfield generate create seedream_v5_lite \
  --prompt "..." \
  --aspect_ratio 16:9 \
  --quality high \
  --wait --json

# macOS fallback without ImageMagick/Pillow: crop to 1.91:1 then resize to 1200x628
sips -c 2144 4096 input.png --out cropped.png
sips -z 628 1200 cropped.png --out google-landscape.png
sips -s format jpeg -s formatOptions 92 google-landscape.png --out google-landscape.jpg
```

Use 1:1 directly for square variants and resize to 1200x1200.

## Chart/callout double-down pattern

When a known winning image is a clean chart/callout creative, do not regress to generic phone mockups. Make variants that preserve the causal visual grammar:

- White background
- Thick green rising stock line
- Orange event marker at the inflection point
- Small tooltip connected to the marker
- Neutral event language: `Earnings beat`, `Analyst upgrade`, `Guidance raised`, `Market-moving news`
- Avoid real tickers, guaranteed returns, and copy that sounds like timed trading advice

Visual QA should explicitly check: legible text, correct spelling, no wrong logos, no people/phones if the winner had none, no artifacts, no misleading financial promises.

## Hard quality gate after 2026-05-10 rejection

Eric rejected the previous generated candidate as unacceptable for ads. Treat this as a strict taste bar, not a minor preference.

Reject and do not attach any asset that looks like generic AI ad slop: bland finance charts, abstract arrows, meaningless dashboards, fake polished templates, crypto/Wall Street clichés, clipart people, awkward typography, overproduced AI gloss, or visuals that are only loosely related to Bloom.

Approved assets need to score at least 4/5 overall, with no category below 3/5, on:
- Specificity to Bloom's real value prop
- Taste/design quality
- Typography/readability
- Non-generic finance visual
- Policy safety

Rejected assets must not appear as MEDIA attachments, must not be called uploadable, and must not be included in an upload CTA. If nothing clears the gate, report that no usable image assets were generated and attach zero images.
