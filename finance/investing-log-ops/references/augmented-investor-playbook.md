# The Augmented Investor Playbook — Distilled Notes

Source: David Plawn, Portrait Analytics (Business Breakdowns). 12-page PDF, May 2026.

## Core Framework: AI = Acceleration, Not Replacement

Two domains:
- **Conviction Building (Human):** Deep research friction is required to build real conviction. Building the model, internalizing the thesis. Can't be outsourced.
- **Information Triage (AI):** Solves the hours-in-a-day problem. Processes vast surface areas, pulls relevant signals, triages data. Never outsources the final decision.

## Augmented Research Funnel (3 stages)

| Stage | AI Role | Description |
|---|---|---|
| 1. Idea Generation | AI Enabled | Translate qualitative intuition into queries. "Historically high-performing franchise suffering temporary macro headwind" |
| 2. Pre-Buy Triage | AI Accelerated | Surface existential risks fast to kill bad ideas earlier. Map 5yr CEO proxy comp. Track guidance credibility (promised margin expansion, revised down repeatedly). |
| 3. Deep Research | Human Zone | Creative synthesis, bespoke financial modeling, final conviction. |

Key insight: AI most valuable at top of funnel (breadth), least at bottom (depth/judgment). Biggest time savings come from killing bad ideas faster (Stage 2).

## Intelligence Mosaic

Don't research stocks in isolation. Mine the ecosystem:
- Identify 2-3 peripheral companies (competitors, suppliers, customers) for each target position
- Deploy AI filters with SPECIFIC extraction goals per source (not "summarize the earnings call")
- Explicitly tell AI what to IGNORE from each source
- Example: Target = Expedia. Mine Marriott earnings for pricing/demand signals. Mine CPG transcripts for freight costs. Ignore Marriott unit growth (irrelevant).

"The End of Control-F" — move from keyword search to semantic, thesis-driven extraction.

## Overnight Analyst Mental Model

Prompting AI = delegating to a smart junior analyst who lacks your context:
- Explain the task, provide background, dictate format
- Assume smart but no domain-specific context
- Key difference: AI responds instantly → rapid iteration loop
- **Start simple → review instant output → add complexity → course-correct in real-time**
- The insight comes from the iterative dance, not a single perfect prompt

## 5-Part Prompt Blueprint

1. **CONTEXT** — "We are tracking potential shifts in the cost curve for [Industry] to project future pricing changes."
2. **TASK** — "Build a timeline of all management commentary regarding marginal vs. long-term cost curves over the last 3 years."
3. **OUTPUT FORMAT** — "Introductory summary, followed by chronological table with Date, Metric, Direct Quote."
4. **GUIDELINES** — "Capture both specific quantitative figures and soft qualitative guidance."
5. **DOMAIN KNOWLEDGE** — "Management teams are inherently biased positively. Apply skeptical lens to turnaround claims."

## Gaps Identified in investing-log (May 2026)

Applied against the 4-phase pipeline in $INVESTING_LOG_REPO:

1. **Intelligence Mosaic** (HIGH) — Add "Ecosystem Signal Extraction" to Stage 3 deep research. Currently researches candidates in isolation.
2. **Management Credibility Tracking** (MEDIUM) — Add to Pass 3 screening: track last 3-4 quarters guidance vs actuals. Flag serial over-promisers.
3. **Skeptical Lens in Domain Knowledge** (LOW-MEDIUM) — Inject "management positivity bias" warning into deep research prompt preamble. Bear Challenge handles this post-hoc but earlier injection reduces sycophantic buy bias.

Implementation plan: `~/.hermes/plans/augmented-investor-improvements.md`
