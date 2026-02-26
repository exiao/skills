---
name: google-ads
description: "Use when managing Google Ads campaigns: performance checks, keyword pausing, report downloads, or campaign optimization via browser or API."
---

# Google Ads Skill

Manage Google Ads accounts via API or browser automation.

## Mode Selection

**Check which mode to use:**

1. **API Mode** - If user has `google-ads.yaml` configured or `GOOGLE_ADS_*` env vars
2. **Browser Mode** - If user says "I don't have API access" or just wants quick checks

```bash
# Check for API config
ls ~/.google-ads.yaml 2>/dev/null || ls google-ads.yaml 2>/dev/null
```

If no config found, ask: "Do you have Google Ads API credentials, or should I use browser automation?"

---

## Browser Automation Mode (Universal)

**Requirements:** User logged into ads.google.com in browser

### Setup
1. User opens ads.google.com and logs in
2. User clicks Clawdbot Browser Relay toolbar icon (badge ON)
3. Use `browser` tool with `profile="chrome"`

### Common Workflows

#### Get Campaign Performance
```
1. Navigate to: ads.google.com/aw/campaigns
2. Set date range (top right date picker)
3. Snapshot the campaigns table
4. Parse: Campaign, Status, Budget, Cost, Conversions, Cost/Conv
```

#### Find Zero-Conversion Keywords (Wasted Spend)
```
1. Navigate to: ads.google.com/aw/keywords
2. Click "Add filter" → Conversions → Less than → 1
3. Click "Add filter" → Cost → Greater than → [threshold, e.g., $500]
4. Sort by Cost descending
5. Snapshot table for analysis
```

#### Pause Keywords/Campaigns
```
1. Navigate to keywords or campaigns view
2. Check boxes for items to pause
3. Click "Edit" dropdown → "Pause"
4. Confirm action
```

#### Download Reports
```
1. Navigate to desired view (campaigns, keywords, etc.)
2. Click "Download" icon (top right of table)
3. Select format (CSV recommended)
4. File downloads to user's Downloads folder
```

**For detailed browser selectors:** See `references/browser-workflows.md`

---

## API Mode (Power Users)

**Requirements:** Google Ads API developer token + OAuth credentials

### Setup Check
```bash
# Verify google-ads SDK
python -c "from google.ads.googleads.client import GoogleAdsClient; print('OK')"

# Check config
cat ~/.google-ads.yaml
```

### Common Operations

#### Query Campaign Performance
```python
from google.ads.googleads.client import GoogleAdsClient

client = GoogleAdsClient.load_from_storage()
ga_service = client.get_service("GoogleAdsService")

query = """
    SELECT campaign.name, campaign.status,
           metrics.cost_micros, metrics.conversions,
           metrics.cost_per_conversion
    FROM campaign
    WHERE segments.date DURING LAST_30_DAYS
    ORDER BY metrics.cost_micros DESC
"""

response = ga_service.search(customer_id=CUSTOMER_ID, query=query)
```

#### Find Zero-Conversion Keywords
```python
query = """
    SELECT ad_group_criterion.keyword.text,
           campaign.name, metrics.cost_micros
    FROM keyword_view
    WHERE metrics.conversions = 0
      AND metrics.cost_micros > 500000000
      AND segments.date DURING LAST_90_DAYS
    ORDER BY metrics.cost_micros DESC
"""
```

#### Pause Keywords
```python
operations = []
for keyword_id in keywords_to_pause:
    operation = client.get_type("AdGroupCriterionOperation")
    operation.update.resource_name = f"customers/{customer_id}/adGroupCriteria/{ad_group_id}~{keyword_id}"
    operation.update.status = client.enums.AdGroupCriterionStatusEnum.PAUSED
    operations.append(operation)

service.mutate_ad_group_criteria(customer_id=customer_id, operations=operations)
```

**For full API reference:** See `references/api-setup.md`

---

## Google Ads Scripts

For recurring automation tasks, use Google Ads Scripts (JavaScript running in Google Ads editor). See `references/google-ads-scripts.md` for the full guide including:

- AdsApp API fundamentals (selectors, iterators, statistics)
- Campaign, ad group, keyword, and ad operations
- Bid optimization (ROAS/CPA-based)
- Performance reporting and Google Sheets export
- Budget management and spending alerts
- Automated rules (pause low-quality keywords, quality score monitoring)
- Error handling and debugging patterns

**Additional script resources:**
- `references/google-ads-scripts-api-reference.md` — Complete AdsApp API reference
- `references/google-ads-scripts-examples.md` — Production-ready code examples
- `references/google-ads-scripts-best-practices.md` — Best practices with code
- `references/google-ads-scripts-patterns.md` — Reusable automation patterns
- `references/google-ads-scripts-validators.py` — Python validation utilities
- `references/google-ads-scripts-campaign-optimizer.js` — Campaign optimizer template
- `references/google-ads-scripts-bid-manager.js` — Bid manager template

---

## Audit Checklist

Quick health check for any Google Ads account:

| Check | Browser Path | What to Look For |
|-------|--------------|------------------|
| Zero-conv keywords | Keywords → Filter: Conv<1, Cost>$500 | Wasted spend |
| Empty ad groups | Ad Groups → Filter: Ads=0 | No creative running |
| Policy violations | Campaigns → Status column | Yellow warning icons |
| Optimization Score | Overview page (top right) | Below 70% = action needed |
| Conversion tracking | Tools → Conversions | Inactive/no recent data |

---

## Output Formats

When reporting findings, use tables:

```markdown
## Campaign Performance (Last 30 Days)
| Campaign | Cost | Conv | CPA | Status |
|----------|------|------|-----|--------|
| Branded  | $5K  | 50   | $100| ✅ Good |
| SDK Web  | $10K | 2    | $5K | ❌ Pause |

## Recommended Actions
1. **PAUSE**: SDK Web campaign ($5K CPA)
2. **INCREASE**: Branded budget (strong performer)
```

---

## Common Mistakes

1. **Using dashes in Customer ID** — The Google Ads API requires the 10-digit customer ID without dashes (e.g., `1234567890` not `123-456-7890`). Wrong format causes immediate authentication failure.
2. **RSA character limits ignored** — Headlines max 30 chars, descriptions max 90 chars. Exceeding these silently truncates or rejects ads. Always count before submitting.
3. **Developer token in test mode** — A test-mode developer token can query the API but can't modify campaigns. If mutations silently fail, verify the token is approved for production.
4. **Checking UI before waiting for tables** — The Google Ads UI is heavy and loads data asynchronously. Taking a snapshot too early captures loading spinners, not data. Wait for tables to fully render.
5. **`proto-plus CopyFrom` errors on create** — Assign resource fields directly (e.g., `operation.create = campaign`) rather than using `CopyFrom` on create operations; `CopyFrom` is for updates only.

## Troubleshooting

### Browser Mode Issues
- **Can't see data**: Check user is on correct account (top right account selector)
- **Slow loading**: Google Ads UI is heavy; wait for tables to fully load
- **Session expired**: User needs to re-login to ads.google.com

### API Mode Issues
- **Authentication failed**: Refresh OAuth token, check `google-ads.yaml`
- **Developer token rejected**: Ensure token is approved (not test mode)
- **Customer ID error**: Use 10-digit ID without dashes
- **proto-plus CopyFrom errors**: Assign directly (e.g., `operation.create = obj`) instead of `CopyFrom` on create fields
- **contains_eu_political_advertising required**: Set to integer `0/1` (not boolean)
- **RSA text too long**: Headlines max 30 chars, descriptions max 90 chars
