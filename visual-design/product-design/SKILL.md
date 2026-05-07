---
name: product-design
description: >
  Strategic product design thinking: information architecture, interaction
  design, AI-native patterns, and quality checklists. Use before building any
  interface to ensure the right thing gets built, not just built well.
  Triggers: "design an app", "plan this feature", "what should this screen do",
  "product design", "information architecture", "design thinking", "UX strategy",
  "app concept", "feature design", "what screens do we need", "user flow",
  "how should this work". For visual execution (code, CSS, motion), use
  frontend-design instead. For brand tokens, load ~/.hermes/VISUAL-IDENTITY.md if available.
---

# Product Design

Strategic design thinking before pixels. This skill answers "what to build and why" so that execution skills (frontend-design, impeccable) can answer "how to build it."

For specific brand tokens (fonts, colors, spacing scale), reference `~/.hermes/VISUAL-IDENTITY.md` if it exists. If unavailable, use sensible defaults or ask the user for brand guidance.

---

## 00 — Four Questions Before Designing

Stop. Answer these before any visual or structural decision.

**1. Who is the primary user and what is their mental model?**
Not a persona. A specific person with a specific job, vocabulary, and assumptions. What do they already know? What do they expect when they tap?

**2. What is the one job this interface exists to do?**
One. If you cannot name it in a single verb-object sentence ("review today's portfolio", "understand a stock's risk", "compare two ETFs"), the scope is not clear enough.

**3. What is the riskiest moment?**
Where a wrong action is irreversible, expensive, or embarrassing. Design around this first.

**4. What does success feel like to the user?**
Not conversion rate. The felt experience of accomplishment. Hold that as the north star.

---

## 01 — Structured Output for App Concepts

When generating an app concept or feature design, structure the response in this order:

1. **Product goal** — what problem this solves and for whom
2. **Primary user** — specific, not a persona category
3. **Core workflow** — the single path that matters most
4. **Information architecture** — structure and navigation logic
5. **Key screens / modules** — what each contains and why
6. **States and edge cases** — all eight states per component (see section 05)
7. **AI behaviour** — only if the product includes AI features (see section 06)
8. **Risks and recommendations** — what to build now vs. defer

---

## 02 — Product Framing

- Optimize for the **main job**, not for feature count.
- Prefer **one strong workflow** over multiple weak ones.
- Separate clearly:
  - what the user needs to **understand**
  - what the user needs to **do**
  - what the user only needs as **context**
- If scope is broad, define:
  - **MVP** — what ships first
  - **v1** — what comes after validation
  - **Future** — what requires more signal

Every element on screen must earn its place.

---

## 03 — Information Architecture

IA is the skeleton. Bad IA cannot be fixed with good UI.

### Content Hierarchy (strict order)

- **Level 1 — Identity**: What is this? Where am I?
- **Level 2 — Status**: What is the current state of things?
- **Level 3 — Action**: What can I do?
- **Level 4 — Context**: What do I need to know to act well?

Never invert this order. The most common IA failure is promoting Level 4 (context) above Level 3 (action), burying the thing the user came to do.

### Navigation

- Reflect the user's mental model of their tasks, not the product's internal architecture.
- Maximum primary nav items: 5-7. Beyond this, group.
- Active state must be unmistakable. Never rely on color alone.
- Every screen must answer: "Where am I?", "Where can I go?", "How do I get back?"

### Progressive Disclosure

- Default views show only what is needed for the primary action.
- Secondary options belong in overflow menus, drawers, or modals.
- Rule: if fewer than 30% of users need it in the first 30 seconds, hide it by default.

---

## 04 — Screen and Flow Design

For every proposed screen, define:

| Element | Question |
|---------|----------|
| **Purpose** | The single reason this screen exists |
| **Primary action** | The one thing the user should do here |
| **Secondary actions** | Available but not dominant |
| **Critical content** | Must be visible without scrolling |
| **Hidden by default** | What is deferred and where it lives |
| **After the action** | Next state, confirmation, redirect |

Prefer flows that are:
- Obvious on first use
- Reversible where possible
- Hard to misuse by accident
- Fast for repeat users
- Understandable without documentation

---

## 05 — The Eight States Checklist

For every component or view, design all eight states before calling it done:

1. **Empty** — nothing exists yet. This is an onboarding moment, not a blank void.
2. **Loading** — data is in transit. Match skeleton to expected loaded shape.
3. **Partial** — some data present, more coming.
4. **Populated** — the primary state. Usually the only one designed.
5. **Error** — fetch failed, action failed, input invalid. Must include resolution path.
6. **Disabled** — user lacks permission or action unavailable in context.
7. **Read-only** — data visible but not editable.
8. **Overflow** — 10x more data than expected. 1,000 rows. 80-character names. Failed image loads.

If you design only the populated state, you have designed less than 15% of the interface.

### Feedback Timing

| Duration | Response |
|----------|----------|
| < 100ms | Instant. Every action must produce visible feedback within this window. |
| < 1s | Subtle indicator on the element itself (button spinner, shimmer). No full-screen loader. |
| 1-5s | Progress with estimate. Keep user in context. |
| > 5s | Background the task, notify on completion. |

### Error Design

- **Prevent before catch**: constraints, validation, confirmation patterns.
- **Be specific**: "We couldn't save your changes. Your session expired. Sign in again and your draft will be restored."
- **Point to resolution**: every error must contain or link to a fix. Never a dead end.
- **Preserve work**: never lose a partial form or draft on error. Auto-save aggressively.

### Affordances

- Interactive elements must look interactive. Clickable ≠ readable.
- Hover states mandatory on desktop.
- Touch targets: minimum 44x44px on mobile. No exceptions.

---

## 06 — AI-Native Interface Patterns

AI features introduce states that do not exist in traditional software. Design them explicitly.

### Trust and Transparency

- **Show basis for output**: data source, timeframe, sample size. Even one metadata line ("Based on 47 transactions, Sep-Nov 2024") dramatically increases trust.
- **Confidence signals**: definitive outputs look different from suggestions. Use visual weight, not just labels.
- **Never fake certainty**: uncertain model = uncertain UI. A confident interface over an uncertain model is a liability.

### Streaming and Generation

- Streaming text must not cause layout reflow. Reserve space before content arrives.
- Show generation indicator (cursor, pulse, shimmer). Not a full-screen loader.
- Allow interruption at any point.
- Distinguish AI-produced content from user-produced content visually.

### AI Input Design

- The prompt input is a product surface, not a text field. Design with weight.
- Provide example prompts, suggested actions, or guided templates for new users.
- Voice, image, file inputs should feel first-class.
- Show length constraints only when approaching the limit.

### Human-in-the-Loop

- Irreversible or high-consequence actions require explicit confirmation regardless of AI confidence.
- Confirmation dialogs: describe the action specifically. Never "Are you sure?" Always "This will permanently delete 14 client records. This cannot be undone."
- **Preview before commit**: show what AI intends to do.
- **Edit before apply**: AI content editable before it affects state.

### Graceful Degradation

- AI features must degrade gracefully when model is slow, rate-limited, or unavailable.
- Fallback states must be designed, not generic error messages.
- Core product must remain usable when AI is down.

### AI Anti-Patterns

- **The blank oracle**: chat interface with no guidance or structure.
- **Silent failure**: returns nothing or garbage with no explanation.
- **Overexposed infrastructure**: token counts, model names, temperature visible to end users.
- **Magic without feedback**: AI acts without explaining what or why.
- **Generic AI aesthetic**: purple gradient on white, confident UI over uncertain output.

---

## 07 — Anti-Patterns (Avoid Always)

### Structural
- **Card cemetery**: grid of equal-weight cards. Use hierarchy.
- **Sidebar overload**: 20+ nav items = feature list, not navigation.
- **Modal cascade**: modal opening modal = needs a full page or drawer.
- **Orphaned empty state**: empty list with no CTA. Every empty state is onboarding.
- **Settings graveyard**: dumping ground for everything that didn't fit.

### Interaction
- Hover states that cause reflow.
- Form submission that loses data on error.
- Destructive actions without confirmation.
- Full-page loaders for non-blocking operations.
- Success states that vanish before readable (minimum 3 seconds).
- Tooltips as sole source of critical info (inaccessible on touch).

### Copy
- Buttons that describe the system, not the user: "Submit" → "Save changes"
- Error messages that apologize without helping: "An error occurred" → "We couldn't connect. Check your internet connection and try again."
- Placeholder text used as label (disappears on input).
- Marketing copy inside the product. The user is already inside.

---

## 08 — Quality Bar

Run this checklist before any interface is considered complete.

### Functional
- [ ] All eight component states designed
- [ ] Every error state has a resolution path
- [ ] Destructive actions have confirmation
- [ ] Forms auto-save or warn on unsaved exit
- [ ] All interactive elements keyboard-navigable

### Information Architecture
- [ ] Primary action visible without scrolling
- [ ] Navigation reflects user task model, not product architecture
- [ ] Empty states include a call to action
- [ ] Content hierarchy follows Level 1-4 order

### AI-Specific (if applicable)
- [ ] AI outputs have visible basis or source signal
- [ ] Streaming content does not cause layout reflow
- [ ] Generation can be interrupted
- [ ] High-consequence AI actions require explicit confirmation
- [ ] Graceful degradation state designed

### Accessibility
- [ ] All text meets WCAG AA contrast (4.5:1)
- [ ] Focus states visible and unambiguous
- [ ] Interactive elements have accessible labels
- [ ] Motion respects `prefers-reduced-motion`
- [ ] Touch targets >= 44x44px on mobile

### Copy
- [ ] Every button label describes the user's action
- [ ] Every error message includes a resolution path
- [ ] No placeholder text used as field label
- [ ] No marketing language inside the product UI

---

## When to Use Other Skills

| Need | Skill |
|------|-------|
| Build the UI (code, CSS, motion) | frontend-design |
| Brand tokens (fonts, colors, spacing) | ~/.hermes/VISUAL-IDENTITY.md (optional) |
| Design token spec file (DESIGN.md) | design-md |
| Apple platform conventions | apple-ux-guidelines |
| Design QA and polish | impeccable |
