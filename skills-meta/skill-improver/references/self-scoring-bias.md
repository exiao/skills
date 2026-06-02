# Self-Scoring Bias in Autoresearch

## The Problem

When the same agent generates outputs AND scores them, scores inflate. The agent is biased toward its own outputs and interprets eval criteria generously. A baseline that comes back 95%+ on the first run is a red flag, not a green light.

Observed in practice: a content-strategy skill baseline scored 24/25 (96%) when the generating agent also scored. The agent gave itself YES on evals where outputs name-dropped skill frameworks but didn't deeply apply them, and where "anti-slop" checks passed despite containing some generic CTA advice.

## Mitigations

1. **Use a separate scoring agent.** Spawn a dedicated grader subagent that only sees the output and eval criteria, not the skill or the generation context. The grader should not know which experiment produced the output.

2. **Adversarial eval phrasing.** Write evals that look for the absence of bad patterns rather than the presence of good ones. "Does the output contain zero instances of [generic advice pattern]?" is harder to game than "Does it include specific tactical advice?"

3. **Spot-check manually.** Before trusting a high baseline, read 2-3 outputs yourself. If they feel like generic ChatGPT responses that happen to name-drop skill frameworks, the evals are too easy.

4. **Discrimination test.** Add an eval: "Would this output be materially different without the skill? Could a vanilla Claude produce something equivalent?" If yes, the skill isn't adding value and the eval is non-discriminating. This is the most important eval for strategy/creative skills where the failure mode is "sounds good but says nothing the model wouldn't say anyway."

5. **Calibrate with a known-bad output.** Before running the loop, manually write one deliberately mediocre output and score it against your evals. If it scores above 50%, your evals are too easy.

## When to Suspect Inflated Scores

- Baseline scores above 90% on the first run
- All evals pass on every run (no variance = no signal)
- The "anti-slop" or "specificity" eval passes consistently but the outputs feel generic when you read them
- The agent's self-generated outputs suspiciously match the eval criteria phrasing

## Source

Discovered during content-strategy autoresearch session, May 2026. The agent scored itself 96% baseline; manual review suggested the real score was closer to 75-80% due to framework name-dropping without deep application and generic CTA advice passing the anti-slop check.
