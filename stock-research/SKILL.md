---
name: stock-research
description: Use when performing stock or equity research, earnings analysis, coverage reports, or generating daily market briefings for Bloom. Covers on-demand research tasks and the scheduled daily market briefing cron job.
---

# Stock Research

Two modes: **on-demand equity research** (analyze a company, generate ideas, write coverage) and **daily market briefing** (automated cron job for Bloom users).

---

## Quick Reference

| Task | Trigger phrase |
|------|----------------|
| Earnings analysis | "analyze [TICKER] earnings", "how did [company] do" |
| Initiating coverage | "initiate coverage on [TICKER]", "deep dive on [company]" |
| Comps analysis | "run comps for [company]", "how does [ticker] compare" |
| DCF sanity check | "DCF for [ticker]", "is [company] overvalued" |
| Morning note (on-demand) | "morning note", "what's moving today", "market briefing" |
| Idea generation | "screen for ideas in [sector]", "high conviction ideas" |
| Daily briefing (auto) | Cron: 3pm ET Mon-Fri → Signal DM to Eric |

---

## Tools

- **Serper** (`web-search` skill, `SERPER_API_KEY`): Search for earnings, analyst commentary, news, filings
- **Firecrawl** (`FIRECRAWL_API_KEY`): Scrape full articles, earnings releases, SEC filings when search snippets aren't enough
- **Bloom MCP** (`https://api.getbloom.app/mcp/`, Bearer: `test-api-key`): Check what stocks Bloom users are watching; prioritize coverage accordingly

---

## On-Demand Research Workflows

### Earnings Analysis
Triggered by: "analyze [TICKER] earnings", "how did [company] do this quarter"

1. Search for the earnings release and analyst reactions
2. Pull actual vs. consensus EPS and revenue (beat/miss/in-line)
3. Cover: stock reaction (%, after-hours vs. open), guidance changes, 2-3 key takeaways (margins, growth drivers, segment breakdowns, management commentary)
4. Flag if Bloom users hold this stock (check Bloom MCP)

### Initiating Coverage / Deep Dive
Triggered by: "initiate coverage on [TICKER]", "deep dive on [company]"

Structure:
- **Thesis**: 2-3 sentence bull case
- **Business**: What they do, how they make money, moat
- **Financials**: Revenue growth, margins, key ratios
- **Valuation**: Current multiple vs. peers, historical range, rough DCF sanity check
- **Bull/Bear**: 3 bull points, 3 bear points
- **Verdict**: Rating (Buy/Hold/Sell equivalent) with price target rationale

### Comps Analysis
Triggered by: "run comps for [company]", "how does [ticker] compare to peers"

1. Identify 4-6 comparable companies (same sector, similar business model/size)
2. Pull key metrics: EV/Revenue, EV/EBITDA, P/E, P/FCF, revenue growth, EBITDA margin
3. Show where the target trades vs. peer median/mean
4. Note any premium or discount and why it's warranted or not

### DCF Sanity Check
Triggered by: "DCF for [ticker]", "is [company] overvalued"

Keep it simple — this is a sanity check, not a Bloomberg model:
1. Revenue estimates for 3-5 years (use analyst consensus if available)
2. Assumed FCF margin
3. Terminal growth rate and discount rate
4. Implied price vs. current; sensitivity on key assumptions

### Morning Note / Market Briefing (On-Demand)
Triggered by: "morning note", "what's moving today", "market briefing"

Lead with the biggest story. Cover: pre-market movers, overnight news, earnings, economic data due today. Keep under 300 words. Conversational, no tables.

### Idea Generation
Triggered by: "screen for ideas in [sector]", "high conviction ideas", "what's interesting right now"

1. Search for recent sector themes, analyst upgrades, catalyst-driven setups
2. Cross-reference with Bloom's watchlist (what are users already watching?)
3. Surface 3-5 names with a one-line thesis for each

---

## Daily Market Briefing (Cron Job)

**Cron ID:** `b04e6814-7840-4927-b529-feb052cadbfc`
**Schedule:** `0 15 * * 1-5` (3pm ET, Mon-Fri)
**Model:** Sonnet
**Delivery:** Signal DM to Eric

Runs automatically every weekday at 3pm ET. Covers:

1. **Earnings results** (today + last night): Beat/miss on EPS and revenue, stock reaction, 2-3 takeaways. Prioritize mega-caps, widely-held names, big movers, and anything popular on Bloom.
2. **Market-moving news**: Fed commentary, economic data (CPI, jobs, GDP), sector rotations, single-stock moves >5%, M&A, regulatory news.

**Output format:** Conversational narrative. No tables, no bullet dumps. Lead with the biggest story. Quiet days = 2-3 sentences. Under 2000 characters total.

---

## Common Mistakes

1. **Skipping Bloom MCP check** — Not verifying whether Bloom users hold the stock being analyzed. User-held stocks should be front-loaded in coverage; it's directly relevant to the product.
2. **Using search snippets for earnings numbers** — News article snippets often cut off before the actual EPS/revenue figures. Use Firecrawl to scrape the full earnings press release when numbers are missing.
3. **DCF overconfidence** — Presenting DCF output as a target price without flagging assumptions. These are sanity checks, not Bloomberg models. Always show sensitivity on key assumptions.
4. **Market briefing too long** — Daily briefings should be under 2000 characters, conversational, no tables. Bullet dumps and tables belong in research notes, not the cron delivery to Signal.
5. **Missing the stock reaction** — For earnings analysis, reporting EPS beat/miss without the stock's actual price reaction (% change, after-hours vs. open) is incomplete. Both numbers are required.

## Notes

- For valuation work, always note assumptions explicitly — these are frameworks, not financial advice
- When Bloom MCP shows a stock is widely held by users, front-load that coverage
- Use Firecrawl on earnings press releases when search snippets cut off before the numbers
