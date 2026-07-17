# Attention Basis for the P Items

The P1-P3 checklist items aren't style preferences; each is a finding about how models
attend to and follow instructions in a long prompt. Cite the relevant paper when flagging a
P item so the author sees *why* it matters. This is the compact version for SOUL.md work;
the papers are cited in full below.

## Positional attention (P1)

- **Lost in the Middle: How Language Models Use Long Contexts** — arXiv:2307.03172 (Liu et al., Stanford, 2023). Accuracy is highest when relevant info sits at the start or end of the input and degrades sharply in the middle, a U-shaped curve, even for long-context models. The reason non-negotiables go at the top of the file. (Recency at the end is real too, but the audit does not require restating a rule to exploit it.)
- **Positional Biases Shift as Inputs Approach Context Window Limits** — arXiv:2508.07479 (Veseli et al., 2025). The Lost-in-the-Middle effect is strongest when input fills up to ~50% of the window; past that, primacy weakens and recency holds. For SOUL.md this compounds with Hermes' 70%-head/20%-tail truncation: the low-attention middle is also the first content dropped.

## Redundancy / conflicting instructions (P2)

- **A Closer Look at System Prompt Robustness** — arXiv:2502.12197 (Mu, Lu, Lavery, Wagner; Berkeley; 2025). Built from real system prompts, models routinely forget guardrails and fail to resolve conflicting demands *within the system prompt itself*. Overlapping restatements are a real failure source, not a cosmetic nit.
- **Dynamic System Instructions and Tool Exposure for Efficient Agentic LLMs** — arXiv:2602.17046 (Franko, 2025). Long instructions re-ingested every turn raise cost, latency, and *derailment probability*; retrieving only the minimal fragment cuts per-step context 95% and improves routing. The case against a bloated, self-repeating identity file.

## Enforceability / instruction hierarchy (P3)

- **Control Illusion: The Failure of Instruction Hierarchies in LLMs** — arXiv:2502.15851 (Geng et al., 2025). Across six SOTA models, system/user separation fails to establish a reliable hierarchy even on simple conflicts, and societal framings (authority, expertise) sway behavior more than the role label. "IMPORTANT/NEVER" weighting is weaker than assumed; unenforceable aspirational rules erode the whole doc's authority.
- **The Instruction Hierarchy: Training LLMs to Prioritize Privileged Instructions** — arXiv:2404.13208 (Wallace et al., OpenAI, 2024). Models treat system/user/third-party text as equal priority unless trained otherwise; an explicit privileged hierarchy sharply raises robustness. Why a hard-line "never without approval" block belongs at the privileged top.

## Anchor survey

- **The Prompt Report: A Systematic Survey of Prompt Engineering Techniques** — arXiv:2406.06608 (Schulhoff et al., 2024). 58 techniques, 33-term vocabulary. The single authoritative citation for "prompt engineering best practices."
