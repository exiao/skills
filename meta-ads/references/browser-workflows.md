# Meta Ads Browser Workflows

Browser automation workflows for Meta Ads Manager.

## Setup

1. User opens business.facebook.com/adsmanager and logs in
2. User clicks Clawdbot Browser Relay toolbar icon (badge ON)
3. Use `browser` tool with `profile="chrome"`

## Campaign Setup

```
1. browser:navigate → business.facebook.com/adsmanager
2. Create campaign → Choose objective:
   - Traffic (CPC testing): Best for initial creative testing
   - Conversions: Once pixel has 50+ conversions/week
   - Lead Gen: In-platform forms
3. Set audience, budget, placements
4. Upload creatives
5. Launch
```

## CPC Testing Protocol (the $100/3-day method)

- Upload all variations into one CPC campaign
- Set $100 budget over 3 days
- Cheapest CPC wins → scale that creative

## Optimization Workflows

### Check Performance
```
1. Navigate to Ads Manager
2. Set date range
3. Review: CPC, CTR, CPM, ROAS at ad level
4. Snapshot the results table
```

### Kill Underperformers
```
1. Filter to ads with 1,000+ impressions
2. Sort by CPM or CPC
3. Toggle off ads above 2x median CPM
```

### Scale Winners
- Increase budget 20% every 2-3 days for winning ads
- Refresh creative every 2-4 weeks (fatigue)

## Platform Decision Guide

| Factor | Detail |
|--------|--------|
| Best for | Demand generation, visual products, cold audiences |
| Creative | Images, video, carousels (lo-fi wins) |
| Targeting | Interests, lookalikes, custom audiences |
| Testing | CPC test 30-40 variations, $100/3 days |
| Pixel requirement | 50+ conversions/week for Conversions objective |
| Budget minimum | $5-10/day per ad set |
