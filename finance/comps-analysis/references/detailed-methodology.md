# Comps Analysis: Detailed Methodology

## Choosing the Right Metrics

### Start with "What question am I answering?"

**"Which company is undervalued?"**
Focus on: EV/Revenue, EV/EBITDA, P/E, Market Cap

**"Which company is most efficient?"**
Focus on: Gross Margin, EBITDA Margin, FCF Margin, Asset Turnover

**"Which company is growing fastest?"**
Focus on: Revenue Growth %, EBITDA CAGR, User/Customer Growth

**"Which is the best cash generator?"**
Focus on: FCF, FCF Margin, FCF Conversion, CapEx intensity

## Excel/Spreadsheet Output

When building in Excel or CSV:

### Formatting Conventions
- Blue text = hardcoded input data
- Black text = formula/calculated
- Section headers: dark blue background (#1F4E79), white bold text
- Column headers: light blue background (#D9E1F2), black bold text
- Statistics rows: light grey (#F2F2F2)
- No borders (clean, minimal)
- All metrics center-aligned
- One blank row between company data and statistics

### Formula Examples
```
Gross Margin: =GrossProfit/Revenue
EBITDA Margin: =EBITDA/Revenue
EV/Revenue: =EnterpriseValue/Revenue
EV/EBITDA: =EnterpriseValue/EBITDA
P/E: =MarketCap/NetIncome
FCF Yield: =FCF/MarketCap
```

### Statistics Formulas
```
Maximum: =MAX(range)
75th Percentile: =QUARTILE(range, 3)
Median: =MEDIAN(range)
25th Percentile: =QUARTILE(range, 1)
Minimum: =MIN(range)
```

### Cell Comments
Every hardcoded input needs a comment citing the source:
- "bloom-cli financials MSFT, accessed 2025-05-05"
- "Q4 2024 10-K filing, page 42"
- "Consensus estimate from Yahoo Finance, 2025-05-05"

## Step-by-Step Build Process

1. **Set up structure** (headers, formatting, units) -- confirm with user
2. **Gather data** (bloom-cli, web search, SEC) -- input all raw numbers
3. **Build formulas** (margins first, then multiples) -- verify each section
4. **Add statistics** (copy formula structure for all columns)
5. **Quality control** (sanity checks, verify references, check for errors)
6. **Documentation** (sources, methodology, date stamp)

## Common Ratio Formulas

```
Gross Margin = Gross Profit / Revenue
EBITDA Margin = EBITDA / Revenue
FCF Margin = Free Cash Flow / Revenue
FCF Conversion = FCF / Operating Cash Flow
ROE = Net Income / Shareholders' Equity
ROA = Net Income / Total Assets
Asset Turnover = Revenue / Total Assets
Debt/Equity = Total Debt / Shareholders' Equity
PEG Ratio = P/E / Growth Rate
Rule of 40 = Revenue Growth % + FCF Margin %
```

## Output Checklist

- [ ] All companies are truly comparable
- [ ] Data is from consistent time periods
- [ ] Units clearly labeled
- [ ] All inputs have source citations
- [ ] Statistics include 5 rows (Max, 75th, Median, 25th, Min)
- [ ] Sanity checks pass (margins logical, multiples reasonable)
- [ ] Date stamp is current
