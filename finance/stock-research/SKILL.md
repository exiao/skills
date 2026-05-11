---
name: stock-research
description: Perform stock and equity research, earnings analysis, peer comparison, watchlist review, and concise market commentary. Use when analyzing a ticker, writing an investment research note, comparing companies, preparing earnings context, or creating a market briefing.
---

# Stock Research

Research public companies using structured market data, filings, earnings materials, analyst context, and news.

## Scope

This skill supports equity research and market commentary. It does not provide personalized financial advice, trade execution, or guarantees.

## Modes

| Mode | Use |
|------|-----|
| Quick ticker brief | User asks "what is going on with $TICKER?" |
| Deep research note | User asks for a full company analysis |
| Earnings analysis | User asks about earnings, guidance, or transcript takeaways |
| Peer comparison | User asks to compare companies or sectors |
| Market briefing | User asks for a concise daily market update |

## Data Sources

Prefer structured sources first:

- Market data CLI/API: price, market cap, financials, estimates, analyst ratings, peers
- SEC filings: 10-K, 10-Q, 8-K, S-1, proxy filings
- Earnings materials: press release, slides, transcript
- Company investor relations pages
- Reputable market news
- Optional watchlist file or API supplied by the user

If a specialized CLI is available, use it first. Otherwise use web search and source links.

## Quick Ticker Brief

Answer in this order:

1. What the company does
2. Current stock move and timeframe
3. Most likely reason for the move
4. Key financial snapshot
5. Bull case
6. Bear case
7. What to watch next

Keep it concise unless the user asks for depth.

## Deep Research Note

Include:

### 1. Business overview
- Products and segments
- Revenue model
- Customers
- Geography
- Competitive position

### 2. Financial profile
- Revenue growth
- Gross margin and operating margin
- Free cash flow
- Balance sheet
- Dilution or buybacks
- Unit economics, if relevant

### 3. Valuation
Use simple sanity checks before complex models:
- Market cap and enterprise value
- Revenue and earnings multiples
- Free cash flow yield
- Peer comparison
- Growth-adjusted context

DCF is optional. If used, show assumptions and sensitivity. Do not present a DCF output as a target price without caveats.

### 4. Catalysts
- Earnings dates
- Product launches
- Regulatory events
- Macro sensitivity
- Industry shifts
- Management changes

### 5. Risks
- Competitive risk
- Margin pressure
- Customer concentration
- Balance sheet risk
- Valuation risk
- Regulatory or legal risk

### 6. Bull and bear cases
Write both clearly. If one side is weak, say so.

## Earnings Analysis

For earnings, collect:
- EPS and revenue vs consensus
- Guidance vs consensus
- Segment performance
- Margin commentary
- Cash flow
- Management tone
- Stock reaction
- Analyst or market interpretation

Output:

```
$TICKER earnings:

The headline: [one sentence]

Numbers:
- Revenue: [actual] vs [estimate]
- EPS: [actual] vs [estimate]
- Guidance: [actual] vs [estimate]

What mattered:
1. [takeaway]
2. [takeaway]
3. [takeaway]

Bull read: [...]
Bear read: [...]
Watch next: [...]
```

## Peer Comparison

Compare:
- Growth
- Margins
- Valuation
- Balance sheet
- Market share or product differentiation
- Execution quality

Use tables when comparing multiple companies.

## Market Briefing

For daily commentary, keep it under 2,000 characters unless asked for a full note.

Prioritize:
- Major index moves
- Mega-cap movers
- Earnings results
- Macro data
- Sector moves
- User-provided watchlist names

Use the separate `market-daily-briefing` skill if available for a more detailed briefing workflow.

## Verification Rules

- Verify every price move and percentage against a reliable source.
- Do not trust stale snippets without checking dates.
- Distinguish reported facts from interpretation.
- Quote filings and transcripts directly for important claims.
- If data is missing, say what is missing.
- Never use ID columns or row counts as revenue or payout figures.

## Writing Style

- Be specific
- Avoid vague "strong fundamentals" language
- Explain the mechanism behind a stock move
- Separate thesis from evidence
- No unsupported price targets
- No personalized buy/sell advice

## Output Format

For most requests:

1. Bottom line
2. Key facts
3. What changed
4. Bull case
5. Bear case
6. What to watch
7. Sources or data notes
