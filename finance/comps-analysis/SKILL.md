---
name: comps-analysis
description: |
  Build comparable company analyses with operating metrics, valuation multiples, and statistical benchmarking. Outputs structured markdown tables or CSV.

  Use for: public company valuation, benchmarking vs. peers, identifying valuation outliers, sector overview reports, investment committee presentations.

  Triggers on "comps analysis", "comparable companies", "peer comparison", "trading comps", "valuation comps", "how does X compare to peers", "build me a comps table".
---

# Comparable Company Analysis

Build comparable company analyses with operating metrics, valuation multiples, and statistical benchmarking.

## Data Sources

1. **bloom-cli**: `bloom info TICKER`, `bloom financials TICKER`
2. **Web search**: For consensus estimates, recent multiples, sector benchmarks
3. Mark all figures with source. If a figure can't be sourced, mark it `[UNSOURCED]`.

## Core Philosophy

"Build the right structure first, then let the data tell the story."

Start with 5-10 metrics that matter. A good comp is immediately readable by someone who didn't build it.

## Workflow

### Step 1: Define the Peer Group

- Companies must be truly comparable (similar business model, scale, geography)
- 5-10 peers is ideal. 3 is minimum. More than 15 is noise.
- Better to exclude than force a bad comp

### Step 2: Operating Metrics

**Core columns (always include):**
1. Company (with ticker)
2. Revenue (LTM or latest annual)
3. Revenue Growth (YoY %)
4. Gross Margin (%)
5. EBITDA Margin (%)

**Optional (choose based on industry):**
- FCF Margin, Net Margin, Rule of 40 (SaaS), ROE, Asset Turnover

### Step 3: Valuation Multiples

**Core multiples (always include):**
1. Market Cap
2. Enterprise Value
3. EV/Revenue
4. EV/EBITDA
5. P/E Ratio

**Optional:**
- FCF Yield, PEG Ratio, Price/Book, EV/FCF

### Step 4: Statistics

For every ratio/multiple column, compute:
- Maximum
- 75th Percentile
- Median
- 25th Percentile
- Minimum

Quartiles show distribution, not just average. 75th = "premium" territory. 25th = "discount" territory.

### Step 5: Output Format

```markdown
## [SECTOR] -- Comparable Company Analysis
As of [Date] | All figures in USD Millions

### Operating Metrics

| Company | Revenue | Growth | Gross Margin | EBITDA | EBITDA Margin |
|---------|---------|--------|-------------|--------|---------------|
| MSFT | 261,400 | 12.3% | 68.7% | 205,100 | 78.4% |
| GOOGL | 349,800 | 11.8% | 57.9% | 239,300 | 68.4% |
| AMZN | 638,100 | 10.5% | 47.3% | 152,600 | 23.9% |
| | | | | | |
| Median | -- | 11.8% | 57.9% | -- | 68.4% |
| 75th % | -- | 12.1% | 63.3% | -- | 73.4% |
| 25th % | -- | 11.2% | 52.6% | -- | 46.2% |

### Valuation Multiples

| Company | Mkt Cap | EV | EV/Rev | EV/EBITDA | P/E |
|---------|---------|-----|--------|-----------|-----|
| ... | | | | | |
```

## Industry-Specific Metrics

**Software/SaaS**: ARR, Net Dollar Retention, Rule of 40
**Financial Services**: ROE, Net Interest Margin, Efficiency Ratio
**Retail/E-commerce**: GMV, Take Rate, Same-Store Sales
**Healthcare**: R&D/Revenue, Pipeline Value
**Industrials**: Asset Turnover, Backlog, CapEx/Revenue

## The "5-10 Rule"

5 operating metrics + 5 valuation metrics = 10 total. Enough to tell the story. More than 15 is noise. Edit ruthlessly.

## Sanity Checks

- Gross margin > EBITDA margin > Net margin (typically true)
- EV/Revenue: typically 0.5-20x
- EV/EBITDA: typically 8-25x
- P/E: typically 10-50x
- Higher growth usually means higher multiples

## Common Mistakes

- Mixing market cap and enterprise value in formulas
- Different time periods for numerator/denominator
- Including non-comparable companies
- Using outdated data without disclosure
- Missing source citations

## Red Flags

- Negative EBITDA valued on EBITDA multiples (use revenue instead)
- P/E >100x without hypergrowth story
- Margins that don't make sense for the industry
- Mixing pure-play and conglomerates

When in doubt, exclude the company. Better 3 perfect comps than 6 questionable ones.

## Detailed Reference

See `references/detailed-methodology.md` for:
- Full formula reference guide
- Excel/spreadsheet formatting conventions
- Advanced features (dynamic headers, conditional formatting)
- Complete quality checklist
