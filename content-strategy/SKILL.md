---
name: content-strategy
description: "Use when building content strategy: hooks, angles, and ideas from what's trending now. Covers organic and paid creative across TikTok, X, YouTube, Meta, LinkedIn."
---

# Content Strategy

## Purpose

Turn zeitgeist signals into content that connects — then delegate creation, distribution, and optimization to the right tools.

**The flow:** Zeitgeist → Angles & Hooks → Create (via other skills) → Distribute → Analyze

**NOT this skill:**
- Writing tweets or posts → `tweet-ideas`
- Generating images → `image-generator` or `nano-banana-pro`
- Creating TikTok slideshows → `slideshow-creator`
- Writing articles → `article-writer`
- Scheduling → `typefully` or `slideshow-creator`/ReelFarm

---

## Step 1: Zeitgeist Research

Mine what's working **right now** before writing a single word.

**Sources:**

| Source | What to look for |
|--------|-----------------|
| Reddit/Facebook groups | Exact audience language, recurring complaints, questions |
| Competitor posts (30+ days live) | Proven angles, format patterns, hook structures |
| X/TikTok trending content | Viral formats, cultural hooks, emerging memes |
| Google trends and news | Breaking topics, search-driven angles, seasonal signals |
| Testimonials and reviews | Transformation language, before/after framing |
| Support tickets and FAQs | Objections, misconceptions, friction points |
| TikTok accounts with <1k followers | Viral signals before algo amplification; comment sentiment on what's actually resonating |

**Skills to use:** `last30days`, `grok-search`, `trend-research`, `web-search`

**Output:** 10-20 hook angles + exact audience language in their own words. Store in `[Campaign]_Research.md`.

> **Verbalized Sampling — avoid mode collapse:** LLMs default to the most "typical" response due to RLHF typicality bias. To get genuinely diverse angles, use this prompt structure:
> *"Generate 15 hook angles for [topic]. For each, assign a probability (0–100%) representing how likely a typical AI would produce this exact angle. Include angles across the full distribution — obvious to unusual. Mark any below 20% probability as ⚡ Novel."*
> This forces the model to surface low-probability angles it would normally skip. Aim for at least 4–5 ⚡ Novel angles per batch. ([Source: Verbalized Sampling, arXiv 2510.01171](https://arxiv.org/abs/2510.01171) — 1.6–2.1x diversity increase in creative writing)

> **Novel angle, not novel solution.** You don't need a new idea. You need a fresh angle to an existing solution — repackaged for a specific person with a specific need. A Bible app for women. A screen blocker that won't unlock until you complete a task. The solution exists; your job is the repackage.

> **Load on-demand:** `references/creative-research-methods.md` for detailed research process.

---

## Step 2: Angles & Hooks

Transform research into angles that match audience awareness.

### Reader-First Reframe

Every piece of content must pass this test: **can a stranger who has never heard of you use or relate to this right now?**

| Source framing | Reader-first reframe |
|----------------|----------------------|
| "We hit 50k users by doing X" | "The one thing that unlocks your first 50k users" |
| "Bloom now supports Y feature" | "The feature that makes investors actually stick around" |
| "I learned Z from this experience" | "Why Z is the thing most people get backwards" |

Tutorials, frameworks, explainers: no reframe needed. Achievements, milestones, announcements: always reframe.

### Match Awareness Level

| Level | Audience State | Angle |
|-------|---------------|-------|
| 1 - Unaware | Don't know problem exists | Lead with problem agitation |
| 2 - Problem Aware | Know problem, not solutions | Validate + introduce solution |
| 3 - Solution Aware | Know solutions, not you | Differentiate your approach |
| 4 - Product Aware | Know you, haven't acted | Address objections, provide proof |
| 5 - Fully Aware | Ready to act | Make offer irresistible |

Cold traffic = Level 1-2. Retargeted = Level 3-4. Email list = Level 4-5.

### Hook Types

Write all three, then pick the right one for the format:

- **Stated** — what you SAY in copy
- **Visual** — what they SEE in the first frame
- **Audio** — what they HEAR in the first 3 seconds

> **Load on-demand:** `headlines` skill has 15+ proven hook formulas.

### Hook Psychology Triggers

Each hook type maps to a specific psychological mechanism. Name the mechanism when writing hooks to ensure you're triggering a real response, not just sounding clever.

| Trigger | What it does | Hook example |
|---------|-------------|--------------|
| **Pattern interrupt + commitment cue** | Breaks scroll autopilot, asks for micro-commitment | "Stop scrolling if you're ready to level up" |
| **Authority pledge + specificity** | Credibility claim + concrete action = trust | "I guarantee you'll sleep better if you try this tonight" |
| **Effort reduction** | Lowers perceived friction; viewer believes it's easy | "The easiest path to real progress (no hustle myth)" |
| **Contrast framing** | Replace a bad habit with a better one in one sentence | "Skip detox teas. Track protein instead." |
| **Identity affirmation** | Speaks to a valued self-image; viewer feels seen | "To everyone building in silence: this is your nudge" |
| **Curiosity gap** | Promises a solved puzzle, withholds the solution | "I finally cracked sustainable productivity" |
| **Loss aversion** | Frames inaction as losing something | "Your portfolio is bleeding and you don't know why" |

When brainstorming hooks, pick the trigger first, then write the line. Not the other way around.

> **Verbalized Sampling for hooks:** After picking a trigger, prompt: *"Write 5 hooks using the [trigger] mechanism. For each, assign a probability (0–100%) of a typical AI writing this exact line. Prioritize the lowest-probability hooks — those are the least clichéd."* Reject any hook above 70% probability unless it's a deliberate generic baseline.

Source: @thebranding.ai — viral format breakdown (https://www.instagram.com/reel/DVPGF9BEz2n/)

### The Wound-First Pattern

Open with a shared fear the audience already carries. Not a product problem — a *life* fear.

1. Open with the wound (fear, frustration, societal shift)
2. Deepen it: make it personal, inevitable, real
3. Let the tension sit — no product mention yet
4. Resolve with your brand as the only logical answer

The product is never the subject. The fear is. The product is the exit.

Best for: cold traffic at Level 1-2. Highly shareable because the fear is universal.

### Open Loops

An open loop is an unresolved question in the viewer's mind. The brain has physical discomfort with unresolved information (Zeigarnik Effect: incomplete tasks are remembered far better than completed ones). Every great piece of content opens a loop in the first few seconds and delays closing it until the end.

Examples: "I spent $5k on XYZ and I hate what I found…" / "GRWM" / cliffhanger episode structure.

**Open loops = tension engine.** Curiosity gaps = sustain attention between open and close.

### Curiosity Gap

The space between what someone knows and what they want to know. Foreshadow the destination, withhold the route.

Example: movie shows the ending first, cuts to "72 hours earlier" — you know where it ends, not how it gets there, so you watch for 2 hours.

Apply in content: state the outcome or insight in the hook, then build toward it. Never give away the answer before the middle.

### Format Selection

Match the angle to a format that amplifies it.

**15-second silent demo test:** If someone watched a 15s demo of your content/app with sound off and didn't understand it, no amount of marketing fixes that. Visual hook must work muted. If it doesn't, the format choice is wrong — not the hook copy.

| Format | Why It Works | Best For |
|--------|-------------|---------|
| Notes App | Looks like personal content | Problem-solution, starter packs |
| Text-Over-Video | Story through text sequence | Transformations, confessions |
| Reddit/Tweet Screenshot | Discovery energy | Hot takes, personal stories |
| Instagram Comment | Dialogue/Q&A feel | Addressing objections |
| Meme | Culturally native | Contrasts, humor |
| Testimonial Card | Direct social proof | Warm audiences |
| Documentary/Talking Head | High trust, feels like journalism | Skeptical audiences, financial products |
| Hands-Doing-Something | Tactile background task holds attention subconsciously while spoken content delivers value | Tutorials, study/productivity tips, any niche where the visual task signals relatability |
| Tier List | Gamified ranking format; viewers argue placements in comments, driving engagement | Content strategy, tool reviews, platform comparisons, "best of" lists |
| Viral Breakdown / Reaction | Dual-screen commentary on a viral post; borrowed traffic + authority positioning | Creator education, niche analysis, weekly pillar content |

> **See:** `references/content-formats.md` for the "Hands-Doing-Something" format details, structure, and Bloom application.

| Audience Temp | Best Formats |
|--------------|-------------|
| Cold | Notes App, Meme, Text-Over-Video, Reddit/Tweet, Documentary |
| Warm | UGC, Testimonial, Carousel, Before/After |
| Hot | Talking Head, Demo, Direct Offer |

> **Load on-demand:** `references/ad-formats-library.md` for all formats with templates.

---

## Step 2b: Pre-Creator Validation (Before Paying Anyone)

**Recreate before you recruit.** Prove a format works on your own account before committing creator budget to it.

1. **Warm up one account** in the niche — watch and engage with niche content for a few days before posting
2. **Save viral videos** from <1k follower accounts; these are pre-algo signals of what's actually resonating
3. **Analyze why they worked** — hook structure, comment sentiment, format, pacing
4. **Recreate the format yourself** — don't copy, match the structure and emotional beat
5. **See early traction** before sourcing any paid creators

Once a format proves out, hand it to creators via `whop-content-rewards` (managed tier). Skip this step only if you're scaling a format already validated in a prior batch.

---

## Step 2c: Video Series Planning

When the output is an AI character video series (TikTok, Reels, Shorts) rather than a single post.

### Series Setup

1. **Load character config** from `~/clawd/characters/<slug>/config.json` — this defines the persona, speech style, and visual identity
2. **Define the series**: topic cluster + episode count + arc (standalone episodes vs. serialized)
3. **Generate episode ideas**: 10-20 ideas per series; each idea = one episode concept. Use Verbalized Sampling: *"Generate 15 episode ideas for [series]. For each, assign a probability (0–100%) a typical AI would generate this idea. Flag anything under 20% as ⚡ Novel."* Pick from the low end of the distribution.
4. **Score each idea** (0-10 on each axis):

| Axis | What it measures |
|------|-----------------|
| **Hook strength** | Can you write a compelling first 3 seconds? |
| **Shareability** | Would someone forward this? |
| **Niche relevance** | Does it serve the target audience directly? |
| **Evergreen vs. timely** | Timely = post now; evergreen = queue |
| **Production simplicity** | Can it be done with just a talking head? |

Pick the top 3-5 ideas by total score. Those become the next production batch.

### Script Format

Write scripts in the character's voice (from config). Structure:

```
HOOK (0-3s): [Visual action or statement that stops the scroll]
SETUP (3-10s): [State the problem or tension]
BODY (10-50s): [Deliver the value — 3 points max, punchy]
CTA (last 3s): [Follow for more / comment below / link in bio]
```

Rules:
- Write how the character talks, not how you write
- No paragraph-length sentences — one idea per line
- Hook must work read aloud with no visuals (audio-only test)
- 60-90 second scripts for TikTok/Reels; 60s max for Shorts
- Label each line: HOOK / SETUP / POINT 1 / POINT 2 / POINT 3 / CTA
- **No-intro rule:** Never use the first 3 seconds to introduce yourself or your topic. Your caption/title card is the verbal intro. Jump directly to the hook action. If you feel the urge to say "Hey guys, today I'm going to..." — cut it.

### Output

One file per episode: `~/clawd/characters/<slug>/scripts/YYYY-MM-DD-episode-title.md`

---

> **See:** `references/content-formats.md` for viral breakdown pillar details, dual-screen format, on-screen labels, and Bloom-specific examples.

---

## Step 3: Create (Delegate)

Don't write here. Route to the right skill.

| Content Type | Skill |
|-------------|-------|
| Tweets / X posts | `tweet-ideas` |
| Articles / long-form | `article-writer` |
| TikTok slideshows | `slideshow-creator` |
| Hooks and headlines | `headlines` |
| Ad copy (paid) | `ad-copy` |
| Paid creative concepts | `ad-copy` (includes A/B blitz protocol) |
| AI character video scripts | Write inline using Step 2c above |
| New AI character | `character-creation` |

---

## Step 4: Distribute

| Platform | Tool |
|---------|------|
| LinkedIn, X, Threads | `typefully` skill |
| TikTok | `slideshow-creator` / ReelFarm |

> **See:** `references/distribution.md` for queue minimums and batch scheduling cadence.

> **Load on-demand:** `references/calendar-batching.md` for scheduling strategy and optimal posting times.

> **See:** `references/geo-targeting.md` for Instagram/Reels geo-targeting strategy, location tags, localization rules, and the 4-phase regional batch framework.

---

## Step 5: Analyze & Optimize

### Decision Rules (Post Level)

| Views | Action |
|-------|--------|
| 50K+ | DOUBLE DOWN — make 3 variations immediately |
| 10K-50K | Good — keep in rotation, test small tweaks |
| 1K-10K | Okay — try 1 variation before dropping |
| <1K (twice) | DROP — radically different approach needed |

### Two-Axis Diagnostic

| Views | Conversions | Diagnosis | Fix |
|-------|-------------|-----------|-----|
| High | High | Scale it | Make variations, increase frequency |
| High | Low | CTA problem | Hook works, downstream is broken |
| Low | High | Hook problem | Content converts, needs more reach |
| Low | Low | Full reset | Try radically different approach |

### Hook Evolution Loop

Track hook text, CTA, platform, and view/conversion data in `hook-performance.json`. Over time this reveals which hook + CTA combos actually drive results.

### Monthly Pillar Review (Run on the 1st)

Run 3-5 pillars at once. A pillar = one concept + 1-2 formats.

| Status | Criteria | Action |
|--------|---------|--------|
| SCALE | High views + high conversions | Increase frequency |
| KEEP | Decent and stable | Hold cadence |
| ELEVATE | Underperforming but sound concept | Change one lever: hook, format, or value density |
| ROTATE OUT | 2+ months underperforming after elevation | Move to bench |

Retired pillars aren't deleted. Keep `tiktok-marketing/pillar-bench.json` and revisit quarterly.

> **Load on-demand:** `references/analytics-loop.md` and `references/feedback-loop.md` for tracking setup and optimization details.

---

## References (Load On-Demand)

| Reference | Contents |
|-----------|---------|
| `references/6-elements-framework.md` | Paid creative element guidance (Media, Primary Text, Headline, etc.) |
| `references/ad-formats-library.md` | All formats with templates and examples |
| `references/copywriting-formulas.md` | PAS, AIDA, hooks, headlines |
| `references/creative-research-methods.md` | Research process and sources |
| `references/analytics-loop.md` | Per-post tracking, pillar-level monthly review |
| `references/feedback-loop.md` | Daily diagnostic, hook evolution, CTA rotation |
| `references/calendar-batching.md` | Scheduling strategy, queue management, posting cadence |
| `references/monetization-research.md` | CPM research, Content Rewards, niche selection |
| `references/competitor-research.md` | TikTok/App Store gap analysis, storing findings |

---

## Sample Output

What a complete strategy card looks like after running this skill. Use this as the template for what to produce.

---

**Campaign:** Bloom AI — Cold TikTok / Instagram (March 2026)  
**Topic:** AI has an edge in investing that retail investors don't know about  
**Audience level:** 1–2 (unaware / problem-aware)

**Research insights:**
- Trending on TikTok: "passive income" + "the stock market is rigged" + "what hedge funds don't tell you"
- Competitor weakness (from reviews): "Robinhood tells you nothing, just a chart" — users want context
- Audience language: "I don't even know where to start", "I feel like I'm always late to the news"

**Angles (pick one per batch):**
1. *Wound-first:* "By the time you read the news, the trade already happened." → exits to Bloom seeing it first
2. *Surprising number:* "Hedge funds run 10,000 stock screens before breakfast. Here's how to match that for free."
3. *Stolen thought:* "You already know the stock market isn't fair. Here's the part nobody explains."

**Hook (stated / visual / audio):**
- Stated: "The stock market has a cheat code most people don't know exists."
- Visual: Phone showing a red portfolio → cut to AI identifying the reason → cut to green
- Audio: "What if I told you the stocks that just dumped were actually the buy signal?"

**Format:** Notes App (cold) → Testimonial Card (retargeted)  
**Awareness level targeted:** Level 1–2 cold, Level 3–4 retargeted

**Delegate to:**
- Visuals → `ad-copy` + `nano-banana-pro`
- Tweets → `tweet-ideas`
- TikTok → `slideshow-creator`
- Scheduling → `typefully`

---

> **See:** `references/content-formats.md` for creator activity tier list (S through F ranking by impact).

---

> **See:** `references/distribution.md` for channel tier list (high-signal, questionable-signal, low-signal channels) and SEO timing.

> **See:** `references/interactive-content.md` for quiz-based landing page funnels, sequencing, drop-off benchmarks, and retargeting play.

---

## Related Skills

- `headlines` — hook formulas and title generation
- `ad-copy` — direct response copy, brand voice, A/B testing blitz
- `tweet-ideas` — standalone tweet content
- `article-writer` — long-form drafts
- `slideshow-creator` — TikTok production and ReelFarm automation
- `content-atomizer` — repurpose long-form into platform-native pieces
- `typefully` — scheduling to LinkedIn, X, Threads
- `last30days` — recent trending research
- `grok-search` — X/web search for zeitgeist signals
- `trend-research` — trending content across platforms
- `web-search` — Google search for trending topics and news
- `character-creation` — create and store AI video character configs + portraits
