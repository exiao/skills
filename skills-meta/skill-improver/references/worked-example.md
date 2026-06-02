# Worked Example and Operational Tips

A full walkthrough of an optimization run, plus operational guidance. SKILL.md points here.

---

## example: optimizing a diagram-generator skill

**Context gathered:**
- Target skill: `~/.hermes/skills/visual-design/diagram-generator/SKILL.md`
- Optimizer model: claude-opus-4-6 (session model)
- Target model: gpt-5.5 (cross-architecture)
- Test inputs (10): "OAuth flow", "CI/CD pipeline", "microservices arch", "onboarding funnel", "DB schema", "payment flow", "auth sequence", "deploy pipeline", "event system", "API gateway"
- Split: 5 train, 3 val, 2 test
- Evals: (1) All text legible? (2) Pastel/soft colors only? (3) Linear layout? (4) No numbers or ordinals?
- Runs per experiment: 3

**Baseline (experiment 0):**
Ran train+val inputs with gpt-5.5. Scored against 4 evals. (Test set held back — not scored until the end.)
Train: 65% | Val: 60%

**Experiment 1 — KEEP (train 80%, val 75%):**
Failure clustering (opus): "3/5 training failures share the same pattern: numbered steps appear in flow diagrams. This is the highest-impact cluster."
Edit proposed:
```json
{"edits": [{"op": "append", "content": "## Anti-patterns\n\nNEVER include step numbers, ordinal numbers (1st, 2nd), or sequential numbering in diagrams."}]}
```
Apply report: 1 applied, 0 skipped.
Regression guard: no regressions on previously-passing evals.
Val score improved 60% → 75%. **KEEP.**

**Experiment 2 — DISCARD (train 85%, val 70%):**
Edit: `{"op": "replace", "target": "pastel colors", "content": "all text minimum 14px font"}`
Apply report: 1 applied.
Train improved (80→85%), but val dropped (75→70%). **DISCARD.**
Added to rejected-edit buffer: "font size rule — improved training but hurt validation, likely overfit to training inputs."

**Experiment 3 — KEEP (train 90%, val 85%):**
Failure clustering (opus): "2/5 training failures: bright red elements. Rejected-edit buffer says don't try font size. Recommend: replace vague 'pastel colors' with specific hex codes."
Edit: `{"op": "replace", "target": "Use pastel, soft colors", "content": "Use these exact colors: #A8D8EA, #AA96DA, #FCBAD3, #FFFFD2, #B5EAD7"}`
Val improved 75% → 85%. **KEEP.**

**Slow update (after experiment 5):**
Longitudinal comparison (baseline vs current, all 8 train+val inputs):
- Improved: 3 inputs (numbering fixed, colors fixed)
- Regressed: 1 input (complex diagram labels now overlap)
- Persistent fail: 1 input (always too small text)
- Stable success: 3 inputs

Guidance written to protected section:
```
<!-- SLOW_UPDATE_START -->
When generating complex diagrams with many nodes, increase spacing between elements
to prevent label overlap. The color hex codes are working well; do not revert them.
The persistent small-text issue on dense diagrams needs a different approach than
font-size rules (which regressed validation scores in experiment 2).
<!-- SLOW_UPDATE_END -->
```

**Final test evaluation:**
Test set scored for the first time. Test score: 70% → it improved relative to a baseline test run computed against `SKILL.md.baseline` at the very end (also 70% baseline → 85% final). Honest improvement: +15 points.
Val improved +25 points but test only +15 — some val-specific optimization, but test still improved meaningfully. No overfitting flag.

**Final delivery:**
- Baseline: train 65%, val 60% → Final: train 95%, val 90%, test 85%
- 8 experiments, 5 kept, 3 discarded
- 1 slow update pass
- Top changes: hex color codes, anti-numbering rule, worked example
- Remaining issue: dense diagrams occasionally get overlapping labels (flagged in slow update)

---

## operational tips

**Cross-model setup:** Default is Config A: opus as optimizer (current session), gpt-5.5 as target. For the target model, use `hermes chat -q` with a `--model` flag, or delegate to a subagent with the target model specified. To flip it (Config B: gpt optimizes, opus executes), tell the user to start the session on gpt-5.5 and set opus as target. Config C (same model) skips cross-architecture entirely. The optimizer makes ~2 calls per experiment (analysis + edit proposal). The target makes ~N x runs calls per experiment (rollouts). Cost difference is small.

**Operational skills (API calls, uploads, deploys):** If the target skill makes real third-party calls, extract the testable section into a standalone mini-skill for optimization. See `ad-creative-ideation-case-study.md` for a worked example (43% → 95%).

**Timeout risk for expensive skills:** If each test run is slow, subagents will timeout at 600s. Mitigations: (1) truncate test inputs to a representative subset, (2) reduce runs-per-experiment to 2-3, (3) pre-compute the filtering step, (4) run the loop in the main context instead of delegating. Plan your time budget: if one run takes ~60s, 3 runs × 10 experiments = 30 minutes minimum.

**If you run out of ideas:** Re-read the failing outputs. Check the rejected-edit buffer for patterns in what didn't work. Try combining two previous near-miss mutations. Try removing things instead of adding them. Simplification that maintains the score is a win. Check the slow update guidance for persistent failures you haven't addressed.

---

## how this connects to other skills

**What feeds into skill-improver:**
- Any existing skill that needs optimization
- User-defined eval criteria (or help them define evals using the eval guide)

**What skill-improver feeds into:**
- The improved skill replaces the original (user's decision)
- The changelog can be passed to future models for continued optimization
- The eval suite can be reused whenever the skill is updated
- The rejected-edit buffer prevents future runs from repeating failed approaches

**Techniques adopted by other systems:**
- CPE Research's `hill_climb.py` adopted structured edit ops, failure clustering, rejected-edit buffer, and report content analysis from this skill (PR #205, 2026-05-27). Key adaptation: their evals are deterministic pytest tests rather than LLM-judged binary checks, so the structured edits operate against a more stable scoring function. Their per-test regression guard (reject if ANY previously-passing test regresses) is stricter than the validation-gate approach here and worth considering for skills where eval stability is high.
