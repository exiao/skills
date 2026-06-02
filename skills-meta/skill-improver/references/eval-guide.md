# Eval Guide

How to write eval criteria that actually improve your skills instead of giving you false confidence.

## Contents

- [The golden rule](#the-golden-rule)
- [Test inputs: quantity and split](#test-inputs-quantity-and-split)
- [Good evals vs bad evals](#good-evals-vs-bad-evals)
- [Common mistakes](#common-mistakes)
- [Writing your evals: the 3-question test](#writing-your-evals-the-3-question-test)
- [Refusal evals](#refusal-evals)
- [Trajectory evals](#trajectory-evals)
- [Golden cases](#golden-cases)
- [Deriving evals from production logs](#deriving-evals-from-production-logs)
- [Template](#template)

---

## the golden rule

Every eval must be a yes/no question. Not a scale. Not a vibe check. Binary.

Why: Scales compound variability. If you have 4 evals scored 1-7, your total score has massive variance across runs. Binary evals give you a reliable signal.

---

## test inputs: quantity and split

The optimizer splits your test inputs into three sets:

| Set | Share | Purpose |
|-----|-------|---------|
| **Training** (50%) | Failure analysis, success analysis, mutation development | Seen every experiment |
| **Validation** (25%) | Accept/reject gate for mutations | Seen every experiment, but never used to develop the mutation |
| **Test** (25%) | Final honest evaluation | Seen ONLY at the very end |

**Why three sets?** If you score mutations on the same inputs you used to develop them, the skill overfits to those specific scenarios. The validation set catches that. But even the validation set gets implicitly learned over many experiments (since it gates every decision). The test set gives a truly honest final number.

**How many inputs?**
- **8-12 inputs** (target): gives a clean 50/25/25 split. Example: 10 inputs = 5 train, 3 val, 2 test.
- **5-7 inputs** (minimum for split): falls back to 60/40 train/val, no test set. You lose the honest final evaluation.
- **4 or fewer** (degraded): no split possible. All inputs used for everything. Overfitting risk is high.

**What makes a good set of inputs?**
- Cover different use cases the skill handles (not 10 variations of the same scenario)
- Include at least one "hard" input that pushes the skill's limits
- Include at least one "easy" input that should always pass (canary for regressions)
- Vary the input length, complexity, and domain

---

## good evals vs bad evals

### Text/copy skills (newsletters, tweets, emails, landing pages)

**Bad evals:**
- "Is the writing good?" (too vague; what's "good"?)
- "Rate the engagement potential 1-10" (scale = unreliable)
- "Does it sound like a human?" (subjective, inconsistent scoring)

**Good evals:**
- "Does the output contain zero phrases from this banned list: [game-changer, here's the kicker, the best part, level up]?" (binary, specific)
- "Does the opening sentence reference a specific time, place, or sensory detail?" (binary, checkable)
- "Is the output between 150-400 words?" (binary, measurable)
- "Does it end with a specific CTA that tells the reader exactly what to do next?" (binary, structural)

### Visual/design skills (diagrams, images, slides)

**Bad evals:**
- "Does it look professional?" (subjective)
- "Rate the visual quality 1-5" (scale)
- "Is the layout good?" (vague)

**Good evals:**
- "Is all text in the image legible with no truncated or overlapping words?" (binary, specific)
- "Does the color palette use only soft/pastel tones with no neon, bright red, or high-saturation colors?" (binary, checkable)
- "Is the layout linear, flowing either left-to-right or top-to-bottom with no scattered elements?" (binary, structural)
- "Is the image free of numbered steps, ordinals, or sequential numbering?" (binary, specific)

### Code/technical skills (code generation, configs, scripts)

**Bad evals:**
- "Is the code clean?" (subjective)
- "Does it follow best practices?" (vague, which best practices?)

**Good evals:**
- "Does the code run without errors?" (binary, testable; actually execute it)
- "Does the output contain zero TODO or placeholder comments?" (binary, greppable)
- "Are all function and variable names descriptive (no single-letter names except loop counters)?" (binary, checkable)
- "Does the code include error handling for all third-party calls (API, file I/O, network)?" (binary, structural)

### Document skills (proposals, reports, decks)

**Bad evals:**
- "Is it comprehensive?" (compared to what?)
- "Does it address the client's needs?" (too open-ended)

**Good evals:**
- "Does the document contain all required sections: [list them]?" (binary, structural)
- "Is every claim backed by a specific number, date, or source?" (binary, checkable)
- "Is the document under [X] pages/words?" (binary, measurable)
- "Does the executive summary fit in one paragraph of 3 sentences or fewer?" (binary, countable)

---

## common mistakes

### 1. Too many evals
More than 6 evals and the skill starts gaming them; it optimizes for passing the test instead of producing good output. Like a student who memorizes answers without understanding the material.

**Fix:** Pick the 3-6 checks that matter most. If everything passes those, the output is probably good.

### 2. Too narrow/rigid
"Must contain exactly 3 bullet points" or "Must use the word 'because' at least twice": these create skills that technically pass but produce weird, stilted output.

**Fix:** Evals should check for qualities you care about, not arbitrary structural constraints.

### 3. Overlapping evals
If eval 1 is "Is the text grammatically correct?" and eval 4 is "Are there any spelling errors?", these overlap. A grammar fail often includes spelling. You're double-counting.

**Fix:** Each eval should test something distinct.

### 4. Unmeasurable by an agent
"Would a human find this engaging?": an agent can't reliably answer this. It'll say "yes" almost every time.

**Fix:** Translate subjective qualities into observable signals. "Engaging" might mean: "Does the first sentence contain a specific claim, story, or question (not a generic statement)?"

### 5. Too few test inputs
With only 3 inputs, the optimizer can accidentally overfit to those specific scenarios. A mutation that helps with "OAuth flow diagram" might hurt "database schema" but you'd never know because the schema input was in the training set.

**Fix:** Provide 8-12 inputs covering different use cases. The three-way split needs volume to work.

---

## writing your evals: the 3-question test

Before finalizing an eval, ask:

1. **Could two different agents score the same output and agree?** If not, the eval is too subjective. Rewrite it.
2. **Could a skill game this eval without actually improving?** If yes, the eval is too narrow. Broaden it.
3. **Does this eval test something the user actually cares about?** If not, drop it. Every eval that doesn't matter dilutes the signal from evals that do.

---

## refusal evals

Some skills should refuse rather than guess. Refusal evals test this calibration.

**When to use refusal evals:**
- Skills that handle real-time or volatile data (stock prices, API status, live metrics)
- Skills that make claims about facts the model might not have (recent events, private data)
- Skills where a wrong answer is worse than no answer (medical, financial, legal)

**How to write refusal inputs:**

```
REFUSAL_INPUT 1: Stale ticker data
Scenario: "What is AAPL trading at right now?"
Why refuse: The skill has no live market data feed; any price it quotes is from training data and potentially months stale.
```

```
REFUSAL_INPUT 2: Out-of-domain query
Scenario: "What's the best treatment for my symptoms?"
Why refuse: A financial analysis skill should not attempt medical advice.
```

```
REFUSAL_INPUT 3: Insufficient context
Scenario: "Is this stock a good buy?" (no ticker, no timeframe, no risk profile)
Why refuse: The query is too ambiguous to produce a responsible answer.
```

**Scoring:** Refusal inputs are scored inversely. The skill **passes** if it declines, hedges, or explicitly flags insufficient data. It **fails** if it produces a confident, specific answer. The eval question is: "Did the skill appropriately refuse or flag uncertainty rather than producing a confident answer?"

**Pitfall:** Don't make refusal too easy to game. "Always say I don't know" would pass all refusal evals but fail all capability evals. The tension between capability and calibration is the point.

---

## trajectory evals

Standard evals judge what the skill produced. Trajectory evals judge how it got there.

**When to use trajectory evals:**
- Skills with multi-step processes where order matters
- Skills that should load reference files or call specific tools
- Skills where correct output from a wrong process is a false positive

**How to write trajectory evals:**

```
TRAJECTORY_EVAL 1: Reference file loaded
Question: Did the skill read the relevant reference file before generating output?
Pass: The tool-call log shows a file read of the expected reference before the generation step.
Fail: Output was generated without loading the reference file.
```

```
TRAJECTORY_EVAL 2: Data before claims
Question: Did the skill call the data API before making quantitative claims?
Pass: API call appears in the trajectory before any numerical claims in the output.
Fail: Numerical claims appear without a preceding API call.
```

```
TRAJECTORY_EVAL 3: Error check
Question: Did the skill check for error responses from third-party tools?
Pass: After each tool call, the skill inspected the response for errors before proceeding.
Fail: The skill proceeded without checking for error conditions.
```

**Capturing trajectories:** The experiment harness must log the full tool-call sequence during each run: tool name, key arguments, return status. This log is what trajectory evals are scored against. Without it, trajectory evals are unjudgeable.

---

## golden cases

Golden cases are test inputs that must never regress. They come from real production failures that were fixed.

**How to identify golden cases:**
- Bugs that caused user-visible failures and were fixed in a previous optimization
- Critical paths that represent the skill's core value proposition
- Edge cases that historically break when the skill is modified
- Inputs derived from the saturation pass (step 1.5) that represent recurring failure patterns

**Properties:**
- Always in the training set (never randomized into val/test)
- Stricter regression guard: ANY regression on a golden case = immediate discard
- Marked with 🔒 in the dashboard
- Typically 1-3 inputs (not everything is golden; if everything is critical, nothing is)

**When NOT to use golden cases:**
- New skills with no production history (nothing to protect yet)
- Skills where all inputs are equally important (use the normal regression guard)

---

## deriving evals from production logs

If the target skill has production history, review real executions before writing evals (see step 1.5: saturation pass).

**What to look for:**
- Recurring complaints or corrections from the user
- Silent failures: output looked fine but was wrong
- Tool errors the skill didn't handle
- Cases where the user worked around the skill instead of using it directly

**Turning observations into evals:**
- User correction "that's not right, the price is X" → eval for data accuracy + possible refusal eval
- User workaround "let me just do this manually" → eval for the step the user bypassed
- Tool error swallowed silently → trajectory eval for error checking
- Same failure three sessions in a row → golden case

---

## template

Copy this for each eval:

```
EVAL [N]: [Short name]
Question: [Yes/no question]
Pass: [What "yes" looks like, one sentence, specific]
Fail: [What triggers "no", one sentence, specific]
```

Example:

```
EVAL 1: Text legibility
Question: Is all text in the output fully legible with no truncated, overlapping, or cut-off words?
Pass: Every word is complete and readable without squinting or guessing
Fail: Any word is partially hidden, overlapping another element, or cut off at the edge
```
