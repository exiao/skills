# ACE Framework & Harness-Agnostic Eval Design

Two patterns that emerged from the CPE Research Agent eval build (May 2026).

## ACE Framework: Self-Improving Playbooks

For agents that produce scored output (memos, reports, code), integrate ACE (github.com/ace-agent/ace, ICLR 2026 paper: arxiv.org/abs/2510.04618).

ACE treats the agent's context as an evolving playbook via three roles:

1. **Generator** -- produces the output, surfaces effective strategies and pitfalls
2. **Reflector** -- scores output against rubric, extracts insights (separate from Generator to prevent contamination)
3. **Curator** -- converts insights into delta updates with `helpful=N harmful=M` counters, deterministic merging, auto-pruning

Results: +8.6% on finance tasks (FiNER + XBRL), +10.6% on agent tasks (AppWorld), -91.5% latency, -83.6% token cost vs alternatives.

### Integration (3 methods)

```python
class MyDataProcessor:
    def process_task_data(self, raw_data):
        return {"id": raw_data["id"], "question": raw_data["prompt"]}
    
    def format_prompt(self, task, playbook):
        return f"{base_prompt}\n\n## EVOLVED PLAYBOOK\n{playbook}\n\n## TASK\n{task['question']}"
    
    def evaluate_response(self, task, response):
        return score_output(response) / 5.0  # Normalize to 0-1
```

### Playbook Format

```
## STRATEGIES & INSIGHTS
[str-00001] helpful=5 harmful=0 :: Always check 10-K risk factors before writing bear case
[str-00003] helpful=0 harmful=4 :: Don't rely on Serper for SEC filing search (use EDGAR)

## COMMON MISTAKES TO AVOID
[mis-00001] helpful=6 harmful=0 :: Revenue growth from acquisitions != organic growth
```

High harmful count = strategy gets pruned. Solves context collapse. ACE formalizes investing-log's manual `[SUCCESS/MISTAKE/DISPUTED]` tags with automatic de-duplication and pruning.

Modes: offline (batch), online (real-time), eval_only (frozen playbook). Finance CLI built-in.

## Harness-Agnostic Eval Design

When the agent can run on different harnesses (Pi Agent vs Claude Agent SDK), design evals to test file outputs, not harness internals.

Define a filesystem contract both harnesses must produce:

```
workspace/{ID}/
├── raw/              # Input data
├── analysis/         # Intermediate analysis
├── output.md         # Final output
├── sources.md        # Source index
├── eval/             # Quality gate results
└── tool_log.jsonl    # Command transcript (both harnesses must write this)
```

Every eval reads these files. Never import agent code or inspect session state. The one exception: tool usage tests need tool_log.jsonl, which Pi produces via extension and Claude SDK via PostToolUse hook.

### Evals same-repo vs separate-repo

Keep evals in the same repo as the agent. Three reasons:
1. Evals gate the code they test. CI triggers on same commit. Separate repos mean prompt changes can merge before evals catch regressions.
2. Evals read the agent's output files. Format changes need coordinated updates in the same commit.
3. EVAL_SCENARIOS.md IS the spec. Keeping it next to prompts makes the relationship explicit.

Only use a separate repo if multiple agents share the same eval suite.

## CI Gotchas Discovered During Implementation

- `uv sync` requires pyproject.toml (not just requirements.txt). Use `[project.optional-dependencies.eval]` + `uv sync --extra eval`.
- `evals/__init__.py` must exist AND `pythonpath = ["."]` must be in pytest config for `from evals.conftest import ...` to work.
- Workflow path filters don't include the workflow file itself. Changes to evals.yml alone won't trigger the workflow. Use `workflow_dispatch` for testing.
- `extract_section` regex parsing: `--\s*\w` matches inline `--` in content (e.g., "metric -- threshold"). Anchor to line start with `^--` and `re.MULTILINE`.

## Source Files

- CPE eval PR: github.com/cpe-research/avgo/pull/1 (34 files, ~2800 lines, all 6 layers + DST + ACE + CI)
- CPE eval implementation plan: ~/.hermes/plans/cpe-eval-implementation.md
- CPE harness proposals: ~/.hermes/plans/2026-05-11-cpe-research-harness-proposals.md
- CPE published site (self-contained for coding agents): https://cpe-eval-research.surge.sh
