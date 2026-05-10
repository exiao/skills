# Bloom and BloomBot paywall copy notes

Use this when writing Bloom or BloomBot paywalls, subscribe pages, onboarding screens, ads, or short conversion copy.

## Strongest positioning

Primary headline:
Your thinking partner for investing

Best supporting lines:
- Your portfolio deserves more than 6 minutes of research.
- $5,000 decisions shouldn’t be guesses.
- Know what you’re buying, with the receipts to prove it.
- Research any stock in 30 seconds.
- You can’t read every filing, earnings call, chart, and headline. BloomBot can.
- Catch red flags before your money does.
- Uncover your investing blind spots.
- Understand why prices move.

## Current BloomBot subscribe copy

Headline:
Your thinking partner for investing

Subhead options, ranked:
1. Your portfolio deserves more than 6 minutes of research.
2. Upgrade from quick answers to full stock research.
3. Unlock every model, alert, and data source.

Bullets, concise version:
- Research everything: filings, news, fundamentals, earnings, ratings, and charts
- Catch red flags before your money does
- Uncover blind spots before you trade
- Get alerts when the story changes

Bullets, clearer paid/free delta:
- All data: filings, news, fundamentals, earnings, ratings, and charts
- All red flags: valuation, guidance, chart, and thesis risks
- All blind spots: bull case, bear case, and what could go wrong
- All alerts: price moves, news, earnings, and watchlist changes

CTA:
Continue with annual plan

Footer:
BloomBot is for research, not financial advice.

## Strategic copy angle

Do not sell “more AI chat.” Sell proof, attention, and risk control.

Core anxieties to write toward:
- What should I pay attention to?
- Is this a real opportunity?
- What am I missing?
- What would prove me wrong?
- Did news, earnings, price action, or valuation change the thesis?

The WhatsApp bot’s job is to tap the user on the shoulder before they have to stare at markets all day. Lead with proactive alerts and second opinions. Use deeper research as the follow-through.

## Compliance and taste guardrails

Avoid:
- “Pick winning stocks”
- “Avoid losses”
- “Boost your return”
- “Copy trade AI portfolios” unless the product promise is actually copy trading
- “No hallucinations” because it is not defensible
- “Hidden investing opportunities” because it sounds scammy
- “Latest AI models” because most users care about outcomes, not model names
- “AI portfolio manager” when selling WhatsApp research
- “Know what to buy” unless legal/compliance has approved that phrasing

Prefer:
- “Know what you’re buying”
- “Get a second opinion”
- “Catch red flags before they get expensive”
- “Research any stock without reading every filing, chart, and headline”
- “Understand why prices move”

## BloomBot paywall copy lessons

- Make the free vs paid delta explicit. Free is quick answers; Pro is full stock research.
- Do not lead with feature soup like "all models, all alerts, all data" unless clarity matters more than taste. Translate features into outcomes: research everything, catch red flags, uncover blind spots, get alerts.
- Keep mobile paywall bullets short. Long colon bullets read well in drafts but feel heavy on a phone.
- "Never miss a trade" is too close to profit-promise territory. Use "Never miss what matters" or "Get alerts when the story changes."
- Strong reusable lines: "Your portfolio deserves more than 6 minutes of research," "Catch red flags before your money does," and "Uncover your investing blind spots."

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
- Alerts, research reports, trades, and “all data sources” should not be claimed as gated BloomBot Pro benefits unless product/code confirms they are wired into this paywall.

Use this upsell shape:
- Free = a limited number of deep research answers.
- Pro = unlimited/deeper BloomBot research workflow.

Good compact copy:
Title: `Go Pro before your next trade`
Subtitle: `Unlock unlimited deep research in BloomBot.`
Bullets:
- Ask unlimited questions about any stock
- Get a second opinion before you buy or sell
- Catch red flags before your money does
- Uncover blind spots in your thesis
- See the receipts behind every answer
