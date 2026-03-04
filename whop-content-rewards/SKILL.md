---
name: whop-content-rewards
description: Set up and manage Content Rewards UGC campaigns on Whop for Bloom. Use when launching new campaigns, adding budget, reviewing submissions, or checking campaign performance.
---

# Whop Content Rewards — Bloom

Launch and manage pay-per-view UGC campaigns on Whop's Content Rewards platform for Bloom.

## Access

- **URL:** https://whop.com/hub/
- **Campaign type:** UGC (user-generated content)
- **Default CPM:** $2 per 1,000 views
- **Chrome tab required** — use `browser` with `profile="chrome"` (attach tab first)

## AI UGC Production Stack

Use this when producing AI-generated UGC videos (for Whop campaigns or dedicated creator program).

### Step 1 — Find a Reference Ad
- Use [Meta Ad Library](https://facebook.com/ads/library) or [GetHooked.ai](https://gethooked.ai) to find ads in your category running 30+ days
- Run duration = signal the advertiser is seeing return
- Watch 3x: first for overall feel, second to map hook/product intro/proof structure, third to write explicit architecture you'll use as blueprint

### Step 2 — Generate a Credible Avatar
- Presenter should look like a peer to the target audience, not a tech spokesperson
- For Bloom: working investor/operator in their 30s, not a finance bro or formal advisor
- Tools: [Midjourney](https://midjourney.com) or [HeyGen](https://heygen.com)
- Generate 4–6 variants, pick the one that matches the visual profile of the target audience's peer group
- Competitor shortcut: find a high-performing ad with a presenter running 45+ days → use Claude to describe the demographic profile → generate a similar (not identical) avatar

### Step 3 — Voice Match
- Avatar voice must match in age, energy, and personality register — mismatches create subconscious friction
- Tool: [ElevenLabs](https://elevenlabs.io) for micro-variation control
- Test: place avatar image on screen, play voice samples, ask "can I genuinely imagine this person speaking like this?"
- After generating VO: remove silences and gaps (Adobe Premiere silence removal) — reduces a 3-min VO by 20–30s and meaningfully improves pacing

### Step 4 — Native Caption Formatting
- 50–80% of Instagram viewers see content muted first — captions are not optional
- Use Instagram's native story text style (semi-transparent dark background) — brain registers it as organic content, not an ad
- Technique: generate caption inside the Instagram app using native text tool on a throwaway photo → import into editing software → remove background → overlay on video

---

## Bloom Creative Brief

The canonical brief lives at:
https://docs.google.com/document/d/1-mxmJNBJDuozCIq76TmAx7wpOBZEStOpjQ2viXgRW7Q/edit

### Summary for campaign setup

**Campaign name:** Bloom — AI Investing UGC

**Brand description:**
Bloom is the best AI for investing in stocks. It researches stocks and helps you invest smarter. 100K+ downloads. Targeting TikTok/Reels finance creators.

**Content type:** UGC (original short-form videos, not clipping)

**Platforms:** TikTok, Instagram Reels, YouTube Shorts

**CPM:** $2 per 1,000 views

**Content guidelines (paste into brief field):**
```
Make short, engaging finance/investing videos. DO NOT hard sell — make it feel like native FYP content. Mention Bloom subtly (screenshots of the app, casual references) or not at all. No hard selling. No explicit performance/return claims.

Good hooks to use:
- "i showed bloom my robinhood portfolio…it ROASTED me"
- "i gave bloom 10k to invest"
- "Before I do something dumb on robinhood…"
- "You're picking stocks wrong"
- "Did you know you can use AI to analyze 20 stocks in the time it takes to make a coffee?"
- "Your financial advisor won't tell you this"
- "hedge funds are buying these 5 stocks"

Posting tips:
- Post 1-2x/day. Use a fresh account named like investingwithsarah or moneywithjake.
- Warm up account first (watch finance content, search keywords).
- Use trending sounds. Engage with FYP 10 min before/after posting.

What Bloom does: AI investing research that helps retail investors catch red flags, audit portfolios, stress-test trades, and know what's moving their stocks.

Target audience: newer investors, millennials/gen-z with brokerage accounts, Robinhood users, anyone anxious about their portfolio.
```

**Compliance note:** No claims about specific returns or stock picks. App features only.

---

## Setup Flow (first time)

### Step 1: Access your Whop dashboard

Navigate to https://whop.com/hub/ and log in.

### Step 2: Add Content Rewards app (if not already added)

1. Go to your whop → click **Add app**
2. Find **Content Rewards** in the App Store
3. Click **Add**

### Step 3: Create campaign

1. Inside Content Rewards, click **Create Campaign**
2. Select campaign type: **UGC**
3. Fill in fields:
   - Campaign name
   - Brand description
   - Content brief (see above)
   - CPM: `$2`
   - Platforms: TikTok, Instagram Reels, YouTube Shorts
4. Submit

### Step 4: Fund and launch

1. After creating, **Add Budget** popup appears
2. Add initial budget (recommend $200–$500 to start)
3. Choose payment method and confirm
4. Campaign moves from **Pending** → **Active** once payment clears (~1 min)

---

## Ongoing Management

### Review submissions

- Approve: content follows guidelines, no compliance issues, quality looks good
- Reject: hard selling, specific return claims, low quality, clearly fake engagement

### Add more budget

- Click ··· on the campaign → **Add budget**

### Check performance

- Views, spend, top-performing creators visible in the dashboard
- Track which hooks/formats perform best

---

---

## Dedicated Creator Program (Managed Tier)

For scaling beyond open campaigns. Run this alongside or instead of the open Whop campaign once you've validated formats.

### Creator Sourcing

- Find creators from saved viral content with **<1k followers** — not agencies or open applications
- Source 5 to start. Watch their content cadence and comment engagement before reaching out.
- Each creator sets up a **fresh ambassador account** (e.g. investingwithsarah, moneywithjake)

### Compensation Structure

| Component | Amount |
|-----------|--------|
| Monthly retainer | $500/m for 1 video per day |
| Bonus — 10k views | Tiered payout |
| Bonus — 100k views | Tiered payout |
| Bonus — 1M views | Tiered payout |
| Max payout cap | Set per video |
| Eligibility window | 7 days per video |

Cap total payout per video to control downside on breakout posts. Eligibility window prevents paying on views that trickle in months later.

### Tracking & Payouts

- Whop Content Rewards handles up to ~10 creators well
- At scale, consider **viral.app** for automated campaign tracking and payouts

### Scale Stages

1. **5 creators** — validate CPM and format fit
2. **Validate** — confirm eCPM >$1, views consistent, formats repeatable
3. **Scale steadily to 100+ creators** — don't rush; quality degrades fast when overscaling

### Creator Retention

- Track performance of every video; give hands-on feedback + coaching
- Double down on winning formats immediately
- Keep experimenting — formats stop working overnight
- **Coach flywheel:** top performers become creator coaches who recruit/train new creators
- Build referral incentives to grow the roster organically

---

## Notes

- No API available — all browser-based
- Payments auto-process after approval, no manual work needed
- Set CPM higher ($3–5) to attract better creators if quality is low
