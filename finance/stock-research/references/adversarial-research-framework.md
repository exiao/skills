# Adversarial Equity Research Framework

From CPE-research agent architecture (May 2026). Designed to produce institutional-quality one-page memos judged on reasoning quality and conviction calibration, not summarization.

## Core Principle
Bad AI research = "here's what everyone says." Good research = "here's what I believe and why, having stress-tested the thesis." Force adversarial reasoning, not consensus aggregation.

## Source Hierarchy (Eric's weighting, May 2026)

Sources are NOT equal. Weight them explicitly:

**Ground Truth (high confidence, treat as authoritative):**
1. SEC filings (10-K, 10-Q, proxy statements via EDGAR) -- audited, legally binding
2. Investor presentations and IR materials -- management's prepared narrative backed by filed numbers
3. Financial statements (FMP standardized) -- derived from filings, comparable across companies

**Biased View (use with healthy skepticism):**
4. Earnings call transcripts -- management is SELLING a narrative. Note what they emphasize AND what they avoid. Compare priorities quarter-over-quarter. Forward-looking statements are aspirational, not factual.

**Worth Reading, Verify Independently:**
5. Expert call transcripts, industry expert interviews -- channel checks, limited sample size
6. Independent research (Substacks, deep-dive blogs, short-seller reports) -- contrarian insights, verify against primary sources
7. Sell-side analyst reports (AlphaSense) -- consensus gauge, not evidence
8. News and press coverage -- context and timing, not evidence

**Rule:** When sources conflict, always default UP the hierarchy. A 10-K number overrides a transcript claim.

## First-Principles Reasoning Methodology

The lens skills must force causal reasoning, not pattern matching. For each key question:
1. **Hypothesize first** -- what would you EXPECT before looking at data?
2. **Look up the data** -- now check actuals
3. **Explain the delta** -- the gap between hypothesis and reality is where insight lives
4. **Build causal chains** -- each KEY ARGUMENT needs 2+ steps ("X because Y, which persists because Z")
5. **Falsify your own thesis** -- equal effort trying to disprove. Name what evidence would change your mind.

## 4-Phase Pipeline

```
GATHER (parallel) -> ANALYZE (per-lens) -> SYNTHESIZE (adversarial) -> EVAL (citations)
```

### Phase 1: GATHER
No reasoning. Parallel data collection into raw files. Gather MORE than needed; synthesis decides what matters.

**Required data sources (updated May 2026):**
- All research CLI commands (financials, metrics, ratios, scores, DCF, earnings, transcript, ratings, insider, holders, peers, filings, XBRL, AlphaSense queries, news)
- Investor presentations (scrape IR page)
- Independent research (Substack, SeekingAlpha searches)
- Competitor financial data (top 3 competitors' revenue/margins)
- Supply/demand dynamics (capacity, lead times, pricing)
- Expert insights (channel checks, industry expert commentary)
- Industry market outlook (multiple web searches)

### Phase 2: ANALYZE (5 Independent Lenses)
Each lens gets its OWN LLM call with fresh context. No cross-contamination.

| Lens | Focus | Key Questions |
|------|-------|---------------|
| Business Quality | Moat, revenue quality, management, execution | How durable is the moat? Revenue recurring vs one-time? |
| Financial Health | FCF, margins, debt, capital returns, reinvestment | FCF conversion real? Margin trajectory sustainable? |
| Competitive Position | Market share, switching costs, TAM skepticism, **supply/demand**, **competition evolution** | Supply/demand balance by segment? How has the competitive field changed over 3-5 years? |
| Valuation | What's priced in, implied growth, scenarios | What growth is the current multiple assuming? |
| Risk Assessment | Concentration, cyclicality, regulatory, thesis-killers | What would make you WRONG? |

**Each lens must:**
- Lead with conclusion
- Assign confidence 1-10 with explicit reasoning
- Cite specific data with file + field path
- Flag MISSING data that would change the view
- Include 2+ steps of causal reasoning per key argument
- Start with a hypothesis BEFORE reading data, then explain the delta

### Phase 3: SYNTHESIZE (Adversarial Reasoning)
NOT a summary. Steel-man bull, steel-man bear, pre-mortem, conviction scoring.

**Anti-pattern detection:**
- Bull/bear within 10% -> "insufficient edge"
- Conviction >8 -> MUST have explicit "what makes me wrong"
- All lenses agree -> flag potential groupthink

### Phase 4: EVAL (Automated Quality Gate)
Adversarial reviewer checks:
- Every number traces to a raw source
- Sources recent (flag >6 months old)
- No circular reasoning
- Bull/bear genuinely adversarial
- Conviction calibrated
- **Reasoning depth:** >80% of key arguments have 2+ step causal chains
- **Source hierarchy compliance:** key claims anchored to ground truth, not news/blogs
- FAIL -> loop to Phase 3 with feedback. Max 2 retries.

## Required Report Sections (May 2026)

### Supply/Demand Balance (in Competitive lens)
Per segment: current balance (capacity utilization, lead times, inventory, pricing), supply trajectory (who's adding capacity, when), demand drivers (secular vs cyclical), pricing implications, historical cycle context.

### Competition Evolution Over Time (in Competitive lens)
Not just current state but trajectory: consolidation trends, intensity changes, market structure evolution, technology reshuffling, barriers to entry direction.

## Eval Dimensions (7 total, updated May 2026)

| Dimension | What It Measures | Target |
|-----------|-----------------|--------|
| Conviction Clarity | Clear direction with justified score | >=4/5 |
| First-Principles Reasoning | Causal chains from data, not consensus | >=4/5 |
| Directional Insight | Non-obvious thesis, "what's priced in" work | >=3/5 |
| Source Quality | Primary sources, cited, verified | >=4/5 |
| Information Density | Every sentence earns its place, <800 words | >=3/5 |
| Source Diversity & Hierarchy | 4+ source types, correct weighting | >=3/5 |
| Industry Dynamics | Supply/demand + competition evolution present | >=3/5 |

Composite target: >=3.5/5 for production quality.

## One-Page Memo Format

```
====================================================
{TICKER} -- {COMPANY NAME}
{DATE} | ${PRICE} | ${MARKET_CAP} Market Cap
====================================================

VERDICT: {LONG/SHORT/NEUTRAL} | Conviction: {X}/10
Time Horizon: {specific period}

-- THESIS --
{2-3 sentences. Core insight. Why this, why now.}

-- KEY ARGUMENTS --
1. {Most important point with specific data} [source]
2. {Second} [source]
3. {Third} [source]

-- WHAT'S PRICED IN --
{Current multiple implies X% growth. We think Y because Z.}

-- BIGGEST RISK --
{The one thing that kills the thesis. Specific, not generic.}

-- MONITORABLES --
* {Metric/event} -- reassess if {threshold}
* {Metric/event} -- reassess if {threshold}
====================================================
```

## Data Sources (Non-Bloom, Self-Contained)

Alpha Vantage dropped May 2026. FMP covers all AV functionality with better rate limits.

| Source | Strengths | Auth | Cost |
|--------|-----------|------|------|
| FMP | Workhorse: financials, DCF, ratios, metrics, insider, holders, peers, screener, news, profile | API key | $29/mo+ |
| SEC EDGAR | Authoritative filing text, XBRL cross-verification | Free | Free |
| AlphaSense | GenSearch: NL questions with cited answers | OAuth + API key | Subscription |
| Serper | News, industry context, recent developments | API key | $50/mo |
| Firecrawl | Deep scrape: JS-rendered pages, full articles | API key | Subscription |

**Key FMP endpoints:**
- `/stable/income-statement?symbol=X` / `balance-sheet-statement` / `cash-flow-statement`
- `/stable/key-metrics?symbol=X` / `ratios` / `financial-scores`
- `/stable/profile?symbol=X` / `stock-peers`
- `/stable/analyst-estimates?symbol=X` / `price-target` / `analyst-stock-recommendations`
- `/stable/earnings-surprises?symbol=X`
- `/stable/news/stock?symbols=X&limit=N`

**Key EDGAR endpoints (no auth, JSON):**
- `data.sec.gov/submissions/CIK{10-digit}.json`
- `data.sec.gov/api/xbrl/companyfacts/CIK{10-digit}.json`
- `data.sec.gov/api/xbrl/companyconcept/CIK{10-digit}/us-gaap/{Concept}.json`

**AlphaSense Agent API:**
- OAuth password-grant -> Bearer token
- GraphQL at `api.alpha-sense.com/gql`
- `genSearch.auto` mutation -> poll `genSearch.conversation` until progress=1.0
- Returns markdown with inline citations `[[N * Source]]`
- Modes: auto (recommended), fast, thinkLonger, deepResearch

## Quality Audit Checklist (May 2026)

When auditing a research agent's output:
- [ ] Source hierarchy respected (filings > IR > transcripts > expert calls > news)
- [ ] 4+ distinct source types in the memo
- [ ] Key arguments have 2+ step causal chains
- [ ] Supply/demand analyzed per segment with data
- [ ] Competition evolution tracked over 3-5 years
- [ ] Transcripts treated as biased (management spin noted)
- [ ] Evaluator checks reasoning depth, not just citation accuracy
- [ ] Eval rubric covers all 7 dimensions
