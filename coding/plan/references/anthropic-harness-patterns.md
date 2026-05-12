# Anthropic Agent Harness Design Patterns

Condensed from three Anthropic engineering articles (2025-2026). Use when planning agent architectures for long-running, multi-phase, or production-grade agents.

## Source Articles

1. "Scaling Managed Agents: Decoupling the brain from the hands" (Apr 2026)
2. "Effective harnesses for long-running agents" (Nov 2025)
3. "Harness design for long-running application development" (Mar 2026)

## Core Principle: Harness Assumptions Go Stale

> "Harnesses encode assumptions about what Claude can't do, but those assumptions become obsolete as models improve."

Example: Claude Sonnet 4.5 had "context anxiety" (wrapping up prematurely near context limits), requiring harness-level context resets. Opus 4.5 eliminated this. The resets became dead weight.

Design around stable INTERFACES, not current model limitations.

## Three Stable Interfaces

| Interface | Purpose |
|-----------|---------|
| **Session** | Append-only log of everything that happened. Lives OUTSIDE the harness. Durable, recoverable. NOT the context window. |
| **Harness** ("brain") | The loop that calls Claude and routes tool calls. Stateless. If it crashes, `wake(sessionId)` resumes. |
| **Sandbox** ("hands") | Execution environment. Just a tool: `execute(name, input) -> string`. Could be a container, a phone, or a Pokemon emulator. |

Key separation: Session provides `getEvents()` to let the harness interrogate context by selecting positional slices. Events can be transformed before passing to Claude (compaction, prompt cache optimization).

## Inter-Session State (Long-Running Agents)

For agents working across multiple context windows:

1. **Structured state files beat memory:** `progress.txt` + `feature_list.json` > trying to summarize what happened. Use JSON over Markdown (models less likely to inappropriately overwrite JSON).

2. **Initializer + Worker pattern:**
   - Initializer (first run): creates progress log, feature list, init script, git commit
   - Worker (every subsequent run): reads progress + git logs, picks next task, commits + updates progress

3. **Session startup sequence:**
   - Read progress files to understand state
   - Read git log for recent changes
   - Run basic validation before starting new work
   - Commit with descriptive messages at session end

**For filesystem-based pipelines:** The workspace directory IS the session state. If a run crashes, resume by reading what files exist. No separate progress file needed when output files are the progress.

## Generator / Evaluator Pattern (GAN-Inspired)

> "When asked to evaluate work they've produced, agents tend to respond by confidently praising the work, even when the quality is obviously mediocre."

**Solution:** Separate the agent doing the work from the agent judging it.

### Design Principles

1. **Tuning a standalone evaluator to be skeptical is far more tractable** than making a generator critical of its own work.

2. **Concrete grading criteria over subjective questions:** "Does every number trace to a source?" works. "Is this good?" doesn't.

3. **Few-shot calibration:** Give the evaluator examples of PASS and FAIL outputs with detailed score breakdowns.

4. **Context resets > compaction** for isolation between generator and evaluator. Fresh context window for the evaluator prevents contamination.

5. **Retry loop:** On FAIL, feed evaluation feedback back to generator. Max 2-3 retries. Quality improves over iterations before plateauing.

### Three-Agent Architecture (for complex tasks)

| Agent | Role |
|-------|------|
| **Planner** | Expands brief prompt into full spec. Ambitious scope. No granular implementation details (errors cascade). |
| **Generator** | Works in sprints, one feature at a time. Self-evaluates before handoff. Has version control. |
| **Evaluator** | Uses browser/tools to test like a real user. Grades against criteria with hard thresholds. Failing any criterion triggers re-do. |

## Lens Isolation Pattern

For multi-faceted analysis (e.g., equity research with business quality, financial health, competitive position, valuation, risk):

- Each analytical "lens" gets its OWN context window / agent call
- Prevents anchoring (valuation doesn't contaminate business quality assessment)
- Implementation options:
  - **Subagents** (Claude Agent SDK): `AgentDefinition` per lens
  - **Tree branching** (Pi): branch from root, navigate back
  - **delegate_task** (Hermes): each lens = separate delegated task
  - **Separate API calls** (hand-rolled): fresh messages array per lens
- Synthesis step reads OUTPUT files from all lenses, not their conversation histories

## Agent Framework Selection Criteria

When choosing a harness for a specific use case, evaluate on:

| Criterion | What to check |
|-----------|--------------|
| **Pipeline shape** | Well-defined phases -> simpler harness. Open-ended -> richer framework. |
| **Language alignment** | Same language as existing tools reduces subprocess overhead. |
| **Model commitment** | Single provider -> provider SDK. Multi-model -> provider-agnostic. |
| **Deployment target** | Local only -> profiles/CLI. Cloud -> HERMES_HOME/container/API. |
| **Control vs convenience** | Framework assumptions go stale. How much do you need to own? |
| **Subagent needs** | Built-in vs spawn subprocess vs separate API calls. |
| **Cost controls** | Budget caps, token tracking, per-phase cost monitoring. |
