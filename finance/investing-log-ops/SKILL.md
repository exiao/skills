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

## Inspecting Pipeline Health

When asked "is the pipeline working?" or "check the logs", follow this diagnostic sequence:

### 1. Overview of recent runs (main branch only)
```bash
cd ~/projects/investing-log
gh run list --limit 20 --json name,status,conclusion,createdAt,headBranch,databaseId \
  --jq '.[] | select(.headBranch=="main") | "\(.createdAt) | \(.status)/\(.conclusion) | \(.name)"'
```

### 2. Identify failures
```bash
gh run list --limit 40 --json name,status,conclusion,createdAt,headBranch,databaseId \
  --jq '.[] | select(.headBranch=="main" and .conclusion=="failure") | "\(.databaseId) | \(.createdAt) | \(.name)"'
```

### 3. Drill into a failed run
```bash
RUN_ID=<id>
# Which jobs failed?
gh run view $RUN_ID --json jobs --jq '.jobs[] | "\(.name) | \(.status)/\(.conclusion)"'

# Which step failed?
gh api repos/$INVESTING_LOG_REPO/actions/runs/$RUN_ID/jobs \
  --jq '.jobs[] | select(.conclusion=="failure") | .steps[] | select(.conclusion=="failure") | {name, conclusion}'

# Get the failed job's logs (gh run view --log-failed often returns empty for matrix jobs)
JOB_ID=$(gh api repos/$INVESTING_LOG_REPO/actions/runs/$RUN_ID/jobs \
  --jq '.jobs[] | select(.conclusion=="failure") | .id')
gh api repos/$INVESTING_LOG_REPO/actions/jobs/$JOB_ID/logs 2>&1 | tail -40
```

### 4. Check for in-progress / stuck runs
```bash
gh run list --limit 10 --json name,status,conclusion,createdAt,databaseId,headBranch \
  --jq '.[] | select(.headBranch=="main" and (.status=="in_progress" or .status=="pending" or .status=="queued")) | "\(.databaseId) | \(.status) | \(.name)"'
```

### Known Failure Modes

**Parallel push race condition (commit/push step):** When multiple matrix jobs (e.g., OpenAI, Gemini, Grok) try to commit and push to main simultaneously, later jobs fail with `error: cannot rebase: You have unstaged changes.` The 3-attempt retry can't recover because pull-rebase leaves unstaged changes from the conflict. Non-critical when other models succeed for the same pipeline phase.

**`gh run view --log-failed` returns empty for matrix jobs:** Use the job-level API endpoint (`gh api .../jobs/$JOB_ID/logs`) instead for reliable log retrieval.

## Reference Materials

- `references/augmented-investor-playbook.md` — Distilled notes from "The Augmented Investor Playbook" (David Plawn / Portrait Analytics). Contains the Intelligence Mosaic framework, 5-part prompt blueprint, management credibility tracking, and gap analysis against the investing-log pipeline. Load when implementing research pipeline improvements.

## Incorporating External Research

When the user shares research, articles, or tweets about investing approaches, evaluate each recommendation against what already exists before making changes:

1. **Audit existing coverage first.** Read the relevant skill files before proposing additions. Most "new ideas" are already covered (e.g., bear case reviews, scenario analysis with DO NOTHING baseline, limit order discipline).
2. **Distinguish human edge from automation edge.** Social/cultural signals (Google Trends, TikTok, family conversations) are human observations, not things the GitHub Actions pipeline can automate. Bridge this with input mechanisms (e.g., `watchlist.md` for manual ticker injection) rather than trying to make agents browse social media.
3. **Map each tip to the file that owns that concern.** Don't dump everything into one file. Calmar ratio belongs in TRADING_PROCESS.md (scenario analysis). Data integrity checks belong in SAFETY_RULES.md. Benchmarks belong in RESEARCH_REFERENCE.md.
4. **Say what's already covered.** The user values honesty over action. If 4 out of 5 suggestions are redundant, say so and only implement the 1-2 that add real value.
5. **Keep changes minimal.** A one-line addition to an existing table or a 4-line new section is better than restructuring the file. The agents read these files every run; bloat = token cost.

### Files by Concern

| Concern | File |
|---------|------|
| Catalyst types | `.agents/skills/value-investing/SKILL.md` |
| Screening universe + filters | `.agents/skills/screening/PROCESS.md` |
| Deep analysis process | `.agents/skills/deep-research/RESEARCH_PROCESS.md` |
| Metric definitions + benchmarks | `.agents/skills/deep-research/RESEARCH_REFERENCE.md` |
| Trade execution + scenario analysis | `.agents/skills/trading/TRADING_PROCESS.md` |
| Hard safety blocks + data integrity | `.agents/skills/trading/SAFETY_RULES.md` |
| Adversarial trade review | `.agents/skills/trading/DEVILS_ADVOCATE.md` |
| Holdings health check | `.agents/skills/portfolio-review/PORTFOLIO_REVIEW_PROCESS.md` |
| Per-model lessons | `memory/{model}.md` |

## Pitfalls

- **Don't update only one layer**: If you change philosophy in memory but not in the skill files, the model may get contradictory signals. Always check which layers a change touches.
- **Claude's memory is the richest**: It has 18+ weeks of structured lessons. OpenAI/Gemini/Grok have less. Changes to trading approach should be reflected in ALL relevant model memories.
- **Hard blocks vs judgment**: The user explicitly chose judgment-based decisions over scoring frameworks. Don't re-introduce mechanical thresholds or "if X AND Y then Z" logic. Guidance is fine; binary triggers are not (except in SAFETY_RULES.md).
- **AGENTS.md is authoritative**: The repo's AGENTS.md describes the full 4-phase pipeline architecture. Read it before making structural changes.
