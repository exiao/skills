---
name: thesis-tracker
description: Maintain and update investment theses for portfolio positions and watchlist names. Track key data points, catalysts, and thesis milestones over time. Use when updating a thesis, reviewing position rationale, or checking if a thesis is still intact. Triggers on "update thesis for [company]", "is my thesis still intact", "thesis check", "add data point to [company]", "review my positions", "thesis scorecard".
---

# Thesis Tracker

Maintain and update investment theses for portfolio positions and watchlist names.

## Storage

Theses are stored as markdown files in `~/Documents/investing/theses/TICKER.md`. Create the directory if it doesn't exist.

## Workflow

### Step 1: Define or Load Thesis

**New thesis:**
- **Company**: Name and ticker
- **Position**: Long or Short
- **Thesis statement**: 1-2 sentence core thesis
  - e.g., "Long AAPL: services mix shift drives margin expansion + installed base monetization underappreciated"
- **Key pillars**: 3-5 supporting arguments
- **Key risks**: 3-5 risks that would invalidate
- **Catalysts**: Upcoming events that prove/disprove (earnings, product launches, regulatory)
- **Target price / valuation**: What it's worth if thesis plays out
- **Stop-loss trigger**: What would cause an exit
- **Entry date and price**

**Existing thesis:** Load from `~/Documents/investing/theses/TICKER.md`

### Step 2: Update Log

For each new data point:

```markdown
## Update Log

### YYYY-MM-DD: [Brief title]
- **Data point**: What changed (earnings beat, mgmt departure, competitor move)
- **Thesis impact**: Strengthens / Weakens / Neutral on which pillar
- **Action**: No change / Increase / Trim / Exit
- **Conviction**: High / Medium / Low
```

### Step 3: Thesis Scorecard

Maintain a running scorecard:

| Pillar | Original Expectation | Current Status | Trend |
|--------|---------------------|----------------|-------|
| Revenue growth >20% | On track | Q3 was 22% | Stable |
| Margin expansion | Behind | Margins flat YoY | Concerning |
| New product launch | Pending | Delayed to Q2 | Watch |

### Step 4: Catalyst Calendar

| Date | Event | Expected Impact | Notes |
|------|-------|-----------------|-------|
| | | | |

### Step 5: Output

Thesis summary formatted for:
- Quick portfolio review
- Detailed position write-up
- Risk assessment

## File Template

```markdown
# [COMPANY] ([TICKER]) -- [LONG/SHORT]

**Thesis**: [1-2 sentence core thesis]
**Entry**: [Date] at $[Price]
**Target**: $[Price] ([X]% upside)
**Stop**: $[Price] or [condition]
**Conviction**: [High/Medium/Low]

## Pillars

1. [Pillar 1]
2. [Pillar 2]
3. [Pillar 3]

## Risks

1. [Risk 1]
2. [Risk 2]
3. [Risk 3]

## Scorecard

| Pillar | Expected | Current | Trend |
|--------|----------|---------|-------|

## Catalysts

| Date | Event | Impact | Status |
|------|-------|--------|--------|

## Update Log

### YYYY-MM-DD: [Title]
- Data point:
- Impact:
- Action:
- Conviction:
```

## Important Notes

- A thesis should be falsifiable. If nothing could disprove it, it's not a thesis.
- Track disconfirming evidence as rigorously as confirming evidence.
- Review theses at least quarterly, even when nothing dramatic happened.
- If managing multiple positions, offer a full portfolio thesis review.
- Use `bloom earnings TICKER` and `bloom info TICKER` for latest data when updating.
