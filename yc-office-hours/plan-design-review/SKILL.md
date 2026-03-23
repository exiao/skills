# Plan Design Review

Interactive design review for plans and specs, before any code is written. Rates each design dimension 0-10, explains what a 10 looks like, then edits the plan to close the gap.

Use when: a plan or spec exists and you want to catch missing UI states, vague layouts, AI slop risk, and unresolved design decisions before implementation. Works on any plan file, not just ones from yc-office-hours.

## How It Works

This is an interactive review. For each dimension, rate it, explain what excellence looks like, then fix the plan or ask the user to make a design choice. One issue at a time (don't dump a wall of findings).

---

## Initial Rating

Read the plan. Give an honest overall design score (0-10) with a one-paragraph explanation of why. Be blunt.

Example:
> **Initial Design Rating: 4/10**
> This plan describes a user dashboard but never specifies what the user sees first. It says "cards with icons," which looks like every SaaS template. It mentions zero loading states, zero empty states, and no mobile behavior.

---

## 7 Review Passes

Work through each pass in order. For each:
1. Rate the dimension 0-10
2. Describe what a 10 looks like for this specific plan
3. Fix obvious gaps directly in the plan
4. For genuine tradeoffs, ask the user to decide (one question at a time)

### Pass 1: Information Architecture
- Is there a clear content hierarchy (primary / secondary / tertiary) for every screen?
- What's the most important thing on each page? Is it visually dominant?
- Does the navigation structure match how users think about the product?

### Pass 2: Interaction State Coverage
For every UI feature, check all 5 states:
- **Empty** — what does the user see before any data exists?
- **Loading** — what happens while data is being fetched?
- **Partial** — what if there's some data but not all?
- **Error** — what does the user see when something breaks?
- **Ideal** — what does the full, working state look like?

Count them: `[number of features] × 5 = [total states needed]`. How many does the plan specify? Report the gap.

### Pass 3: User Journey
- What's the first thing a new user sees?
- What's the path from landing to core value?
- Where can a user get stuck or confused?
- Are there dead ends (pages with no clear next action)?

### Pass 4: AI Slop Risk
Flag patterns that scream "AI-generated template":
- "Clean, modern UI with cards and icons"
- Hero sections with gradients
- 3-column icon grids
- Uniform border-radius on everything
- Generic stock-photo-style imagery descriptions
- "Sleek" / "intuitive" / "seamless" as design specs

For each one found, propose a specific, intentional alternative.

### Pass 5: Design System Alignment
- Does the plan reference an existing design system? If yes, does it follow it?
- If no design system exists, does the plan at least specify: colors, typography, spacing, component patterns?
- Are UI descriptions specific enough to implement without guessing?

### Pass 6: Responsive & Accessibility
- Does the plan specify behavior at mobile, tablet, and desktop breakpoints?
- Are touch targets large enough (44px minimum)?
- Is there sufficient color contrast?
- Does the plan mention keyboard navigation, screen readers, or focus management?
- Does `prefers-reduced-motion` need consideration?

### Pass 7: Unresolved Design Decisions
- Are there any "TBD" or vague sections in the plan?
- Are there places where two reasonable approaches exist and nobody picked one?
- List every unresolved decision. Ask the user to resolve each one.

---

## Scoring & Re-runs

After all passes, give a final score.

```
Pass                          Before  After
Information Architecture      3/10    8/10
Interaction State Coverage    2/10    7/10
User Journey                  5/10    8/10
AI Slop Risk                  4/10    9/10
Design System Alignment       6/10    7/10
Responsive & Accessibility    3/10    6/10
Unresolved Decisions          1/10    8/10
─────────────────────────────────────────
Overall                       4/10    7/10
```

On re-runs, passes already at 8+ get a quick confirmation. Passes below 8 get full treatment.

---

## Conversation Style

- One finding at a time. Don't overwhelm with a list of 20 problems.
- Fix the obvious stuff silently. Only ask about genuine tradeoffs.
- Be specific. "The empty state needs work" is useless. "When a user has zero transactions, they see a blank white page with no guidance on what to do next" is actionable.
- Rate honestly. A 4 is a 4. Don't give 7s to be nice.
- When describing what a 10 looks like, reference real products when possible.

## Anti-Patterns

- Don't redesign the product. You're reviewing the plan's design completeness, not proposing a different product.
- Don't add features disguised as design feedback.
- Don't skip passes because "it's fine." Rate it and move on quickly if it is.
- Don't give generic feedback that applies to any plan. Every comment should reference something specific in this plan.
