# investing-log Repo Architecture & Cost Profile

## Pipeline Overview
The investing-log repo (bloom-invest/investing-log) runs a 4-phase automated investing pipeline via GitHub Actions across 4 AI models (Claude, OpenAI, Gemini, Grok).

```
Phase 1a: Sector Analysis      Phase 1b: Portfolio Review
  (sector_multi.yml)              (portfolio_review_multi.yml)
  Cron: 8:30 AM + 2:00 PM ET     Cron: 8:30 AM + 2:00 PM ET
         │                                 │
         ▼                                 ▼
Phase 2: Research (research_multi.yml)
  Cron fallback: 9:30 AM ET
  Gate: waits for BOTH Phase 1a AND 1b to complete today
         │
         ▼
Phase 3: Trade Execution (trade_{model}.yml)
  Dispatched by Phase 2 on success
         │
         ▼
Phase 4: Validation (validate_research.yml, validate_trades.yml)
  Triggered by workflow_run on Phases 1-3
```

## Models & Frameworks Per Phase

| Phase | Claude | OpenAI | Gemini | Grok |
|-------|--------|--------|--------|------|
| Sector | claude-code-action | Deep Agents (gpt-5.5) | Deep Agents (gemini-3.1-pro) | Deep Agents (grok-4.3) |
| Portfolio | claude-code-action | Deep Agents (gpt-5.5) | Deep Agents (gemini-3.1-pro) | Deep Agents (grok-4.3) |
| Research | claude-code-action | Deep Agents (gpt-5.5) | Deep Agents (gemini-3.1-pro) | Deep Agents (grok-4.3) |
| Trade | claude-code-action | **Codex Action (gpt-5.4)** | claude-code-action | claude-code-action |
| Validate | claude-code-action | claude-code-action | claude-code-action | claude-code-action |

Key: OpenAI trade execution uses `openai/codex-action@v1` with `--model gpt-5.4`, while research uses `run_research.py` with `gpt-5.5` via Deep Agents + langchain `init_chat_model()`.

## Context Size
- `.agents/skills/` directory: ~130KB total (screening, deep-research, trading, sector-analysis, portfolio-review, value-investing, personas)
- `memory/openai.md`: ~20KB (per-model lessons from past trades)
- System prompt in `run_research.py`: ~2KB
- Inline RESEARCH_PROMPT in workflow YAML: ~4KB
- Total context per run: ~150KB+ (~50K+ tokens)

## Cost Drivers (as of May 2026)
- OpenAI API: $XXX over recent period
- Breakdown: gpt-5.4 (majority), gpt-5.5 (small portion)
- The gpt-5.4 spend is from Codex Action (trade execution), NOT Deep Agents research
- Each model runs the full pipeline daily on weekdays

## OpenAI Prompt Caching (for cost reduction)
- Automatic for prompts >= 1024 tokens, 50% discount on cached input
- Extended retention (`prompt_cache_retention: "24h"`) available for gpt-5.4, gpt-5.5
- `prompt_cache_key` parameter influences cache server routing
- Cache hits require exact prefix match: static content FIRST, dynamic content LAST
- xAI already has caching enabled (`x-grok-conv-id` header in run_research.py); OpenAI does NOT
- In-memory cache evicts after 5-10 min inactivity; extended retention survives 24h

## Key Files
- `.github/scripts/run_research.py` — Deep Agents wrapper (OpenAI, Gemini, Grok research)
- `.github/workflows/research_multi.yml` — Multi-model research pipeline
- `.github/workflows/sector_multi.yml` — Multi-model sector analysis
- `.github/workflows/portfolio_review_multi.yml` — Multi-model portfolio review
- `.github/workflows/trade_openai.yml` — OpenAI trade execution (Codex Action)
- `.github/workflows/validate_research.yml` / `validate_trades.yml` — Validation (Claude only)
- `.agents/skills/` — All investing process documentation
- `memory/{model}.md` — Per-model structured lessons
