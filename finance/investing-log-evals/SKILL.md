---
name: investing-log-evals
description: Run and debug LLM-agent-vs-simulator evals for the investing-log repo. Use when running DST evals, debugging trade workflow failures, analyzing NOACTION cascades, adding eval scenarios, or working on the SimulatorBackend/CLI router infrastructure. Also triggers on "investing-log tests", "DST tests", "eval framework", "why isn't GPT trading", "trade workflow broken".
---

# Investing-Log Eval Framework

Run real LLM agents against deterministic simulated market data. SimulatorBackend intercepts bloom/alpaca CLI commands and routes to BloomSimulator/AlpacaSimulator. Same seed = same market = reproducible failures.

## Architecture

```
MarketScenario.generate(seed, regime)
        ↓
  BloomSimulator (16 tools)  +  AlpacaSimulator (orders/positions)
        ↓                              ↓
  SimulatorBackend intercepts shell commands
  "bloom info AAPL" → BloomSim    "alpaca_cli.py order" → AlpacaSim
  ls/cat/jq → real shell
        ↓
  Deep Agent (real LLM, same production prompt)
        ↓
  Agent writes research/trade/sector files
        ↓
  check_output.py validates against DST invariants + scenario ground truth
```

## Quick Start

```bash
# List scenarios
python -m tests.evals.run_eval --list

# Run a full eval
GOOGLE_API_KEY=$GEMINI_API_KEY python -m tests.evals.run_eval \
  --scenario bull_clean_value \
  --provider google_genai \
  --model gemini-3-flash-preview

# Check existing output
python -m tests.evals.run_eval --scenario bull_clean_value \
  --check-only --workspace /path/to/workspace

# Run unit tests (no LLM needed)
python -m pytest tests/evals/test_backend_smoke.py -v
python -m pytest tests/ -x -q  # all 135 tests
```

## Key Files

| File | Purpose |
|------|---------|
| `tests/evals/run_eval.py` | Entry point. setup_eval + run_agent + check_eval |
| `tests/evals/simulator_backend.py` | Intercepts bloom/alpaca → simulators |
| `tests/evals/bloom_cli_router.py` | Parses 16 bloom commands → BloomSim methods |
| `tests/evals/alpaca_cli_router.py` | Parses alpaca_cli.py → AlpacaSim methods |
| `tests/evals/check_output.py` | Parses markdown, runs invariant checks |
| `tests/evals/scenarios.py` | 27 predefined eval configs |
| `tests/evals/test_backend_smoke.py` | 29 routing/integration tests |
| `tests/simulator/` | BloomSimulator, AlpacaSimulator, MarketScenario |

## 4 Pipeline Phases

| Phase | Scenarios | What agent does | What checker validates |
|-------|-----------|-----------------|----------------------|
| 1a. Sector | 4 | bloom sentiment/market → sector_snapshot.json | JSON schema, regime, favor/avoid overlap |
| 1b. Portfolio Review | 6 | bloom info/technicals per holding → PORTFOLIO_REVIEW.md | All holdings covered, verdicts present |
| 2. Research | 11 | Screen universe → MARKET_RESEARCH.md + BUY reports | Allocations 100%, thesis, chart, sizing |
| 3. Trade | 6 | Read research + review → execute orders | Post-trade S1/S2/S4, cash non-negative |

## Model Compatibility

- **gemini-3-flash-preview**: Works. Cheap (~$0.05-0.15/run).
- **gemini-2.5-pro**: Works. More expensive.
- **gemini-2.5-flash**: BROKEN with deepagents. Returns empty content.
- **gpt-4o-mini**: Works if langchain-openai installed.
- Requires `GOOGLE_API_KEY` (not GEMINI_API_KEY) for langchain google_genai provider.

## Pitfalls

- **Allocation parser**: Takes FIRST percentage per table row (weight column), not subsequent ones (conviction). Handles `**bold**` ticker names.
- **Missing output = violation**: If agent exhausts run_limit without writing files, check_output flags OUTPUT violation.
- **venv confusion**: The repo has investing-arena/.venv. Use `~/projects/investing-log/investing-arena/.venv/bin/python` explicitly.
- **deepagents not installed locally**: Only available in CI or investing-arena venv. Don't try to import from system python.

## Debugging Trade Workflow Failures

When non-Claude models produce endless NOACTION trades:

1. Check `gh run list --workflow="Execute Trade (OpenAI)" --limit 10` for failure pattern
2. Check `gh run view <id>` for which step fails
3. Common causes:
   - **codex-action permission error**: "Actor 'github-actions[bot]' must have write access" → Switch to Deep Agents pattern (trade_multi.yml)
   - **DNS resolution failures**: Sandbox can't resolve paper-api.alpaca.markets → Use LocalShellBackend instead of sandboxed action
   - **No workflow_run trigger**: Trade workflow only has workflow_dispatch → Add workflow_run from research workflow
   - **After-hours execution**: Cron fires after market close → Fix cron to 15:30 UTC (10:30 AM EST)

## References

- `references/DST_PLAN.md` in investing-log repo: original DST design doc
- `.agents/skills/trading/TRADING_PROCESS.md`: production trade prompt source
- `.agents/skills/deep-research/RESEARCH_PROCESS.md`: production research prompt source
- `.github/scripts/run_research.py`: Deep Agents pattern reference
- `.github/scripts/run_trade.py`: Trade-specific Deep Agents wrapper
