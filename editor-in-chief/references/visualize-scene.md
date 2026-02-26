---
name: visualize-scene
description: Simulate famous directors, designers, or visual thinkers describing how they'd visualize a section of content. Use to brainstorm image concepts, diagram ideas, and visual storytelling approaches for articles.
---

# Visualize Your Scene

Inspired by Sudowrite's plugin (1.8k users). Give it a section of text and get back multiple expert perspectives on how to visualize it — as if famous directors, designers, or visual thinkers were art-directing your article.

## How It Works

Feed in a passage of text. The skill evaluates the content type and summons three relevant visual thinkers to describe how they'd illustrate it.

## Process

### Step 1 — Evaluate the Content

Read the passage and determine:
- **Content type**: data/stats, concept/framework, process/workflow, narrative/story, comparison, tutorial/how-to
- **Emotional tone**: serious, playful, urgent, contemplative, triumphant
- **Key visual elements**: numbers, relationships, sequences, contrasts, metaphors

### Step 2 — Pick Three Visual Thinkers

Based on the content type, choose three relevant perspectives:

**For data/stats content:**
- Edward Tufte (data visualization purist — minimal, high-density, no chartjunk)
- Hans Rosling (animated, narrative-driven data storytelling)
- Giorgia Lupi (data humanism — hand-drawn, personal, artistic)

**For concept/framework content:**
- Richard Feynman (simple diagrams that make complex ideas obvious)
- Tim Urban (Wait But Why stick figures and absurd visual metaphors)
- Bret Victor (interactive, explorable explanations)

**For process/workflow content:**
- Dieter Rams (clean, functional, nothing unnecessary)
- IDEO (human-centered design thinking, journey maps)
- Miyazaki (rich, layered worlds where the process feels alive)

**For narrative/story content:**
- Wes Anderson (symmetrical, color-coded, whimsical)
- David Fincher (dark, precise, information-dense frames)
- Spielberg (emotional close-ups, light as storytelling)

**For comparison content:**
- Tufte (small multiples, side-by-side)
- Nolan (parallel timelines, structural juxtaposition)
- McCloud (comic-panel sequential art)

**For tutorial/how-to content:**
- IKEA instruction designers (wordless, step-by-step, universal)
- Kurzgesagt (friendly, colorful, makes complex things approachable)
- Randall Munroe / xkcd (whiteboard diagrams with humor)

### Step 3 — Generate Three Visions

Each thinker describes:
1. **The visual** — what exactly they'd create (image, diagram, chart, screenshot, illustration)
2. **The medium** — Excalidraw diagram, AI-generated image (Nano Banana Pro), screenshot, photo, chart
3. **The composition** — layout, colors, focal point, relationship to text
4. **Why it works** — what it communicates that words alone can't

### Step 4 — Recommend

Pick the best vision (or combine elements from multiple) and produce:
- A concrete image brief for the **image-generator** skill
- Alt text for SEO
- Placement recommendation (above fold, inline, full-width)

## Output Format

```markdown
## Visual Scene: [passage summary]

### Content Analysis
- Type: [data/concept/process/narrative/comparison/tutorial]
- Tone: [emotional tone]
- Key visual elements: [what needs to be shown]

### Vision 1: [Thinker Name]
**Visual:** [description]
**Medium:** [Excalidraw / Nano Banana Pro / screenshot / chart]
**Composition:** [layout details]
**Why:** [what it adds]

### Vision 2: [Thinker Name]
**Visual:** [description]
**Medium:** [tool]
**Composition:** [layout]
**Why:** [what it adds]

### Vision 3: [Thinker Name]
**Visual:** [description]
**Medium:** [tool]
**Composition:** [layout]
**Why:** [what it adds]

### Recommendation
**Go with:** Vision [X] because [reason]
**Image brief for image-generator:**
> [concrete description of what to create]
**Alt text:** [SEO-friendly description]
**Placement:** [above fold / after ¶X / full-width]
```

## Example

**Input passage:**
> "Energy's current ~3% weighting in the S&P 500 is near an all-time low. At its peak in the early 1980s and again before the 2008 financial crisis, energy represented ~15% of the index."

**Vision 1 — Edward Tufte:**
A sparkline-style area chart showing energy's S&P weighting from 1980 to 2026. No gridlines, no legend clutter. Just the shape of the decline with two labeled peaks (1980: 15%, 2008: ~13%) and today's trough (3.3%). The visual story is the collapse itself.

**Vision 2 — Tim Urban:**
A stick-figure diagram where a tiny figure labeled "Energy" stands next to a massive figure labeled "Apple." Caption: "The entire industry that powers the global economy vs. one phone company." Scale exaggeration makes the absurdity visceral.

**Vision 3 — Giorgia Lupi:**
A hand-drawn circular chart where energy's 3.3% is a thin sliver, with small annotations showing what fills the rest — tech at 30%+, each FAANG company individually larger than all of energy combined. Personal, warm, annotated.

**Recommendation:** Vision 2 (Tim Urban style) — the absurdity of the comparison is the whole point of the passage. Create as an Excalidraw diagram with stick figures and exaggerated scale.

## References

- Feeds into **image-generator** (provides the image brief)
- Used during **article-writer** drafting or revision
- Can also be used standalone for social media visuals
