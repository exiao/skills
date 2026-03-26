---
name: hooks
description: Use when generating hooks, headlines, titles, and scroll-stopping openers for content.
---
# Headlines & Hooks Engine

Generate scroll-stopping titles, subtitles, and opening hooks for articles, posts, and videos.

## LinkedIn Hook Formula

LinkedIn shows exactly 2 lines before the "…more" button. That cutoff is the only conversion that matters. If readers don't click "…more", nothing else counts.

**Constraints:**
- 2 lines max, each ≤55 characters
- Never about the author — always about the reader or a universal tension
- Creates an open loop: unanswered question, contradiction, or bold claim
- No emoji openers, no hashtags, no personal achievements

**5 pattern-interrupt techniques:**

| Technique | Formula | Example |
|-----------|---------|---------|
| Contradiction | Say something that sounds wrong | "The worst posts get the most followers." |
| Specific number + twist | Number + unexpected result | "I deleted 500 connections. Reach went up 40%." |
| Direct accusation | Call the reader out | "You're writing for your mom, not your market." |
| Stolen thought | Say what they secretly think | "You already know your posts are boring." |
| Absurd reframe | Make the mundane dramatic | "Your hook has 1.2 seconds. Most waste all of them." |

**Process:** Generate 10 variants (2 per technique). Don't pick the "safest" one — pick the one that made you wince slightly.

## Working Examples (Before → After)

These show the transformation. The before is what a first draft usually looks like. The after is what actually gets clicked.

**Topic: AI stock research**
- ❌ Before: "How AI Can Help You Research Stocks Better"
- ✅ After: "The Stock Market Has a Cheat Code. Most People Just Don't Know It Exists."
- *Why:* Before describes the tool. After sells the outcome + implies insider knowledge.*

**Topic: Bloom app feature**
- ❌ Before: "Bloom Now Has an AI Portfolio Analyzer"
- ✅ After: "I Let an AI Critique My Portfolio for 30 Days. It Found Things My Broker Never Mentioned."
- *Why:* Personal experiment framing = relatable. Specific timeframe. Implies betrayal by trusted source.*

**Topic: Investing with AI**
- ❌ Before: "Why Retail Investors Should Use AI Tools"
- ✅ After: "Hedge Funds Have Had This Advantage for 10 Years. You Can Have It Now for Free."
- *Why:* Us vs. them + democratization. "10 years" makes the gap feel real. "For free" handles objection before it forms.*

**Topic: Building Bloom (founder angle)**
- ❌ Before: "Lessons From Building a Fintech App as a Solo Founder"
- ✅ After: "6 Months Building a Fintech App Alone Taught Me One Thing Most PMs Never Learn"
- *Why:* Specific time + specific person (solo) + promises one concrete lesson. Curiosity gap.*

**LinkedIn hooks for the same Bloom topic:**
```
Line 1 (≤55 chars): "I replaced my analyst with an AI."
Line 2 (≤55 chars): "It found what 3 years of manual research missed."
```
*Pattern: Contradiction → Proof. Reader hits "…more" to find out what it found.*

---

## References

This skill content is modularized into reference docs for readability.

- [Brand Voice Reference](references/brand-voice-reference.md)
- [The Process](references/the-process.md)
- [Layered Hooks](references/layered-hooks.md)
- [Hook Rules](references/hook-rules.md)
- [Title Formulas (Ranked by Effectiveness)](references/title-formulas-ranked-by-effectiveness.md)
- [Subtitle Rules](references/subtitle-rules.md)
- [Anti-Patterns (Never Do These)](references/anti-patterns-never-do-these.md)
- [X/Twitter Title Adaptations](references/x-twitter-title-adaptations.md)
- [LinkedIn Title Adaptations](references/linkedin-title-adaptations.md)
- [Quality Check](references/quality-check.md)
- [The 9 Universal Hook Types (Mary Buckham)](references/the-9-universal-hook-types-mary-buckham.md)
- [Better Openers (Post-Draft)](references/better-openers-post-draft.md)
- [TikTok Video Hooks (First 1-3 Seconds)](references/tiktok-video-hooks-first-1-3-seconds.md)
- [Remix Strategy (Alex Ruber)](references/remix-strategy-alex-ruber.md)
- [The Moneyball Method for Hooks (Social Growth Engineers)](references/the-moneyball-method-for-hooks-social-growth-engineers.md)
- [13 Engagement Farming Strategies (SGE)](references/13-engagement-farming-strategies-sge.md)
- ["Too Good To Be True" Hook Formula (SGE)](references/too-good-to-be-true-hook-formula-sge.md)
- [Comparison Hook (SGE)](references/comparison-hook-sge.md)
- [Hook Micro-Optimization (SGE)](references/hook-micro-optimization-sge.md)
- [Conversation-Triggering Hooks (SGE)](references/conversation-triggering-hooks-sge.md)
- [Faceless Content Formats (SGE)](references/faceless-content-formats-sge.md)
- [4 Organic Growth Hacks That Look Like Cheating (SGE)](references/4-organic-growth-hacks-that-look-like-cheating-sge.md)
- [Multi-Account Hook Testing at Scale (SGE)](references/multi-account-hook-testing-at-scale-sge.md)
- [Instagram-Specific Adaptations (SGE)](references/instagram-specific-adaptations-sge.md)
- [Video Retention Architecture: 6-Step Framework](references/video-retention-architecture-6-step.md)
- [Usage](references/usage.md)
- [References](references/references.md)

## Output Format

Generate **10 headlines** for the given topic or content. Present as a numbered list:

1. ⭐ **Best headline here** — _Rationale: why this one wins (hook strength, clarity, curiosity gap)_
2. **Another headline** — _Rationale: one line on why it works_
3. **Another headline** — _Rationale: ..._
...

Rules:
- Star ⭐ the single recommended pick
- Each headline gets a 1-line rationale explaining the mechanism (curiosity gap, pattern interrupt, specificity, etc.)
- Mix formats: questions, statements, "How to", lists, contrarian takes
- After presenting, ask if the user wants variations on any specific headline or adaptation for a different platform
