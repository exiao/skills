---
name: ci-evals-llm-agents
description: "Build and design eval systems for LLM agent systems. Use when: adding evals to repos with LLM agents, selecting benchmarks for a new agent, creating SimulatorBackend patterns, setting up multi-model CI matrices, designing eval rubrics, researching which benchmarks to use, or debugging flaky agent eval output. Triggers: CI evals, agent evals, simulator backend, eval matrix, eval CI, benchmark selection, eval rubric, eval harness, eval strategy."
---

# Evals for LLM Agent Systems

Design, select, build, and run evaluations for LLM agents. Covers benchmark selection (which evals to use), eval category design, grader architecture, and CI implementation (how to run them).

## When to Use

- **Benchmark selection:** Researching which benchmarks matter for a new agent domain
- **Eval design:** Structuring eval categories, graders, and rubrics for an agent
- Adding evals to a repo that uses LLM agents with tool-use (CLI tools, APIs)
- Building SimulatorBackend patterns (intercept real tool calls, return deterministic data)
- Setting up CI workflows that run LLM evals with multi-model matrices
- Debugging flaky agent eval output (stdout pollution, JSON parsing issues)

## Benchmark Selection Strategy

When evaluating a new agent, layer benchmarks by what they test:

1. **Domain-specific accuracy** - Find the benchmark closest to your exact task (e.g., Vals.ai Finance Agent for SEC filing research, SWE-bench for coding agents)
2. **Citation/source quality** - If the agent produces sourced output, find a benchmark that grades citation traceability (e.g., FinanceBench for financial QA with mandatory filing citations)
3. **Hard reasoning ceiling** - Pick the hardest domain benchmark as a stress test (e.g., Mercor APEX IB where even GPT-5.5 scores 41%)
4. **Retrieval quality** - Benchmark the search/RAG pipeline separately (e.g., OBLIQ-Bench for latent pattern retrieval)
5. **Agent endurance** - Apply METR time horizon methodology to your own tasks: time human experts, measure agent success rate at each duration tier
6. **Custom output quality** - Build your own rubric eval for the specific output format (memos, reports, code). No general benchmark tests "is this a good X?"

See `references/benchmark-selection-research.md` for a worked example (equity research agent benchmarks).

## Eval Category Design (from Bloom's proven system)

Structure eval scenarios into categories, each testing a different failure mode. Bloom uses 17 categories across 59 scenarios:

| Category Type | Example Categories | Threshold |
|--------------|-------------------|-----------|
| Core quality | Task Completion, Memo Quality | >80% |
| Accuracy | Hallucination, Citation Accuracy | >90% |
| Process | Trajectory, Research Path | >80% |
| Safety | Guardrails, Jailbreak, Regulatory | 100% |
| UX | Tone, Response Length, Format | >80% |
| Edge cases | Adversarial inputs, unusual data | >60% |

**Key principle:** Adversarial/safety categories must have 100% pass rate. Any single failure = guardrail gap.

**Bloom architecture to copy:**
- Plain markdown (EVAL_SCENARIOS.md) as single source of truth
- Claude Code reads markdown, runs harness, judges pass/fail, posts PR comments
- eval_runner.py runs all scenarios concurrently (semaphore=5), judging separate from running
- CI-triggered on prompt changes; failures auto-open GitHub issues

## Three Grader Types (Use All Three)

Per Anthropic's agent eval guide (anthropic.com/engineering/demystifying-evals-for-ai-agents):

1. **Code-based** (fast, cheap, objective): Format checks, URL resolution, tool call verification, transcript metrics
2. **Model-based** (flexible, nuanced): Rubric scoring, reference comparison, natural language assertions, multi-judge consensus (3 LLMs, majority vote)
3. **Human** (gold standard, sparingly): SME calibration set (10 items), spot-check 10-20% monthly, inter-annotator agreement baseline

## Capability vs. Regression Evals

- **Capability evals** start at LOW pass rate. That's the point. Hill to climb.
- **Regression evals** must stay ~100%. Any drop = investigate immediately.
- **Graduation:** Capability eval hits >95% consistently -> promote to regression, add harder tasks.

## Non-Determinism Rule

Never evaluate on a single run. 3-5 trials minimum per task. Report the distribution.

## DST (Deterministic Simulation Testing)

Property-based testing + fault injection for agents. Three levels:

1. **Property-based invariants** (Level 1): Use `hypothesis` to fuzz agent inputs/outputs against hard rules. 500+ examples per invariant, same seed = reproducible failures. Start here.
2. **Fault injection simulators** (Level 2): Deterministic simulators for each third-party service (search, scraping, APIs). Configure failure rates (timeouts, partial results, 403s). Test graceful degradation.
3. **Multi-agent / stale data** (Level 3): Event queue simulation for concurrent agents or long-running tasks where data changes mid-execution.

See `references/dst-and-memory-patterns.md` for implementation patterns, code examples, and invariant mapping tables.

## Agent Memory Feedback Loop

For agents that improve over time, implement: Research -> Output -> Outcome Review -> Memory -> Research. Key patterns:
- Structured lessons: `[SUCCESS/MISTAKE/DISPUTED] Rule + Source + Refs`
- Lesson lifecycle: confirmed -> or contradicted -> `[DISPUTED]` -> 3+ contradictions -> removed
- Write isolation with cross-pollination (each agent writes its own file, reads all)
- 30-lesson cap + prompt injection prevention via `<memory>` delimiters

See `references/dst-and-memory-patterns.md` for full architecture.

## ACE Framework: Self-Improving Playbooks

For agents that produce scored output, integrate ACE (github.com/ace-agent/ace, ICLR 2026). Three roles: Generator (produces output), Reflector (scores against rubric), Curator (evolves playbook with helpful/harmful counters). Only 3 methods to implement. +8.6% on finance tasks. Solves context collapse and brevity bias. See `references/ace-and-harness-agnostic.md`.

## Harness-Agnostic Eval Design

When the agent can run on different harnesses, design evals to test file outputs, not harness internals. Define a filesystem contract (workspace/{ID}/ with raw/, analysis/, output, sources, tool_log.jsonl). Every eval reads these files. Never import agent code or inspect session state. See `references/ace-and-harness-agnostic.md`.

---

## CI Implementation

### Architecture Pattern

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

### SimulatorBackend Pattern

Subclass or wrap the agent shell backend. Intercept domain-specific commands, route to deterministic simulators. Let everything else hit the real filesystem.

```python
class SimulatorBackend:
    def execute(self, command: str) -> dict:
        if self._is_domain_command(command):
            return self.simulator.handle(command)
        return self._run_real_shell(command)
```

### Multi-Provider Support

Use `langchain.chat_models.init_chat_model("provider:model")` for deepagents-based evals. For Claude, use the Anthropic SDK directly with tool_use (replicates claude-code-action including hooks).

### JSON Output for CI (Critical)

LLM agent libraries (deepagents, langchain) often pollute stdout despite sys.stdout redirects. Some write to fd 1 directly.

Solution: Use --json-file instead of --json (stdout).

```yaml
# GOOD: write JSON to file, read from file
python -m evals.run_eval --json-file /tmp/result.json > /tmp/stdout.txt 2>/tmp/stderr.txt
OUTPUT=$(cat /tmp/result.json)
```

### Claude-Specific Eval (claude-code-action replication)

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

### Scenario Design

Each scenario = frozen state (seed + regime + fault level). Same seed = same data = reproducible. Good CI smoke set: 1 happy-path per phase. Full matrix for nightly.

### Cost: Run production models, not cheap proxies

Flash/mini: $0.01-0.03/scenario. Pro: $0.05-0.15. Opus: $0.15-0.30.

## Pitfalls

1. Scenario name mismatches: CI matrix names must exactly match scenarios.py. Typos = cryptic ValueError.
2. workflow_run name matching: Exact string match against name: field. One char off = never triggers.
3. claude-code-action infra failures: "Claude Code native binary not found" = runner issue, not code. Re-run.
4. Agent timeout vs job timeout: Set both. Agent (300s) < job (10min).
5. Dedup guards: cron + workflow_run needs date-based dedup to prevent double execution.
6. Gate logic: Chained workflows need listWorkflowRunsForRepo checks for prerequisites.
7. gh pr edit fails on repos with classic projects. Use gh api PATCH instead.
8. **`uv sync` needs pyproject.toml:** CI with `uv sync` fails with "No pyproject.toml found" if the repo only has requirements.txt. Always add pyproject.toml with `[project.optional-dependencies.eval]` and use `uv sync --extra eval`.
9. **Module imports in evals:** Tests using `from evals.conftest import ...` fail with `ModuleNotFoundError` unless (a) `evals/__init__.py` exists and (b) `pythonpath = ["."]` is in `[tool.pytest.ini_options]`.
10. **Workflow path filters exclude workflow file itself:** Changing only `.github/workflows/evals.yml` won't trigger if evals.yml isn't in its own `paths:` filter. Add `pyproject.toml` and `.github/workflows/**` to paths, or use `workflow_dispatch` to test.
11. **Section regex vs inline markers:** When parsing agent output with section markers like `-- SECTION --`, regex `--\s*\w` matches inline `--` in content (e.g., "metric -- threshold"). Fix: anchor to line start with `^--` and `re.MULTILINE`.
12. **Hypothesis deterministic seeding:** `--hypothesis-seed=0` in CI ensures reproducible failures, but the same seed reproduces the same falsifying example. When fixing a test, verify with the exact seed that failed.
13. **CI jobs that need agent output:** Eval jobs like "memo quality scoring" require a workspace with agent output that doesn't exist in fresh CI. Use `continue-on-error: true` and catch the missing-workspace case gracefully in the runner script. Don't block PRs on evals that can't run yet.
14. **Alternate GitHub account repos:** When the eval repo uses a different GitHub account (SSH alias + fine-grained PAT), `gh pr checks` may 403 due to missing `checks:read` on the PAT. Fall back to `gh run list --branch $BRANCH` for CI status. See babysit-pr `references/alternate-github-accounts.md`.
15. **AIAgent `session_db` not passed:** When embedding AIAgent in a pipeline script (not CLI/gateway), sessions only write to JSON files unless you pass `session_db=SessionDB()`. Without it, `hermes dashboard` shows 0 sessions and there's no FTS5 search. See `references/hermes-session-format.md`.

## Reference Implementations

- Bloom llm_tests/: eval_harness.py, eval_runner.py, EVAL_SCENARIOS.md, .github/workflows/claude-evals.yml
- Bloom-Invest/investing-log: tests/evals/run_eval.py, tests/evals/claude_eval.py, tests/evals/simulator_backend.py
- CPE benchmark analysis: references/benchmark-selection-research.md
- DST patterns + memory feedback loops: references/dst-and-memory-patterns.md
- ACE self-improving playbooks + harness-agnostic eval design: references/ace-and-harness-agnostic.md
- Hermes session JSON schema + programmatic AIAgent usage: references/hermes-session-format.md
- Research agent quality patterns (bear challenge, embedded expectations, citation errors): references/research-agent-quality-patterns.md