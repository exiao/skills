---
name: design-review
description: Run a product design review on a feature or site. Answers 13 design questions, runs Nielsen Norman heuristic evaluation, builds before/after visual fixes, and deploys a shareable report to Surge. Use when asked to review a design, audit UX, do a design review, or analyze a product's user experience.
---

# Design Review

Run a full product design review. Walk through the product as a first-time user, answer 13 design questions, run a heuristic evaluation, and deploy a shareable before/after report to Surge.

## Inputs

| Parameter | Required | Description |
|-----------|----------|-------------|
| **URL or feature** | Yes | A live URL, local HTML file, or description of the feature to review |
| **Context** | No | Any additional context about the product, audience, or goals |

Start immediately with defaults. Do not ask clarifying questions. Make your best assumptions for anything you don't know.

## Workflow

### 1. Walk Through as a New User

Open the URL in the browser. Navigate screen by screen, taking screenshots. React to what you see out loud:

- What am I being asked to do?
- Is it clear WHY I'd do it?
- Where would I get confused or frustrated?
- What would I expect to happen next?

Pay special attention to:
- **Time to wow:** How quickly does a new user think "this is why I came here"?
- **Dead ends:** Places where the user finishes something and there's no clear next step.
- **Empty states:** Screens that look broken when there's no data yet.

### 2. Answer the 13 Design Questions

For each question, provide a specific answer based on what you observed. Do not ask the user. Make your best assumption.

1. **What is the objective of this feature?** What problem does it solve? What outcome does it drive?
2. **Who is this for?** Specific user persona, not "everyone."
3. **When and why would they use it?** The trigger moment. What just happened that brings them here?
4. **What are they thinking about?** Their mental state, concerns, expectations when they arrive.
5. **How did they get here?** The previous step in their journey. What screen or action preceded this?
6. **What do we want users to feel?** The emotional response we're designing for.
7. **What would they do without this feature?** The alternative. Manual workaround, competitor, nothing?
8. **What do they do next?** The next step after using this feature. Is it clear?
9. **Are we confident this is better than what already exists?** Compared to the current state or competitors.
10. **What can we remove to have it work just as well?** Strip to the essential. What's decorative vs functional?
11. **If we throw away our constraints, would we still design it this way?** Imagine unlimited time and resources.
12. **Will most users realize the value of this feature?** Is the benefit obvious or hidden?
13. **Is this for user growth, engagement, or retention?** Which metric does this primarily serve?

Use ASCII diagrams to visualize the user journey where it helps paint the picture.

### 3. Nielsen Norman Heuristic Evaluation

Evaluate against all 10 heuristics. For each one, give a pass/fail with specific evidence:

1. **Visibility of system status** — Does the user always know what's happening?
2. **Match between system and real world** — Does it use language and concepts the user knows?
3. **User control and freedom** — Can users undo, go back, escape?
4. **Consistency and standards** — Does it follow platform conventions?
5. **Error prevention** — Does it prevent mistakes before they happen?
6. **Recognition rather than recall** — Are options visible, not memorized?
7. **Flexibility and efficiency of use** — Are there shortcuts for power users?
8. **Aesthetic and minimalist design** — Is every element earning its place?
9. **Help users recognize, diagnose, and recover from errors** — Are error messages useful?
10. **Help and documentation** — Is guidance available when needed?

### 4. Identify Top 3 Issues

From the walkthrough and heuristic evaluation, pick the 3 highest-impact issues. For each:

- **What to fix:** Plain language description.
- **Why it matters:** Tie it back to a specific heuristic violation or design question answer.
- **Expected impact:** What changes if you fix this.

### 5. Build the Before/After Report

For each issue, build two HTML renders side by side:

- **Before:** Recreate the current state of the problem area in code.
- **After:** Show the visual fix in code.

These are rebuilt in HTML, not screenshots. Both versions should be crisp and consistent.

Package everything into a single Surge page:

```
┌─────────────────────────────────┐
│  [Product Name] Design Review   │
│  Date · URL                     │
├─────────────────────────────────┤
│  Summary                        │
│  13 Design Questions (answered) │
│  Heuristic Scorecard            │
│  Issue 1: Before / After        │
│  Issue 2: Before / After        │
│  Issue 3: Before / After        │
└─────────────────────────────────┘
```

### 6. Deploy

```bash
npx surge . [product-name]-design-review.surge.sh
```

Share the URL with the user.

## Output

A single shareable URL containing:
- Design question answers with user journey visualization
- Heuristic evaluation scorecard
- Before/after visual comparisons for the top 3 issues
- Specific, actionable recommendations tied to evidence

## Notes

- Make your best assumptions. Do not ask the user to answer the 13 questions. You answer them based on observation.
- Be specific and constructive. Not "improve onboarding" but "add a welcome screen that asks what the user wants to accomplish."
- The report should be presentation-ready. A PM could send it to stakeholders without explanation.
- For local HTML files, open them in the browser. Do not read source code.
