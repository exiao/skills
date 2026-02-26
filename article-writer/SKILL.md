---
name: article-writer
description: Use when writing article drafts from approved outlines with SEO and brand voice.
---

# Article Writer Skill

Write full article drafts from approved outlines with SEO optimization and Bloom's voice.

## Pipeline Position

**Inputs:**
- Approved outline → `outline-generator` skill
- Approved title/subtitle → `headlines` skill
- Generated images → `visual-design` skill

**Output:**
- Full draft → `marketing/substack/drafts/[slug]/draft.md`

**Downstream:** Feeds into `typefully` for promotion.

---

## Writing Style — Bloom Voice

**⚠️ MANDATORY: Read `~/marketing/WRITING-STYLE.md` before writing any article.**

WRITING-STYLE.md contains Eric's actual voice fingerprint extracted from his Substack, Twitter, and guest posts. It defines:
- 8 voice fingerprints with real examples from Eric's writing
- Voice evolution (2023 academic → 2026 punchy) — **write in the 2025-26 voice**
- Anti-patterns to avoid
- Platform-specific rules (long-form vs Twitter)
- Reader context by audience level
- Domain knowledge (investing principles + building/product principles)

The rules below supplement WRITING-STYLE.md with additional detail:

- **Conversational but authoritative** — not a textbook, not a Reddit post
- **Data-driven** — every claim has a number, source, or example
- **Opinionated** — take a clear stance, don't hedge everything
- **Actionable** — reader should know exactly what to do after reading
- **Story-led** — open with a narrative hook, not "In this article..."
- Write like talking to a friend at a bar
- **Never use:** "Empower", "Leverage", "Unlock"
- Short paragraphs (2-4 lines max). Subheadings every 3-5 paragraphs.
- **Bold key insights** in each section
- Show don't tell: follow every claim with evidence (stats, story, before/after)
- Edit ruthlessly: target cutting 20-30% on revision pass

---

## Humanizer — Anti-Slop Rules

The #1 failure mode is sounding like AI. Every draft MUST pass these checks. Study these two reference voices:
- **Aman Khan** (amankhan1.substack.com) — practical, direct, first-person, admits mistakes, uses real examples
- **Ahmad Jivraj** (playingfordoubles.substack.com) — conversational, opinionated, short punchy sentences, builds arguments like a conversation

### Voice Fingerprint (What Makes Them Human)

**Sentence rhythm is irregular.** Mix short punches with longer thoughts. Never let three sentences in a row be the same length.
- ✅ "Everyone talks about AI. Nobody wants to talk about oil. And that, right there, might be the opportunity."
- ✅ "This stuff is not sexy. You're in a Google Sheet. But this is probably one of the most important things you'll get right with your team."
- ❌ "AI is transforming the investment landscape. Investors should consider diversifying their portfolios. Energy stocks offer compelling value at current levels." (robot cadence)

**Use "I" and admit fallibility.** Real writers share what they got wrong, not just what they got right. Vulnerability = trust.
- ✅ "I've fallen into this trap."
- ✅ "Looking back at my losers, the patterns are embarrassingly clear."
- ✅ "Coffee Can 11 in particular was a result of Hubris. Betting 20% on CWEB was particularly dumb."
- ❌ "Investors should be cautious about overconcentration." (professor voice)

**Take a side.** Don't present "both sides" neutrally. Have a thesis. Defend it. Then acknowledge the counter-argument honestly.
- ✅ "I'd be dishonest if I didn't acknowledge the headwinds. [...] But here's my pushback:"
- ✅ "I pushed back: 'Is losing the box covered in the policy or not? If not, why punt to another team?'"
- ❌ "There are pros and cons to consider." (fence-sitting)

**One-line paragraphs for emphasis.** Use them for transitions, zingers, and to let an idea breathe.
- ✅ "That's exactly what's happening in Energy right now."
- ✅ "Most people can't do it. That's precisely why it works."
- ✅ "Exactly why you need evals!"

**Conversational connectors.** Write like you're continuing a thought out loud, not writing an essay.
- ✅ "Here's the thing about mean reversion:"
- ✅ "Here's where it gets interesting."
- ✅ "Speaking of which…"
- ✅ "And money doesn't disappear: it rotates."
- ❌ "Furthermore," / "Moreover," / "Additionally," / "In conclusion,"

**Rhetorical questions that advance the argument.** Not filler questions — questions that make the reader think.
- ✅ "Why does this matter for oil stocks?"
- ✅ "What does that thumbs down actually mean?"
- ❌ "Have you ever wondered about the future of investing?" (empty)

**Specific over general. Always.** Concrete details make it real. Vague claims make it slop.
- ✅ "Exxon Mobil (XOM) returned over 80% in 2022 alone."
- ✅ "Our tone evaluations... was nearly random. Product knowledge was a 100% match."
- ✅ "Energy's current ~3% weighting in the S&P 500 is near an all-time low."
- ❌ "Energy stocks have performed well historically." (says nothing)

**Personal anecdotes and real stories.** Not hypotheticals — things that actually happened.
- ✅ "Robert experienced this firsthand when one of his clients came to him..."
- ✅ "When we built the On shoes agent, we had our team use it to answer their own customer service questions first."
- ❌ "Consider a hypothetical investor named Sarah who..." (fake)

### Banned Patterns (Instant Slop Indicators)

These phrases are AI tells. If ANY appear in a draft, rewrite the sentence:

**Structural slop:**
- "In this article, we'll explore..."
- "Let's dive in" / "Let's dive deeper" / "Let's unpack"
- "In today's rapidly evolving..."
- "In the world of..."
- "It's worth noting that..."
- "Needless to say" (unless genuinely ironic)
- "At the end of the day"
- "The landscape of X is changing"
- "Without further ado"
- "In conclusion" / "To sum up" / "To wrap things up"

**Dramatic contrast slop (AI's favorite crutch):**
- "Every X is Y. This one isn't." — false drama, formulaic
- "X isn't Y — it's Z." / "It's not X. It's Y." — fake-deep inversion
- "Most X. But not this X." — lazy setup/payoff
- "[Noun]. [Same noun], but [adjective]." — repetitive emphasis trick
- "The problem isn't X. The problem is Y." — overworn reframe
- Any sentence structured as "[Universal claim]. [Exception]." — it's a template, not a thought

**Adjective slop:**
- "Robust" / "Comprehensive" / "Holistic"
- "Cutting-edge" / "State-of-the-art" / "Groundbreaking"
- "Seamless" / "Streamlined" / "Frictionless"
- "Game-changing" / "Revolutionary" / "Transformative"
- "Nuanced" / "Multifaceted" / "Dynamic"
- "Innovative" / "Disruptive" (unless about actual disruption theory)

**Verb slop:**
- "Leverage" / "Utilize" / "Facilitate"
- "Empower" / "Enable" / "Foster"
- "Navigate" (used metaphorically) / "Unpack" / "Delve"
- "Spearhead" / "Catalyze" / "Supercharge"
- "Harness" / "Optimize" / "Amplify"

**Filler slop:**
- "It's important to note/remember/understand"
- "This is a great example of..."
- "Interestingly," / "Fascinatingly,"
- "The key takeaway here is..."
- "This begs the question"
- "When it comes to X,"

**Significance/legacy puffery (from Wikipedia's AI writing field guide):**
- "stands as" / "serves as" / "is a testament to"
- "a vital/significant/crucial/pivotal/key role/moment"
- "underscores/highlights its importance/significance"
- "reflects broader" / "symbolizing its ongoing/enduring/lasting"
- "setting the stage for" / "marking/shaping the"
- "represents/marks a shift" / "key turning point"
- "evolving landscape" / "focal point" / "indelible mark" / "deeply rooted"

**Superficial analysis slop (trailing -ing phrases):**
- "highlighting/underscoring/emphasizing [its importance]"
- "ensuring [quality/success/etc]"
- "reflecting/symbolizing [broader trends]"
- "contributing to [the field/industry/etc]"
- "cultivating/fostering [growth/innovation/etc]"
- "showcasing" / "exemplifies" / "commitment to"

**Promotional/puffery slop:**
- "boasts a" / "nestled" / "in the heart of"
- "rich" (figurative) / "vibrant" / "profound"
- "renowned" / "groundbreaking" (figurative)

**Vague attribution slop:**
- "Industry reports suggest" / "Observers have cited"
- "Experts argue" / "Some critics argue"
- "has been described as" (without naming who)

**"Despite challenges" formula:**
- "Despite its [positive thing], [subject] faces challenges" → "Despite these challenges, [positive outlook]"
- Any sentence that follows the pattern: acknowledge difficulty → but optimistic anyway

**Structure slop:**
- Bullet points that all start with the same word
- Three adjectives in a row ("powerful, innovative, and transformative")
- Paragraphs that start with "This" more than twice in a section
- Every section being exactly the same length
- Lists where every item is one sentence of the same length
- Ending with a generic "The future is bright" / "Only time will tell" / "One thing is clear"

### Co-Writing Principles (from Kaj Sotala's LLM writing research)

These apply to non-fiction too:

1. **Specificity in = humanity out.** The more specific details, real scenarios, and concrete examples you feed the LLM, the less generic the output. "Write about AI investing" → slop. "Write about how I used Claude to screen 47 small-cap stocks and found 3 with insider buying above $500k" → alive. Before drafting, front-load the prompt with: Eric's actual opinions, real Bloom data, specific user stories, concrete numbers.

2. **The LLM defaults to average.** Without steering, it writes what the average internet reader might like — which means safe, balanced, generic. Push it toward a specific voice by showing it examples of what you want (the Aman/Ahmad samples above) and explicitly telling it what NOT to do (the banned list).

3. **Generate, combine, rewrite.** Don't accept the first draft. Generate 2-3 versions of key sections, Frankenstein the best parts together, then manually edit. The best output comes from treating the LLM as a co-writer producing raw material, not a finished-article machine.

4. **Edit in your own voice last.** After the LLM draft, do a manual pass where you add your own asides, opinions, and one-liners. These human touches are what make the piece feel written, not generated.

### The Humanizer Checklist (Run on Every Draft)

Before a draft is final, it must pass ALL of these:

1. [ ] **Read it aloud.** If you wouldn't say it in conversation, rewrite it.
2. [ ] **Ctrl+F the banned list.** Zero tolerance. Every hit gets rewritten.
3. [ ] **Count your "I"s.** If the article has zero first-person pronouns, it's probably slop. Aim for at least 5-10 natural uses.
4. [ ] **Find the vulnerability.** Where does the author admit something hard? If nowhere, add one.
5. [ ] **Check sentence variety.** Open the draft and look at sentence starts. If 3+ consecutive sentences start with the same word or structure, vary them.
6. [ ] **Verify specificity.** Every claim should have a number, name, date, or source. "Many investors" → "68% of retail investors" or "my friend Alex".
7. [ ] **Test the transitions.** Read just the first sentence of each section in order. Does it flow like a conversation or like a textbook table of contents?
8. [ ] **One-liner test.** Are there at least 3-4 standalone one-sentence paragraphs used for emphasis? If not, find places to add them.
9. [ ] **Kill the throat-clearing.** Delete the first 1-2 sentences of each section. Does it read better? If yes, they were filler.
10. [ ] **Ending punch.** Does the last line land like a punchline or trail off? Rewrite until it hits.

### Voice Calibration Examples

**❌ AI slop:**
> The intersection of artificial intelligence and personal finance represents a transformative opportunity for investors. By leveraging cutting-edge technology, individuals can optimize their portfolio management and unlock new pathways to wealth creation. In this comprehensive guide, we'll explore how AI-powered tools are revolutionizing the investment landscape.

**✅ Human (Ahmad style):**
> Everyone's talking about AI investing tools. Most of them just Google things for you. I know because I built one and tested it 363 times. Here's what I actually found.

**❌ AI slop:**
> It's important to note that market valuations can fluctuate significantly. Investors should carefully consider their risk tolerance and investment horizon before making any decisions. Additionally, past performance does not guarantee future results.

**✅ Human (Aman style):**
> The market seems to be pricing energy as if the transition is already complete. It isn't. Meanwhile, energy is already the best-performing sector YTD in 2026, up nearly 23% through February 11. This might just be the start.

**❌ AI slop:**
> There are several key factors to consider when evaluating this opportunity. First, the macroeconomic environment presents both challenges and opportunities. Second, sector-specific dynamics play an important role. Third, individual company fundamentals matter significantly.

**✅ Human (mixed style):**
> Here's what I'd be looking at. Not the narrative — everyone's got a narrative. The numbers. Energy at 3.3% of the S&P. That's less than any single top-5 stock. The entire industry that powers the global economy, reduced to a rounding error. That smells like a setup.

---

## SEO Rules (Non-Negotiable)

| # | Rule | Target |
|---|------|--------|
| 1 | **Title** | Include primary keyword, <60 chars, compelling hook |
| 2 | **Subtitle** | Include secondary keyword, expand on title promise, 150-160 chars |
| 3 | **First 100 words** | Must contain primary keyword naturally |
| 4 | **Direct answer block** | 40-60 words near top that can be cited by AI |
| 5 | **H2 headings** | 4-6 per article, include keyword variations |
| 6 | **Keyword density** | Primary keyword 3-5 times naturally |
| 7 | **Internal links** | Link 2-3 previous Substack posts |
| 8 | **External links** | 2-3 authoritative sources |
| 9 | **Stats with sources** | 1-2 stats with cited sources and dates |
| 10 | **Word count** | 1500-2500 words |
| 11 | **Image alt text** | Describe with keywords where natural |

---

## Structural Rules

- Every section opens with a **mini-hook**
- Use **"But, so"** transitions between sections, not "and"
- Open loops throughout:
  - "But here's where it gets crazy..."
  - "Wait until you see this part..."
- **Close strong** — like a punchline
- **Soft CTA** at end — not salesy
- **AI share CTA**: if relevant, add a line like “Want an AI summary? Use the AI share button above”

---

## Content Authenticity

- Use real data, prices, dates
- Cite sources (earnings reports, SEC filings, etc.)
- **Never fabricate numbers**
- Mark hypotheticals clearly
- Include timestamps

---

## Revision

**⚠️ DO NOT run editing skills in a linear sequence. Use the `editor-in-chief` skill instead.**

The editor-in-chief orchestrates all editing skills (remove-chaff, show-dont-tell, emotion-amplifier, prosody-checker, reader-simulator, evaluate-content) in an intelligent diagnostic loop. It diagnoses what's wrong, prescribes only what's needed, and applies all fixes in consolidated rewrites — not 6 separate passes that overwrite each other.

After the first draft is written, hand it to `editor-in-chief` and let it loop until convergence (max 10 iterations).

## Final Revision Checklist (after editor-in-chief delivers)

1. [ ] Editor-in-chief delivered with all dimensions STRONG (or flagged what needs Eric's input)
2. [ ] **Humanizer checklist** — all 10 checks from above
3. [ ] Ctrl+F the banned patterns list — zero tolerance
4. [ ] Every section has a visual reference
5. [ ] All links verified
6. [ ] SEO checklist passed
7. [ ] Morning test: sleep on it, re-read fresh
8. [ ] **Final slop scan**: intro and outro read one more time
