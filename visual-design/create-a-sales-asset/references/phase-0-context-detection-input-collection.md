# Phase 0: Context Detection & Input Collection

### Step 0.1: Identify Seller Context

If not already known from user context, ask:
1. "What company/product is this for?"
2. "What do you sell? (one line)"

Store for reuse:
```yaml
seller:
  company: "[Company Name]"
  product: "[Product/Service]"
  value_props:
    - "[Key value prop 1]"
    - "[Key value prop 2]"
    - "[Key value prop 3]"
  differentiators:
    - "[Differentiator 1]"
    - "[Differentiator 2]"
  pricing_model: "[If publicly known]"
```

On subsequent invocations, confirm: "I have your seller context from last time. Still selling [Product] at [Company]?"

---

### Step 0.2: Collect Prospect Context (a)

| Field | Prompt | Required |
|-------|--------|----------|
| **Company** | "Which company is this asset for?" | ✓ |
| **Key contacts** | "Who are the key contacts? (names, roles)" | No |
| **Deal stage** | "What stage is this deal?" | ✓ |
| **Pain points** | "What pain points or priorities have they shared?" | No |
| **Past materials** | "Upload any conversation materials (transcripts, emails, notes)" | No |

Deal stage options: Intro / Discovery / Evaluation / POC / Negotiation / Close

---

### Step 0.3: Collect Audience Context (b)

| Field | Prompt | Required |
|-------|--------|----------|
| **Audience type** | "Who's viewing this?" | ✓ |
| **Specific roles** | "Any specific titles to tailor for?" | No |
| **Primary concern** | "What do they care most about?" | ✓ |
| **Objections** | "Any concerns or objections to address?" | No |

Audience types: Executive / Technical / Operations / Mixed

Primary concerns: ROI / Technical depth / Strategic alignment / Risk mitigation / Timeline

---

### Step 0.4: Collect Purpose Context (c)

| Field | Prompt | Required |
|-------|--------|----------|
| **Goal** | "What's the goal of this asset?" | ✓ |
| **Desired action** | "What should the viewer do after seeing this?" | ✓ |

Goals: Intro / Discovery follow-up / Technical deep-dive / Executive alignment / POC proposal / Deal close

---

### Step 0.5: Select Format (d)

| Format | Description | Best For |
|--------|-------------|----------|
| **Interactive landing page** | Multi-tab page with demos, metrics, calculators | Exec alignment, intros, value prop |
| **Deck-style** | Linear slides, presentation-ready | Formal meetings, large audiences |
| **One-pager** | Single-scroll executive summary | Leave-behinds, quick summaries |
| **Workflow demo** | Interactive diagram with animated flow | Technical deep-dives, POC demos |

---

### Step 0.6: Format-Specific Inputs (Workflow Demo)

If workflow demo selected, parse from user's description. Look for systems, components, data flows, human touchpoints, example scenarios. Ask for any gaps:

| If Missing... | Ask... |
|---------------|--------|
| Components unclear | "What systems or components are involved?" |
| Flow unclear | "Walk me through the step-by-step flow" |
| Human touchpoints unclear | "Where does a human interact?" |
| Scenario vague | "What's a concrete example scenario?" |

---
