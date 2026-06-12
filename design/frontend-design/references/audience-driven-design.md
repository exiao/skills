# Audience-Driven Design

## The Problem

When building stakeholder-facing pages (reports, progress sites, portfolio presentations), the default instinct is to showcase everything that was built: commit counts, PR timelines, skill inventories, test coverage, architecture details. This is engineering-brain output. It impresses builders but bores the audience.

## The Fix: Design for the Reader, Not the Builder

Before writing any HTML, answer three questions from the audience's perspective:

1. **Does this work?** (proof of competence)
2. **How good is the output?** (sample they can judge themselves)
3. **Can I trust it?** (verification, error rates, methodology)

If a section doesn't serve one of those three, cut it.

## What to Cut (Stakeholder Context)

These are impressive to engineers but noise for decision-makers:

- PR timelines and commit history
- Lines of code / repo stats
- Individual skill or module inventories
- CI/CD pipeline details
- "What's Next" roadmaps (they don't care about your backlog)
- Data source lists (they care about the output quality, not the plumbing)
- Eval scenario grids (just show the pass rate)

## What to Show Instead

- **The problem you solve** (framed in their language)
- **How it works** (3-5 steps, high level, no jargon)
- **Proof it works** (before/after, error rates improving, specific failures caught and fixed)
- **Sample output** (let them read it and judge quality themselves)
- **Verification evidence** (claim-by-claim audit table, numbers matching)

## Aesthetic Implications

Stakeholder pages should feel editorial, not technical:

- Serif headlines, clean sans-serif body (Instrument Serif + DM Sans works well)
- Warm paper tones over dark mode
- No emoji-heavy skill grids or badge soup
- Monospace only for actual data/numbers, not decoration
- Tables for verification evidence (claim / memo value / computed / checkmark)
- Let whitespace do the hierarchy work

## Example: Research Tool Report

A first version had: 17 PRs, 7600 lines of code, 15 skill names, full PR timeline, eval scenario grid, data source pills, repo cards. Audience: a portfolio manager evaluating an AI research tool.

A second version cut to: problem statement, 5-phase pipeline (plain English), 3 result cards showing improvement, an actual memo excerpt, a verification table. Half the length, twice the signal.

The audience never asked "how many PRs did you ship?" They asked "can I trust this output?"
