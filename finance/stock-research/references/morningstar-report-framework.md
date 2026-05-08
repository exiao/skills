# Morningstar-Quality Equity Report Framework

Reference for generating institutional-grade stock research reports. Based on Morningstar's actual report structure and methodology. Used by `investing-log` PR #411 (Morningstar-style reports).

## Schema (v2.0)

Required top-level fields: `meta`, `thesis`, `rating`, `bottom_line`, `bull_bear`, `memo`, `moat`, `fair_value`, `capital_allocation`, `financials_history`

Optional: `management`, `appendix`

## Morningstar-Signature Sections

### 1. Economic Moat (required)
Rating: `none` | `narrow` | `wide`

A moat exists ONLY if the company can earn returns above its cost of capital for 10+ years. Five sources:
- **Switching costs**: Real costs for customers to switch (data lock-in, retraining, integration)
- **Network effects**: Product value increases with more users
- **Intangible assets**: Brands, patents, regulatory licenses that block competition
- **Cost advantage**: Structural cost advantages from process, location, scale, or unique assets
- **Efficient scale**: Market only supports limited number of profitable competitors

Key test: ROIC > WACC consistently = moat evidence. ROIC < WACC = no moat regardless of narrative.

### 2. Fair Value Estimate (DCF required)
Must include explicit DCF math, not vibes-based valuation:
1. Project revenue for 5-10 years (state growth assumptions)
2. Estimate terminal FCF margins
3. Apply discount rate (8-12% depending on risk)
4. Calculate terminal value with perpetuity growth (2-4%)
5. Sum discounted cash flows → equity value → per share fair value

Uncertainty classification:
- **Low**: Utilities, regulated monopolies
- **Medium**: Consumer staples, mature tech
- **High**: Growth tech, cyclicals
- **Very High**: Biotech, emerging markets
- **Extreme**: Pre-revenue, speculative

Margin of safety = (fair_value - current_price) / fair_value

### 3. Capital Allocation Rating
Rating: `exemplary` | `standard` | `poor`

Three components:
- **Balance sheet**: Debt/equity, interest coverage, credit quality, cash reserves
- **Investments**: R&D effectiveness, M&A track record, capex discipline
- **Shareholder returns**: Buyback timing (at low prices = good), dividend sustainability, capital return history

### 4. Financial History Table
5-10 years of: revenue, EPS, FCF, operating margin, ROIC, debt/equity, revenue growth.
Present trends, not just snapshots. ROIC > 15% highlight green, < 8% highlight red.

### 5. Management / Stewardship
CEO name and tenure, insider ownership %, capital allocation track record, compensation alignment with shareholders.

## Template Rendering

The `detail.html` template (investing-arena) renders these sections:
- **Moat/FV strip**: Horizontal bar below rating showing moat rating, fair value estimate, uncertainty, capital allocation
- **Financial history table**: 7-column table with color-coded ROIC
- **Chart timeframe selector**: 1M/3M/1Y/3Y/5Y buttons calling `/reports/api/{symbol}/price?timeframe=X`
- **Staleness indicator**: JS-based color coding (green <7d, yellow <30d, red >30d)
- **Print stylesheet**: Hides chart/TOC for PDF export

## Common Mistakes
- Using "strong brand" as moat justification without ROIC evidence
- Presenting DCF output without stating discount rate, growth, and terminal assumptions
- Missing the ROIC vs WACC comparison (the core moat test)
- Financial history with < 5 years of data
- Capital allocation rating without citing specific decisions (buybacks, M&A)
- Font: template uses Inter from Google Fonts (not General Sans, which isn't freely hosted)

## Key Files (investing-log repo)
- `reports/schema.json` — JSON schema v2.0
- `scripts/generate_ondemand.py` — On-demand report generation via DeepAgents
- `scripts/generate_reports.py` — Pipeline-based report generation from research markdown
- `investing-arena/templates/reports/detail.html` — Report template
- `investing-arena/routes/reports.py` — FastAPI routes
