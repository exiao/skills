# Design Critique Reference

Use this during a design-focused dogfood pass — after the functional exploration — to evaluate the UI against established heuristics and produce a triage-ready design report section.

## When to Run

Run a design critique pass when:
- The session scope includes UI/UX quality (not just functional bugs)
- The user asks to "review the design" or "critique the UI"
- You want to go deeper than the visual scan in the standard exploration checklist

## 1. Heuristic Evaluation (Nielsen's 10)

Score each heuristic 1–5 (1 = major violation, 5 = fully satisfied). Cite a specific screen or element for each score.

| # | Heuristic | Score (1–5) | Evidence |
|---|-----------|-------------|----------|
| 1 | Visibility of system status — does the UI always keep users informed (loading states, confirmations, progress)? | | |
| 2 | Match between system and the real world — does it use language and concepts the user knows? | | |
| 3 | User control and freedom — can users undo, exit, or recover from mistakes easily? | | |
| 4 | Consistency and standards — do similar things look and behave the same throughout? | | |
| 5 | Error prevention — does the design prevent problems before they occur? | | |
| 6 | Recognition rather than recall — are options visible rather than requiring memory? | | |
| 7 | Flexibility and efficiency of use — does it work for both novice and expert users? | | |
| 8 | Aesthetic and minimalist design — does every element earn its place? | | |
| 9 | Help users recognize, diagnose, and recover from errors — are error messages clear and actionable? | | |
| 10 | Help and documentation — is contextual help available where users might need it? | | |

## 2. Visual Hierarchy

- What's the first thing a user sees on this screen? Is that the right thing?
- What's the CTA hierarchy? Is the primary action obvious?
- Are visual weights balanced, or is something competing for attention?
- Is there adequate white space, or does it feel cluttered?

## 3. Typography

- Do font choices match the brand's personality?
- Does the type scale create a clear hierarchy (display → headline → body → caption)?
- Are line lengths reasonable (45–75 characters is optimal)?
- Is contrast sufficient for readability everywhere?

## 4. Color

- Does the palette support the brand personality?
- WCAG AA compliance: 4.5:1 for normal text, 3:1 for large text and UI components
- Is color used meaningfully, or just decoratively?
- Does it hold up in both light and dark mode?

## 5. Usability

- Cognitive load: is there too much on screen at once?
- Interaction clarity: is it obvious what's clickable?
- Touch targets: minimum 44×44pt for interactive elements
- Form usability: label placement, inline validation, clear error states

## 6. Strategic Alignment

- Does the design serve the business goal for this screen?
- Does it serve the user's goal?
- Is the value proposition clear to a new user?
- Does it stand apart from competitor patterns, or blend in?

## 7. Prioritized Recommendations

Triage findings into three buckets:

**Critical — fix before launch:**
- [ ] _list issues here_

**Important — fix in next iteration:**
- [ ] _list issues here_

**Polish — nice to have:**
- [ ] _list issues here_

## Output

Add a `## Design Critique` section to the dogfood report after the issue list. Include:
- Heuristic scores table (filled in)
- Top 3 visual hierarchy findings
- Typography and color flags
- Triage table (Critical / Important / Polish)

Keep it punchy — this is input for a designer or PM, not a thesis.
