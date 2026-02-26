# The Feedback Loop (CRITICAL — This is What Makes It Work)

This is what separates "posting TikToks" from "running a marketing machine." The daily cron pulls data from two sources:

1. **Postiz** → per-post TikTok analytics (views, likes, comments, shares)
2. **RevenueCat** (if connected) → conversion data (trial starts, paid subscriptions, revenue)

Combined, the agent can make intelligent decisions about what to do next — not guessing, not vibes, actual data-driven optimization.

### The Daily Cron (Set Up During Onboarding)

Every morning before the first post, the cron runs `scripts/daily-report.js`:

1. Pulls the last 3 days of posts from Postiz (posts peak at 24-48h)
2. Fetches per-post analytics for each (views, likes, comments, shares)
3. If RevenueCat is connected, pulls conversion events in the same window (24-72h attribution)
4. Cross-references: which posts drove views AND which drove paying users
5. Applies the diagnostic framework (below) to determine what's working
6. Generates `tiktok-marketing/reports/YYYY-MM-DD.md` with findings
7. Messages the user with a summary + suggested hooks for today

### The Diagnostic Framework

This is the core intelligence. Two axes: **views** (are people seeing it?) and **conversions** (are people paying?).

**High views + High conversions** → 🟢 SCALE IT
- This is working. Make 3 variations of the winning hook immediately
- Test different posting times to find the sweet spot
- Cross-post to more platforms for extra reach
- Don't change anything about the CTA — it's converting

**High views + Low conversions** → 🟡 FIX THE CTA
- The hook is doing its job — people are watching. But they're not downloading/subscribing
- Try different CTAs on slide 6 (direct vs subtle, "download" vs "search on App Store")
- Check if the app landing page matches the promise in the slideshow
- Test different caption structures — maybe the CTA is buried
- The hook is gold — don't touch it. Fix everything downstream

**Low views + High conversions** → 🟡 FIX THE HOOKS
- The people who DO see it are converting — the content and CTA are great
- But not enough people are seeing it, so the hook/thumbnail isn't stopping the scroll
- Test radically different hooks (person+conflict, POV, listicle, mistakes format)
- Try different posting times and different slide 1 images
- Keep the CTA and content structure identical — just change the hook

**Low views + Low conversions** → 🔴 FULL RESET
- Neither the hook nor the conversion path is working
- Try a completely different format or approach
- Research what's trending in the niche RIGHT NOW (use browser)
- Consider a different target audience angle
- Test new hook categories from scratch
- Reference competitor research for what's working for others

**High views + High downloads + Low paying subscribers** → 🔴 APP ISSUE
- The marketing is working. People are watching AND downloading. But they're not paying.
- This is NOT a content problem — the app onboarding, paywall, or pricing needs fixing.
- Check: Is the paywall shown at the right time? Is the free experience too generous?
- Check: Does the onboarding guide users to the "aha moment" before the paywall?
- Check: Is the pricing right? Too expensive for the perceived value?
- **This is a signal to pause posting and fix the app experience first**

**High views + Low downloads** → 🟡 CTA ISSUE
- People are watching but not downloading. The hooks work, the CTAs don't.
- Rotate through different CTAs: "link in bio", "search on App Store", app name only, "free to try"
- Check the App Store page — does it match what the TikTok shows?
- Check that "link in bio" actually works and goes to the right place

**The daily report automates all of this.** It cross-references TikTok views (Postiz) with downloads and revenue (RevenueCat) and tells you exactly which part of the funnel is broken — per post. It also auto-generates new hook suggestions based on your winning patterns and flags when CTAs need rotating.

### Hook Evolution

Track in `tiktok-marketing/hook-performance.json`:

```json
{
  "hooks": [
    {
      "postId": "postiz-id",
      "text": "My boyfriend said our flat looks like a catalogue",
      "app": "snugly",
      "date": "2026-02-15",
      "views": 45000,
      "likes": 1200,
      "comments": 45,
      "shares": 89,
      "conversions": 4,
      "cta": "Download Snugly — link in bio",
      "lastChecked": "2026-02-16"
    }
  ],
  "ctas": [
    {
      "text": "Download [App] — link in bio",
      "timesUsed": 5,
      "totalViews": 120000,
      "totalConversions": 8,
      "conversionRate": 0.067
    },
    {
      "text": "Search [App] on the App Store",
      "timesUsed": 3,
      "totalViews": 85000,
      "totalConversions": 12,
      "conversionRate": 0.141
    }
  ],
  "rules": {
    "doubleDown": ["person-conflict-ai"],
    "testing": ["listicle", "pov-format"],
    "dropped": ["self-complaint", "price-comparison"]
  }
}
```

**The daily report updates this automatically.** Each post gets tagged with its hook text, CTA, view count, and attributed conversions. Over time, this builds a clear picture of which hook + CTA combinations actually drive revenue — not just views.

**CTA rotation:** When the report detects high views but low conversions, it automatically recommends rotating to a different CTA and tracks performance of each CTA separately. The agent should tag every post with the CTA used so the data accumulates.
```

**Decision rules:**
- 50K+ views → DOUBLE DOWN — make 3 variations immediately
- 10K-50K → Good — keep in rotation
- 1K-10K → Try 1 more variation
- <1K twice → DROP — try something radically different

### CTA Testing

When views are good but conversions are low, cycle through CTAs:
- "Download [App] — link in bio"
- "[App] is free to try — link in bio"
- "I used [App] for this — link in bio"
- "Search [App] on the App Store"
- No explicit CTA (just app name visible)

Track which CTAs convert best per hook category.

### Monthly Pillar Review

The daily cron handles post-level optimization. The monthly review handles strategy-level optimization: which content pillars are working, which need improvement, and which should be rotated out.

**What's a pillar?** A concept + 1-2 formats. "Market explainers via slideshows" is a pillar. "Insider trades via data cards" is another. You run 3-5 pillars at once.

**Monthly protocol (run on the 1st of each month):**

1. **Pull per-pillar metrics** from Postiz analytics. Group posts by pillar. Track: total posts, total views, saves/bookmarks, new followers attributed, conversions (if RevenueCat connected).

2. **Score each pillar** using the diagnostic framework:
   - **SCALE** — High views + high conversions. Make more of this. Increase posting frequency.
   - **KEEP** — Decent performance, stable. Maintain current cadence.
   - **ELEVATE** — Underperforming but concept is sound. Pick one lever:
     - Better hooks (change the opening slide / first 2 seconds)
     - Change production value (lo-fi → polished, or vice versa)
     - 2x the value (double the insight density or entertainment per post)
   - **ROTATE OUT** — Underperforming for 2+ months after elevation attempts. Replace with a new pillar from the bench.

3. **Generate a monthly recap** in `tiktok-marketing/reports/monthly/YYYY-MM.md`:
   ```
   ## Pillar Performance — [Month Year]
   
   | Pillar | Posts | Views | Saves | Follows | Conversions | Verdict |
   |--------|-------|-------|-------|---------|-------------|---------|
   | [name] | X     | X     | X     | X       | X           | SCALE/KEEP/ELEVATE/ROTATE |
   
   ### Changes for next month:
   - SCALE: [pillar] — increasing from 3x/week to 5x/week
   - ELEVATE: [pillar] — testing new hook style (listicle → POV)
   - ROTATE OUT: [pillar] — replacing with [new pillar]
   - NEW: [pillar] — launching with 5-10 posts to establish baseline
   ```

4. **Update hook-performance.json** with pillar-level tags so the daily cron can group future posts correctly.

**Pillar lifecycle:**
- Month 1-2: Launch with 5-10 posts, establish baseline metrics
- Month 3-4: Evaluate. Scale winners, elevate laggards
- Month 5-6: Rotate out persistent underperformers, add new experiments
- Month 7+: Steady state of 2-3 proven pillars + 1-2 experimental slots

**The bench:** Rotated-out pillars aren't dead. Algorithms change, trends shift. Keep a list of retired pillars in `tiktok-marketing/pillar-bench.json` and revisit quarterly.

---
