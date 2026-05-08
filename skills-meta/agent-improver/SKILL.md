---
name: agent-improver
description: >
  Autonomously improve AI agent skills through eval-driven mutation loops.
  Use when asked to "improve a skill", "optimize agent performance", "evolve a skill",
  "run an improvement loop", "make this skill better", "optimize this prompt",
  "self-improve", "mutation loop", "eval-driven optimization", or "GEPA-style evolution".
  Also use when diagnosing why a skill underperforms or when building eval datasets
  from real session history. Works against any agent type: ADK, LangChain, CrewAI,
  AutoGen, custom Python, HTTP API, or CLI agents.
---

# Agent Improver

Eval-driven mutation loop for improving agent skills. Core loop:

**baseline → diagnose → mutate → constraint check → re-eval → keep/discard → repeat**

Before starting, read `references/mutation-playbook.md` for mutation recipes and
`references/eval-quick-reference.md` for scoring rubrics and eval design.

---

## Step 0: Detect Agent Type

Auto-detect the agent framework before anything else. Check the project root for:

| Signal | Framework | Eval Runner |
|--------|-----------|-------------|
| `agent.yaml` + `__init__.py` with ADK imports | **ADK** | `agents-cli eval run` |
| `langchain` in requirements/imports | **LangChain** | Custom harness (invoke chain, capture output) |
| `crewai` in requirements/imports | **CrewAI** | `crewai run` + output capture |
| `autogen` in requirements/imports | **AutoGen** | Custom harness (run conversation, capture) |
| `Dockerfile` or `docker-compose.yml` with API | **HTTP API** | `curl`/`httpie` against endpoint |
| Executable script with `argparse`/`click` | **CLI agent** | Direct invocation + stdout capture |
| Python files with LLM calls, no framework | **Custom Python** | Direct invocation |

If ambiguous, ask. Store the detected type for all subsequent steps.

**For non-ADK agents**, create a lightweight eval harness:

```bash
mkdir -p eval_harness/
```

The harness needs three files:
- `test_cases.json` — inputs and expected outputs
- `run_eval.sh` — invokes the agent, captures full trace + output
- `score.py` — applies multi-dimensional scoring (see Step 1)

---

## Step 1: Establish Baseline

Run the full eval suite and record **multi-dimensional fitness scores**.

### Multi-Dimensional Scoring (3 axes + penalty)

Every eval case gets scored on three weighted dimensions:

| Dimension | Weight | What It Measures |
|-----------|--------|-----------------|
| **Correctness** | 0.50 | Did the agent produce the right answer/output? |
| **Procedure Following** | 0.30 | Did it follow the skill's prescribed workflow, use the right tools, respect constraints? |
| **Conciseness** | 0.20 | Was the response appropriately sized? No unnecessary verbosity, no filler? |

Each dimension: 0.0 to 1.0. Final score formula:

```
raw = (correctness * 0.5) + (procedure * 0.3) + (conciseness * 0.2)
length_penalty = max(0, (actual_tokens - target_tokens) / target_tokens) * 0.1
fitness = max(0, raw - length_penalty)
```

Set `target_tokens` based on the task type (short answer: 200, structured output: 500, long-form: 1500).

### Recording Baseline

Save baseline results to `eval_results/baseline.json`:

```json
{
  "timestamp": "2026-05-04T15:00:00Z",
  "skill_version": "baseline",
  "skill_size_bytes": 4200,
  "overall_fitness": 0.72,
  "dimension_means": {
    "correctness": 0.80,
    "procedure_following": 0.65,
    "conciseness": 0.70
  },
  "per_case": [
    {
      "case_id": "case_1",
      "split": "train",
      "correctness": 0.9,
      "procedure_following": 0.7,
      "conciseness": 0.6,
      "fitness": 0.77,
      "trace_file": "traces/baseline_case_1.txt"
    }
  ]
}
```

**Save full execution traces.** Every agent run must capture the complete transcript
(tool calls, intermediate reasoning, errors, retries) to `traces/`. This is critical
for Step 2. Don't discard traces after scoring.

---

## Step 2: Diagnose (Trace Analysis)

Read the full execution traces, not just final outputs. This is the key insight from
GEPA: understanding WHY something failed enables targeted mutations instead of random ones.

### Trace Analysis Protocol

For each failing or low-scoring case:

1. **Read the full trace** from `traces/`. Look at every tool call, every reasoning step.
2. **Identify the failure point.** Where did the agent go wrong? Categories:
   - **Wrong tool selection** — picked the wrong tool or used tools in wrong order
   - **Missing context** — skill didn't provide info the agent needed
   - **Misinterpretation** — agent understood the skill but applied it incorrectly
   - **Overcompliance** — followed instructions too literally, missed the intent
   - **Runaway elaboration** — kept going when it should have stopped
   - **Dead-end exploration** — tried approaches the skill should have warned against
3. **Find patterns across cases.** If 3/5 failures show "wrong tool selection", that's
   a systemic issue in the skill's tool guidance section.
4. **Write a diagnosis document** to `eval_results/diagnosis.md`:

```markdown
## Diagnosis — Iteration N

### Failure Patterns
1. [Pattern]: seen in cases X, Y, Z. Root cause: [specific skill section/gap]
2. [Pattern]: seen in cases A, B. Root cause: [specific skill section/gap]

### Trace Evidence
- Case X: Agent called `web_search` at step 3 when skill says to use `terminal`.
  Trace line 47: "I'll search for this online" — skill's tool priority section unclear.
- Case Y: Agent produced 800 tokens for a 200-token task. No length guidance in skill.

### Recommended Mutations (ranked by expected impact)
1. [Highest impact]: Add explicit tool priority list to section 2
2. [Medium impact]: Add length targets per output type
3. [Lower impact]: Reword the "when to use" trigger description
```

The diagnosis document drives Step 3. Never skip it. Never mutate without reading traces first.

---

## Step 3: Mutate

Two modes available. Default is **single mutation** (cheaper). Use **population mode**
when the diagnosis reveals multiple independent improvement axes.

### Single Mutation Mode (default)

Pick the highest-impact mutation from the diagnosis. Apply ONE change to the skill.
Save the mutated skill to `candidates/mutation_1/SKILL.md`.

Rules:
- One logical change per mutation. Don't stack unrelated fixes.
- The mutation must directly address a diagnosed failure pattern.
- Preserve everything that's working. Don't rewrite sections that score well.

### Population Mode (optional, use `--population` or when asked)

Generate **3 candidate mutations**, each addressing a different diagnosed issue:

```
candidates/
├── mutation_1/SKILL.md  — addresses failure pattern #1
├── mutation_2/SKILL.md  — addresses failure pattern #2
└── mutation_3/SKILL.md  — addresses failure pattern #3
```

All 3 go through Steps 4-5. The winner (highest val score) advances.

Population mode costs ~3x tokens but converges faster when multiple independent
issues exist. Use single mode when there's one clear dominant failure.

### Mutation Recipes

See `references/mutation-playbook.md` for the full catalog. Common ones:

- **Prompt rewording** — clarify ambiguous instructions
- **Example injection** — add input/output examples for failing cases
- **Tool description tweaks** — improve tool selection guidance
- **Workflow reordering** — change step sequence
- **Constraint addition** — add guardrails the agent was missing
- **Reference file restructuring** — move content between SKILL.md and references/

---

## Step 4: Constraint Check

Every mutation must pass ALL constraints before evaluation. Reject immediately if any fail.

### Mandatory Constraints

| Constraint | Rule | Check |
|-----------|------|-------|
| **Size limit** | SKILL.md ≤ 15KB | `wc -c SKILL.md` |
| **Growth cap** | ≤ 20% larger than baseline per iteration | `new_size / baseline_size ≤ 1.20` |
| **Frontmatter** | Valid YAML with `name` and `description` fields | Parse YAML between `---` markers |
| **Non-empty body** | Skill body has substantive content after frontmatter | `len(body.strip()) > 100` |
| **Test suite** | All existing tests pass (if test suite exists) | Run test suite, require 100% pass |

### Constraint Check Script

```python
import yaml, os

def check_constraints(skill_path, baseline_size):
    content = open(skill_path).read()
    size = os.path.getsize(skill_path)

    # Size limit
    if size > 15_360:
        return False, f"Size {size}B exceeds 15KB limit"

    # Growth cap
    if baseline_size and size > baseline_size * 1.20:
        return False, f"Growth {size/baseline_size:.0%} exceeds 20% cap"

    # Frontmatter integrity
    if not content.startswith('---'):
        return False, "Missing YAML frontmatter"
    parts = content.split('---', 2)
    if len(parts) < 3:
        return False, "Malformed frontmatter"
    try:
        fm = yaml.safe_load(parts[1])
        assert 'name' in fm and 'description' in fm
    except:
        return False, "Frontmatter missing name or description"

    # Non-empty body
    if len(parts[2].strip()) < 100:
        return False, "Skill body too short"

    return True, "All constraints pass"
```

If a mutation fails constraints, discard it. In population mode, only surviving
candidates proceed to re-eval.

---

## Step 5: Re-eval (with Train/Val/Holdout Splits)

### Dataset Splits

Split your eval cases **once at the start** and keep them fixed across all iterations:

| Split | Proportion | Purpose |
|-------|-----------|---------|
| **Train** | 50% | Optimize against these. The mutation targets train failures. |
| **Val** | 25% | Select the best mutation. Compare candidates on val, not train. |
| **Holdout** | 25% | Final report only. Never look at holdout during the loop. |

Assign splits randomly at Step 1 and record them in `eval_results/splits.json`.
Minimum cases per split: train ≥ 3, val ≥ 2, holdout ≥ 2. If you have fewer than
8 total cases, use 60/40 train/val with no holdout.

### Re-eval Process

1. Run the mutated skill against **train + val** cases (not holdout).
2. Score each case using multi-dimensional scoring from Step 1.
3. Record results to `eval_results/iteration_N.json`.
4. In population mode: rank candidates by **val fitness mean**. The winner is the
   candidate with the highest val score, breaking ties by train score.

---

## Step 6: Keep or Discard

Compare the best mutation's **val fitness** against the current best:

```
improvement = mutation_val_fitness - current_val_fitness
```

**Keep** if improvement > 0.01 (1% threshold to avoid noise).
**Discard** if improvement ≤ 0.01. Revert to previous best.

On keep:
- Update `current_best/SKILL.md` with the winning mutation
- Log the iteration to `eval_results/history.json`
- Update baseline_size for growth cap calculations

On discard:
- Log why (which dimension regressed, by how much)
- The diagnosis from Step 2 still stands; try a different mutation approach next round

---

## Step 7: Repeat

Continue the loop until any stopping condition:

| Condition | Threshold |
|-----------|-----------|
| **Max iterations** | 5 (default, override with `--max-iterations`) |
| **Convergence** | < 0.02 improvement over last 2 consecutive iterations |
| **Perfect score** | Val fitness ≥ 0.95 |
| **All mutations rejected** | 2 consecutive discards |

### Final Report

When the loop terminates, run holdout evaluation and produce `eval_results/final_report.md`:

```markdown
## Improvement Summary

| Metric | Baseline | Final | Delta |
|--------|----------|-------|-------|
| Overall Fitness | 0.72 | 0.86 | +0.14 |
| Correctness | 0.80 | 0.92 | +0.12 |
| Procedure Following | 0.65 | 0.82 | +0.17 |
| Conciseness | 0.70 | 0.78 | +0.08 |

### Holdout Results (unseen during optimization)
Overall Fitness: 0.84 (vs 0.86 on val — no overfitting detected)

### Iterations
1. [keep] Added tool priority list → +0.08 val fitness
2. [keep] Added output length targets → +0.04 val fitness
3. [discard] Reworded trigger description → -0.01 val fitness
4. [keep] Added error recovery example → +0.03 val fitness

### Changes Applied
- [diff or summary of all kept mutations]
```

---

## Session Mining for Eval Data

Build eval datasets from real usage instead of (or in addition to) hand-written cases.

### Source Directories

- `~/.hermes/sessions/` — full session transcripts (richest source)
- `~/.hermes/episodes/` — daily episode summaries (faster to scan)

### Two-Stage Filtering

**Stage 1: Keyword Heuristic (fast, cheap)**

Scan session files for the skill name, related keywords, and trigger phrases from
the skill's description. Extract candidate snippets (the user prompt + agent response).

```bash
grep -rl "skill-name\|keyword1\|keyword2" ~/.hermes/sessions/ | head -20
```

**Stage 2: LLM Relevance Judge (accurate, costs tokens)**

For each candidate from Stage 1, ask an LLM:

> "Is this interaction an example of someone using (or trying to use) the [skill-name]
> skill? Rate relevance 0-10. If ≥ 7, extract: (1) the user's input prompt,
> (2) what the ideal output would be, (3) what actually happened."

Keep cases rated ≥ 7. These become eval cases with real-world grounding.

### Building the Dataset

```json
{
  "source": "session_mining",
  "cases": [
    {
      "id": "mined_1",
      "prompt": "extracted user prompt",
      "expected": "description of ideal output",
      "actual_outcome": "what happened in the real session",
      "source_session": "20260501_session.json",
      "relevance_score": 9
    }
  ]
}
```

Aim for 8-12 mined cases. Combine with hand-written cases for a robust dataset.
Then apply the train/val/holdout split from Step 5.

---

## Eval Dataset Management

### Dataset File: `evals/eval_dataset.json`

```json
{
  "skill_name": "target-skill",
  "created": "2026-05-04",
  "cases": [...],
  "splits": {
    "train": ["case_1", "case_3", "case_5", ...],
    "val": ["case_2", "case_7"],
    "holdout": ["case_4", "case_8"]
  }
}
```

### Best Practices

- **Minimum 8 cases** for meaningful splits. Fewer than 8: use 60/40 train/val, no holdout.
- **Discriminating cases matter most.** A case where every skill version scores 1.0 teaches nothing.
  See `references/eval-quick-reference.md` for how to write discriminating cases.
- **Refresh from sessions periodically.** Re-mine after 2 weeks of real usage to catch new patterns.
- **Never edit holdout cases** once the loop starts. Train and val can be augmented mid-loop
  if you discover a gap, but holdout is sacred.
- **Version the dataset.** Copy to `evals/dataset_v1.json` before modifications.
