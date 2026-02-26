---
name: phoenix-cli
description: "Use when debugging LLM apps with Phoenix CLI: traces, errors, experiments."
license: Apache-2.0
metadata:
  author: arize-ai
  version: "1.0"
---

# Phoenix (Arize) — LLM Observability

Unified skill for Phoenix AI observability: CLI debugging, evaluators, and tracing instrumentation.

## Quick Router

| Task | Read This |
|------|-----------|
| CLI usage, fetch traces, debug failures, analyze experiments | This file (below) |
| Build evaluators (code, LLM, RAG) | `references/evals.md` + `references/evals-rules/` |
| Instrument tracing (OpenInference, spans, production) | `references/tracing.md` + `references/tracing-rules/` |

## Connection

```bash
export PHOENIX_HOST=https://app.phoenix.arize.com/s/exiao3
export PHOENIX_API_KEY=<from bloom .env>
```

Projects: `bloom_chat` (prod), `bloom_chat_dev` (dev).

## CLI Quick Start

```bash
npm install -g @arizeai/phoenix-cli
# Or: npx @arizeai/phoenix-cli
```

CLI flags override environment variables when specified.

## Debugging Workflows

### Debug a failing LLM application

```bash
# Recent traces
px traces --limit 10

# Find failed traces
px traces --limit 50 --format raw --no-progress | jq '.[] | select(.status == "ERROR")'

# Specific trace details
px trace <trace-id>

# Errors in spans
px trace <trace-id> --format raw | jq '.spans[] | select(.status_code != "OK")'
```

### Find performance issues

```bash
# Slowest traces
px traces --limit 20 --format raw --no-progress | jq 'sort_by(-.duration) | .[0:5]'

# Span durations within a trace
px trace <trace-id> --format raw | jq '.spans | sort_by(-.duration_ms) | .[0:5] | .[] | {name, duration_ms, span_kind}'
```

### Analyze LLM usage

```bash
px traces --limit 50 --format raw --no-progress | \
  jq -r '.[].spans[] | select(.span_kind == "LLM") | {model: .attributes["llm.model_name"], prompt_tokens: .attributes["llm.token_count.prompt"], completion_tokens: .attributes["llm.token_count.completion"]}'
```

### Review experiments

```bash
px datasets                                    # List datasets
px experiments --dataset my-dataset            # List experiments
px experiment <id> --format raw --no-progress | jq '.[] | select(.error != null) | {input: .input, error}'  # Failures
px experiment <id> --format raw --no-progress | jq '[.[].latency_ms] | add / length'  # Avg latency
```

## Command Reference

| Command | Purpose | Key Options |
|---------|---------|-------------|
| `px traces` | Fetch recent traces | `-n <limit>`, `--last-n-minutes`, `--since`, `--format`, `--include-annotations` |
| `px trace <id>` | Fetch specific trace | `--file`, `--format`, `--include-annotations` |
| `px datasets` | List datasets | |
| `px dataset <name>` | Fetch dataset examples | `--split`, `--version`, `--file` |
| `px experiments` | List experiments | `--dataset <name>` (required) |
| `px experiment <id>` | Fetch experiment runs | `--format`, `--file` |
| `px prompts` | List prompts | |
| `px prompt <name>` | Fetch prompt | |

## Output Formats

- `pretty` (default): Human-readable tree view
- `json`: Formatted JSON with indentation
- `raw`: Compact JSON for piping to `jq`

Use `--format raw --no-progress` when piping.

## Trace Structure

Key span kinds: `LLM`, `CHAIN`, `TOOL`, `RETRIEVER`, `EMBEDDING`, `AGENT`.

Key LLM span attributes:
- `llm.model_name`, `llm.provider`
- `llm.token_count.prompt`, `llm.token_count.completion`
- `llm.input_messages.*`, `llm.output_messages.*`
- `input.value`, `output.value`
- `exception.message`

## Reference Files

| File | Contents |
|------|----------|
| `references/evals.md` | Evaluator guide: code evals, LLM evals, RAG evals, experiments, validation, production guardrails |
| `references/evals-rules/` | 34 rule files for evaluator implementation (fundamentals, error analysis, axial coding, experiments, validation, production) |
| `references/tracing.md` | Tracing guide: setup, instrumentation, span types, projects, sessions, production deployment |
| `references/tracing-rules/` | 30 rule files for tracing implementation (setup, auto/manual instrumentation, span types, annotations, production) |
