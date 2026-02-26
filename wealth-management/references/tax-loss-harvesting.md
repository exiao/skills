# Tax-Loss Harvesting

Identify TLH opportunities across taxable accounts. Find positions with unrealized losses, suggest replacements, and track wash sale windows.

## Workflow

### Step 1: Identify Candidates

| Security | Asset Class | Cost Basis | Current Value | Unrealized Loss | Holding Period | % Loss |
|----------|-----------|-----------|---------------|-----------------|---------------|--------|
| | | | | | ST / LT | |

**Prioritize by:**
1. Largest absolute loss
2. Short-term losses first (offset gains taxed at ordinary income rates)
3. Positions with largest % loss

### Step 2: Gain/Loss Budget

| Category | Amount |
|----------|--------|
| Realized ST gains YTD | |
| Realized LT gains YTD | |
| Realized losses YTD | |
| Net gain/(loss) | |
| Carryforward losses from prior years | |
| **Target harvesting amount** | |

**Tax savings estimate:**
- ST losses × marginal ordinary income rate
- LT losses × capital gains rate
- Up to $3,000 net loss deductible against ordinary income; excess carries forward

### Step 3: Replacement Securities

Replacement must:
- Maintain similar market exposure (same asset class/sector/geography)
- NOT be "substantially identical" (wash sale rule)
- Have similar risk/return characteristics

| Sell | Replace With | Reason | Tracking Error Risk |
|------|-------------|--------|-------------------|
| SPY | IVV | Same index, different fund family | Minimal |
| VXUS | ACWX | Similar exposure, different index | Low |
| Individual stock | Sector ETF | Broader exposure, no wash sale risk | Moderate |

### Step 4: Wash Sale Check

Before executing:
- Check ALL accounts in the household (taxable, IRA, Roth, spouse accounts)
- 30-day lookback: Did we buy substantially identical securities in the last 30 days?
- 30-day forward: Block repurchase for 30 days
- Check DRIPs that could trigger wash sales

| Security Sold | Window Start | Window End | DRIP Active? | Risk |
|--------------|-------------|-----------|-------------|------|
| | | | | |

### Step 5: Execution Plan

| Trade # | Account | Action | Security | Shares | Est. Loss | Replacement |
|---------|---------|--------|----------|--------|-----------|-------------|
| | | Sell | | | | |
| | | Buy | | | | |

**Summary:**
- Total losses harvested: $
- Estimated tax savings: $ (at marginal rate of %)
- Net portfolio impact: minimal

### Step 6: Post-Harvest Tracking

After 30+ days, optionally swap back to original securities or maintain replacements. Update cost basis records.

### Step 7: Output

- Harvest opportunity list (Excel)
- Trade execution sheet
- Wash sale tracking calendar
- Tax savings estimate
- Replacement security rationale

## Important Notes

- Wash sale violations disallow the loss AND adjust cost basis
- Substantially identical = same security, not same asset class — ETFs on different indexes are generally fine
- Coordinate across ALL household accounts including retirement accounts
- Harvesting resets cost basis — more gains later
- Year-end is prime season but opportunities exist year-round
- Mutual fund capital gains distributions in December create additional urgency
- Not all losses are worth harvesting — factor in transaction costs and tracking error
