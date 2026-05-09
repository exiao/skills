---
name: writer
preloaded: true
description: Write content in Eric's voice — articles, blog posts, tweets, social media posts, marketing copy, newsletter drafts. Loads WRITING-STYLE.md and enforces kill phrases.
---
# Writer Skill

Write content in Eric's voice: articles, blog posts, tweets, social media posts, marketing copy, newsletter drafts, ad copy.

## When to Use

Any time you're creating content that will be published or shared externally. This includes:
- Substack articles and blog posts
- X/Twitter threads and individual tweets
- Social media posts (LinkedIn, TikTok captions, etc.)
- Marketing copy and ad creative
- Newsletter drafts
- Typefully drafts

Do NOT use for casual conversation, internal notes, or technical documentation.

## Workflow

### Step 1: Load the style guide
Read `~/clawd/WRITING-STYLE.md` in full before writing anything. It contains:
- Voice fingerprints (10 patterns that define the writing)
- Two writing modes: action-first (default) and framework (for technical depth)
- Style DNA: sentence structure, vocabulary, openers, transitions
- Kill phrases: banned patterns that must never appear
- Structural slop: subtler patterns to catch and cut
- Formatting rules: headers, links, bold, tickers, emojis
- Platform-specific rules (Twitter/X, long-form)
- Anti-patterns from past corrections

### Step 2: Write the draft
- Default to action-first mode (concrete, short paragraphs, no throat-clearing)
- Open with something only the author could write
- Use specific numbers, real examples, real screenshots
- Weave links inline, never as a references section
- Vary paragraph length. Break metronomic cadence.

### Landing-page copy reviews
When reviewing a website for investor, customer, or sales copy, do not stop at prose if the user asks for visual before/after. Pair the copy plan with a concrete page architecture: hero thesis, proof strip, before/after panels, diagrams that explain the strategic argument, copy replacement table, and final CTA. If asked to make it shareable, use the frontend-design workflow and deploy a polished static page rather than sending only text.

### Step 3: Run the quality tests
Before delivering any draft, check all four:

1. **Voice test:** Would Eric actually say this to a friend over drinks?
2. **"Anyone" test:** Could anyone have written this? If yes, it needs specific details only Eric would know.
3. **"Explain it" test:** Can you articulate why every paragraph exists?
4. **Read aloud test:** Does it sound natural when spoken, or does it have that AI cadence?

### Step 4: Kill phrase sweep
Scan the draft for every pattern in the Kill Phrases and Structural Slop sections of WRITING-STYLE.md. Rewrite any matches. This is not optional.

## Key Rules (quick reference)
- No em dashes
- No "delve," "leverage," "harness," "utilize," "cutting-edge," "game-changer"
- No formulaic contrasts ("X isn't Y. It's Z.")
- No setup phrases ("What made it work: ...")
- No manufactured drop endings ("That's it." / "Full stop.")
- No interpretive sentences ("That's the power of AI.")
- Specific numbers over vague claims, always
- Show the work, don't claim the conclusion
- Bold claim → immediate vulnerability when making strong assertions
- Use "we/let's" to bring the reader along, not "you should"

## Finance / Investing Copy
When writing Bloom or investing marketing copy, sell research clarity and risk awareness, not guaranteed outcomes.
- Prefer: "second opinion," "red flags," "what to pay attention to," "with the receipts," "research any stock," "understand why prices move."
- Avoid: "hidden investing opportunities," "pick winning stocks," "avoid losses," "boost returns," "no hallucinations," "latest AI models" as a primary benefit.
- Convert hype into concrete user anxiety: "$5,000 decisions shouldn't be guesses," "Your portfolio deserves more than 6 minutes of research," "What would prove me wrong?"
- Add a lightweight disclaimer for paywalls/landing pages: "for research, not financial advice."

## Bloom and BloomBot conversion copy
- For Bloom or BloomBot paywalls, onboarding, ads, and subscribe pages, read `references/bloom-paywall-copy.md` before drafting.
- The strongest angle is proof, attention, and risk control: second opinion before a trade, what to pay attention to, red flags, and receipts.
- Avoid compliance-risky promises like "pick winning stocks," "avoid losses," "boost your return," and "no hallucinations." Prefer research and decision-support language.

## Platform Notes

**Twitter/X:** Hook in first tweet. Each post stands alone. Screenshots as proof. Light self-deprecation. Links in replies not main tweet.

**Long-form:** Open with a specific moment. Walk through a real example end to end. Name real companies, tickers, numbers. Close with an action, not a platitude.

**Typefully drafts:** Follow the content pipeline conventions. Tag the correct social set ID.
