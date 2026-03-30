# A/B Testing Framework

Test systematically. Most teams test randomly and learn nothing.

### What to Test (In This Order)

Testing priority ranked by conversion impact:

| Priority | Element | Why | Min Sample |
|----------|---------|-----|-----------|
| 1 | **Headlines / Hooks** | Determines if anyone reads the rest | 500 per variant |
| 2 | **Hero image / Video thumbnail** | Determines if anyone clicks | 500 per variant |
| 3 | **CTA text and placement** | Determines if readers become users | 300 per variant |
| 4 | **Social proof** | Determines if uncertain visitors convert | 300 per variant |
| 5 | **Body copy** | Determines conversion rate for engaged readers | 1,000 per variant |
| 6 | **Pricing / Offer** | Determines revenue per conversion | 1,000 per variant |
| 7 | **Page layout** | Marginal gains after the above are optimized | 2,000 per variant |

### Statistical Significance

Don't call a winner too early. You need:

- **Minimum sample**: 300-500 conversions per variant (not impressions, CONVERSIONS)
- **Confidence level**: 95% minimum (p < 0.05)
- **Test duration**: At least 7 days (captures weekly behavior cycles)
- **One variable at a time**: Changing headline AND image means you don't know which worked

**Quick significance check**: If Variant B is beating Variant A by less than 10% relative lift, you probably need 2,000+ conversions per variant to confirm it's real. Big wins (30%+ lift) are detectable faster.

### Testing by Channel

#### Google Ads
- Use RSA headline/description rotation (Google's built-in testing)
- Create separate ad groups for major copy themes, not just keyword groups
- Test landing pages with Campaign Experiments (50/50 split)
- Run for 2+ weeks before judging (Google's learning period)

#### App Store
- Use Apple's Product Page Optimization (3 treatments)
- Test screenshot order and text (highest impact)
- Test icon variants (second highest)
- Run for minimum 7 days, Apple recommends 14
- Google Play: use Store Listing Experiments (up to 5 variants)

#### TikTok / Meta
- Same video with 3 different hooks (first 2-3 seconds)
- Test CTA text: "Download Free" vs "Try It Free" vs "Get the App"
- Test thumbnail/first frame for feed placement
- Budget: min $50/day per variant for 5+ days

#### Email
- Subject line A/B test on 20% of list, send winner to remaining 80%
- Test send time: 7 AM vs 10 AM vs 6 PM (user timezone)
- CTA button color is NOT worth testing until everything above is optimized
- Min list size per variant: 1,000 (for open rate), 5,000 (for click rate)

#### Landing Pages
- Use UTM parameters to track which traffic source converts
- Test one element at a time (hero copy OR CTA text, not both)
- Run tests for full business cycles (7-14 days minimum)
- Tools: Google Optimize (free), VWO, Optimizely

### Rapid Creative Testing (4-Day Blitz)

For paid social (Meta/TikTok), the traditional test cycle is too slow: brief creators → wait for delivery → launch → wait for data → iterate = 4 weeks for 3 variations. This protocol gets 30 variations tested in 4 days:

**Day 1: Generate 20 creative variations.**
Build a testing matrix: 3-5 different visual styles × 4-6 narrative angles × 2-3 emotional tones. Use Nano Banana Pro for visual cards, Larry for TikTok slideshows, screen recordings for demo variants. One operator, one day, 20 ads.

**Day 2: Launch all 20 simultaneously.**
$20-50/day per variant. Broad targeting. Let the algorithm sort. Don't pre-judge which will win (you'll be wrong).

**Day 3: Identify top 3-5 performers.**
Kill the bottom 75% based on CTR and conversion data. Don't wait for statistical significance on losers; you're looking for signal, not proof.

**Day 4: Generate 10 iterations of winners.**
Take each winner's hook, angle, and format. Create variations: different opening lines, different proof points, different CTAs. Launch immediately. This is your second-generation creative set.

**Why this works:** Traditional ugc costs $200-800 per video and 7-14 day turnaround. AI-generated creative (Nano Banana Pro for images, screen recordings for demos, Larry for slideshows) costs $2-8 per asset and takes minutes. The volume advantage means you find winners 10x faster.

**Cadence:** Run a 4-day blitz at launch, then weekly 10-variation refreshes to fight creative fatigue. Every 60-90 days, run a full blitz with new angles.

### The Testing Log

Keep a testing log. Every test.

```markdown
