---
name: earnings-analysis
description: Create equity research earnings update reports analyzing quarterly results. Covers beat/miss analysis, key metrics, updated estimates, guidance changes, and revised thesis. Use when user requests "earnings update", "quarterly update", "earnings analysis", "Q1/Q2/Q3/Q4 results", "post-earnings report", or "how did [company] do this quarter". Data sourced via bloom-cli and web search.
---

# Equity Research Earnings Update

Create **earnings update reports** analyzing quarterly results, following institutional standards.

**Key Characteristics:**
- Length: 8-12 pages (3,000-5,000 words)
- Tables: 1-3 summary tables
- Charts: 8-12 figures
- Focus: What's NEW: beat/miss, updated estimates, thesis impact

## When to Use

- "Create an earnings update for [Company] Q3 2025"
- "Analyze [Company]'s quarterly results"
- "Post-earnings report for [Company]"
- "How did AAPL do this quarter?"

## Data Sources

1. **bloom-cli**: `bloom earnings TICKER`, `bloom financials TICKER`, `bloom quote TICKER`
2. **Web search**: Latest earnings release, transcript, guidance
3. **SEC EDGAR**: 10-Q/10-K filings for detail

Do NOT rely on training data. Always search for the latest results.

## Workflow

### Phase 1: Data Collection

1. Check today's date
2. Run `bloom earnings TICKER` for latest results
3. Search web: "[Company] Q[X] [Year] earnings results"
4. Verify the earnings date is within last 3 months
5. Find the earnings call transcript
6. Pull consensus estimates for comparison

### Phase 2: Analysis

**Beat/Miss Analysis:**
- Lead with whether company beat or missed
- Quantify variances: "Revenue beat by $120M or 3%"
- Explain WHY results differed from expectations

**Key Metrics:**
- Revenue (total + segment breakdown)
- EPS (GAAP and non-GAAP)
- Margins (gross, operating, net)
- Key operating metrics (users, subscribers, GMV, etc.)

**Guidance:**
- Compare new guidance vs. prior guidance vs. consensus
- Highlight any raises, cuts, or narrowing of ranges

### Phase 3: Charts (Python/matplotlib)

Generate 8-12 charts:
1. Quarterly revenue progression (4-8 quarters)
2. Quarterly EPS progression
3. Margin trends
4. Revenue by segment/geography
5. Key operating metrics
6. Beat/miss history
7. Estimate revision trends
8. Valuation chart (forward P/E or EV/EBITDA)

### Phase 4: Report Structure

- **Page 1**: Earnings summary with key takeaways, rating context
- **Pages 2-3**: Detailed results analysis with beat/miss
- **Pages 4-5**: Key metrics, guidance changes
- **Pages 6-7**: Updated investment thesis assessment
- **Pages 8-10**: Valuation and updated estimates
- **Pages 11-12**: Appendix (optional)

### Phase 5: Quality Check

- [ ] Every figure has a cited source with date
- [ ] Beat/miss analysis cites consensus source
- [ ] Guidance changes cite current and prior sources
- [ ] Old vs. new estimates shown clearly
- [ ] No stale/training-data numbers used
- [ ] Charts render correctly

## Output

**Primary**: Markdown report (or DOCX if requested)
**File Name**: `[Company]_Q[Quarter]_[Year]_Earnings_Update.md`

## Key Differences from Full Initiation

| Aspect | Earnings Update | Full Initiation |
|--------|----------------|-----------------|
| Length | 8-12 pages | 30-50 pages |
| Tables | 1-3 summary | 12-20 comprehensive |
| Turnaround | Same day | 3-6 weeks |
| Focus | What's NEW | Everything |
| Background | Brief | 6-10 pages |

## References

See `references/` for:
- `workflow.md`: Detailed search procedures and verification steps
- `report-structure.md`: Page-by-page templates
- `best-practices.md`: Quality checklist and common mistakes
