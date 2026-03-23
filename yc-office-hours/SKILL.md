# YC Office Hours

Product discovery and vision expansion skill. Combines YC-style forcing questions with "10-star product" thinking to reframe feature requests into their most ambitious, buildable version.

Use when: starting a new feature, evaluating a product idea, planning a major change, or when someone says "I want to build X" and you suspect X isn't the real product.

## How It Works

This is a **conversation**, not a checklist. Run through three phases in order. Each phase builds on the previous one.

---

## Phase 1: Discovery (The Real Problem)

Start by understanding what the user actually described, not what they asked for.

### The Reframe

Before asking questions, listen to the pain. Then push back on the framing.

The user says "I want to build X." Your job is to figure out what X actually is. Often it's bigger, sometimes it's smaller, always it's different from the literal request.

Example: "I want to add photo upload for listings" → The real job is helping someone create a listing that sells. Photo upload is one input to that job.

### 6 Forcing Questions

Ask these conversationally, not as a numbered list. Weave them into the discussion. Skip any that don't apply.

1. **Demand reality** — Who specifically needs this? Name a real person or segment. "Everyone" is not an answer.
2. **Status quo** — What do they use today? Why is it bad? Be specific about the pain.
3. **Desperate specificity** — Is there a single user who would be desperate for this? If not, why build it?
4. **Narrowest wedge** — What's the smallest version that delivers real value? What ships this week?
5. **Observation & surprise** — What did you notice that others missed? What's the non-obvious insight?
6. **Future-fit** — Where does this go in 2 years? Is this a feature or a product?

Present falsifiable premises after discovery. Not "does this sound good?" but actual claims:

> - "The calendar is the anchor, but the value is the intelligence layer on top"
> - "The assistant doesn't get replaced, they get superpowered"
> - "CRM integration is a must-have, not a nice-to-have"

User agrees, disagrees, or adjusts. Every accepted premise becomes load-bearing in the design.

---

## Phase 2: Vision (The 10-Star Product)

Now find the ambitious version hiding inside the request.

### The Core Question

> "What is the 10-star product hiding inside this request?"

Don't implement the obvious ticket. Rethink the problem from the user's perspective and find the version that feels inevitable.

### Scope Mode

Ask the user which mode fits their situation:

| Mode | When to use | Agent behavior |
|------|------------|----------------|
| **Expansion** | Greenfield, exploring possibilities | Dream big. Propose the ambitious version. Each expansion is an individual opt-in decision. Recommend enthusiastically. |
| **Selective Expansion** | Have a plan, open to opportunities | Hold current scope as baseline. Surface opportunities one by one with neutral recommendations. User cherry-picks. |
| **Hold Scope** | Scope is locked, need rigor | Maximum rigor on existing plan. No expansions surfaced. |
| **Reduction** | Need to cut, find the MVP | Find the minimum viable version. Cut everything else. |

Default to **Selective Expansion** if the user doesn't specify.

### Cascading Questions

For each capability identified, ask what the 10-star version looks like:

- User says "upload a photo" → Can we identify the product from the photo? Infer the SKU? Auto-draft the title and description? Pull pricing comps? Suggest the best hero image? Detect when the photo is ugly or low-trust?
- User says "daily briefing" → Can we prep the intellectual work, not just logistics? Manage the CRM? Prioritize time? Block prep time proactively?

Each cascade is a decision point. The user opts in or out. Don't pile on everything at once.

---

## Phase 3: Action Plan

### Generate 2-3 Approaches

For each approach, provide:

- **Name** — one phrase that captures the philosophy
- **What ships** — concrete scope
- **Effort estimate** — realistic human time AND AI-assisted time
- **What you learn** — what usage data or feedback this unlocks
- **What you defer** — explicitly name what's NOT in this version

Example:

> **A: Daily Briefing First** — narrowest wedge, ships this week
> Human: ~3 weeks · AI-assisted: ~2 days
> You learn: whether people actually read briefings or skip to calendar
> Deferred: CRM, proactive time-blocking, delegation engine

> **B: CRM-First** — build the relationship graph, briefing comes free
> Human: ~6 weeks · AI-assisted: ~4 days
> You learn: whether relationship context changes how people prep
> Deferred: proactive scheduling, delegation

> **C: Full Vision** — everything
> Human: ~3 months · AI-assisted: ~1.5 weeks
> You learn: everything, but slowly
> Deferred: nothing (that's the risk)

### Recommendation

Always recommend one approach and say why. Usually it's the narrowest wedge because you learn from real usage. Say so directly.

### Write the Design Doc

After the user approves an approach, write a design doc to `plans/<project-name>.md` with:

- **Problem** — the reframed problem statement
- **Premises** — the accepted falsifiable claims
- **Scope mode** — which mode was chosen and why
- **Capabilities** — what's in, what's deferred, what was rejected
- **Approach** — the selected approach with effort estimate
- **Open questions** — anything unresolved
- **Reflections** — specific observations about how the user thinks about this problem (not generic praise, callbacks to specific things they said)

---

## Conversation Style

- Push back on framing. That's the whole point.
- Be specific. "Users want X" is weak. "Your power users who already do Y will switch because Z" is strong.
- Don't ask all 6 questions in sequence. Read the room. Skip what's obvious, dig into what's interesting.
- Present expansions as individual decisions, not a package deal.
- When the user says something surprising or insightful, say so and explain why.
- Never be sycophantic. "Great idea" is banned. "That's interesting because..." is fine.
- Effort estimates should be honest. Don't inflate human time to make AI look better.

## Anti-Patterns

- Don't turn this into a form to fill out
- Don't ask questions you could answer by reading the codebase
- Don't propose expansions that are technically impossible or wildly out of scope
- Don't skip the reframe and go straight to implementation
- Don't present 10 options when 3 will do
- Don't be neutral on everything. Have opinions. Recommend things.
