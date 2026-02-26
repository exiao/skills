---
name: content-management
description: Use when planning, scheduling, distributing, analyzing, or optimizing content across platforms. Covers monetization research, niche selection, calendar management, cross-platform distribution, analytics loops, and hook optimization. Not for creating content — use tweet-ideas, article-writer, slideshow-creator, or image-generator for that.
---

# Content Management

The layer between "what to create" and "what's working." This skill covers everything that isn't making the content itself.

## When to Use This Skill

| Task | Here |
|------|------|
| Research what niche or brand pays best | ✅ |
| Plan a content calendar for the week/month | ✅ |
| Schedule a queue of posts | ✅ |
| Figure out which posts to double down on | ✅ |
| Research what competitors are doing | ✅ |
| Optimize hooks based on performance data | ✅ |
| Decide how to distribute across platforms/accounts | ✅ |
| Write a tweet or LinkedIn post | ❌ → tweet-ideas |
| Generate an image | ❌ → image-generator or nano-banana-pro |
| Create a TikTok slideshow | ❌ → slideshow-creator |
| Write an article | ❌ → article-writer |

## The Five Phases

Content management is a loop, not a line. Run these in order for new channels; run them in parallel for established ones.

```
Phase 0: Research  →  Phase 1: Plan  →  Phase 2: Schedule
                                              ↓
Phase 4: Optimize  ←  Phase 3: Analyze
```

---

## Phase 0: Research

Before creating anything, know what pays and what's working.

### Monetization Research
See [monetization-research.md](references/monetization-research.md)

Find what brands/niches pay per view on platforms like Content Rewards. Let CPM data drive your content brief — not the other way around. Covers: CPM research, niche-to-format matching, before/after format logic, multi-account distribution math.

### Competitor Intelligence
See [competitor-research.md](references/competitor-research.md)

Survey what's getting views in your niche. Find the hook gaps, format gaps, and audience gaps competitors are missing. Store findings in `tiktok-marketing/competitor-research.json`.

---

## Phase 1: Plan

Decide what to make, for whom, and why.

### Reader-First Reframe

Every piece of content must pass this test: **can a stranger who has never heard of you use or relate to this right now?**

Strangers don't care about your achievements. They care about their own problems. Before scheduling anything, run the source material through this filter:

| Source framing | Reader-first reframe |
|----------------|----------------------|
| "We hit 50k users by doing X" | "The one thing that unlocks your first 50k users" |
| "Bloom now supports Y feature" | "The feature that makes investors actually stick around" |
| "I learned Z from this experience" | "Why Z is the thing most people get backwards" |

If the content is already reader-first (tutorials, frameworks, explainers) — no reframe needed. If it's an achievement, milestone, or announcement — always reframe before scheduling.

### Content Pillars

Run 3-5 pillars at once. A pillar = one concept + 1-2 formats. Examples:
- "Market explainers via slideshows"
- "Investor mistakes via listicles"
- "Before/after transformations via image pairs"

See pillar lifecycle and rotation rules in [analytics-loop.md](references/analytics-loop.md).

---

## Phase 2: Schedule

Build a queue, not a single post.

See [calendar-batching.md](references/calendar-batching.md)

Key rules:
- Batch at least 7 days of posts per session — never schedule one at a time
- Fill `next-free-slot` back-to-back until the queue is full
- If the queue drops below 3 days, flag it and refill
- Schedule via **typefully** skill (LinkedIn, X, Threads) or **ReelFarm** (TikTok)

**Optimal posting times** (adjust for audience timezone):
- 7:30 AM — early scrollers
- 4:30 PM — afternoon break
- 9:00 PM — evening wind-down

**Target queue depth by platform:**

| Platform | Min queue | Cadence |
|----------|-----------|---------|
| LinkedIn | 7 posts | 1/day |
| X | 14 posts | 2/day |
| TikTok | 14–21 posts | 2–3/day |
| Threads | 7 posts | 1/day |

---

## Phase 3: Analyze

Track what's working at the post level and the pillar level.

See [analytics-loop.md](references/analytics-loop.md) and [feedback-loop.md](references/feedback-loop.md)

**Decision rules (post level):**

| Views | Action |
|-------|--------|
| 50K+ | DOUBLE DOWN — make 3 variations immediately |
| 10K–50K | Good — keep in rotation, test small tweaks |
| 1K–10K | Okay — try 1 more variation before dropping |
| <1K (twice) | DROP — radically different approach needed |

**Two-axis diagnostic:**

| Views | Conversions | Diagnosis | Fix |
|-------|-------------|-----------|-----|
| High | High | 🟢 Scale it | Make variations, increase frequency |
| High | Low | 🟡 CTA problem | Hook works, downstream is broken |
| Low | High | 🟡 Hook problem | Content converts, needs more reach |
| Low | Low | 🔴 Full reset | Try radically different approach |

---

## Phase 4: Optimize

Evolve what's working. Drop what isn't.

See [feedback-loop.md](references/feedback-loop.md)

**Hook evolution:** Track in `hook-performance.json`. Every post gets tagged with hook text, CTA, platform, and view/conversion data. Over time this builds the pattern: which hook + CTA combinations actually drive results.

**Monthly pillar review (run on the 1st):**
- SCALE — high views + high conversions → increase frequency
- KEEP — decent and stable → hold cadence
- ELEVATE — underperforming but sound concept → change one lever (hook, format, or value density)
- ROTATE OUT — 2+ months of underperformance after elevation → retire to bench

**The bench:** Retired pillars aren't deleted. Algorithms change. Keep `tiktok-marketing/pillar-bench.json` and revisit quarterly.

---

## References

- [Monetization Research](references/monetization-research.md) — CPM research, Content Rewards, niche selection, before/after format, multi-account math
- [Competitor Research](references/competitor-research.md) — TikTok/App Store research, gap analysis, storing findings
- [Calendar Batching](references/calendar-batching.md) — Scheduling strategy, queue management, posting cadence
- [Analytics Loop](references/analytics-loop.md) — Postiz API, per-post tracking, pillar-level monthly review
- [Feedback Loop](references/feedback-loop.md) — Daily cron, diagnostic framework, hook evolution, CTA rotation

## Related Skills

- **tweet-ideas** — generating standalone tweet content
- **content-atomizer** — repurposing long-form into platform-native pieces
- **typefully** — scheduling to LinkedIn, X, Threads
- **slideshow-creator** — TikTok slideshow production and ReelFarm automation
- **headlines** — hook formulas and title generation
- **ads-strategy** — paid content strategy (Meta, Google)
