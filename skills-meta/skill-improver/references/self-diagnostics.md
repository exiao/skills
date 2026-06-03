# Self-Diagnostics Reference

How to capture and use an agent's self-reported confidence signals during optimization runs.

---

## the diagnostic prompt

After each run completes, send this to the **target model** before scoring:

```
You just completed this task. Before I score your output, report any moments where you:
(a) lacked sufficient context to be confident
(b) guessed or assumed instead of verifying
(c) had a tool call fail or return unexpected data
(d) were unsure which approach to take

Report each as: DIAGNOSTIC: [category] [one-line description]

Categories: missing_context, guessed, tool_failure, low_confidence, none

If everything went smoothly, report: DIAGNOSTIC: none
```

---

## categories

| Category | What it means | Optimization signal |
|----------|--------------|-------------------|
| `missing_context` | The skill didn't have enough information to be confident | Add context to the skill, or design a refusal eval for this input type |
| `guessed` | The agent made an assumption it couldn't verify | Add verification steps to the skill, or add a "check before proceeding" instruction |
| `tool_failure` | A tool call failed, returned errors, or returned unexpected data | Fix the tool integration, add error handling, or add a fallback path |
| `low_confidence` | The agent completed the task but isn't sure the output is correct | Investigate why: is the task ambiguous? Is the skill instruction unclear? |
| `none` | Everything went smoothly | No action needed (but verify against eval scores; false confidence is a signal too) |

---

## using diagnostics in the optimization loop

### during failure clustering (step 6a)

Include diagnostics in the failure analysis prompt:

```
Here are [N] outputs that failed evaluation. For each, the agent also reported these diagnostics:

Output 1: [output]
Diagnostics: DIAGNOSTIC: missing_context No reference file for enterprise pricing
Evals failed: [list]

Output 2: [output]
Diagnostics: DIAGNOSTIC: none
Evals failed: [list]
```

Failures with diagnostics are higher-signal fix targets. The agent already identified what went wrong. Failures with `DIAGNOSTIC: none` that still fail evals are more concerning: the agent was confidently wrong, which suggests a deeper skill issue.

### detecting calibration problems

Track diagnostic frequency across all runs. Warning signs:

- `guessed` on 30%+ of runs: the skill doesn't provide enough verification steps
- `missing_context` on specific input types: those inputs may need refusal evals instead of capability evals
- `none` on runs that fail evals: the agent is confidently wrong; this is the most dangerous pattern and suggests the skill is misleading the agent
- `tool_failure` clustering: a specific tool integration is unreliable and needs error handling

### feeding into refusal eval design

If the agent consistently reports `missing_context` or `low_confidence` on a category of inputs, those are candidates for refusal eval inputs. The agent is already signaling "I shouldn't be confident here." Turning that into a formal refusal eval prevents the optimization loop from teaching the agent to be confident where it shouldn't be.

---

## false confidence warning

Self-diagnostics are self-reported. The agent may:
- Report `none` when it should report `guessed` (overconfidence)
- Report `low_confidence` as a hedge even when output is correct (underconfidence)
- Rationalize failures as `missing_context` when the real issue is a bad instruction

Always cross-reference diagnostics against actual eval scores. The correlation between diagnostics and failures is the real signal, not the diagnostics alone.

Source: "Self-Diagnostics (Agent Reports Its Own Problems)" pattern from howtoeval.com (Ben Hylak, May 2026). Adapted from Raindrop's hidden tool injection approach to a post-run prompt approach suitable for skill optimization.
