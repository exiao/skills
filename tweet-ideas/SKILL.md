---
name: tweet-ideas
description: Use when generating 10-20 standalone tweets to build topical authority on a subject. Not for threads or promos. Uses the Aaron Levie playbook.
---

# Tweet Ideas From Post

Generate 10-20 standalone tweets about the *topic* of an article without ever mentioning the product, brand, or linking the article. This builds topical authority so when you do drop the article, the algorithm already associates you with the subject.

## The Aaron Levie Playbook

Aaron Levie tweets about cloud computing, enterprise software, and AI dozens of times a day. He rarely mentions Box directly. But when you think "cloud storage CEO who's funny and smart on Twitter" — you think of him.

That's the goal. Own the topic in people's feeds. The article link comes later.

## Input

- A finished article or topic brief
- The core topic/thesis (1 sentence)

## Process

### Step 1 — Extract Tweetable Angles

From the article, pull:
- **Hot takes** — contrarian opinions stated as facts
- **Data points** — surprising numbers that stand alone
- **Observations** — things everyone experiences but nobody says
- **Questions** — things you're genuinely curious about
- **Mini-stories** — 1-2 sentence anecdotes
- **Analogies** — "X is the Y of Z" comparisons

### Step 2 — Write Tweets in 5 Categories

Generate 3-4 tweets per category:

**1. Contrarian takes**
State your opinion as if it's obvious. No hedging.
- ✅ "The entire energy sector is worth less than Apple. That's not a market — that's a blind spot."
- ✅ "Every PM who says they don't need to understand evals is about to get replaced by one who does."
- ❌ "I think some investors might be overlooking energy stocks right now." (weak)

**2. Surprising numbers**
Lead with the number. Let it do the work.
- ✅ "3.3%. That's how much of the S&P 500 is energy. The stuff that powers the entire global economy."
- ✅ "We ran 363 tests. The AI couldn't tell that 45 < 60."
- ❌ "Energy stocks make up a small percentage of the index." (no number = no impact)

**3. Observations / "everyone knows but nobody says"**
Tap into shared frustration or recognition.
- ✅ "The most sophisticated AI systems in the world are evaluated in Google Sheets by PMs manually labeling data."
- ✅ "Most investors can't sit still for 3 months, let alone 3 years. Their impatience is your opportunity."

**4. Questions that provoke**
Not "what do you think?" — questions with a point of view baked in.
- ✅ "What happens when money floods out of a sector for 15 years and the survivors are all printing cash?"
- ✅ "If your portfolio has zero energy exposure, what bet are you actually making?"

**5. Analogies and reframes**
Make complex ideas click.
- ✅ "Evaluating AI products is like wine tasting — everyone thinks they're an expert, but nobody agrees on what 'good' means."
- ✅ "A Coffee Can portfolio is a commitment device. You're not investing — you're handcuffing yourself to patience."

### Step 3 — Schedule the Drip

Don't post them all at once. Spread across 3-5 days:
- **Day -1 to Day 0** (before article drops): 3-4 takes to prime the audience
- **Day 0** (publish day): 2-3 more, plus the thread/link
- **Day 1-3** (after): 3-4 more to keep the topic alive
- **Ongoing**: Recycle the best performers when news hits the same topic

## Reader-First Framing (Ruben Hassid Rule)

Strangers can't relate to your achievements. They only care about themselves.

Every tweet must pass this test: **does this help or resonate with a stranger, or is it just about me?**

- ❌ "I grew Bloom to 50k users by doing X." (about you)
- ✅ "Here's the one thing that unlocks your first 10k users." (about the reader)
- ❌ "Proud to announce we shipped this feature." (about you)
- ✅ "The feature nobody builds — but everyone needs — is a simple daily limit." (useful insight)

The reframe: swap every achievement into a lesson, pattern, or tool the reader can use today.

## Broad Angle Rule (validated: 18M views from zero audience)

Niche angles reach niche audiences. Broad angles reach everyone.

Nobody cares about "AI investing app" or "endless runner game." But they care about FOMO, outsmarting the system, self-discovery, proving someone wrong, not missing what everyone else missed.

**Find the universal human experience your niche topic connects to:**

- ❌ "Bloom uses AI to find undervalued stocks" (niche — investors only)
- ✅ "What would you do if you could see what hedge funds are buying before the news breaks?" (universal — FOMO, insider edge)
- ❌ "AI can analyze earnings reports faster than analysts" (niche — finance nerds only)
- ✅ "The stock market has a cheat code most people don't know exists." (universal — everyone wants an edge)

Apply this when selecting which angles to tweet. Not "what's interesting about investing" — but "what universal feeling does this investing insight tap into?"

## LinkedIn Hook Formula (Pattern Interrupt)

When adapting tweets for LinkedIn, the first 2 lines are everything — that's all readers see before "…more." Each line should be ≤55 characters. The hook's only job: break the scroll.

**5 techniques (use one per hook):**

1. **Contradiction** — say something that sounds wrong
   - "The worst LinkedIn posts get the most followers."
2. **Specific number + unexpected context**
   - "I mass-unfollowed 2,000 people. My engagement tripled."
3. **Direct accusation** — call the reader out
   - "You're writing posts for your mom, not your audience."
4. **Stolen thought** — say what the reader secretly thinks
   - "You know your posts are boring. So does everyone scrolling."
5. **Absurd reframe** — make something mundane dramatic
   - "Your hook has 1.2 seconds to live. Most die instantly."

Generate 10 hook variants (2 per technique), pick the best one. Volume → taste → post.

## Rules

1. **Never mention the product, app, or company name.** Talk about the topic.
2. **Never include a link.** These are standalone thoughts, not promotions.
3. **Each tweet must be interesting on its own.** If it needs context, it's not a tweet.
4. **No "just wrote about this" or "new article" energy.** That's a link dump.
5. **Be opinionated.** Neutral observations don't get engagement.
6. **One idea per tweet.** If you need "also" or "additionally" — split it.
7. **Under 200 characters performs best.** Shorter = more retweets.
8. **Reader-first always.** If a stranger can't relate or use it, rewrite it.

## Output Format

```markdown
# Tweet Ideas: [topic]
## Source: [article URL or draft path]
## Core thesis: [one sentence]

### Contrarian Takes
1. [tweet]
2. [tweet]
3. [tweet]

### Surprising Numbers
1. [tweet]
2. [tweet]
3. [tweet]

### Observations
1. [tweet]
2. [tweet]
3. [tweet]

### Provocative Questions
1. [tweet]
2. [tweet]

### Analogies
1. [tweet]
2. [tweet]

## Suggested Schedule
- Day -1: [tweet 1, tweet 2, tweet 3]
- Day 0 (publish): [tweet 4, tweet 5] + thread
- Day 1: [tweet 6, tweet 7]
- Day 2-3: [tweet 8, tweet 9]
```

Save to `marketing/tweets/[slug]-tweet-ideas.md`

Schedule via **typefully** skill.

## Reference Files

| File | Contents |
|------|----------|
| `references/formats.md` | 8 proven X/Twitter post formats with structure templates, psychology, and format-specific rules |
| `references/posts.md` | 49+ proven viral posts organized by format type. Study for rhythm, structure, and length. |
| `references/voices.md` | 7 creator voice profiles (Hormozi, Naval, Gazdecki, etc.) with writing DNA and signature patterns. Match voice structurally, don't copy. |

## Related Skills

- Fed by **article-writer** or any published content
- Part of **distribution** playbook (Aaron Levie section)
- Scheduled via **typefully**
- Quality-checked via **evaluate-content**
