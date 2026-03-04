# Analytics & Feedback Loop

## Performance Tracking

Pull analytics directly from each platform's native API or dashboard. Track at two levels: platform-level (followers, aggregate views) and per-post (views, likes, comments, shares).

Key fields to capture per post:
```json
{
  "date": "2026-02-15",
  "hook": "hook text exactly as posted",
  "hookCategory": "person-conflict-ai",
  "views": 15000,
  "likes": 450,
  "comments": 23,
  "saves": 89,
  "platform": "tiktok",
  "postId": "platform-native-id",
  "appCategory": "home"
}
```

Store in `hook-performance.json`. Update within 24-48h of each post.

**Note on TikTok:** Per-post analytics may return empty arrays for some posts. Fall back to the **delta method**: record platform-level view totals before and after each post to estimate per-post views.

### RevenueCat Integration (Optional)

If RevenueCat is connected, track conversions from TikTok:
- Downloads → Trial starts → Paid conversions
- UTM parameters in App Store link
- Compare conversion spikes with post timing

## The Feedback Loop

### After Every Post (24h)
Record in `hook-performance.json`:
```json
{
  "posts": [
    {
      "date": "2026-02-15",
      "hook": "boyfriend said flat looks like catalogue",
      "hookCategory": "person-conflict-ai",
      "views": 15000,
      "likes": 450,
      "comments": 23,
      "saves": 89,
      "postId": "platform-post-id",
      "appCategory": "home"
    }
  ]
}
```

### Weekly Review
1. Sort posts by views
2. Identify top 3 hooks → create variations
3. Identify bottom 3 hooks → drop or radically change
4. Check if any hook CATEGORY consistently wins
5. Update prompt templates with learnings

### Decision Rules

| Views | Action |
|-------|--------|
| 50K+ | DOUBLE DOWN — make 3 variations immediately |
| 10K-50K | Good — keep in rotation, test tweaks |
| 1K-10K | Okay — try 1 more variation before dropping |
| <1K (twice) | DROP — radically different approach needed |

### What to Vary When Iterating
- **Same hook, different person:** "landlord" → "mum" → "boyfriend"
- **Same structure, different room/feature:** bedroom → kitchen → bathroom
- **Same images, different text:** proven images can be reused with new hooks
- **Same hook, different time:** morning vs evening posting

## Conversion Tracking

### Funnel
```
Views → Profile Visits → Link Clicks → App Store → Download → Trial → Paid
```

### Benchmarks
- 1% conversion (views → download) = average
- 1.5-3% = good
- 3%+ = great

### Attribution Tips
- Track download spikes within 24h of viral post
- Use unique UTM links per campaign if possible
- RevenueCat `$attribution` for source tracking
- Compare weekly MRR growth with weekly view totals

## Daily Analytics Cron

Set up a cron job to run every morning before the first post (e.g. 7:00 AM user's timezone):

```
Task: Pull last 3 days of posts → fetch analytics → cross-reference conversions → apply diagnostic → suggest hooks → message user
Output: tiktok-marketing/reports/YYYY-MM-DD.md
```

The daily report:
1. Pulls per-post analytics (views, likes, comments, shares) from platform APIs
2. If RevenueCat is connected, pulls conversion events (trials, purchases) in the same window
3. Cross-references: maps conversion timestamps to post publish times (24-72h attribution window)
4. Applies the diagnostic framework:
   - High views + High conversions → SCALE (make variations)
   - High views + Low conversions → FIX CTA (hook works, downstream is broken)
   - Low views + High conversions → FIX HOOKS (content converts, needs more eyeballs)
   - Low views + Low conversions → FULL RESET (try radically different approach)
5. Suggests 3-5 new hooks based on what's working
6. Updates `hook-performance.json` with latest data
7. Messages the user with a summary

### Why 3 Days?
- TikTok posts peak at 24-48 hours (not instant like Twitter)
- Conversion attribution takes up to 72 hours (user sees post → downloads → trials → pays)
- 3-day window captures the full lifecycle of each post

### RevenueCat Integration
When connected, the daily report pulls:
- **Trial starts** within 24-72h of each post → maps to which hooks drive installs
- **Paid conversions** (initial purchase + trial converted) → maps to which CTAs convert
- **Revenue** per period → tracks actual MRR impact of content

This is the difference between "this post got 50K views" (vanity) and "this post generated $47 in new subscriptions" (intelligence).
