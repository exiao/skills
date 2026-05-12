# Click-to-WhatsApp ads for Bloombot

Use this reference when setting up Meta ads that send users into Bloombot's WhatsApp Business number.

## Core strategy

Do not optimize for generic "chat with AI." Advertise one concrete job the user can complete in WhatsApp:

1. **Portfolio screenshot second opinion** (primary wedge)
   - Promise: send a portfolio screenshot, get a research-style breakdown of concentration, risk, recent news, and what deserves a closer look.
   - Best fit for WhatsApp because image upload is natural and intent is high.
2. **Ticker gut check**
   - Promise: text one ticker, get bull case, bear case, recent catalysts, and key risks.
   - Lower friction, but can attract low-quality curiosity messages.
3. **Market brief**
   - Promise: text "brief," get a concise market update and opt into recurring updates.
   - Better retention angle than first paid-acquisition wedge.

## Campaign setup

**If using wa.me deep link workaround (Baileys gateway, current):**
- Objective: Traffic (`OUTCOME_TRAFFIC`). Do NOT use Engagement or Messages (they require WABA).
- Conversion location: Website (the wa.me link).
- Optimization goal: `LINK_CLICKS`.
- CTA type: `LEARN_MORE` (verified working).
- Link: `https://wa.me/<phone>?text=<url-encoded-prefill>`.
- See `references/2026-05-12-wame-traffic-campaign-setup.md` for the proven end-to-end API sequence.

**If using native CTWA (Cloud API gateway, future):**
- Objective: Engagement or Leads.
- Conversion location: Messaging apps / WhatsApp.
- Destination: WhatsApp only.

**Common settings:**
- Audience: broad US, 25-54, English. Add an investing interest ad set only if broad traffic is junk.
- Placements: Advantage+ placements initially; inspect Reels, Stories, and Feed breakdown after 72 hours.
- Budget: start around $50/day total for 4-7 days.
- Avoid fragmenting budgets across too many ad sets. Test creative first.

## Creative test matrix

Run 6 initial ads: 3 angles x 2 native formats.

Recommended formats:
- WhatsApp chat screenshot / phone recording.
- Notes app checklist.
- Reddit-style question.
- Product test reveal / data card.
- Quick-cut text-over-video.
- Lo-fi bold statement.

Example portfolio screenshot ad:
- Primary text: "Your brokerage shows positions. Bloom tells you what deserves a closer look. Send a portfolio screenshot on WhatsApp."
- Headline: "Review Your Portfolio in WhatsApp"
- Prefill/welcome message: "Can you review my portfolio?"

## Creative production workflow

When asked to "make ads" for Bloombot CTWA, produce reviewable assets first. Do not launch or spend without explicit confirmation.

1. **Create the batch folder**
   - Use `~/.hermes/ads/iteration/creatives/YYYY-MM-DD-ctwa-bloombot/` for local drafts.
   - Include PNG exports, editable source files, `manifest.md`, `ad-copy.csv`, and `paused-ad-payload-template.json`.
   - Zip the folder for handoff.

2. **Make six rough/native 9:16 statics first**
   - 2 portfolio screenshot ads: WhatsApp mock chat + Notes checklist.
   - 2 ticker ads: product-test reveal + Reddit-style question.
   - 2 market brief ads: text sequence + bold statement.
   - Keep them intentionally clear and native. Avoid polished fintech brand-ad energy until the funnel is proven.

3. **Use deterministic local rendering when image generators are unnecessary**
   - If Pillow is unavailable in the execution sandbox but `rsvg-convert` exists, generate SVG creatives with HTML-escaped text and export to PNG via:
     `rsvg-convert -w 1080 -h 1920 input.svg -o output.png`
   - This is fast, deterministic, and good enough for first-pass Notes/Reddit/WhatsApp mockups.
   - Keep SVG sources in the batch so future edits do not require regenerating from scratch.

4. **Manifest fields per creative**
   - file name, angle, psychological trigger, format, first-frame text, primary text, headline, description, CTA, WhatsApp prefill/welcome message, bot flow target, source engine/tool, QA status, compliance notes.

5. **Visual QA before handoff**
   - Text readable on mobile at half brightness.
   - WhatsApp action visually obvious.
   - One promise per ad.
   - No fake returns, profit claims, urgent trading pressure, or personalized advice language.
   - Include "research context, not financial advice" on ticker/portfolio assets where space allows.
   - Watch for UI-mimic risk when using Reddit/WhatsApp-style mockups. They are useful, but should not imply official partnership.

6. **Pre-launch platform check**
   - Meta ad account `account_status=1` and `disable_reason=0` means the ad account is active.
   - Querying Page fields like `whatsapp_number` may return empty even when the number is connected elsewhere, and fields such as `connected_whatsapp_business_account` may not exist in the Graph version. Treat this as a warning to verify Page + WhatsApp connection in Ads Manager or WhatsApp Manager, not as proof the number is disconnected.
   - Before activation, create ads paused, preview on a real phone, confirm the tap opens the correct Bloombot WhatsApp thread with the correct prefill/welcome flow, then send a test message and verify webhook referral metadata or prefill fallback.

## Bot message match

The first Bloombot response must match the ad promise exactly.

Portfolio screenshot first reply:
"Send a screenshot of your holdings. I'll look for concentration, risk, recent news, and anything worth researching more. This is research context, not financial advice."

Ticker first reply:
"Send one ticker. I'll give you the bull case, bear case, recent catalysts, and key risks. Research context only, not financial advice."

Market brief first reply:
"Here's the quick brief: indexes, biggest movers, one macro thing, and what to watch tomorrow. Want this every morning?"

## Attribution and events

### Unique prefill text per ad (primary attribution method for wa.me campaigns)

Each ad gets a distinct prefilled message matching its angle. This doubles as routing (BloomBot can respond to the intent) and basic attribution (unique text maps to exactly one ad).

Proven prefill set (2026-05-12 launch):

| Ad | Angle | Prefill |
|----|-------|---------|
| 1 | Portfolio WhatsApp chat | Can you review my portfolio? |
| 2 | Portfolio Notes checklist | I want a second opinion on my holdings |
| 3 | Stock gut check product test | What do you think about NVDA? |
| 4 | Stock gut check Reddit | Can you break down a stock for me? |
| 5 | Market brief sequence | What's happening in the market today? |
| 6 | Market brief bold statement | Give me today's market brief |

Frame prefills as natural conversation starters, not tracking codes (e.g. avoid `[ref:ad1]` suffixes). Users are less likely to edit/delete text that sounds like their own intent. Research suggests up to 90% of users may edit or delete prefilled messages.

### CTWA metadata (native CTWA campaigns only)

Capture CTWA attribution on the first inbound WhatsApp webhook message. Store, when available:

- `wa_id` or phone hash, not raw phone in analytics tables unless needed.
- message id and timestamp.
- campaign id, ad set id, ad id / `source_id`.
- `ctwa_clid`.
- referral source URL.
- referral headline/body/media type.
- ad angle and prefill text.

### Funnel events

1. `whatsapp_conversation_started` = first inbound message from CTWA.
2. `bloombot_activated` = user sends ticker, screenshot, or substantive follow-up.
3. `qualified_conversation` = 2+ user messages or completed portfolio/stock/brief response.
4. `recurring_opt_in` = user asks for daily brief, watchlist, or monitoring.
5. `paywall_viewed`.
6. `subscription_started`.
7. `purchase`.

CAPI mapping:
- Lead = qualified conversation.
- CompleteRegistration or Subscribe = recurring opt-in.
- Purchase = paid subscription.

Do not optimize on conversations once qualified Lead or Purchase events are flowing with enough volume. Conversation optimization finds bored tappers; CAPI quality events teach Meta who pays.

## Kill and scale rules

Judge by cost per qualified conversation, not cheapest conversation.

Kill when:
- CTR < 0.5% after 1,000 impressions.
- Cost per conversation is 2x median and activation is below median.
- Activation rate < 20% after 20+ conversations.
- Users message but do not send ticker/screenshot/follow-up.

Keep when:
- Cost per conversation is mediocre but activation and user message quality are strong.
- The ad creates recurring opt-ins.

Scale when:
- Qualified conversation cost is acceptable.
- Bot latency/errors are under control.
- CTWA attribution or CAPI is working.

Budget increases: max 20%, then wait 3 days. Prefer creating variants of the winning creative over big budget jumps.

## Compliance language

Use:
- research-style breakdown.
- second opinion.
- things to look closer at.
- bull case / bear case.
- risk, concentration, catalysts, valuation, earnings.
- helps you think through investing decisions.

Avoid:
- what to buy.
- guaranteed returns.
- beat the market.
- financial advisor language.
- personalized recommendation language.
- never miss a trade.
- profit claims.
- urgent trading pressure.

## Sources

- Meta Business Help: Create ads that click to WhatsApp.
- Meta for Business: Optimizations for ads that click to WhatsApp.
- Meta Developers: Click-to-WhatsApp Marketing API and AdCreative references.
- WhatsApp Business: Conversions API for Business Messaging.
- RevenueCat: UGC ads for apps, value-first native creative.
- Infobip: Click-to-WhatsApp ads setup and scaling.

## WABA phone number prerequisite and Baileys incompatibility

Native CTWA campaigns require the destination WhatsApp number to be registered in a WABA (WhatsApp Business Account) under Meta Business Manager. Verify via Graph API:

```bash
curl -sG "$GRAPH_URL/<WABA_ID>/phone_numbers" \
  --data-urlencode "fields=id,display_phone_number,verified_name,status" \
  --data-urlencode "access_token=$TOKEN"
```

If `data` is empty or the production number is missing, native CTWA is blocked.

**Baileys/whatsapp-web.js gateway conflict:** Registering a number in a WABA via "Coexistence" (Cloud API) disables E2E encryption for that number. Baileys relies on Signal protocol E2E encryption to send messages. Confirmed: Baileys can connect but cannot send any messages after coexistence onboarding (WhiskeySockets/Baileys#2152). This means:

- If BloomBot uses Baileys as its WhatsApp gateway, do NOT register its number in a WABA.
- Migrating to Meta Cloud API is the permanent fix but requires replacing the Baileys gateway.

**Workaround: wa.me deep link traffic campaign (no WABA needed)**

Run a Traffic campaign with the ad's website URL set to a wa.me deep link:

```
https://wa.me/19293262783?text=Can+you+review+my+portfolio%3F
```

User taps the ad, WhatsApp opens with the prefilled message, they send it, Baileys receives it like any normal incoming message.

What you lose vs native CTWA:
- No green "WhatsApp" CTA button (use "Learn More" instead, verified working).
- No `ctwa_clid` in webhook payload. Use unique prefill text per ad as attribution proxy.
- Meta optimizes for link clicks, not "conversations started."
- No free 72-hour Cloud API conversation window (irrelevant for Baileys).

What you keep:
- User lands directly in WhatsApp with a prefilled message (same end UX).
- Baileys receives the message with the prefilled text for flow routing.
- No WABA registration, no Baileys breakage.
- Different prefill text per ad provides basic attribution.

**Campaign setup for wa.me traffic approach:**
- Objective: Traffic (`OUTCOME_TRAFFIC`).
- Conversion location: Website (the wa.me link).
- Optimization goal: `LINK_CLICKS`.
- CTA type: `LEARN_MORE` (verified).
- Link: `https://wa.me/<phone>?text=<url-encoded-prefill>`.
- Ad set MUST include `targeting_automation.advantage_audience` (0 or 1) or creation fails with error 1870227.
- See `references/2026-05-12-wame-traffic-campaign-setup.md` for the complete proven API sequence.
