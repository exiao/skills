---
name: content-strategy
description: "Use when building content strategy: hooks, angles, and ideas from what's trending now. Covers organic and paid creative across TikTok, X, YouTube, Meta, LinkedIn."
---

# Content Strategy

## Purpose

Turn zeitgeist signals into content that connects — then delegate creation, distribution, and optimization to the right tools.

**The flow:** Zeitgeist → Angles & Hooks → Create (via other skills) → Distribute → Analyze

**How to use this skill:** Synthesize, don't recite. When answering a question, pick the 2-3 frameworks most relevant to the specific situation and weave them into a coherent strategy. Don't list every framework in the skill. A strategy that references 12 frameworks is an index, not advice. The user should walk away with "here's what to do in what order" — not "here are all the concepts that exist."

**Every response must include a research step.** Even format-focused or optimization questions need 2-3 sentences on what to research first and which tools to use. Content strategy without audience research is guessing. If the question is narrow (e.g., "plan a repeatable format"), the research step can be short ("Use `grok-search` to find 5 accounts running similar formats; note which variables drive the most views"), but it must exist.

**NOT this skill:**
- Writing tweets or posts → `writer`
- Generating images → `image-generator` or `nano-banana-pro`
- Creating TikTok slideshows → video skills
- Writing articles → `writer`
- Scheduling → `typefully` or video skills/ReelFarm

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

**Skills to use:** `last30days`, `grok-search`

**Output:** 10-20 hook angles + exact audience language in their own words. Store in `[Campaign]_Research.md`.

### Credibility-Led Selling

Source: Naval Ravikant, `Sell the Truth`, nav.al/sell, May 2026.

For trust-sensitive categories, the content should sell by increasing credibility, not pressure. The best proof is often what you refuse to sell.

Principles:
- Tell the truth the buyer needs, even when it disqualifies them.
- Explain simply enough that a smart outsider can follow.
- Move on when the message does not resonate. Do not hammer skeptical viewers into submission.
- Let the product be the answer to a real situation, not the subject of every post.
- Optimize for the people who can see through tactics. If they trust it, everyone else gets easier.

Bloom application: say when Bloom is not needed, what it cannot do, and what kind of investor it is actually for. This is stronger than pretending every retail investor needs AI research.

### Trust Ledger Content Pillar

Source: Naval Ravikant, `Sell the Truth`, nav.al/sell, May 2026.

Credibility should compound through a recurring pillar, not just one honest hook. Build a public ledger of moments where the brand chooses truth over conversion.

Run 1-2 trust-ledger posts per week:
- **Bad-fit post:** who should not use the product
- **Limitation post:** what the product cannot know or cannot do
- **Tradeoff post:** what users gain and what they give up
- **Rejected-example post:** a stock, claim, tactic, or shortcut the product would reject
- **Better-alternative post:** when a simpler/free/default option is enough
- **Postmortem post:** where the product or thesis was wrong and what changed

Bloom examples:
- `3 times you don't need Bloom`
- `What Bloom can't know about a stock`
- `This stock went up after Bloom flagged it. Here's what the flag actually meant.`
- `If your portfolio is 100% VTI, don't overcomplicate it.`

Track these separately from conversion ads. Their job is trust density: saves, thoughtful replies, lower skepticism in comments, and better conversion when viewers later see a direct offer.

### Creative-Fatigue Research Stack

Source: @adamtaylorl X article on beating Meta creative fatigue, May 2026.

Before producing new ads, separate research into three jobs:
1. **Validate demand:** find where spend and repeated creative effort are actually going. Do not treat ad-library longevity as proof by itself.
2. **Find native inspiration:** mine organic social for formats that hold attention without looking like ads.
3. **Source customer language:** pull reviews, Reddit threads, comments, support tickets, and post-purchase surveys for exact phrasing, failed solutions, and inside jokes.

Use the research to reflect the audience back to itself. The goal is not more angles. The goal is angles that sound impossible for an outsider to write.

> **Verbalized Sampling — avoid mode collapse:** LLMs default to the most "typical" response due to RLHF typicality bias. To get genuinely diverse angles, use this prompt structure:
> *"Generate 15 hook angles for [topic]. For each, assign a probability (0–100%) representing how likely a typical AI would produce this exact angle. Include angles across the full distribution — obvious to unusual. Mark any below 20% probability as ⚡ Novel."*
> This forces the model to surface low-probability angles it would normally skip. Aim for at least 4–5 ⚡ Novel angles per batch. ([Source: Verbalized Sampling, arXiv 2510.01171](https://arxiv.org/abs/2510.01171) — 1.6–2.1x diversity increase in creative writing)

> **Novel angle, not novel solution.** You don't need a new idea. You need a fresh angle to an existing solution — repackaged for a specific person with a specific need. A Bible app for women. A screen blocker that won't unlock until you complete a task. The solution exists; your job is the repackage.

> **Load on-demand:** `references/creative-research-methods.md` for detailed research process.

---

## Step 2: Angles & Hooks

Transform research into angles that match audience awareness.

### Sell the Big Picture, Then the Small Action

Source: Naval Ravikant, `Sell the Truth`, nav.al/sell, May 2026.

Strong persuasion often starts with a preamble: larger context, historical shift, problem situation, or mission. The point is not to add throat-clearing. It is to make the requested action feel like the natural next step.

Structure:
1. Name the larger reality the audience already half-believes.
2. Explain the implication for their life or work.
3. Offer one small action that follows from it.

Bloom example:
`Markets are not short on opinions. They are short on clean reasoning. Before you buy another ticker from your feed, run the thesis check.`

Use this for founder-led posts, landing page openings, and skeptical-audience ads. For pure Reels hooks, keep the first frame sharper and move this context into seconds 3-10.

### Reader-First Reframe

Every piece of content must pass this test: **can a stranger who has never heard of you use or relate to this right now?**

| Source framing | Reader-first reframe |
|----------------|----------------------|
| "We hit 50k users by doing X" | "The one thing that unlocks your first 50k users" |
| "[Your App] now supports Y feature" | "The feature that makes investors actually stick around" |
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

### Full-Funnel Angle OS

Source: @adamtaylorl X article on beating Meta creative fatigue, May 2026.

Creative fatigue often means the account has exhausted one awareness level, not that the product needs a totally new story. Most brands overproduce bottom-of-funnel ads that mention the product immediately. To scale, map each major angle across all five awareness levels, then produce at least three format variations per angle so the platform can route the right message to the right person.

For each angle, create:
- **Unaware:** educate that the problem exists
- **Problem aware:** validate the pain and name the hidden cost
- **Solution aware:** compare paths and failed solutions
- **Product aware:** show why this product is different
- **Most aware:** offer, proof, guarantee, risk reversal, urgency

Rule: if every ad mentions the product in the first three seconds, the account is probably overfed on Level 4-5 creative and starving Level 1-2.

### Hook Types

Write all three, then pick the right one for the format:

- **Stated**: what you SAY in copy
- **Visual**: what they SEE in the first frame
- **Audio**: what they HEAR in the first 3 seconds

For Instagram Reels UGC, add a fourth micro-hook before the spoken hook: **Audible stim**. This is a diegetic sound in the first 0.5 seconds that breaks scroll autopilot before language lands. Use phone set-downs, pen clicks, ice clinks, typing bursts, page flips, or cap pops. Keep it native to the action on screen. If it feels like a stock sound effect, cut it. (Source: @Jibran_05, May 2026)

> **Load on-demand:** `hooks` skill has 15+ proven hook formulas.

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

Open with a shared fear the audience already carries. Not a product problem, a *life* fear.

1. Open with the wound (fear, frustration, societal shift)
2. Deepen it: make it personal, inevitable, real
3. Let the tension sit. No product mention yet
4. Resolve with your brand as the only logical answer

The product is never the subject. The fear is. The product is the exit.

Best for: cold traffic at Level 1-2. Highly shareable because the fear is universal.

### Social-Failure Tutorial Pattern

Source: Adrian Per, `@omgadrian`, Instagram Reel `DG-5t5lJxOO`, Mar 2025.

Tutorials get more shareable when they fix an embarrassing social failure, not just a technical skill gap. Adrian's photos Reel worked because it was not framed as "photo composition tips." It was framed as: your partner hates the photos you take, and here is how to stop failing at that visible relationship task.

Formula:
`Here's how to stop failing at [socially visible task], using [simple system anyone can follow].`

Why it works:
- **Relational stakes:** the viewer wants to be seen as competent by someone specific.
- **Instant audience fit:** "GF (or BF)" tells the right person this is for them within one second.
- **Share mechanic:** people can forward it as a playful accusation or useful nudge.
- **Effort reduction:** "with just your phone" removes the gear/expertise objection.
- **System promise:** "3 categories" makes the improvement feel repeatable, not taste-based.

Use this pattern for any category where the product helps someone avoid looking clueless in front of another person: investing, fitness, dating, work, parenting, style, cooking, travel.

Bloom applications:
- `If your friend asked why you own that stock, could you answer? Here's the 5-minute check.`
- `Most people explain their portfolio like they guessed. Here's the 3-pass review.`
- `Stop sending your friend random tickers. Run this check first.`

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
| Three-Screen App Demo | Shows the core product loop in a way creators can repeat: input → processing → result | Influencer-led consumer apps, AI utilities, scanning/logging/analyzer apps |
| Investigation Arc | Creator reacts to a familiar claim/expert, finds a contradiction, investigates, then reveals proof | Anti-ad UGC, skeptical audiences, finance, health, categories with trust issues |
| Before/After [Product] | Two-word text overlay ("Before [PRODUCT]" / "After [PRODUCT]") over creator showing emotional transformation. No feature explanation needed. | Any product where the transformation is emotional (confidence, ease, joy), not just functional. AI tools, creative apps, fitness, learning. |

### Anti-Ad Execution

Source: @adamtaylorl X article on beating Meta creative fatigue, May 2026.

Polished UGC can become an ad smell. For cold audiences, mimic the organic feed first and sell second.

Execution rules:
- Use loose **idea plus freestyle** creator briefs: hook, proof points, claims to avoid, and customer phrases. Do not script every line.
- Build around human conflict or discovery, not product explanation.
- Drop social proof early when skepticism is high.
- Let the creator's phrasing stay imperfect if it feels native.
- Product appears as the thing discovered during the investigation, not the thing announced at the start.

**The 80/20 emotion-to-product ratio:** The best anti-ads spend ~80% of runtime on emotion (frustration, transformation, confidence, joy) and ~20% on product proof (a quick app UI flash, enough to show it's real). The product demo exists to prove legitimacy, not to explain features. If the feature demo exceeds 30% of the video, it's an ad again. (Source: Suno "Before/After" ad, May 2026 — 50s runtime, ~10s of app UI, rest is pure creator emotion)

**No-CTA as positioning:** Some of the strongest ads end on emotion, not a sales pitch. No "download now," no "link in bio," no logo card. The brand name appears in the opening text overlay and that's enough. This works when: (1) the content is so good it gets shared as entertainment, (2) the product name is embedded in the hook text itself, and (3) a CTA would cheapen the emotional payoff. This is walk-away positioning applied to ad creative. Reserve for brand-building, not direct response.

### Three-Screen App Demo

Design the product so an influencer can explain it in three screens without narration. Cal AI's creator videos repeatedly show: camera → loading → food detail page. The product team optimized those screens for instant comprehension because influencer marketing was the primary growth loop. (Source: @JosephKChoi interview with Daniel from Cal AI, May 2026)

**Use this as an app idea and product design test:**
1. What is the input screen?
2. What is the magical processing or suspense screen?
3. What is the result screen worth showing?

If those three screens are not obvious, creators will have to explain too much and paid/organic creative gets weaker.

**Bloom adaptation:** stock/ticker input or portfolio screenshot → AI analysis loading → clear insight card/risk score/actionable watchlist result.

### Viral Feature Test

Source: @athcanft X guide, Apr 2026.

Before building a campaign around an app, ask whether the app has a viral feature: a single visual moment that satisfies a core human desire and can be screen-recorded or shown in one frame.

Formula:
`core human desire + one-frame reveal = ad-native product loop`

Core desires/insecurities that reliably sell: attractiveness, health, wealth, sex/dating, status, intelligence, identity, fear, belonging. Weak apps sell a feature. Strong apps sell an answer to a question the user already cares about.

Reveal examples:
- food scanner → calorie/macros breakdown
- face/looks app → score/rating reveal
- fitness/body app → scan or transformation
- Bloom → risk score, portfolio diagnosis, hidden problem, AI insight card

If the reveal cannot be understood muted in 1-2 seconds, fix the product surface before buying ads. The ad should not explain the app. The reveal should make the viewer want the answer.

### The "Hands-Doing-Something" Format

A viral format where the creator does a simple tactile task (cutting fruit, making tea, crafting) while speaking about a completely unrelated topic. The visual activity is background; the spoken content is the payload.

Source: @thebranding.ai breakdown of multiple creators going viral with the same format.

**Why it works:**
- Tactile hand activity holds visual attention subconsciously (the eye tracks movement)
- The mismatch between casual activity and spoken content creates curiosity ("why is she cutting an apple while talking about studying?")
- Extremely simple production: phone on a stand, good mic, something to do with your hands
- Scalable to any niche: investing (writing in a notebook), cooking (prep work), fitness (stretching), tech (unboxing)

**Structure:**
1. Open with a relatable spoken hook ("you don't wanna study? that's fine, just imagine...")
2. Hands doing something throughout (never stop the activity)
3. Deliver value through speech while the visual activity anchors attention
4. Close with soft CTA or open loop

**Bloom application:** Film hands writing stock tickers on a notepad, scrolling through the Bloom app, or organizing investment notes while delivering investing insights via voiceover.

| Audience Temp | Best Formats |
|--------------|-------------|
| Cold | Notes App, Meme, Text-Over-Video, Reddit/Tweet, Documentary |
| Warm | UGC, Testimonial, Carousel, Before/After |
| Hot | Talking Head, Demo, Direct Offer |

> **Load on-demand:** `references/ad-formats-library.md` for all formats with templates.

---

## Step 2b: Pre-Creator Validation (Before Paying Anyone)

**Recreate before you recruit.** Prove a format works on your own account before committing creator budget. Warm up the account, save viral videos from small accounts, recreate the format yourself, and see traction before paying creators. Includes the Pre-Posting Creative QA Loop, Obsession Filter, and the Daniel/Cal AI/Sway Playbook.

> **Load on-demand:** `references/pre-creator-validation.md` for the full TikTok warmup process, virality predictor workflow, obsession filter checklist, and localization strategy.

---

## Step 2c: Video Series Planning

When the output is an AI character video series (TikTok, Reels, Shorts) rather than a single post.

### Series Setup

1. **Load character config** from `$CHARACTERS_DIR/<slug>/config.json` — this defines the persona, speech style, and visual identity
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
| **Pre-posting score** | If using a predictor, does the finished cut clear the target hook/hold/share threshold? |

Pick the top 3-5 ideas by total score. Those become the next production batch. If a predictor score disagrees with your taste, inspect the first 3 seconds manually before trusting either one.

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

One file per episode: `$CHARACTERS_DIR/<slug>/scripts/YYYY-MM-DD-episode-title.md`

---

## Step 2d: Viral Breakdown Pillar

Weekly pillar: react to and annotate 1-3 viral posts in your niche with dual-screen format. Use on-screen keyword labels ("HOOK", "OPEN LOOP", "SOCIAL PROOF") as retention devices. Label every piece "pt 1" for series architecture.

> **Load on-demand:** `references/viral-breakdown-pillar.md` for the full format, on-screen labels technique, and Bloom-specific examples.

---

## Step 2e: Result-First Product Proof Loop (WayShot Model)

For visual consumer apps, lead with the aspirational result, then reveal the ordinary input. Do not open with a feature explanation or a before shot. The result earns attention; the original creates the shock.

**Case study:** WayShot, a photo editor, reached 150M+ views across 8 accounts, 500K+ downloads in one month, $100K MRR, and #6 in the U.S. App Store by stacking three repeatable TikTok/Reels formats. (Source: Social Growth Engineers, May 2026)

**The sequence that worked:**
1. **Audience builder:** Native, barely promotional relatable format: "That friend who thinks everything is aesthetic." Product signal only through account name. Job: reach, comments, shares. One breakout reached ~48.6M views.
2. **Product proof:** Two-slide faceless slideshow: edited photo first, original second, caption "edited by [app]." Job: make the product transformation obvious without explaining it. One example reached ~7.5M views.
3. **Save engine:** Sharper identity/reveal hook: "What camera did you use?" → "Oh it's my phone." Job: bookmarks because the result feels aspirational and replicable. The strongest newer variation reportedly hit ~7M views and 230K bookmarks.

**Operating rule:** This is not before/after. It is after/before. Beautiful outcome first, flat source second, app mention last. Do not explain the product if the contrast can prove it.

**Metric rule:** For save-engine formats, bookmarks are the leading signal. Comments show conversation; saves show desire to recreate.

**Use when:** the product creates a visible transformation: photo/video editing, design tools, fitness/body changes, home decor, dashboards, AI-generated assets, makeovers, portfolio analysis cards.

**Bloom application:** Show the clean AI insight/card first, then reveal the messy raw signal: confusing chart, analyst noise, Reddit hype, or flat brokerage screen. The app is the tool that made the useful version.

## Step 2f: Repeatable Daily Format (The Oasis Model)

Most creators chase variety. The highest-growth accounts do the opposite: one format, repeated daily, with only the subject changing. Two case studies prove this: @oasishealthapp (30M views, 232 identical Reels, $23K/month MRR) and Suno AI creators running "turning texts into songs" at part 65+.

Generalized pattern: `[raw material with built-in curiosity] + [AI/tool transformation] + [serial numbering] = compounding series`

Bloom candidates: "I ran [ticker] through Bloom's AI," "I tested [guru]'s stock pick," or "[Trending stock] — what the AI actually sees." Pick ONE. Run it for 30 days before adding a second format.

> **Load on-demand:** `references/repeatable-daily-format.md` for both case studies, the Serialized AI Transformation Pattern table, how to build a repeatable format, part numbering strategy, referral-as-gate loop, and emotional paywall sequencing.

---

## Step 2g: Conversion Bridge (Views → Install → Payment)

Views without installs = entertainment. CTA patterns vary by format: cold traffic should never see "download now" (let them ask what the product is), while warm audiences get direct CTAs. Diagnose drop-offs by funnel step: views → profile visits → link clicks → installs.

> **Load on-demand:** `references/conversion-bridge.md` for CTA patterns by format, profile-visit funnel benchmarks, discount bounce-back tactic, and comment-as-distribution mechanic.

---

## Step 3: Create (Delegate)

Don't write here. Route to the right skill.

| Content Type | Skill |
|-------------|-------|
| Tweets, X posts, articles, long-form | `writer` |
| TikTok slideshows | video skills |
| Hooks and headlines | `hooks` |
| Ad copy (paid) | `copywriting` |
| Paid creative concepts | `copywriting` (includes A/B blitz protocol) |
| AI character video scripts | Write inline using Step 2c above |
| New AI character | `character-creation` |

---

## Step 4: Distribute

| Platform | Tool | Cadence |
|---------|------|---------|
| LinkedIn, X, Threads | `typefully` skill | 1/day (LI, Threads), 2/day (X) |
| TikTok | video skills / ReelFarm | 2-3/day |

Batch at least 7 days per session. If queue drops below 3 days, refill immediately.

> **Load on-demand:** `references/calendar-batching.md` for scheduling strategy, optimal posting times, and TikTok-at-scale batch production.

### Geo-Targeting (Instagram / Reels)

Regional markets have lower CPMs, less competition, and more engaged audiences. Use native location tags (business districts, not just city names) for zero-cost discovery.

> **Load on-demand:** `references/geo-targeting.md` for the full 4-Phase Regional Batch Framework, localization rules, and custom location tag strategy.

---

## Step 5: Analyze & Optimize

Use the Two-Axis Diagnostic (views × conversions) to classify every piece of content and decide: scale, tweak, or drop. Track hooks, CTAs, and angles in a leaderboard. Compound winners by recombining proven parts (swap hooks, change formats, shift awareness levels). Run a Monthly Pillar Review on the 1st.

Key decision rules: 50K+ views = double down immediately. <1K twice = full reset. High views + low conversions = CTA problem. Low views + high conversions = hook problem.

> **Load on-demand:** `references/analyze-optimize.md` for decision rules table, weekly creator review, Two-Axis Diagnostic, Hook Evolution Loop, Angle Leaderboard, Walk-Away Positioning, and Monthly Pillar Review.

---

## References (Load On-Demand)

Load the relevant file in `references/` when you need implementation detail: analytics/feedback loops, calendar batching, monetization, competitor research, creative research, ad formats, copywriting formulas, content formats, distribution, geo-targeting, interactive content, TikTok warmup, the Daniel Calai/Sway playbook, Bloom organic growth case studies (real creator data, verified TikTok accounts, hook patterns that drove downloads), or the Glam Up case study (referral-as-gate, emotional paywall sequencing, price increase paradox, UGC creator playbook).

---

## Examples and Tier Lists

Load `references/examples-and-tier-lists.md` when you need a complete strategy-card example, creator activity tier list, channel tier list, or quiz-funnel details.

---

## Related Skills

Use adjacent skills as needed: `hooks`, `copywriting`, `writer`, `typefully`, `last30days`, `grok-search`, and `character-creation`.
