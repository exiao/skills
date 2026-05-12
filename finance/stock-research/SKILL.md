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
| Daily briefing (auto) | Cron: 3pm ET Mon-Fri → Signal DM to the account owner |

---

## Tools

**Bloom-based (default):**
- **bloom-cli** (preloaded skill): Primary data source. `bloom info`, `bloom earnings`, `bloom financials`, `bloom price`, `bloom screen`, `bloom transcript`, `bloom catalysts`. Always try bloom-cli first before web search.
- **Bloom MCP** (`https://$BLOOM_API_DOMAIN/mcp/`, Bearer: `$BLOOM_MCP_API_KEY`): Check what stocks Bloom users are watching; prioritize coverage accordingly

**Self-contained (CPE-research, no Bloom dependency):**
- **research CLI** (`CPE-research/research-cli`): Wraps FMP, SEC EDGAR (XBRL + EFTS full-text search + filing text + 13F holders), AlphaSense, and Serper. 25 commands with `--source auto|edgar|fmp` routing. See [research-cli.md](references/research-cli.md) for full command reference and [sec-edgar-api.md](references/sec-edgar-api.md) for EDGAR endpoint details. Use when work must be self-contained. See [adversarial-research-framework.md](references/adversarial-research-framework.md) for full data source mapping.

**Shared:**
- **Serper** (`web-search` skill, `SERPER_API_KEY`): Search for earnings releases, analyst commentary, news, filings
- **Firecrawl** (`FIRECRAWL_API_KEY`): Scrape full articles, earnings releases, SEC filings when search snippets aren't enough

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

### Morningstar-Quality Report (investing-log)
Triggered by: "generate report for [TICKER]", "Morningstar report", "stock report"

Uses the investing-log `generate_ondemand.py` script with DeepAgents. Reports must conform to schema v2.0 with these Morningstar-signature sections: economic moat (none/narrow/wide with ROIC evidence), fair value estimate (explicit DCF with stated assumptions), capital allocation rating, 5+ year financial history table, and management assessment.

See **[references/morningstar-report-framework.md](references/morningstar-report-framework.md)** for full schema, methodology, template rendering details, and common mistakes.

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

**Cron ID:** `$CRON_JOB_ID`
**Schedule:** `0 15 * * 1-5` (3pm ET, Mon-Fri)
**Model:** Sonnet
**Delivery:** Signal DM to the account owner

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

## Reference Material

- **[Adversarial Research Framework](references/adversarial-research-framework.md)** — 4-phase pipeline (Gather → 5-lens Analyze → Adversarial Synthesize → Eval) for institutional-quality one-page memos. Includes Eric's source hierarchy (filings > IR materials > transcripts-as-biased > expert calls > news), first-principles reasoning methodology (hypothesize-before-lookup), required supply/demand and competition-evolution sections, 7-dimension eval rubric, memo template, anti-pattern detection, and non-Bloom data source mapping. Use this for CPE-research work or any research that needs to be self-contained without Bloom CLI.
- **[Anthropic FSI Plugins](references/anthropic-fsi-plugins.md)** — Index of institutional-grade skill templates cloned from github.com/anthropics/financial-services-plugins and knowledge-work-plugins. Contains prompt patterns, workflow sequences, and output templates for earnings analysis, comps, DCF, idea generation, thesis tracking, and sector overviews. Consult when you need institutional framing beyond what this skill covers.
- **[SEC EDGAR API Reference](references/sec-edgar-api.md)** — Complete free EDGAR API surface: endpoints in research-cli (submissions, XBRL company concept/facts/frames), endpoints not yet added (EFTS full-text search, filing document text, 13F holdings parsing), XBRL taxonomy/period/unit details, and bulk data downloads. Consult when expanding EDGAR coverage or debugging EDGAR API calls.
- **[Eval Benchmarks for Research Agents](references/eval-benchmarks-for-research-agents.md)** — 6-layer eval framework for measuring equity research agent quality: Vals.ai Finance Agent (accuracy), FinanceBench (citations), APEX IB (hard reasoning), OBLIQ (retrieval), METR (endurance), custom memo rubric. Includes Opus 4.6 scorecard, DST patterns from investing-log, ACE self-improving playbook framework, and Bloom eval system patterns. Consult when building or evaluating research agent output quality.
- **[CPE Pipeline Operations](references/cpe-pipeline-operations.md)** — How to run the CPE research agent end-to-end, workspace reuse/caching behavior, eval runner commands, billing proxy setup for Layer 6 LLM-as-judge (model name mismatch workaround), known test failures, and latest benchmark scores.

## Notes

- For valuation work, always note assumptions explicitly — these are frameworks, not financial advice
- When Bloom MCP shows a stock is widely held by users, front-load that coverage
- Use Firecrawl on earnings press releases when search snippets cut off before the numbers
