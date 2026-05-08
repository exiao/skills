---
name: investing-log-ops
description: Manage the investing-log trading system — update trading philosophy, memory files, skill configurations, review performance, and modify pipeline behavior. Use when asked to change how the AI models trade, update trading rules, review cross-model performance, modify entry/exit criteria, or adjust the investing-log pipeline configuration. Triggers on "investing-log", "trading rules", "update the trading", "performance review", "how the models trade", "change the strategy".
---

# Investing-Log Operations

Manage and evolve the 4-model AI trading system (Claude, OpenAI, Gemini, Grok). Each model runs autonomously via GitHub Actions with its own research, portfolio review, and trade execution pipeline.

## System Architecture

```
~/projects/investing-log/
├── .agents/skills/           ← Trading system behavior (skills define HOW models trade)
│   ├── deep-research/        ← Research pipeline (screening, analysis, BUY reports)
│   ├── portfolio-review/     ← Holdings health check, SELL signal generation
│   ├── trading/              ← Trade execution, safety rules, devil's advocate
│   ├── sector-analysis/      ← Macro regime, sector rotation
│   ├── value-investing/      ← Core philosophy, case studies
│   └── personas/             ← Investment persona filters
├── memory/                   ← Per-model learned lessons (claude.md, openai.md, gemini.md, grok.md)
├── reviews/                  ← Weekly performance reviews by model
├── research/                 ← Daily research output by model
├── portfolio/                ← Daily portfolio reviews by model
├── trades/                   ← Trade execution logs by model
└── .github/workflows/        ← Pipeline automation (cron triggers, workflow_run chains)
```

## Key Relationships Between Files

When changing trading philosophy or rules, you typically need to update MULTIPLE files because the system has layered concerns:

| Layer | Files | Purpose |
|-------|-------|---------|
| Philosophy | `memory/{model}.md` | Learned lessons, what worked/failed. Shapes judgment. |
| Entry criteria | `.agents/skills/deep-research/SKILL.md` + `RESEARCH_PROCESS.md` | How candidates become BUY signals |
| Exit criteria | `.agents/skills/portfolio-review/SKILL.md` + `PORTFOLIO_REVIEW_PROCESS.md` | How holdings become SELL signals |
| Execution | `.agents/skills/trading/TRADING_PROCESS.md` + `SAFETY_RULES.md` | How signals become trades |
| Hard blocks | `.agents/skills/trading/SAFETY_RULES.md` | Non-negotiable compliance rules |

**Rule of thumb**: Philosophy changes touch memory + at least one skill. Hard block changes touch only SAFETY_RULES.md. Process changes touch the relevant PROCESS.md file.

## Changing Trading Rules

### Judgment-based vs Mechanical

The system uses TWO types of rules:
1. **Hard blocks** (SAFETY_RULES.md) — binary, non-negotiable. Death cross = no buy. These override judgment.
2. **Judgment calls** (everything else) — the model reads all signals (RSI, 21D EMA crossover, macro, F&G, momentum, catalyst timeline) and makes a reasoned decision. No scoring framework.

When the user says "add a rule", determine which type:
- If it's a risk guardrail that should NEVER be violated → SAFETY_RULES.md hard block
- If it's a heuristic/preference about when to act → memory lesson or skill guidance

### Signal Palette (available to all models)

Models should consider these signals holistically for any buy/sell/trim/hold decision:
- RSI (level + direction)
- 21D EMA crossover direction
- Price vs 21D EMA and 50D SMA
- Fear & Greed regime
- Sector momentum and rotation
- Macro news and catalysts
- Volume and institutional flow
- Catalyst proximity and timeline

### Updating Memory Files

Memory files (`memory/{model}.md`) contain structured lessons. Format:
```markdown
- [SUCCESS|MISTAKE|LESSON|RESOLVED] **Title**: Description
  - *Source: evidence and week reference*
  - *Refs: file paths to supporting data*
```

When converting a mechanical rule to judgment-based, change from `[MISTAKE]` (implying "never do X") to `[LESSON]` (implying "here's context for your judgment").

## Performance Review Analysis

Reviews live in `reviews/{model}/YYYY-WW-Week-NN-performance.md`. To analyze:

```bash
# List all reviews
ls reviews/*/

# Current standings (check latest week across all models)
for model in claude gemini openai grok; do
  echo "=== $model ===" && head -20 reviews/$model/$(ls reviews/$model/ | tail -1)
done

# Key metrics to extract: Total Value, Win Rate, Catalyst Accuracy
```

Cross-model comparison dimensions:
- Total return from $4K starting capital
- Win rate (closed trades)
- Catalyst prediction accuracy
- Average hold duration (longer = better historically)
- Pipeline uptime (days with successful research generation)

## Common Operations

### Add a new hard block
Edit `.agents/skills/trading/SAFETY_RULES.md` under "Hard Blocks" section.

### Change entry/exit philosophy
1. Update `.agents/skills/deep-research/SKILL.md` (entry)
2. Update `.agents/skills/portfolio-review/SKILL.md` (exit)
3. Update `memory/claude.md` (or relevant model) with lesson explaining the change
4. Update `.agents/skills/trading/TRADING_PROCESS.md` Trading Philosophy section

### Fix pipeline infrastructure
See `investing-log-evals` skill for debugging workflow failures, DNS issues, after-hours timing.

### Review and compare model performance
See `~/.hermes/plans/investing-log-performance-analysis.md` for the latest cross-model analysis.

## Pitfalls

- **Don't update only one layer**: If you change philosophy in memory but not in the skill files, the model may get contradictory signals. Always check which layers a change touches.
- **Claude's memory is the richest**: It has 18+ weeks of structured lessons. OpenAI/Gemini/Grok have less. Changes to trading approach should be reflected in ALL relevant model memories.
- **Hard blocks vs judgment**: The user explicitly chose judgment-based decisions over scoring frameworks. Don't re-introduce mechanical thresholds or "if X AND Y then Z" logic. Guidance is fine; binary triggers are not (except in SAFETY_RULES.md).
- **AGENTS.md is authoritative**: The repo's AGENTS.md describes the full 4-phase pipeline architecture. Read it before making structural changes.
