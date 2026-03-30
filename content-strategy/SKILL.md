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

## Step 3: Create (Delegate)

Don't write here. Route to the right skill.

| Content Type | Skill |
|-------------|-------|
| Tweets / X posts | `tweet-ideas` |
| Articles / long-form | `article-writer` |
| TikTok slideshows | `slideshow-creator` |
| Hooks and headlines | `headlines` |
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
- Visuals → `copywriting` + `nano-banana-pro`
- Tweets → `tweet-ideas`
- TikTok → `slideshow-creator`
- Scheduling → `typefully`

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

What actually works for consumer apps vs. what sounds good but doesn't.

**High-signal channels:**
- TikTok / Instagram Reels — primary B2C organic discovery; recreate before recruiting creators
- Influencer/creator marketing — TikTok/YouTube/Instagram. Lovable ($400M ARR) spends 10x more on influencer marketing than paid social and considers it their key growth driver. Validate formats with your own account first, then hand proven formats to creators. This should be the primary paid channel, not Meta ads.
- Free credits / freemium as marketing — treat free tier as a marketing channel, not a cost center. "Our free giveaways are bigger than paid marketing spend." (Lovable CEO, 20VC March 2026)
- Free SEO tools — high-value lead magnets, easier to rank than blog posts, builds backlinks
- Email marketing — works if sequences are built correctly (see growth skill); people do read emails

**Questionable-signal channels (test carefully):**
- Meta/Facebook ads — Lovable's CEO at $400M ARR: "Meta ads have little incrementality; pass through views which don't materialize into anything. I haven't seen them work in a while." (Lenny's Podcast, Dec 2025). If running Meta ads, watch incrementality closely: are installs you're paying for ones that would have happened organically? Compare install lift when ads are paused vs. running.

**Low-signal channels (avoid or deprioritize):**
- Newsletter sponsorships — expensive and most clicks are bots
- Twitter ads — worst targeting in the industry; not worth the spend
- Google ads — more expensive than Facebook for consumer apps, higher irrelevant clicks
- Referral programs — very hard to make work; only viable with stable conversion and large customer base
- Reddit audience building — ban risk is high; answering long-tail questions can work, but building an audience there doesn't
- Beta directories (BetaList, etc.) — mostly dead; not worth the setup

**Alternative funnel: Quiz-based landing pages**

Instead of Ad → App Store → Install, run Ad → Web Quiz → Personalized Results → App Store. A quiz between the ad and the offer warms cold traffic through micro-commitments. DTC benchmark: cold traffic conversion jumped from 1.2% to 4.7% with a quiz funnel (@DTC_Quizbuilder, $2M in 90 days).

Why it works for apps:
- Each question answered is a small "yes" that compounds (sunk cost)
- Questions seed beliefs and pre-handle objections before the user sees pricing
- Non-completers give you zero-party data for segmented retargeting (someone who answered "I struggle with timing the market" gets a different retargeting ad than someone who answered "I don't know what to invest in")
- The loading/results screen is captive attention: 10-15s where you show testimonials, social proof, and app previews while "calculating their results"

Quiz sequencing that converts:
1. Q1-Q2: Low-friction demographics (age, experience level). Zero cognitive load, starts the yes-chain.
2. Q3-Q4: Aspirational goals ("What's your investing goal?"). Emotional questions hit harder after they've committed.
3. Q5-Q6: Pain points and struggles. Now they've told you their problems.
4. Breather slide with social proof after Q4.
5. Results page → personalized app recommendation → App Store link.

Drop-off benchmarks: Q1 = 30-40% drop-off (normal, biggest filter). Remaining questions: under 15% each. Overall completion: aim for 25%+. If any single question has 10%+ drop-off, simplify it (fewer options, add "None of the above").

Retargeting play: Everyone who takes the quiz but doesn't install gave you data. Segment retargeting by their answers: "tried other investing apps" → ad about why Bloom's AI is different. "Low confidence in stock picks" → ad about AI-powered research. Specific beats generic.

Bloom application: The onboarding flow already asks risk tolerance and goals post-install. A pre-install web quiz version of this would warm traffic before the App Store page, and the data feeds retargeting even if they never install.

Source: @DTC_Quizbuilder thread (https://x.com/DTC_Quizbuilder/status/2010379560769015885)

**SEO timing:**
- Don't prioritize SEO before your first customers — takes months to kick in, and if you pivot the product, the work goes to zero
- When you do SEO: free tools first (easier to rank, more shareable, generate backlinks naturally), then long-tail blog posts with purchase intent, then programmatic data-driven pages

---

## Reference Files

| File | Contents |
|------|----------|
| `references/social-content.md` | Social media strategy: content pillars, hook formulas, calendars, engagement, repurposing, analytics |
| `references/free-tool-strategy.md` | Engineering-as-marketing: tool types, ideation, evaluation scorecard, lead capture |
| `references/lead-magnets.md` | Lead magnet types, buyer stage matching, gating strategy, distribution, benchmarks |
| `references/marketing-ideas.md` | 139 SaaS marketing ideas catalog organized by category, stage, and budget |
| `references/blog-seo-planning.md` | Searchable vs shareable, content pillars, topic clusters, buyer stage keywords, ideation sources |


---

## Related Skills

- `headlines` — hook formulas and title generation
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
