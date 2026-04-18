---
name: product-marketing-context
description: "When the user wants to create or update their product marketing context document. Use at the start of any new project before using other marketing skills. Creates a context file that all other skills reference for product, audience, and positioning info."
metadata:
  version: 1.0.0
---

# Product Marketing Context

Help users create and maintain a product marketing context document. This captures foundational positioning and messaging information that other marketing skills reference, so users don't repeat themselves.

The document is stored at `.agents/product-marketing-context.md`.

## Workflow

### Step 1: Check for Existing Context

Check if `.agents/product-marketing-context.md` exists.

**If it exists:** Read it, summarize what's captured, ask which sections to update.

**If it doesn't exist, offer two options:**

1. **Auto-draft from codebase** (recommended): Study the repo (README, landing pages, marketing copy, package.json) and draft a V1. User reviews, corrects, fills gaps.

2. **Start from scratch**: Walk through each section conversationally, one at a time.

### Step 2: Gather Information

Push for verbatim customer language. Exact phrases are more valuable than polished descriptions because they reflect how customers actually think.

---

## Sections to Capture

### 1. Product Overview
- One-line description
- What it does (2-3 sentences)
- Product category (what "shelf" you sit on)
- Product type (SaaS, marketplace, e-commerce, service)
- Business model and pricing

### 2. Target Audience
- Target company type (industry, size, stage)
- Target decision-makers (roles, departments)
- Primary use case
- Jobs to be done (2-3 things customers "hire" you for)
- Specific use cases or scenarios

### 3. Personas (B2B only)
For each stakeholder: User, Champion, Decision Maker, Financial Buyer, Technical Influencer. What each cares about, their challenge, the value you promise.

### 4. Problems & Pain Points
- Core challenge before finding you
- Why current solutions fall short
- What it costs them (time, money, opportunities)
- Emotional tension (stress, fear, doubt)

### 5. Competitive Landscape
- **Direct competitors**: Same solution, same problem
- **Secondary competitors**: Different solution, same problem
- **Indirect competitors**: Conflicting approach
- How each falls short

### 6. Differentiation
- Key differentiators
- How you solve it differently
- Why that's better
- Why customers choose you over alternatives

### 7. Objections & Anti-Personas
- Top 3 objections and how to address them
- Who is NOT a good fit

### 8. Switching Dynamics (JTBD Four Forces)
- **Push**: Frustrations with current solution
- **Pull**: What attracts them to you
- **Habit**: What keeps them stuck
- **Anxiety**: What worries them about switching

### 9. Customer Language
- How customers describe the problem (verbatim)
- How they describe your solution (verbatim)
- Words/phrases to use and avoid
- Glossary of product-specific terms

### 10. Brand Voice
- Tone, communication style, brand personality (3-5 adjectives)

### 11. Proof Points
- Key metrics or results to cite
- Notable customers/logos
- Testimonial snippets

### 12. Goals
- Primary business goal
- Key conversion action
- Current metrics

---

## Document Template

```markdown
# Product Marketing Context

*Last updated: [date]*

## Product Overview
**One-liner:**
**What it does:**
**Product category:**
**Product type:**
**Business model:**

## Target Audience
**Target companies:**
**Decision-makers:**
**Primary use case:**
**Jobs to be done:**

## Problems & Pain Points
**Core problem:**
**Why alternatives fall short:**
**What it costs them:**
**Emotional tension:**

## Competitive Landscape
**Direct:** [Competitor] — falls short because...
**Secondary:** [Approach] — falls short because...

## Differentiation
**Key differentiators:**
**Why customers choose us:**

## Objections
| Objection | Response |
|-----------|----------|

## Customer Language
**How they describe the problem:** "[verbatim]"
**How they describe us:** "[verbatim]"
**Words to use:**
**Words to avoid:**

## Brand Voice
**Tone:**
**Style:**
**Personality:**

## Proof Points
**Metrics:**
**Customers:**

## Goals
**Business goal:**
**Conversion action:**
```

---

## Step 3: Confirm and Save

Show the completed document, ask for adjustments, save to `.agents/product-marketing-context.md`. Other marketing skills will reference this context automatically.

---

## Related Skills

- **competitive-analysis**: For deeper competitive research
- **brand-identity**: For visual and verbal brand identity
- **positioning-angles**: For positioning framework development
- **copywriting**: For writing copy using this context
