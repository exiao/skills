---
name: earnings-card-pipeline
description: Create weekly earnings preview cards and social drafts. Use when a scheduled job or user asks to find major upcoming earnings, gather analyst estimates, write concise investor takeaways, generate visual cards, and save unscheduled social drafts for review.
---

# Earnings Card Pipeline

Create visual earnings preview cards for widely followed companies reporting this week, then draft social posts for human review.

## Scope

This skill creates educational market content. It should not make trade recommendations or guarantee earnings outcomes.

## Default Cadence

- Weekly preview: Monday morning before market open
- On-demand: whenever the user asks for upcoming earnings content
- Drafts should remain unscheduled unless the user explicitly approves publishing

## Required Tools

| Tool | Purpose |
|------|---------|
| Web search | Discover companies reporting this week |
| Market data CLI/API | Verify earnings dates, estimates, price, market cap |
| Image generation or HTML/SVG | Generate cards |
| Social scheduler CLI/API | Save draft posts for review |

## Workflow

### Step 1: Discover earnings events

Find companies reporting in the next 7 days. Prefer:
- Mega-cap and large-cap names
- Widely held retail stocks
- Companies with big expected moves
- Names with clear catalysts or controversy
- Companies with recognizable products

Avoid:
- Microcaps
- Companies that already reported
- Events where the date cannot be confirmed

### Step 2: Verify event data

For each candidate, collect:
- Ticker
- Company name
- Report date
- Report timing: before open or after close
- Consensus EPS estimate
- Consensus revenue estimate
- Latest price
- Market cap
- Options-implied move, if available
- Recent 1 month and YTD performance

Use a market data CLI/API if available. Otherwise use web sources and include source notes.

### Step 3: Select up to 5 cards

Rank candidates by:
1. Audience familiarity
2. Market cap and liquidity
3. Expected volatility
4. Narrative clarity
5. Whether the result can signal something broader about the sector

### Step 4: Write the take

Each card needs one concise analyst-style point:
- What investors are watching
- What a beat or miss would signal
- What metric matters most
- Why this earnings event is interesting now

Examples:
- "Investors are watching whether cloud growth can offset margin pressure."
- "The real question is guidance, not last quarter's EPS."
- "A strong print could reset expectations for the whole sector."

### Step 5: Generate the card

Card fields:
- Company logo or ticker mark
- Ticker and company name
- Earnings date and timing
- EPS estimate
- Revenue estimate
- Implied move or recent stock move, if available
- One-sentence watch item
- Source note

Design rules:
- Mobile-first
- High contrast
- Readable at feed size
- No fake claims or invented estimates
- Use `$BRAND_NAME` watermark only if provided

### Step 6: Draft social copy

Template:

```
$TICKER reports earnings [date/timing].

Consensus is looking for [EPS] on [revenue].

The number that matters: [metric/watch item].

Not a prediction. Just the setup going into the print.
```

Keep drafts short. Do not schedule automatically unless explicitly asked.

## Batch Generation Pattern

When generating multiple cards, prefer writing a small script that loops over structured JSON input rather than issuing one-off commands for every ticker.

Example input shape:

```json
[
  {
    "ticker": "AAPL",
    "company": "Apple",
    "date": "2026-05-14",
    "timing": "after close",
    "eps_estimate": "1.61",
    "revenue_estimate": "$95.3B",
    "watch_item": "iPhone demand and China growth"
  }
]
```

## Quality Bar

Before saving drafts, verify:
- Earnings date is current
- Estimates are not stale
- No company already reported
- Card numbers match draft text
- Claims are framed as setup, not advice
- Image text is legible on mobile

## Output Format

Return:

1. Selected earnings list
2. Source notes
3. Card prompts or file paths
4. Draft post text for each ticker
5. Skipped candidates and why
6. Any data uncertainty
