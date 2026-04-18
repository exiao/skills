---
name: another-perspective
description: Run a multi-perspective council analysis on any question, plan, or decision. Spawns parallel cognitive perspectives (Architect, Skeptic, Pragmatist, Innovator, User Advocate, Temporal Analyst) and synthesizes via structured dialectical analysis. Use when: making a significant decision, stress-testing a plan, red-teaming an idea, exploring alternatives, or needing a "devil's advocate" on something. Trigger phrases include "another perspective", "council analysis", "stress test this", "red team this", "poke holes in this", "multiple viewpoints", "what am I missing", "challenge this idea".
---

# Another Perspective — Multi-Perspective Council Analysis

Spawns parallel cognitive perspectives to analyze questions, plans, and ideas from multiple angles, then synthesizes findings through structured dialectical analysis.

## Usage

Invoke this skill when the user asks for another perspective, wants a decision stress-tested, or needs a structured multi-angle analysis.

**Council sizes:**
- `--quick` — 2 perspectives (User Advocate + 1 adaptive). Fast sanity check.
- *(default)* — 4 perspectives (User Advocate + 3 adaptive). Balanced.
- `--full` — all 6 perspectives. Comprehensive deep dive.
- `--council N` — exactly N perspectives (2–6).

**Quality:**
- *(default)* — Sonnet agents (~$0.15–0.45)
- `--deep` — Opus agents (~$0.75–2.25). Max analytical depth.

**Perspective overrides:**
- `--include name,name` — force-include specific perspectives
- `--exclude name,name` — force-exclude specific perspectives

Perspective names: `architect`, `skeptic`, `pragmatist`, `innovator`, `advocate`, `temporal`

---

## Step 1: Parse Input

Parse flags from the user's message (remove each from the question after parsing):

**Council size (mutually exclusive):**
- `--quick` → 2 perspectives
- *(no flag)* → 4 perspectives (default)
- `--full` → 6 perspectives
- `--council N` → exactly N (2–6)

**Quality:** `--deep` → use `model: opus` for agents (default: sonnet)

**Overrides:** `--include name,name` / `--exclude name,name`

If no question is present after parsing, ask what the user wants analyzed.

---

## Step 2: Classify and Select Perspectives

Read classification rules: @${SKILL_DIR}/references/classification.md

Resolution order:
1. Classify question type → get default relevance order
2. Apply `--include` overrides (add, up to 6 max)
3. Apply `--exclude` overrides (remove)
4. User Advocate is always included unless explicitly excluded via `--exclude advocate`
5. Final council: 2–6 perspectives

---

## Step 3: Announce

Announce before spawning agents:

```
Convening the council...

Question type: [classification]
Council ([N] perspectives): [Perspective 1] + [Perspective 2] + ...
Mode: [Default (sonnet) / Deep (opus)]
Estimated cost: ~$[X.XX]
```

Cost table:
| Perspectives | Sonnet | Opus (--deep) |
|---|---|---|
| 2 | ~$0.15 | ~$0.75 |
| 3 | ~$0.22 | ~$1.10 |
| 4 | ~$0.30 | ~$1.50 |
| 5 | ~$0.37 | ~$1.85 |
| 6 | ~$0.45 | ~$2.25 |

---

## Step 4: Load Perspectives

Read perspective definitions: @${SKILL_DIR}/references/perspectives.md

---

## Step 5: Spawn Parallel Agents

Launch **all N agent tool calls in a single message** for parallel execution. Each agent receives:
- Full perspective identity, methodology, output structure from perspectives.md
- User's question verbatim
- Instructions to follow methodology step by step
- Instructions to rate confidence (High/Medium/Low) with reasoning
- Instructions to note what they are MOST and LEAST qualified to assess
- Model: `sonnet` (default) or `opus` (if `--deep`)

**Agent prompt template:**

```
You are [PERSPECTIVE NAME] on a multi-perspective analysis council.

[FULL PERSPECTIVE DEFINITION — Identity, Methodology, Signature Questions, Challenge Targets, Confidence Calibration]

---

QUESTION TO ANALYZE:
[User's question, verbatim]

---

INSTRUCTIONS:
1. Follow your methodology step by step
2. Apply your signature questions to this specific situation
3. Consider your challenge targets — what would other perspectives likely argue, and where would you push back?
4. Rate your confidence (High/Medium/Low) with a specific reason
5. Note which aspects you are MOST and LEAST qualified to assess
6. Use your perspective's output structure exactly

Be thorough but focused. 300–600 words. Quality over quantity.
```

**Critical:** All N agent calls MUST be in a single message to execute in parallel.

---

## Step 6: Synthesize

After all agents return, perform dialectical synthesis.

Read synthesis methodology: @${SKILL_DIR}/references/synthesis.md

Follow the 7-step process:
1. Map consensus (proportional thresholds)
2. Identify tensions (2+ perspectives meaningfully disagree)
3. Resolve or frame each tension
4. Detect blind spots (what nobody addressed)
5. Build confidence map (skip for --quick)
6. Synthesize verdict (1–3 sentences, actionable)
7. Order next steps (3–5 concrete actions)

---

## Step 7: Output Council Report

Read output format: @${SKILL_DIR}/references/output-format.md

- **Quick (2 perspectives):** Compact format — Verdict, Agreement/Disagreement, Blind Spots, Next Steps
- **Standard (3–6 perspectives):** Full format with all sections

Include individual perspective analyses in collapsible `<details>` sections at the bottom.

**Important:**
- Do NOT editorialize between spawning agents and synthesizing
- Do NOT show raw agent output — only the final Council Report
- If an agent fails, proceed with remaining and note: "The [X] perspective was unavailable."
- Synthesize yourself — do not spawn an additional agent for synthesis
- Represent tensions faithfully — don't smooth them over
- At 5–6 perspectives, surface only the 2–3 most significant tensions
