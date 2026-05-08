---
name: ci-evals-llm-agents
description: "Build CI eval pipelines for LLM agent systems. Use when adding evals to repos with LLM agents, creating SimulatorBackend patterns, setting up multi-model CI matrices, or debugging flaky agent eval output. Triggers: CI evals, agent evals, simulator backend, eval matrix, eval CI."
---

# CI Evals for LLM Agent Pipelines

Run deterministic evaluations of LLM agents in CI. Tests agents against simulated tool backends, checks invariants, catches prompt regressions and hallucination patterns before merge.

## When to Use

- Adding evals to a repo that uses LLM agents with tool-use (CLI tools, APIs)
- Building SimulatorBackend patterns (intercept real tool calls, return deterministic data)
- Setting up CI workflows that run LLM evals with multi-model matrices
- Debugging flaky agent eval output (stdout pollution, JSON parsing issues)

## Architecture Pattern

```
CI Workflow (eval_ci.yml)
  Matrix: N scenarios x M models
  Each cell:
    1. Setup workspace (symlink skills, seed simulators)
    2. Run agent with SimulatorBackend intercepting tool calls
    3. Check output against invariant rules
    4. Upload workspace artifact on failure
  Graceful skip if API keys missing (forks)
```

## SimulatorBackend Pattern

Subclass or wrap the agent shell backend. Intercept domain-specific commands, route to deterministic simulators. Let everything else hit the real filesystem.

```python
class SimulatorBackend:
    def execute(self, command: str) -> dict:
        if self._is_domain_command(command):
            return self.simulator.handle(command)
        return self._run_real_shell(command)
```

## Multi-Provider Support

Use `langchain.chat_models.init_chat_model("provider:model")` for deepagents-based evals. For Claude, use the Anthropic SDK directly with tool_use (replicates claude-code-action including hooks).

## JSON Output for CI (Critical)

LLM agent libraries (deepagents, langchain) often pollute stdout despite sys.stdout redirects. Some write to fd 1 directly.

Solution: Use --json-file instead of --json (stdout).

```yaml
# GOOD: write JSON to file, read from file
python -m evals.run_eval --json-file /tmp/result.json > /tmp/stdout.txt 2>/tmp/stderr.txt
OUTPUT=$(cat /tmp/result.json)
```

## Claude-Specific Eval (claude-code-action replication)

Claude uses a different tool loop. Replicate with:
1. Anthropic SDK messages.create() with tools=[Bash, Read, Write, Edit, Glob, Grep]
2. PreToolUse hooks (shell scripts) run before Write/Edit calls
3. PostToolUse hooks run after Bash calls
4. Stop hook runs before agent finishes (can re-activate agent)

```python
def run_hook(hook_script, tool_name, tool_input, workspace):
    result = subprocess.run(
        ["bash", hook_script],
        input=json.dumps({"tool_name": tool_name, "tool_input": tool_input}),
        capture_output=True, text=True, cwd=workspace, timeout=10,
    )
    return result.returncode == 0  # 0=allow, non-zero=block
```

## Scenario Design

Each scenario = frozen state (seed + regime + fault level). Same seed = same data = reproducible. Good CI smoke set: 1 happy-path per phase. Full matrix for nightly.

## Cost: Run production models, not cheap proxies

Flash/mini: $0.01-0.03/scenario. Pro: $0.05-0.15. Opus: $0.15-0.30.

## Pitfalls

1. Scenario name mismatches: CI matrix names must exactly match scenarios.py. Typos = cryptic ValueError.
2. workflow_run name matching: Exact string match against name: field. One char off = never triggers.
3. claude-code-action infra failures: "Claude Code native binary not found" = runner issue, not code. Re-run.
4. Agent timeout vs job timeout: Set both. Agent (300s) < job (10min).
5. Dedup guards: cron + workflow_run needs date-based dedup to prevent double execution.
6. Gate logic: Chained workflows need listWorkflowRunsForRepo checks for prerequisites.
7. gh pr edit fails on repos with classic projects. Use gh api PATCH instead.

## Reference Implementation

See $INVESTING_LOG_REPO: tests/evals/run_eval.py, tests/evals/claude_eval.py, tests/evals/simulator_backend.py, .github/workflows/eval_ci.yml