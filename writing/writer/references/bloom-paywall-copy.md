# Bloom and BloomBot paywall copy notes

Use this when writing Bloom or BloomBot paywalls, subscribe pages, onboarding screens, ads, or short conversion copy.

## Strongest positioning

Primary headline:
Your thinking partner for investing

Best supporting lines:
- Your portfolio deserves more than 6 minutes of research.
- $5,000 decisions shouldn't be guesses.
- Know what you're buying, with the receipts to prove it.
- Research any stock in 30 seconds.
- You can't read every filing, earnings call, chart, and headline. BloomBot can.
- Catch red flags before your money does.
- Uncover your investing blind spots.
- Understand why prices move.

## Current BloomBot subscribe copy (May 2026)

Headline:
Your thinking partner for ________
(rotating: investing, research, trading, backtesting, rebalancing, technicals, earnings, portfolios)

Subtitle:
Unlock unlimited deep research in BloomBot

Bullets (Eric's approved upsell):
- Access to our research reports and trades
- Access to all data sources
- Access to all alerts
- Unlimited chat

CTA:
Continue yearly / Continue weekly

Footer:
BloomBot is for research, not financial advice.

Note: these bullets are broader than the narrow backend gate (which is deep research credits). Eric approved this copy knowing it is aspirational. Do not rewrite it back into safer bullets unless he asks.

## Copy iteration lessons (May 2026)

- The subscribe page has two layers: (1) a value prop about what BloomBot is ("thinking partner"), (2) an upsell about what Pro unlocks. Do not collapse them.
- "Go deeper before you invest" tested poorly as a subtitle. Too vague on its own. "Unlock unlimited deep research in BloomBot" was clearer about the paid delta.
- Discount anchoring: ground the yearly discount on the weekly price, not monthly. "$78/year = $1.50/week = 70% off" is stronger than "$6.50/month."
- "Never miss a trade" is too advice-y. Use "Alerts when the story changes."
- "Know what to buy or sell" is too close to financial advice. Use "Know what you're buying, with receipts."
- Keep mobile paywall bullets short. Long colon-prefixed bullets read well in drafts but feel heavy on a phone.
- Strong reusable lines: "Your portfolio deserves more than 6 minutes of research," "Catch red flags before your money does," and "Uncover your investing blind spots."

## Strategic copy angle

Do not sell "more AI chat." Sell proof, attention, and risk control.

Core anxieties to write toward:
- What should I pay attention to?
- Is this a real opportunity?
- What am I missing?
- What would prove me wrong?
- Did news, earnings, price action, or valuation change the thesis?

The WhatsApp bot's job is to tap the user on the shoulder before they have to stare at markets all day. Lead with proactive alerts and second opinions. Use deeper research as the follow-through.

## Compliance and taste guardrails

Avoid:
- "Pick winning stocks"
- "Avoid losses"
- "Boost your return"
- "Copy trade AI portfolios" unless the product promise is actually copy trading
- "No hallucinations" because it is not defensible
- "Hidden investing opportunities" because it sounds scammy
- "Latest AI models" because most users care about outcomes, not model names
- "AI portfolio manager" when selling WhatsApp research
- "Know what to buy" unless legal/compliance has approved that phrasing

Prefer:
- "Know what you're buying"
- "Get a second opinion"
- "Catch red flags before they get expensive"
- "Research any stock without reading every filing, chart, and headline"
- "Understand why prices move"

## RevenueCat subscribe page pattern

For a branded BloomBot paywall, host the pitch on `$APP_DOMAIN/subscribe` rather than relying on the generic RevenueCat package selector. Keep one clear Continue CTA after plan selection.

Current CTA target pattern:
`https://pay.rev.cat/<token>/<encoded_phone>?package_id=bloombot_yearly_onboarding`

Preserve phone parsing carefully. Standard `URLSearchParams` can convert `+` in phone numbers into spaces. Parse query strings manually or otherwise ensure E.164 phone numbers survive intact.

## BloomBot Pro upsell clarity

Before writing BloomBot paywall copy, verify what is actually behind the current gate. Do not use broad Bloom app value props as if they are BloomBot Pro entitlements.

Current WhatsApp paywall behavior from code:
- Free users get 10 deep research queries (`WhatsAppSubscription.DEFAULT_FREE_DEEP_RESEARCH = 10`).
- Low warning triggers at 3 or fewer remaining queries.
- Hard paywall appears when `can_use_deep_research()` is false.
- Active subscribers unlock continued deep research chat.
- Alerts, research reports, trades, and "all data sources" should not be claimed as gated BloomBot Pro benefits unless product/code confirms they are wired into this paywall.

Use this upsell shape:
- Free = a limited number of deep research answers.
- Pro = unlimited/deeper BloomBot research workflow.
