---
name: idea-generation
description: Systematic stock screening and investment idea sourcing. Combines quantitative screens, thematic research, and pattern recognition to surface new long and short ideas. Use when looking for new ideas, running screens, or conducting thematic sweeps. Triggers on "idea generation", "stock screen", "find ideas", "what looks interesting", "screen for", "new ideas", "pitch me something", "what should I buy".
---

# Idea Generation

Systematic stock screening and investment idea sourcing.

## Data Sources

1. **bloom-cli**: `bloom screen`, `bloom quote TICKER`, `bloom peers TICKER`, `bloom financials TICKER`
2. **Web search**: Sector trends, insider buying, recent IPOs, activist activity
3. **Serper/Grok**: News, sentiment, social chatter

## Workflow

### Step 1: Define Search Criteria

Ask for parameters (or use sensible defaults):
- **Direction**: Long, short, or both
- **Market cap**: Large, mid, small, micro
- **Sector**: Specific or cross-sector
- **Style**: Value, growth, quality, special situation, event-driven
- **Geography**: US, international, global
- **Theme**: Any specific angle (AI, reshoring, aging demographics, etc.)

### Step 2: Quantitative Screens

**Value Screen**
- P/E below sector median
- EV/EBITDA below historical average
- Free cash flow yield >5%
- Price/book below 1.5x
- Insider buying in last 90 days

**Growth Screen**
- Revenue growth >15% YoY
- Earnings growth >20% YoY
- Revenue acceleration (growth rate increasing)
- Expanding margins
- ROIC >15%

**Quality Screen**
- Consistent revenue growth (5+ years)
- Stable or expanding margins
- ROE >15%
- Low debt/equity
- High FCF conversion
- Insider ownership >5%

**Short Screen**
- Declining revenue or decelerating growth
- Margin compression
- Rising receivables/inventory vs. sales
- Insider selling
- Valuation premium to peers without justification
- Accounting red flags

**Special Situation Screen**
- Recent IPOs/SPACs with lockup expirations
- Spin-offs in last 12 months
- Companies emerging from restructuring
- Activist involvement
- Management changes at underperformers

### Step 3: Thematic Sweep

For thematic ideas:
1. Define the thesis (e.g., "AI infrastructure spending accelerates through 2027")
2. Map the value chain: who benefits directly vs. indirectly?
3. Pure-play vs. diversified exposure
4. What's already "priced in" vs. under-appreciated
5. Second-order beneficiaries the market hasn't connected to the theme

### Step 4: Idea Presentation

For each idea that passes:

**[Company Name] (TICKER) -- [Long/Short] -- [One-Line Thesis]**

| Metric | Value | vs. Peers |
|--------|-------|-----------|
| Market cap | | |
| EV/EBITDA (NTM) | | |
| P/E (NTM) | | |
| Revenue growth | | |
| EBITDA margin | | |
| FCF yield | | |

**Thesis (3-5 bullets):**
- Why this is mispriced
- What the market is missing
- Catalyst to realize value

**Key Risks:**
- What would make this wrong

**Next Steps:**
- Build full model? Deep-dive? Expert call?

### Step 5: Output

- Shortlist of 5-10 ideas with one-page summaries
- Screening criteria documented
- Comparison table across all ideas
- Prioritized: which to research first

## Important Notes

- Screens surface candidates, not conclusions. Every output needs fundamental work.
- Best ideas come from intersections (quality company at value price due to temporary headwind)
- Avoid crowded trades: check ownership data, short interest, analyst coverage
- Contrarian ideas need a catalyst. Being early without a catalyst is the same as being wrong.
- Short ideas need higher conviction: timing is harder, risk is asymmetric
