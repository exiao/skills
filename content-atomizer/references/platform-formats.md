# Platform Formats

### 1. X/Twitter Thread

**Use the `typefully` skill as the base**, then layer these atomizer-specific rules:

**Structure:**
```
Post 1 (Hook): The most surprising claim from the article. Under 280 chars. No "Thread 🧵". No "I wrote about...". Use hook formulas from the headlines skill.
Posts 2-6: One standalone insight per post. Specific numbers. "But" transitions.
Final Post: Sharpest version of the thesis + link to full article.
```

**Rules:**
- Pull hook candidates from the `headlines` skill formulas (Tier 1 preferred)
- Each post must pass the screenshot test: interesting if someone shares just that one post
- Front-load power words: "I deleted", "363 tests", "$0", "Most investors"
- Include 1 image/screenshot on the most data-heavy post
- No numbering ("1/", "2/") unless it's a literal numbered list
- 3-7 posts total. Over 7 loses people unless the data is extraordinary.

**Example Hook Post:**
```
The entire oil and gas industry is 3.3% of the S&P 500.

Less than any single top-5 stock.

The stuff that powers the global economy. A rounding error.
```

**Scheduling:** Save to `marketing/atomized/YYYY-MM-DD/x-thread.md`. Schedule via **typefully**.

---

### 2. X/Twitter Standalone Tweets (Topic Authority)

**Use the `tweet-ideas` skill.** Generate 10-15 standalone tweets about the TOPIC, not the article. No links. No mentions of Bloom. Build topical authority via the Aaron Levie playbook.

**The Drip Schedule:**
- Day -1 (before article): 3-4 topic tweets to prime the algorithm
- Day 0 (publish): 2-3 more topic tweets + the thread
- Day 1-3: 3-4 follow-up takes to keep the topic alive

Save to `marketing/atomized/YYYY-MM-DD/x-standalone-tweets.md`. Schedule via **typefully**.

---

### 3. LinkedIn Post

LinkedIn is not X with longer posts. It's a professional stage where the "see more" fold is life or death.

**Structure:**
```
[LINE 1: Hook - must create curiosity gap in under 100 characters]
[LINE 2: Amplify the hook - add a specific number or surprising detail]

[← "see more" fold lives here. Everything above must compel the click.]

[PARAGRAPH 1: The context. 2-3 sentences. What happened, why it matters.]

[PARAGRAPH 2: The insight. The contrarian take or framework. Be opinionated.]

[PARAGRAPH 3: The proof. Specific numbers, results, screenshots described.]

[PARAGRAPH 4: The takeaway. What should the reader do differently?]

[FINAL LINE: Engagement prompt - a genuine question, not "thoughts?"]
```

**Rules:**
- First 2 lines are the ONLY thing people see before "see more." These ARE your hook. Treat them like a tweet.
- NO external links in the body. Links suppress reach by 50%+. Put the article link in the FIRST COMMENT.
- Write "(link in first comment)" at the end of the post.
- Line breaks between every paragraph. LinkedIn's renderer eats dense text.
- Use "I" not "we." Personal voice outperforms corporate voice 3:1 on LinkedIn.
- One post per article, not a carousel (unless the content is a framework/how-to; see IG carousel below and adapt for LinkedIn carousel if needed).
- 1,200-1,500 characters. Long enough to deliver value, short enough to not lose people.
- No hashtags in the body. If you must, 3 max at the very end.

**Example:**
```
I deleted half my AI's prompt.

It got smarter. Then I tested it 363 times and everything broke.

But the failures told me exactly what to add back. Here's what 363 automated tests taught me about building AI products that actually work.

[insight paragraph]

[proof paragraph]

[takeaway paragraph]

What's the dumbest thing your AI has done that taught you the most?

(link in first comment)
```

**First Comment (post immediately after publishing):**
```
Full breakdown here: [article URL]
```

**Scheduling:** Save to `marketing/atomized/YYYY-MM-DD/linkedin-post.md`. Schedule via **typefully** (supports LinkedIn).

---

### 4. TikTok Video Script

TikTok is not a reading platform. It's a performance. Every script must specify exactly what happens second by second.

**Script Format:**
```markdown
