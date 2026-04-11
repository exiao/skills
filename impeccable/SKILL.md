---
name: impeccable
description: Run impeccable design quality commands on frontend code — audit, critique, polish, animate, normalize, and more. Built on top of the frontend-design skill with 21 steering commands and 7 domain-specific reference files. Use when doing a design QA pass, reviewing UI quality, or refining a frontend component before shipping.
---

> **Source:** External skill (frontend-design ecosystem) — local copy, do not modify without checking upstream.

# Impeccable

Design quality layer for Claude Code. 21 commands that audit, review, polish, and refine frontend interfaces. Complements the `frontend-design` skill (vision/direction) with systematic QA passes.

**Source:** https://github.com/pbakaus/impeccable  
**Installed at:** `~/clawd/skills/` (frontend-design + 7 individual command skills)

## When to Use

- After building a component or page with `frontend-design` — run a quality pass
- Pre-ship review: `/audit` → `/critique` → `/polish`
- Targeted fixes: `/colorize`, `/animate`, `/bolder`, `/quieter`
- Design system alignment: `/normalize`, `/extract`

## 21 Commands

| Command | What it does |
|---|---|
| `/teach-impeccable` | One-time setup: gather design context, save to project config |
| `/audit` | Technical quality checks (a11y, performance, responsive) — scores 5 dimensions with P0-P3 severity |
| `/critique` | UX design review — scores against Nielsen's 10 heuristics, persona archetypes, cognitive load |
| `/normalize` | Align with design system standards |
| `/polish` | Final pass before shipping |
| `/distill` | Strip to essence — remove unnecessary complexity |
| `/clarify` | Improve unclear UX copy and labels |
| `/optimize` | Performance improvements |
| `/harden` | Error handling, i18n, edge cases |
| `/animate` | Add purposeful motion |
| `/colorize` | Introduce strategic color |
| `/bolder` | Amplify boring designs |
| `/quieter` | Tone down overly bold designs |
| `/delight` | Add moments of joy |
| `/extract` | Pull into reusable components |
| `/adapt` | Adapt for different devices |
| `/onboard` | Design onboarding flows |
| `/typeset` | Fix typography: font choices, hierarchy, sizing, weight, readability |
| `/arrange` | Fix layout, spacing, visual rhythm, monotonous grids |
| `/overdrive` | Technically extraordinary effects: shaders, spring physics, scroll-driven reveals (beta) |

## 10 Reference Files

| Reference | Covers |
|---|---|
| `typography.md` | Type systems, font pairing, modular scales, OpenType |
| `color-and-contrast.md` | OKLCH, tinted neutrals, dark mode, accessibility |
| `spatial-design.md` | Spacing systems, grids, visual hierarchy |
| `motion-design.md` | Easing curves, staggering, reduced motion |
| `interaction-design.md` | Forms, focus states, loading patterns |
| `responsive-design.md` | Mobile-first, fluid design, container queries |
| `ux-writing.md` | Button labels, error messages, empty states |
| `cognitive-load.md` | Cognitive load theory, chunking, progressive disclosure |
| `heuristics-scoring.md` | Nielsen's heuristics scoring rubric and evaluation |
| `personas.md` | User persona archetypes for design critique |

## How to Use from OpenClaw

Delegate to Claude Code via acpx. Pass the target file/component and the command:

```bash
# Pre-ship QA pass (recommended sequence)
acpx --approve-all claude --cwd ~/bloom/frontend \
  'Run impeccable quality pass on [component/file]:
  1. /audit — check a11y, performance, responsive
  2. /critique — UX design review
  3. /polish — final pass
  Report issues found and fixes applied.'

# Targeted single command
acpx --approve-all claude --cwd ~/bloom/frontend \
  '/animate the [component] — add purposeful motion using the impeccable animate skill'

# Design system alignment
acpx --approve-all claude --cwd ~/bloom/frontend \
  '/normalize [component] to align with our design system tokens'
```

## Recommended Workflow

```
1. Build         → frontend-design skill (vision + direction)
2. QA            → /audit + /critique
3. Refine        → /polish + targeted commands as needed
4. Ship
```

## Anti-Patterns (Built-in to the Skill)

Impeccable explicitly tells the agent what NOT to do:
- Overused fonts (Arial, Inter, system defaults)
- Gray text on colored backgrounds
- Pure black/gray (always tint neutrals)
- Cards nested in cards
- Bounce/elastic easing (feels dated)
