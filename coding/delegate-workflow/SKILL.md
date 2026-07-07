---
name: delegate-workflow
description: "Build a durable, fault-tolerant multi-agent workflow in Hermes by writing a checkpointing Python driver that POSTs one agent call per step to the local billing proxy, instead of orchestrating turn-by-turn with TaskDelegate. Use when a fan-out job must survive a restart, run unattended, hold its plan in code (not context), fan out to dozens of agents, or apply an adversarial cross-check/vote. The native equivalent of Claude Code ultracode workflows."
version: 1.0.0
author: Hermes Agent
metadata:
  hermes:
    tags: [Orchestration, Workflows, Fault-Tolerance, Checkpointing, Multi-Agent, Billing-Proxy]
---

# Delegate Workflow: durable multi-agent orchestration in Hermes

`TaskDelegate` fans out fine, but the **plan lives in the agent's context, turn by turn**. That has three failure modes for anything nontrivial:
- **Not durable.** Session dies mid-orchestration and the plan is gone. No artifact says "iteration 3 of 5, these 12 survived, re-run only the 4 that failed." Even `background=true` delegation dies on restart.
- **Retry is ad-hoc.** A bad/dead subagent result gets "fixed" by the agent noticing and re-prompting, differently each run.
- **Results clog context.** Every subagent transcript lands in the window; a 50-agent fan-out degrades the orchestrator past ~70% context.

Claude Code's `ultracode` workflows solve this by moving the plan into a script. This skill does the same thing **natively in Hermes**: a checkpointing Python driver where each "agent" call is a tool-less POST to the local billing proxy. Same durability, you own the driver, it's eval-able, and it uses your subscription quota via the normal billing path (no Claude Code spend cap).

## When to use this vs alternatives

- **Inline `TaskDelegate` fan-out**, the right tool for "do these 6 independent things now, I'm waiting." No durability needed. Don't reach for this skill.
- **This skill (delegate-workflow)**, recurring/ownable orchestration that must survive a restart, run unattended, fan out large, or apply a structured verify/vote. E.g. the CPE memo verify gate, a codebase-wide sweep you run weekly, a 100-claim fact-check.
- **Claude Code `ultracode`**, one-off "just sweep this" where you don't want to hand-write a driver and the model can generate the script. Downside: experimental, opaque, hits Claude spend caps.

## The pattern (three mechanisms)

1. **Agent = tool-less proxy POST.** A plain Python script cannot call `TaskDelegate` (that's the agent's tool alone). But it CAN POST to `http://127.0.0.1:18801/v1/messages` with **no `tools` field**, that's the Hermes-native `agent()`. Omitting `tools` is mandatory: the proxy injects Claude-Code tool stubs when it sees `"tools":[`, which 400s. Model: haiku for cheap mechanical stages, sonnet/opus only where reasoning matters.
2. **Checkpoint per call.** Keep a `checkpoint.json` mapping a stable `key` → result. Before running an agent call, check the checkpoint; if the key is present, return the cached result. Write the checkpoint (atomically, via `os.replace`) immediately after each successful call. This IS the durability + resume: a kill mid-run leaves completed calls cached, and re-running skips them.
3. **Structured retry + adversarial verify.** Retry each call 3x with backoff, deterministically. For quality (the one thing plain fan-out lacks), run a verify phase: independent agents try to REFUTE each finding and vote; a claim survives only on majority-support.

## Reference driver

A complete, crash-tested driver is in `references/workflow_harness.py`. It runs a fan-out → 3-vote adversarial-verify → synthesize pipeline over a claim list. Copy it and swap the `CLAIMS` list and the three phase functions for your task. Structure:

```python
def agent(key, prompt, max_tokens=400):
    if key in CKPT_STATE["agents"]:      # resume: skip cached
        return CKPT_STATE["agents"][key]
    # POST to proxy with NO tools field, retry 3x, checkpoint on success
    ...

def parallel(fns, workers=4):            # ThreadPoolExecutor
    ...

# plan-in-code: phases call agent()/parallel(), results held in variables
```

Run it, kill it mid-phase, re-run without `--reset`: it resumes from `checkpoint.json` and re-does zero completed work. Verified this session: killed after phase 1 (5 research calls cached), resumed, ran only the 15 verify + synthesize calls, orchestrator context only ever saw the final table.

## Pitfalls (learned building this)

- **Adversarial "default-to-refuted" over-refutes true claims.** In the test run, "AMD MI300 uses HBM3" (TRUE) was wrongly REFUTED because the refute-default biases toward false-negatives. Before trusting a verify gate on real work (a memo), tune the threshold: require 3/3 to refute rather than defaulting refuted, or add a confirming pass. The bias is a property of the prompt, not a bug.
- **Keys must be stable across runs.** The resume logic keys on the exact `key` string. Derive it from the work item (`f"verify:{i}:{vote}"`), never from a timestamp or random id, or nothing caches.
- **Write the checkpoint atomically.** `json.dump` to a `.tmp` then `os.replace`, a crash mid-write otherwise corrupts the checkpoint and loses everything.
- **Don't POST with a `tools` field.** Empties-or-not, the proxy stub-injection 400s. Tool-less calls only; if a stage needs tools, that stage belongs in a real `TaskDelegate`/kanban lane, not this harness.
- **Background launch:** run the driver with `ShellExec(background=true, notify_on_complete=true)` and redirect to a log; poll the checkpoint for progress. Don't hold it in a foreground turn if it's long.
- **This is for tool-less LLM stages** (research, classify, verify, summarize, extract). Work that needs file writes / shell / git belongs in `TaskDelegate` or a kanban lane, which the harness can't replace.

## Skill source

Built and crash-tested in Hermes this session as the native counterpart to Claude Code dynamic workflows. To extend: add phases to the reference driver; keep the checkpoint/retry/no-tools invariants.
