# Portfolio Rebalance

Analyze portfolio allocation drift and generate rebalancing trade recommendations. Considers tax implications, transaction costs, and wash sale rules.

## Workflow

### Step 1: Current State

For each account:
- Account type (taxable, IRA, Roth, 401k)
- Holdings with current market value
- Cost basis (taxable accounts)
- Unrealized gains/losses per position

### Step 2: Drift Analysis

| Asset Class | Target % | Current % | Drift | $ Over/Under |
|------------|----------|-----------|-------|-------------|
| US Large Cap | | | | |
| US Small/Mid Cap | | | | |
| International Developed | | | | |
| Emerging Markets | | | | |
| Investment Grade Bonds | | | | |
| High Yield / Credit | | | | |
| TIPS | | | | |
| Alternatives | | | | |
| Cash | | | | |

Flag positions exceeding the rebalancing band (typically ±3-5%).

### Step 3: Trade Recommendations

**Tax-Aware Rules:**
- Rebalance in tax-advantaged accounts first (IRA, Roth) — no tax consequences
- In taxable accounts, avoid selling positions with large short-term gains
- Harvest losses where possible while rebalancing
- Watch for wash sale rules (30-day window) across all accounts
- Direct new contributions to underweight asset classes instead of trading

**Trade List:**

| Account | Action | Security | Shares/$ | Reason | Tax Impact |
|---------|--------|----------|----------|--------|-----------|
| | Buy/Sell | | | Rebalance / TLH | ST gain / LT gain / Loss |

### Step 4: Asset Location Review

- **Tax-deferred (IRA/401k)**: Bonds, REITs, high-turnover funds
- **Roth**: Highest expected growth assets
- **Taxable**: Tax-efficient equity (index ETFs, munis), TLH candidates

### Step 5: Output

- Drift analysis table
- Recommended trade list (Excel)
- Tax impact summary
- Before/after allocation comparison

## Important Notes

- Don't rebalance for its own sake — small drift within bands is fine
- Tax costs can outweigh rebalancing benefits in taxable accounts — calculate the breakeven
- Consider pending cash flows before trading
- Wash sale rules apply across all household accounts
- Document rationale for every trade for compliance
