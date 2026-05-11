---
name: post-insider-trades
description: Create social posts from notable insider buying. Use when a scheduled job or user asks to scan OpenInsider or SEC Form 4 filings, pick significant insider purchases, generate a visual trade card, draft social copy, and save an unscheduled review draft.
---

# Post Insider Trades

Find compelling recent insider buys, turn them into a visual social asset, and draft a post for human review.

## Scope

This skill is for content generation, not investment advice. It should frame insider buying as a signal worth researching, not proof that a stock will rise.

## Inputs

- Lookback window: default 24 hours
- Minimum transaction size: default `$500,000`
- Source: OpenInsider and SEC Form 4 filings
- Optional destination: Typefully, Buffer, Hypefury, or local markdown draft
- Optional brand watermark: `$BRAND_NAME`

## Required Tools

| Tool | Purpose |
|------|---------|
| Web search or direct fetch | Pull OpenInsider and Form 4 source data |
| Market data CLI/API | Price, market cap, YTD performance, company context |
| Image generation or HTML/SVG | Create receipt-style trade card |
| Social scheduler CLI/API | Save an unscheduled draft for review |

## Selection Criteria

Prioritize insider buys with:

1. Large dollar value: over `$500k`, ideally over `$1M`
2. Senior role: CEO, CFO, Chair, Director, Founder
3. Open-market purchase: avoid option grants, RSUs, automatic plans, or non-discretionary awards
4. Cluster buying: multiple insiders buying the same ticker in a short window
5. Recent filing: filed in the last 24 to 72 hours
6. Interesting setup: stock down YTD, recent selloff, turnaround, or catalyst
7. Recognizable company: useful for a broad audience

Avoid:
- Tiny purchases that look symbolic
- Planned transactions only
- Illiquid microcaps unless the purchase is extraordinary
- Anything where the filing cannot be verified

## Workflow

### Step 1: Collect candidates

Search OpenInsider for recent insider purchases:

- Transaction code: `P` for purchase
- Value greater than `$MIN_TRANSACTION_VALUE`
- Filed within the lookback window
- Exclude option exercises and awards

For each candidate collect:
- Ticker
- Company
- Insider name
- Insider title
- Transaction date
- Filing date
- Shares purchased
- Average price
- Total value
- SEC filing URL

### Step 2: Verify the filing

Open the SEC Form 4 or source filing and confirm:
- Transaction code is `P`
- Transaction was a purchase, not an award or option exercise
- Shares, price, and total value match the source
- Insider role is accurate

If verification fails, skip the candidate.

### Step 3: Add market context

For the selected ticker, gather:
- Latest price
- Market cap
- YTD change
- 1 month and 6 month price trend if available
- Recent earnings or major news
- Company description
- Sector and industry

Use a market data CLI/API first if available. If not, use web search and cite sources in the draft notes.

### Step 4: Pick the strongest story

Score candidates:

| Factor | Weight |
|--------|--------|
| Dollar value | High |
| Insider seniority | High |
| Cluster buying | Very high |
| Filing recency | Medium |
| Recognizable company | Medium |
| Clear narrative | High |
| Stock down YTD or post-selloff | Medium |

Output the chosen candidate and 1 to 3 runner-ups in the notes.

## Card Format

Create a brokerage-receipt style card.

Required fields:
- Ticker and company name
- Insider name and title
- Buy amount
- Shares purchased
- Average price
- Filing date
- Source: SEC Form 4

Optional context:
- YTD performance
- Market cap
- One-line setup

Visual rules:
- Receipt or trade-ticket feel
- High contrast
- Mobile-readable
- No fake brokerage branding
- Add a small `$BRAND_NAME` watermark only if provided

## Draft Copy Formula

Keep copy short and factual.

Template:

```
[Insider title] at $TICKER just bought $[amount] of stock on the open market.

Not options. Not RSUs. A direct purchase filed with the SEC.

Context: [1 sentence on stock move, company setup, or catalyst].

Insider buys are not a crystal ball, but this is the kind of signal worth adding to the research pile.

Source: SEC Form 4
```

Alternative hook formats:
- `$[amount] insider buy just hit the tape for $TICKER`
- `The [CEO/CFO/Director] of $TICKER just bought stock with their own money`
- `Insiders do not always know the future. But they do know their own business.`

## Compliance Rules

- Do not say the stock is guaranteed to rise.
- Do not recommend buying or selling.
- Do not imply insider buying is always predictive.
- Always distinguish open-market purchases from equity awards.
- Include source attribution.
- Save as draft for human review unless explicitly told to publish.

## Output Format

Return:

1. Selected insider buy
2. Why it was selected
3. Verification notes
4. Market context
5. Card file path or prompt
6. Draft post text
7. Runner-ups skipped
8. Any uncertainty or missing data
