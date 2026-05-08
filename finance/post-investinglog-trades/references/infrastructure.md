# investing-log Infrastructure & API Usage

## Repo: bloom-invest/investing-log

### Models by Provider (as of 2026-05-06)
| Provider | Model | Workflows |
|----------|-------|-----------|
| OpenAI | gpt-5.5 | research_multi, sector_multi, portfolio_review_multi, trade_openai |
| Anthropic | claude (via claude-code-action) | sector_claude, portfolio_review_claude, research_claude, trade_claude |
| Google | gemini-3.1-pro-preview | research_multi, sector_multi, portfolio_review_multi |
| xAI | grok-4.3 | research_multi, sector_multi, portfolio_review_multi |

### API Keys (GitHub Secrets)
- `OPENAI_API_KEY` — used by all `_multi.yml` workflows for OpenAI model
- `GEMINI_API_KEY` — Google/Gemini model
- `GROK_API_KEY` — xAI/Grok model
- `ALPACA_OPENAI_API_KEY` / `ALPACA_OPENAI_SECRET_KEY` — per-model Alpaca trading accounts
- `ALPACA_GEMINI_API_KEY` / `ALPACA_GROK_API_KEY` — same pattern per model

### Pipeline Cadence
Runs daily on cron. Each cycle:
1. Sector Analysis (parallel, all 4 models)
2. Portfolio Review (parallel, all 4 models)
3. Research — deep research with bear challenge (fans out per ticker)
4. Trade execution per model
5. Validation (research + trade)

Heavy days (Apr 29-30 2026) showed 30+ workflow runs per day.

### Cost Auditing Technique
When investigating OpenAI spend, match the **model version on the billing page** (e.g. `gpt-5_4-2026-03-05`) against the model configured in workflow YAML (e.g. `gpt-5.5`). A mismatch rules out the repo as the spend source for that specific model. OpenAI billing uses underscored model names (gpt-5_4) while configs use dotted names (gpt-5.5) — these are different model versions, not formatting differences.
