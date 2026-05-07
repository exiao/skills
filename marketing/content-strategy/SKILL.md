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

### Hook Types

Write all three, then pick the right one for the format:

- **Stated** — what you SAY in copy
- **Visual** — what they SEE in the first frame
- **Audio** — what they HEAR in the first 3 seconds

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

1. **Warm up the account** in the niche — follow the 5-day TikTok warmup process before posting any content. See `references/tiktok-warmup.md` for the full checklist, retention benchmarks (42%+ watch-through), and account abandonment rules. (Sources: @rossark0, @alexcooldev, @lucaspatiri_, May 2026)
2. **Save viral videos** from <1k follower accounts; these are pre-algo signals of what's actually resonating
3. **Analyze why they worked** — hook structure, comment sentiment, format, pacing
4. **Recreate the format yourself** — don't copy, match the structure and emotional beat
5. **See early traction** before sourcing any paid creators

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

One file per episode: `$CHARACTERS_DIR/<slug>/scripts/YYYY-MM-DD-episode-title.md`

---

## Step 2d: Viral Breakdown Pillar

A full account pillar — not a one-off format. Run it every week: pick 1-3 viral posts in your niche, react in dual-screen format, explain the specific mechanics of why they worked.

> **Load on-demand:** `references/viral-breakdown-pillar.md` for full format details, on-screen label technique, and Bloom-specific examples.

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

Regional markets have lower CPMs, less competition, and engaged audiences. Use native location tags for specific business districts, not just city names.

> **Load on-demand:** `references/geo-targeting.md` for the full 4-phase regional batch framework, localization rules, and custom location tag strategy.

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
| `references/analytics-loop.md` | Per-post tracking, pillar-level monthly review |
| `references/feedback-loop.md` | Daily diagnostic, hook evolution, CTA rotation |
| `references/calendar-batching.md` | Scheduling strategy, queue management, posting cadence |
| `references/monetization-research.md` | CPM research, Content Rewards, niche selection |
| `references/competitor-research.md` | TikTok/App Store gap analysis, storing findings |
| `references/creative-research-methods.md` | Discovering trending ad formats, creative concepts, and content styles |
| `references/ad-formats-library.md` | All ad formats with structure templates, best uses, and examples |
| `references/6-elements-framework.md` | The 6 elements of Meta ad creative with best practices and optimization |
| `references/copywriting-formulas.md` | Copy structures for writing Meta ad primary text, headlines, and descriptions |
| `references/content-formats.md` | Content format types, templates, and selection criteria |
| `references/distribution.md` | Distribution channels, cross-posting strategy, amplification |
| `references/geo-targeting.md` | Geo-targeting strategy for content localization |
| `references/geo-llm-discovery.md` | GEO (Generative Engine Optimization): getting cited by AI chatbots via Reddit, LinkedIn, Substack. Includes sycophancy research context. |
| `references/interactive-content.md` | Interactive content types, quizzes, calculators, assessments |
| `references/tiktok-warmup.md` | 5-day TikTok account warmup process, retention benchmarks, account abandonment rules |

---

## Sample Output

What a complete strategy card looks like after running this skill. Use this as the template for what to produce.

---

**Campaign:** [Your App] — Cold TikTok / Instagram (March 2026)
**Topic:** AI has an edge in investing that retail investors don't know about  
**Audience level:** 1–2 (unaware / problem-aware)

**Research insights:**
- Trending on TikTok: "passive income" + "the stock market is rigged" + "what hedge funds don't tell you"
- Competitor weakness (from reviews): "Robinhood tells you nothing, just a chart" — users want context
- Audience language: "I don't even know where to start", "I feel like I'm always late to the news"

**Angles (pick one per batch):**
1. *Wound-first:* "By the time you read the news, the trade already happened." → exits to [Your App] seeing it first
2. *Surprising number:* "Hedge funds run 10,000 stock screens before breakfast. Here's how to match that for free."
3. *Stolen thought:* "You already know the stock market isn't fair. Here's the part nobody explains."

**Hook (stated / visual / audio):**
- Stated: "The stock market has a cheat code most people don't know exists."
- Visual: Phone showing a red portfolio → cut to AI identifying the reason → cut to green
- Audio: "What if I told you the stocks that just dumped were actually the buy signal?"

**Format:** Notes App (cold) → Testimonial Card (retargeted)  
**Awareness level targeted:** Level 1–2 cold, Level 3–4 retargeted

**Delegate to:**
- Visuals → `copywriting` + `nano-banana-pro`
- Tweets → `tweet-ideas`
- TikTok → `slideshow-creator`
- Scheduling → `typefully`

---

## Social Comms Personality

How you show up matters as much as what you post. These principles govern tone and presence across all social channels.

**Voice principles:**
- Simple announcements, human language — no corporate press-release energy
- Socially aware humor and joy — be a person, not a brand account
- Spontaneity — not everything needs to be polished or scheduled
- Generosity — give away value freely, don't gate everything
- Positive about the future and about builders
- Let the product speak for itself — don't oversell
- Let the audience be your champion — amplify them, don't just broadcast
- "Thinking out loud" energy — share process, not just outcomes
- Engage with people (especially small accounts) — don't just talk at the crowd
- Engage with discourse if it's good faith — don't hide from conversation
- Cater to the very online (in moderation)
- Tactful honesty about flaws — acknowledge what's broken, don't pretend
- Tasteful jabs at competitors are fine
- Cringe is better than corporate — if you have to pick, pick human
- Above all, show your humanity

**Anti-patterns:** Overthought announcements. Jargon-heavy feature drops. Ignoring replies. Only engaging with big accounts. Hiding behind brand voice when a real voice would land better.

Source: @anuatluru analysis of OpenAI's comms shift (May 2026)

---

## Creator Activity Tier List

What to spend your time on as a content creator, ranked by impact. Based on @wootak's framework (https://www.instagram.com/reel/DVwed_xEvHx/).

| Tier | Activity | Why |
|------|----------|-----|
| **S** | **Post consistently** | Nothing else matters if you don't publish. Ship beats perfect. |
| **S** | **Define your niche/target** | Focused content reaches the right people. Broad content reaches nobody. |
| **S** | **Use TikTok (especially TikTok Shop)** | Highest-leverage platform for organic discovery right now. |
| **S** | **Repurpose content cross-platform** | Every platform's audience sees it "for the first time." One piece of content = 3-5 posts. |
| **A** | **Script/outline before filming** | Structure beats improv. But execution (posting) matters more than perfect scripts. |
| **A** | **Track analytics** | Know what works. But analysis without posting is procrastination. |
| **A** | **Post at optimal times** | Helps, but doesn't replace quality or consistency. |
| **B** | **Writing elaborate captions** | Useful but overrated. Most creators over-invest here relative to impact. |
| **C** | **Written/text-only content** | Video outperforms text on every social platform. Text content is C tier in a video-first world. |
| **F** | **Hashtags** | Zero meaningful impact on modern algorithms. Complete waste of effort. |

The hierarchy: **Posting > Targeting > Platform choice > Repurposing > Scripting > Analytics > Timing > Captions > Text content > Hashtags.**

---

## Channel Tier List (Bloom / B2C)

What actually works for consumer apps vs. what sounds good but doesn't. Covers high-signal channels (TikTok, influencer marketing, free tools, email), questionable channels (Meta ads), low-signal channels (newsletter sponsorships, Twitter ads, referral programs), and the quiz-based landing page funnel.

> **Load on-demand:** `references/channel-tier-list.md` for full channel analysis, quiz funnel sequencing, and SEO timing.

---

## Reference Files

| File | Contents |
|------|----------|
| `references/social-content.md` | Social media strategy: content pillars, hook formulas, calendars, engagement, repurposing, analytics |
| `references/channel-tier-list.md` | Channel tier list (B2C), quiz funnel strategy, SEO timing |
| `references/viral-breakdown-pillar.md` | Weekly viral breakdown pillar format, on-screen labels, sourcing |
| `references/free-tool-strategy.md` | Engineering-as-marketing: tool types, ideation, evaluation scorecard, lead capture |
| `references/lead-magnets.md` | Lead magnet types, buyer stage matching, gating strategy, distribution, benchmarks |
| `references/marketing-ideas.md` | 139 SaaS marketing ideas catalog organized by category, stage, and budget |
| `references/blog-seo-planning.md` | Searchable vs shareable, content pillars, topic clusters, buyer stage keywords, ideation sources |


---

## Related Skills

- `hooks` — hook formulas and title generation
- `copywriting` — page copy, direct response, brand voice, A/B testing blitz
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
