---
name: outline-generator
description: Use when generating structured article outlines from approved headlines.
---

# Outline Generator Skill

Generate 3 structured outline variants with different angles for any article/blog post topic. Takes an approved headline from the headlines skill and produces detailed outlines with section structures, word count estimates, image placement markers, and a comparison matrix — ready for the human to pick or hybridize.

## Scope

**This skill does:** Outline structure and variant generation only.

**This skill does NOT do:**
- SEO keyword research → `seo-research` skill
- Headline/title generation → `headlines` skill
- Actual article writing → `article-writer` skill
- Image/diagram creation → `image-generator` skill

## Inputs

| Input | Source | Required |
|-------|--------|----------|
| Topic / subject | Human or project brief | Yes |
| Approved title + subtitle | `headlines` skill output | Yes |
| Target word count | Human (default: 1,500–2,500) | No |
| Target audience notes | Human or `seo-research` brief | No |

## Process

### 1. Receive Topic + Approved Headlines
Pull the approved title/subtitle from the headlines skill output (typically in `marketing/substack/drafts/[slug]/headlines.md`). Confirm topic scope and any angle preferences with the human.

### 2. Generate 3 Variant Outlines
Each variant uses a **different structure** from the structure menu below. Pick the 3 most fitting for the topic — don't force a structure that doesn't serve the content.

Each variant includes:
- **Structure type** label
- **Full section outline** with H2 headings
- **Key points** (3–5 bullets) per section
- **Word count estimate** per section and total
- **Image/diagram placement markers** per the image rules below
- **AI citability block marker** (direct answer paragraph near top)
- **Opening hook** concept (1–2 sentences)
- **Closing CTA** concept

### 3. Build Comparison Matrix
Rate each variant (Low / Medium / High) across:

| Dimension | What it measures |
|-----------|-----------------|
| **Emotional arc** | Does it build feeling? Peaks and valleys? |
| **Actionability** | Can the reader DO something after each section? |
| **Shareability** | Would someone screenshot or forward a section? |
| **SEO strength** | Does the structure naturally accommodate target keywords? |

### 4. Create ASCII Wireframe
For each variant, produce an ASCII wireframe showing the full article layout (see format below).

### 5. Present for Selection
Show all 3 variants with the comparison matrix. Human picks one, combines elements from multiple, or requests a new angle. Iterate until approved.

## Structure Menu

Pick 3 per article. Options:

| Structure | Shape | Best for |
|-----------|-------|----------|
| **Chronological narrative** | Timeline: past → present → future | Origin stories, market evolution, "how we got here" |
| **Framework-first** | Method → proof → application | Strategies, mental models, "here's how to think about X" |
| **Results-first** | Numbers/outcome → how → why it matters | Case studies, performance posts, data-driven pieces |
| **Comparison piece** | Option A vs B vs C → verdict | Reviews, tool evaluations, "which approach wins" |
| **Provocative** | Tear down status quo → build up alternative | Hot takes, myth-busting, contrarian angles |
| **Builder's journey** | Personal narrative → lessons → reader application | Personal finance stories, founder journeys |
| **Technical deep-dive** | Concept → mechanics → edge cases → practical use | Explainers, "how X actually works" |

## Section Structure Rules

Every section follows these rules:

- **H2 headings every 300–400 words.** No section exceeds 400 words without a subheading break.
- **Mini-hook opening.** Each section starts with a line that creates tension, curiosity, or stakes. Not a summary — a hook.
- **"But, so" transitions.** Sections connect with "but" (tension/contradiction) or "so" (consequence/momentum) logic. Never "and" (additive/flat). The reader should feel *pulled* forward, not *walked* forward.
- **Open loop endings.** End each section with an unresolved question, a tease, or a "half the picture" moment that makes the next section feel necessary.
- **AI citability block.** Include a 40-60 word direct answer block near the top of the article and mark it in the outline

### Example section skeleton:
```
## H2: [Hook-style heading]
  ↳ Mini-hook opening (1–2 sentences, tension or curiosity)
  ↳ Key point 1
  ↳ Key point 2
  ↳ Key point 3
  ↳ Open loop → next section
  [~350 words]
```

## Image Placement Rules

- **Hero image** above the fold (before first H2)
- **Diagram, screenshot, or image** every 2–3 sections
- **Never exceed 500 words** without a visual break
- Mark placements with tags:
  - `[IMAGE: description of what to show]`
  - `[DIAGRAM: description of what to illustrate]`
  - `[SCREENSHOT: description of what to capture]`
- Image descriptions should be specific enough for the `image-generator` skill to execute without guessing

## ASCII Wireframe Format

Each variant gets a wireframe like this:

```
┌─────────────────────────────────────┐
│         [IMAGE: Hero — ...]         │  ← above fold
├─────────────────────────────────────┤
│  H1: Title                          │
│  H2: Subtitle                       │
│  Byline · Date · Read time          │
├─────────────────────────────────────┤
│  § Intro / Hook          (~200 w)   │
│  Open loop → §1                     │
├─────────────────────────────────────┤
│  §1: [Heading]           (~350 w)   │
│  • Key point A                      │
│  • Key point B                      │
│  • Key point C                      │
│  Open loop → §2                     │
├─────────────────────────────────────┤
│  §2: [Heading]           (~350 w)   │
│  • Key point A                      │
│  • Key point B                      │
│     [DIAGRAM: ...]                  │
│  Open loop → §3                     │
├─────────────────────────────────────┤
│  §3: [Heading]           (~350 w)   │
│  • Key point A                      │
│  • Key point B                      │
│  Open loop → §4                     │
├─────────────────────────────────────┤
│     [IMAGE: ...]                    │  ← visual break
├─────────────────────────────────────┤
│  §4: [Heading]           (~350 w)   │
│  • Key point A                      │
│  • Key point B                      │
│  • Key point C                      │
│  Open loop → Close                  │
├─────────────────────────────────────┤
│  § Closing / CTA         (~150 w)   │
│  Call to action                     │
├─────────────────────────────────────┤
│  TOTAL                  ~1,750 w    │
│  Images: 3  Diagrams: 1            │
└─────────────────────────────────────┘
```

Adapt the number of sections and visuals to the target word count. The wireframe is the **single-glance view** of the whole article.

## Output

Save to: `marketing/substack/drafts/[slug]/outline-variants.md`

Structure of the output file:

```markdown
# Outline Variants: [Title]

**Topic:** ...
**Approved title:** ...
**Approved subtitle:** ...
**Target word count:** ...
**Date generated:** YYYY-MM-DD

---

## Variant A: [Structure Type]

### Wireframe
[ASCII wireframe]

### Section Outline
[Full section-by-section outline]

---

## Variant B: [Structure Type]

### Wireframe
[ASCII wireframe]

### Section Outline
[Full section-by-section outline]

---

## Variant C: [Structure Type]

### Wireframe
[ASCII wireframe]

### Section Outline
[Full section-by-section outline]

---

## Comparison Matrix

| Dimension | Variant A | Variant B | Variant C |
|-----------|-----------|-----------|-----------|
| Emotional arc | ... | ... | ... |
| Actionability | ... | ... | ... |
| Shareability | ... | ... | ... |
| SEO strength | ... | ... | ... |

---

## Recommendation

[Brief note on which variant fits best and why, or suggested hybrid]

---

**Status:** Awaiting human selection
**Next step:** → `article-writer` skill with approved outline
```

## Downstream Handoff

Once the human approves a variant (or hybrid):
1. Mark status as `Approved` in the outline file
2. The approved outline feeds into `article-writer` for drafting
3. Image/diagram markers feed into `image-generator` for visual creation
