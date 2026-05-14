---
name: content-strategy
description: "Use when building content strategy: hooks, angles, and ideas from what's trending now. Covers organic and paid creative across TikTok, X, YouTube, Meta, LinkedIn."
preloaded: true
---

# Content Strategy

## Purpose

Turn zeitgeist signals into content that connects — then delegate creation, distribution, and optimization to the right tools.

**The flow:** Zeitgeist → Angles & Hooks → Create (via other skills) → Distribute → Analyze

**How to use this skill:** Synthesize, don't recite. When answering a question, pick the 2-3 frameworks most relevant to the specific situation and weave them into a coherent strategy. Don't list every framework in the skill. A strategy that references 12 frameworks is an index, not advice. The user should walk away with "here's what to do in what order" — not "here are all the concepts that exist."

**Every response must include a research step.** Even format-focused or optimization questions need 2-3 sentences on what to research first and which tools to use. Content strategy without audience research is guessing. If the question is narrow (e.g., "plan a repeatable format"), the research step can be short ("Use `grok-search` to find 5 accounts running similar formats; note which variables drive the most views"), but it must exist.

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

**Recreate before you recruit.** Prove a format works on your own account before committing creator budget to it.

1. **Warm up the account** in the niche. Follow the 5-day TikTok warmup process before posting any content. See `references/tiktok-warmup.md` for the full checklist, retention benchmarks (42%+ watch-through), and account abandonment rules. (Sources: @rossark0, @alexcooldev, @lucaspatiri_, May 2026)
2. **Save viral videos** from <1k follower accounts; these are pre-algo signals of what's actually resonating
3. **Analyze why they worked**: hook structure, comment sentiment, format, pacing
4. **Recreate the format yourself**: don't copy, match the structure and emotional beat
5. **See early traction** before sourcing any paid creators
6. **Pre-score finished cuts when a predictor tool is available.** Use this as a proxy, not an oracle. Score 3-5 versions before posting, especially if creator budget or trend timing matters. (Source: @johnvirality on Higgsfield `brain_activity`, May 2026)

### Pre-Posting Creative QA Loop

Source: @johnvirality X guide on Higgsfield Virality Predictor / `brain_activity`, May 2026.

Do not wait three days for platform data when the issue is obvious in the first 15 seconds. Before posting, create a small variant batch and score the cuts against proxy attention metrics.

Workflow:
1. Generate or edit 3-5 hook variants of the same video. Change only the first-frame approach per variant: face-forward vs environment-forward, direct eye contact vs looking away, frustrated expression vs vulnerable expression, text-first vs action-first.
2. Run each through the predictor if available. Track hook score, hold rate, viral potential, and any heatmap/report notes.
3. Pick the winner only if it also passes human taste. A high model score with ugly AI slop still loses brand trust.
4. Diagnose losers by attention failure:
   - Silent first 0.5 seconds on Reels UGC: add a diegetic audible stim, such as a pen click, phone set-down, ice clink, typing burst, page flip, or cap pop. Audio can be the pattern interrupt before the viewer processes the first word. (Source: @Jibran_05, May 2026)
   - Low first-3-second hook score: change first frame, proximity, face, motion, text overlay, or visual contrast.
   - High hook but low hold: the middle is clickbait or too slow. Add a payoff beat, cut filler, or increase story tension.
   - Low share/viral potential: add social currency. Make the viewer look smart, funny, early, warned, or seen when they share it.
5. Regenerate the weakest two variants using the diagnosis and rescore once. Do not loop forever.
6. Post the strongest scored variant, then compare predictor score against real retention and conversion data.

Use this loop to shorten feedback cycles, not to outsource taste.

### Obsession Filter

Source: Naval Ravikant, `Sell the Truth`, nav.al/sell, May 2026.

Do not build content pillars around topics the creator cannot genuinely sustain. Sales gets easier when the creator is obviously animated by the thing. If every script feels like pushing, the pillar is probably wrong or the angle is too far from the creator's real obsession.

Use before committing to a recurring pillar:
- Can the creator talk about this without notes for 10 minutes?
- Do they naturally collect examples without being asked?
- Would they still explain it if there were no immediate conversion?
- Does the content feel like kindling for the audience, not homework?

For Bloom, prioritize formats Eric can argue about naturally: bad stock theses, finance-bro nonsense, AI research quality, portfolio reasoning, retail investor psychology.

### Daniel / Cal AI / Sway Playbook

Before paying creators or building more product, check whether the concept can prove demand through content and a manual paid version. The durable lessons: distribution before product, spreadsheet-batched slideshow formats, three-screen product demos, content-niche app scoring, and influencer fit. Load `references/daniel-calai-sway-playbook.md` for the full playbook and Bloom adaptations. (Source: @JosephKChoi interview with Daniel from Cal AI/Sway, May 2026)

Once a format proves out, hand it to creators via `whop-content-rewards` (managed tier). Skip this step only if you're scaling a format already validated in a prior batch.

**Localization:** Use ChatGPT to translate hooks and overlays into Spanish, Portuguese, French, Arabic for international markets. Same content, 4-5x the reach. (Source: @alexcooldev, May 2026)

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

This is a full account pillar — not a one-off format. Run it every week.

**How it works:**
- Pick 1–3 viral posts in your niche each week
- React to + annotate them in dual-screen format (your face/commentary + the source post side by side)
- Explain the *specific mechanics* of why it worked — not "it's good," but "the credibility drop at 0:08 + the stacked loop at 0:14 are why retention holds past 30 seconds"
- Label every piece "pt 1" even if there's no pt 2 yet — it signals series, invites return visits, and the algorithm treats it as episodic

**Why it compounds:**
| Benefit | Mechanism |
|---------|-----------|
| Borrowed traffic | Your content surfaces in searches and feeds for the source post's audience |
| Authority positioning | You're the person who understands the craft, not just a consumer |
| Series architecture | Built-in return reason; viewers expect more installments |

**Format:** Dual-screen reaction (split-screen or side-by-side layout). If screen recording isn't possible, show the source clip and annotate with on-screen text labels while reacting verbally.

**On-screen keyword labels (retention device):** As you narrate your breakdown, flash bold single-word or short-phrase labels on screen that name the tactic being used: "HOOK", "AVATAR", "MESSAGING", "OPEN LOOP", "SOCIAL PROOF", etc. This serves three purposes:
1. Viewers feel like they're learning a *system*, not just watching a reaction
2. Labels create visual rhythm that sustains attention through the middle of the video (the retention dead zone)
3. Each label is a micro-open-loop: the viewer wants to understand *why* you labeled it that, so they keep watching

Place labels at the moment you identify the tactic, not before. Let the source video play 2-3 seconds first, then drop the label as your "aha" moment. Use bold white or colored text, large enough to read on mobile, centered or near the source video panel.

**Bloom-specific example:**
- Source: viral TikTok of someone showing their Robinhood portfolio down 40% (2M+ views)
- Labels you'd drop: "LOSS AVERSION" (the emotional hook), "ROUND NUMBER" (they lost exactly $10K, not $9,847), "SCREENSHOT FORMAT" (looks organic, not produced), "NO CTA" (the virality IS the content, no ask)
- Your commentary: explain each label as an investing psychology + content strategy concept simultaneously. Double value for the viewer.

**Sourcing:** Use `last30days`, `grok-search`, or `trend-research` to find viral posts in the investing/personal finance niche weekly. Look for 50K+ views, especially from accounts under 10K followers (pre-algo signal).

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

Most creators chase variety. The highest-growth accounts do the opposite: one format, repeated daily, with only the subject changing.

**Case study:** @oasishealthapp — 30M views, 232 Reels, $23K/month MRR. Every single video follows the same structure: test a popular water brand, reveal contaminants, show a score, recommend alternatives. The format never changes. The brand being tested changes.

**Case study 2: Suno AI "Turning Texts Into Songs"** — Creators post "turning my [toxic person]'s texts into a song" using Suno AI. Some are on part 20, others on part 65. Every video clears hundreds of thousands of views. The AI-generated song plays while real text screenshots scroll on screen. The format never changes. The subject (which toxic person, which texts) changes. (Source: @alexolim_, May 2026)

Why this variant matters: the raw material is **emotional and personal**, not product-test data. Real text screenshots are inherently voyeuristic (curiosity gap: "what did they say?"). The AI tool is the transformation engine, not the subject. And high part numbers (pt 20, pt 65) do three things:
1. Signal creator commitment and depth of content library
2. Create curiosity about earlier parts ("what happened in pt 1-19?")
3. Train the algorithm on exactly who wants this content, compounding reach per episode

### Serialized AI Transformation Pattern

Generalized from Oasis + Suno cases:

Formula: `[raw material with built-in curiosity] + [AI/tool transformation] + [serial numbering] = compounding series`

| Element | Oasis | Suno | Bloom |
|---------|-------|------|-------|
| Raw material | Water brand | Toxic person's texts | Stock ticker / guru pick / portfolio |
| Transformation | Lab contaminant test | AI song generation | AI analysis / risk score |
| Reveal | Score + contaminants | Song playing over screenshots | Insight card / what AI caught |
| Variable per episode | Which brand | Which person / texts | Which ticker / guru / trade |

The pattern works because the creator's job is curation (picking the next subject), not creation (inventing a new format). Production cost per episode approaches zero.

**Why repetition beats variety:**
- The algorithm rewards predictable quality over creative range
- Viewers know what to expect, so they return (series architecture)
- Production cost drops to near zero after the first video
- You optimize one funnel instead of reinventing constantly
- 232 videos at the same format means 232 data points on what hooks work within that format

**How to build a repeatable format:**

1. **Pick one content structure** that maps to your product's core value (see hooks skill: "Familiar Brand as Villain" for a proven template)
2. **Define the variable** — the one thing that changes per video (Oasis: the water brand. Bloom: the stock/ticker/guru)
3. **Hardcode everything else** — intro pattern, data reveal sequence, CTA placement, music, pacing
4. **Batch production** — once the template exists, produce 10-20 videos per session by swapping the variable
5. **Post daily** — consistency > quality for algorithm favor. 1-2 posts/day minimum
6. **Track per-variable performance** — which subjects drive the most views? Double down on those categories
7. **Variant rule for paid:** when one creative wins, keep the hook and reveal structure fixed. Make 10-12 variants by swapping the person, subject, story, ticker, or result. Creative iteration beats campaign tinkering. (Source: @athcanft X guide, Apr 2026)

**The self-sustaining content loop:**
```
Content → App Downloads → Product Usage Data → More Content
```
Oasis: lab tests → videos → downloads → subscription revenue → fund more lab tests. Bloom: AI analysis → videos → downloads → usage data → more analysis to feature in videos.

**Bloom's repeatable format candidates:**
- "I ran [ticker] through Bloom's AI" — score reveal + what it caught
- "I tested [guru/influencer]'s stock pick" — AI vs human analysis
- "[Trending stock] — what the AI actually sees" — timely hook + evergreen format
- "I ran my most impulsive trade through Bloom's AI — pt 1" — serialized personal portfolio audit
- "Turning my broker's worst advice into an AI analysis — pt 1" — Suno-style emotional raw material + AI transformation

Pick ONE. Run it for 30 days before evaluating or adding a second format.

**Part numbering strategy:** Label every video in the series with a part number, even pt 1. High part numbers (pt 20+) are a growth accelerator: they signal a deep content library, trigger curiosity about earlier episodes, and tell the algorithm this is serialized content worth recommending in sequence. Cross-ref: Step 2d also uses "pt 1" labeling for the Viral Breakdown Pillar.

### Referral-as-Gate + Emotional Paywall Sequencing

Two principles from the Glam Up case study ($0 ad spend → 1M users, $150K MRR in 6 months):

1. **Referral as gate, not bonus.** Make sharing a functional requirement to unlock value ("subscribe OR refer 3 friends"). When users post referral codes in TikTok comments, the platform reads mass commenting as engagement and boosts the video further. The product's growth mechanic and the algorithm feed each other.

2. **Emotional commitment before price.** Build investment through a sequenced funnel (input → processing animation → blurred results → paywall). By the time the user sees the price, they're buying closure on something they feel they've already earned.

> **Load on-demand:** `references/glam-up-case-study.md` for the full playbook: 12-step paywall sequence, discount bounce-back, price increase paradox, copycat judo, UGC creator system, what failed, and Bloom adaptations.

---

## Step 2g: Conversion Bridge (Views → Install → Payment)

Views without installs = entertainment. Installs without payment = a free app. This section covers the bridge between content performance and revenue.

### CTA Patterns by Format

| Format | CTA approach | Why |
|--------|-------------|-----|
| Before/After [Product] | No CTA. Brand name in text overlay is enough | CTA cheapens emotional payoff; works for brand-building |
| Product test reveal | "I used [app] to find this. Link in bio." | Product is the tool, not the subject; soft attribution |
| Three-screen demo | Screen recording IS the CTA (shows the app) | Viewer sees the UI; curiosity drives the search |
| UGC / anti-ad | "Wait, what app is that?" comment bait | Let the audience ask; creator responds in comments |
| Direct response / retargeting | "Download [app]. Link in bio." or "Search [app] on the App Store" | Only for warm/hot audiences (Level 4-5) |

**Rule:** Cold traffic (Level 1-2) should never see "download now." The content must make them want to ask what the product is. Direct CTAs are for retargeting and warm audiences only.

### The Profile-Visit Funnel

On TikTok/Reels, the conversion path is: view → profile visit → link click → App Store → install. Each step loses 80-90% of traffic.

Benchmarks to track weekly:
- **Profile visit rate:** 1-3% of views is healthy. Below 1% = hook works but doesn't create product curiosity
- **Link click rate:** 10-30% of profile visitors. Below 10% = bio/profile isn't selling the app
- **Install rate:** Platform-dependent. Track via attribution (Branch, AppsFlyer) or App Store referrer data

If views are high but installs are low, diagnose by step:
- High views, low profile visits → Content entertains but doesn't signal "this person uses a cool tool"
- High profile visits, low link clicks → Bio copy, profile picture, or pinned content isn't converting
- High link clicks, low installs → App Store page (screenshots, description, reviews) is the bottleneck. Use `aso` skill.

### Discount Bounce-Back

If the product has a paywall, show the full price first. If the user declines, immediately show 50% off. Not later. Not via email. Right now, at peak emotional investment.

Why it works: anchoring (higher price reframes the discount), loss aversion (they're about to lose something they already invested time in), and impulse timing (curiosity is peaking). This was Glam Up's strongest single conversion tactic.

### Comment-as-Distribution

Design content mechanics that incentivize mass commenting:
- Referral codes ("comment your code to unlock the app for free")
- Debates ("is this stock overvalued? comment your take")
- Requests ("comment a ticker and I'll run it through the AI")

Mass commenting → TikTok/Reels algorithm reads it as high engagement → boosts the video → more views → more comments. The comments ARE the distribution channel.

> **Load on-demand:** `references/glam-up-case-study.md` for the full 12-step emotional paywall sequence and conversion data.

---

## Step 3: Create (Delegate)

Don't write here. Route to the right skill.

| Content Type | Skill |
|-------------|-------|
| Tweets / X posts | `tweet-ideas` |
| Articles / long-form | `article-writer` |
| TikTok slideshows | `slideshow-creator` |
| Hooks and headlines | `hooks` |
| Ad copy (paid) | `copywriting` |
| Paid creative concepts | `copywriting` (includes A/B blitz protocol) |
| AI character video scripts | Write inline using Step 2c above |
| New AI character | `character-creation` |

---

## Step 4: Distribute

| Platform | Tool |
|---------|------|
| LinkedIn, X, Threads | `typefully` skill |
| TikTok | `slideshow-creator` / ReelFarm |

**Queue minimums:**

| Platform | Min Queue | Cadence |
|---------|-----------|---------|
| LinkedIn | 7 posts | 1/day |
| X | 14 posts | 2/day |
| TikTok | 14-21 posts | 2-3/day |
| Threads | 7 posts | 1/day |

Batch at least 7 days per session. Never schedule one post at a time. If queue drops below 3 days, refill immediately.

**TikTok at scale:** Batch-create 10-30 pieces per session. Source visuals from Pinterest/Freepik, generate hooks via ChatGPT, assemble in Canva, schedule via Postiz (open-source). For new accounts, use Postiz for drafts only and post manually from the phone. Automate posting only on trusted, established accounts. Some operators run multiple accounts per app targeting different niches/markets; note that coordinated multi-account strategies may violate TikTok's TOS on inauthentic behavior, so evaluate risk and maintain genuine, distinct content per account. (Source: @alexcooldev, May 2026)

> **Load on-demand:** `references/calendar-batching.md` for scheduling strategy and optimal posting times.

### Geo-Targeting (Instagram / Reels)

Most brands compete in the same saturated metros. Regional markets have lower CPMs, less competition, and engaged audiences who see far less branded content.

**Layer 1 — Native location tags (fully compliant):**
- Use Instagram's existing location tag library; attach regional business district tags (not just city name) when posting
- Target specific coworking hubs, financial districts, tech clusters — not "New York City"
- Surfaces content in location-specific story feeds and Explore pages at zero additional media spend

**Layer 2 — Custom location tags (gray area):**
- Create new tags via Facebook check-in + VPN to target underserved areas with no existing tag
- Carries account-level risk if pattern is detectable; vary IP patterns, ensure content is genuinely relevant

**Localization rules (content must feel native, not just tagged):**
- Adapt industry context reference in the hook to match dominant industry in target city
- Adapt business size + operational framing to local business profile
- Adjust tone register: warmer/relationship-oriented in southern markets, direct/efficiency-focused in northern/western

**4-Phase Regional Batch Framework:**
1. **Market selection** — use Instagram Insights for existing follower geography + check location tag feed competition. Pick 8–12 test markets.
2. **Production** — write base script, adapt 2–3 localization elements per variant (hook industry ref, operational framing, pain point language). Tag to specific business districts. Schedule at local peak hours (6:30–8:30am, 12–1:30pm, 6:30–9pm local time).
3. **Evaluate (weeks 2–4)** — rank markets by organic discovery rate + engagement quality. Top 3–5 markets get paid amplification.
4. **Deepen** — produce second-generation content for winning markets with deeper localization; expand test cohort using learnings.

---

## Step 5: Analyze & Optimize

### Decision Rules (Post Level)

| Views | Action |
|-------|--------|
| 50K+ | DOUBLE DOWN — make 3 variations immediately |
| 10K-50K | Good — keep in rotation, test small tweaks |
| 1K-10K | Okay — try 1 variation before dropping |
| <1K (twice) | DROP — radically different approach needed |

**Volume math (creator programs):** You can't predict which video goes viral. But out of 500 videos, 3-5 will break through. Out of 1,800 videos/month, 15-20 cross 100K views and 3-5 cross 1M. The app at $2.7M MRR got there from 15,000+ videos over 18 months. This is math, not luck. (Source: @lucaspatiri_, May 2026)

### Weekly Creator Review

Run this every week when managing creator programs:

1. **Views per creator** — who's performing, who's stalling
2. **Views per hook** — which hooks drive views across all creators
3. **Views per format** — talking head vs POV vs reaction vs demo
4. **Account health** — which accounts are growing vs plateauing

Actions: Rotate out underperformers after 2 weeks. Send winning hooks to ALL creators. When one creator cracks a viral format, every other creator copies it by end of week. See `whop-content-rewards` skill for the full creator briefing method (hooks not scripts).

Source: @lucaspatiri_ (May 2026)

### Two-Axis Diagnostic

| Views | Conversions | Diagnosis | Fix |
|-------|-------------|-----------|-----|
| High | High | Scale it | Make variations, increase frequency |
| High | Low | CTA problem | Hook works, downstream is broken |
| Low | High | Hook problem | Content converts, needs more reach |
| Low | Low | Full reset | Try radically different approach |

### Hook Evolution Loop

Track hook text, CTA, platform, and view/conversion data in `hook-performance.json`. Over time this reveals which hook + CTA combos actually drive results.

### Angle Leaderboard and Creative Compounding

Source: @adamtaylorl X article on beating Meta creative fatigue, May 2026.

Do not let winners die in isolation. When a creative works, log the source, format, concept, angle, hook, persona, awareness level, visual structure, CTA, spend, views, CTR, CVR, CPA, and revenue. Use that as an Angle Leaderboard.

Compound winners by recombining proven parts:
- swap a winning hook onto a previous winning body
- turn a winning video into a static
- scale a winning angle into a new format
- keep the customer language, but change the visual proof
- keep the visual proof, but move it to a different awareness level

Congruency rule for statics: the largest visual element must match the specific desire in the headline. If the headline changes from generic relief to `back on the golf course`, the image must show the golf course desire, not a generic product benefit.

### Walk-Away Positioning

Source: Naval Ravikant, `Sell the Truth`, nav.al/sell, May 2026.

Some offers get more credible when they preserve the buyer's optionality and show a willingness to walk away. This is useful for high-trust products, creator partnerships, investor-facing content, and premium offers.

Content moves:
- Publish honest bad-fit criteria.
- Explain the dealbreakers before the benefits.
- Focus on upside and long-term alignment, not extracting the maximum small concession now.
- Avoid desperation CTAs. If the audience is wrong, let them self-select out.

Bloom examples:
- `Bloom is not a stock-picking signal. It is a reasoning layer.`
- `If you want guaranteed trades, skip this.`
- `If you want to understand why you own what you own, this is for you.`

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

Load the relevant file in `references/` when you need implementation detail: analytics/feedback loops, calendar batching, monetization, competitor research, creative research, ad formats, copywriting formulas, content formats, distribution, geo-targeting, interactive content, TikTok warmup, the Daniel Calai/Sway playbook, Bloom organic growth case studies (real creator data, verified TikTok accounts, hook patterns that drove downloads), or the Glam Up case study (referral-as-gate, emotional paywall sequencing, price increase paradox, UGC creator playbook).

---

## Examples and Tier Lists

Load `references/examples-and-tier-lists.md` when you need a complete strategy-card example, creator activity tier list, channel tier list, or quiz-funnel details.

---

## Related Skills

Use adjacent skills as needed: `hooks`, `copywriting`, `tweet-ideas`, `article-writer`, `slideshow-creator`, `content-atomizer`, `typefully`, `last30days`, `grok-search`, `trend-research`, `web-search`, and `character-creation`.
