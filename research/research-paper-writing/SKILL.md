---
name: research-paper-writing
title: Research Paper Writing Pipeline
description: "Write ML papers for NeurIPS/ICML/ICLR: design→submit."
version: 1.1.0
author: Orchestra Research
license: MIT
dependencies: [semanticscholar, arxiv, habanero, requests, scipy, numpy, matplotlib, SciencePlots]
platforms: [linux, macos]
metadata:
  hermes:
    tags: [Research, Paper Writing, Experiments, ML, AI, NeurIPS, ICML, ICLR, ACL, AAAI, COLM, LaTeX, Citations, Statistical Analysis]
    category: research
    related_skills: [arxiv, plan]
    requires_toolsets: [terminal, files]

---

# Research Paper Writing Pipeline

End-to-end pipeline for producing publication-ready ML/AI research papers targeting NeurIPS, ICML, ICLR, ACL, AAAI, and COLM. Use this skill for research planning, experiment design, paper drafting, review response, revision, and submission.

## When To Use

Use this skill when:
- Starting a new research paper from an existing codebase or idea
- Designing and running experiments to support paper claims
- Writing or revising any section of a research paper
- Preparing for submission to a specific conference or workshop
- Responding to reviews with additional experiments or revisions
- Converting a paper between conference formats
- Writing theory, survey, benchmark, or position papers
- Designing human evaluations for NLP, HCI, or alignment research
- Preparing post-acceptance posters, talks, or code releases

## Core Rules

1. Be proactive. Draft first, ask with the draft.
2. Never hallucinate citations. Fetch programmatically and mark unverifiable citations as `[CITATION NEEDED]`.
3. Treat the paper as a story, not a pile of experiments.
4. Every experiment must support a specific claim.
5. Commit early and often so git becomes the experiment history.
6. Use conference templates and checklists before submission.

## Workflow

1. Define the contribution in one sentence.
2. Run a literature review and citation audit.
3. Design experiments that map directly to paper claims.
4. Execute and monitor experiments with reproducible scripts.
5. Analyze results with statistical tests and clear tables/figures.
6. Draft the paper section by section.
7. Self-review against target venue criteria.
8. Revise, format, and submit.
9. For reviews, map each reviewer concern to evidence, edits, or new experiments.

## Required References

Load the relevant reference files before doing substantial work:

- `references/full-guide.md` — full detailed workflow and expanded instructions
- `references/citation-workflow.md` — citation fetching and verification
- `references/experiment-patterns.md` — experiment design patterns
- `references/writing-guide.md` — paper section writing guidance
- `references/reviewer-guidelines.md` — review and rebuttal guidance
- `references/paper-types.md` — non-empirical paper variants
- `references/human-evaluation.md` — human eval design
- `references/checklists.md` — submission and quality checklists
- `references/sources.md` — source discovery
- `references/autoreason-methodology.md` — AutoReason-specific methodology

## Templates

Use templates under `templates/` for venue formatting, including NeurIPS, ICML, ICLR, ACL, COLM, AAAI, and workshop variants.

## Verification

Before calling the work done:
- Confirm every citation resolves to a real paper
- Confirm every table/figure is backed by a reproducible source
- Confirm claims are supported by experiments or theory
- Run venue formatting checks
- Run spellcheck/grammar pass
- Validate page limits, anonymity, and supplementary material rules
