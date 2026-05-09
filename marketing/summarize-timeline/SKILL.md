---
name: summarize-timeline
description: "Summarize an X/Twitter timeline into a themed daily digest. Use when pulling a Following timeline via bird and producing a structured summary for Signal delivery. Triggers on 'summarize timeline', 'twitter digest', 'timeline summary', 'daily digest from twitter', 'twitter reader'."
version: 1.0.0
author: Assistant Runtime
license: MIT
metadata:
  runtime:
    tags: [twitter, timeline, digest, summarize, cron]
prerequisites:
  skills: [bird-twitter]
---

# Summarize Timeline

Produce a daily digest from the user's X/Twitter Following timeline. Designed for the `summarize-timeline-daily` cron job but works interactively too.

## Pipeline

### 1. Pull timeline

```bash
bird home --following -n 500 --json --plain > /tmp/timeline_raw.json
```

If bird auth fails (401, cookie errors), stop and send a re-auth alert:
> bird auth has expired. Please visit x.com in Chrome to refresh cookies, then run `bird whoami` to verify.

### 2. Filter

Using Python or jq, filter the raw JSON:

- **Last 24h only.** Parse `createdAt` and drop anything older than 24 hours from now.
- **Top-level only.** Drop items where `inReplyToStatusId` is present (these are replies, not original posts).
- **Drop pure RTs.** Drop items where `text` starts with `RT @`.
- Count total items fetched and total after filtering. Report both.

### 3. Theme and summarize

Group tweets into **3-6 themes** based on content clustering. Use descriptive theme names, not generic buckets. Themes should reflect what actually dominated the feed that day.

Common theme areas (adapt to what's actually present):
- Markets, macro, earnings, sector rotation
- AI, compute, models, tools, launches
- Startups, product, growth, building
- Geopolitics, policy, regulation
- Culture, viral moments, notable observations
- Creator economy, content strategy

**Do NOT force tweets into predefined categories.** If the feed is 80% AI discourse and 2 market tweets, reflect that. The themes should mirror the feed's actual distribution.

### 4. Format rules

**Header:**
```
📱 X/Twitter Timeline Digest — Mon May 5, 2026
55 tweets from your Following feed, last 24h.

---

🏦 Markets & Macro

- @macroexample (2k❤): Semiconductors are lagging the broader AI trade. Watch for second-order rotation into suppliers.
- @fundexample (1.1k❤): Thread explaining why a rumored acquisition would destroy shareholder value. Main issue: no strategic overlap.
- @chartexample: $ABC reclaiming its 200 WMA after a three-month base. Breakout level: $42.

---

🤖 AI & Tech

- @aiexample (620❤): LLM quality keeps improving across unrelated tasks, which makes narrow product roadmaps harder to defend.
- @searchexample: Brands are buying competitor comparison queries inside AI search results. Distribution is moving upstream.

---

💼 Business, Strategy & Career

- @careerexample (2.2k❤): Career identity thread: the painful moment when a prestigious path stops fitting.
- @founderexample (640❤): Your income eventually tracks the quality of proof you can show, not the claims you make.

---

🌍 Culture & Notable

- @cultureexample (1.3k❤): Rainy-day joke paired with a photo from a canceled outdoor event.
- @writingexample: New essay on market cycles and how people mistake luck for strategy.

---

*Top engagement: @careerexample identity pivot (2.2k❤), @macroexample semi rotation (2k❤), @cultureexample rainy-day joke (1.3k❤), @fundexample acquisition critique (1.1k❤)*
```

Followed by a `---` separator.

**Theme sections:**

Use emoji + bold title for each theme section. Use broad, recognizable category names:
- 🏦 **Markets & Macro**
- 🤖 **AI & Tech**
- 💼 **Business, Strategy & Career**
- 🚀 **Building & Startups**
- 🌍 **Culture & Notable**
- 📈 **Earnings & Sectors**

Adapt categories to what's present. 3-6 sections typical.

For each tweet:
- Start with **@handle** in bold, followed by engagement in parentheses when notable: `(2.1k❤)`
- Colon, then the core take in 1-2 sentences
- Use `$TICKER` format for stocks
- Separate entries with line breaks

**Footer:**

End with a single italic line showing top engagement:

```
*Top engagement: @handle1 topic (Nk❤), @handle2 topic (Nk❤), @handle3 (N❤)*
```

**No "Best individual reads" section. No "One-line read" section. No "Notable links" blocks.**

### 5. Quality checks

- **No AI slop.** No "let's dive in", "here's what caught my eye", "without further ado". Just the content.
- **Be opinionated.** Flag contradictions between accounts. Note when a take is consensus vs. contrarian. Call out when something is just engagement farming.
- **Specificity over coverage.** 15 well-described tweets beat 40 one-liners. If a thread had a real argument, summarize the argument, not just the topic.
- **Tickers in $FORMAT.** Always use $AAPL format for stock mentions.
- **Don't editorialize excessively.** Summarize what people said, add brief context where useful. The reader wants to know what their feed said, not what you think about it.
- **Skip low-signal tweets.** Motivational quotes, vague announcements, pure self-promotion without substance: skip unless engagement was extraordinary.

### 6. Signal delivery

The cron system handles delivery automatically. Do NOT use send_message. Just produce the formatted digest as your final response.

If the feed had fewer than 5 substantive items in 24h, respond with `[SILENT]` to suppress delivery.

## Example output structure

```
📱 X/Twitter Timeline Digest — Mon May 5, 2026
55 tweets from your Following feed, last 24h.

---

🏦 Markets & Macro

- @macroexample (2k❤): Semiconductors are lagging the broader AI trade. Watch for second-order rotation into suppliers.
- @fundexample (1.1k❤): Thread explaining why a rumored acquisition would destroy shareholder value. Main issue: no strategic overlap.
- @chartexample: $ABC reclaiming its 200 WMA after a three-month base. Breakout level: $42.

---

🤖 AI & Tech

- @aiexample (620❤): LLM quality keeps improving across unrelated tasks, which makes narrow product roadmaps harder to defend.
- @searchexample: Brands are buying competitor comparison queries inside AI search results. Distribution is moving upstream.

---

💼 Business, Strategy & Career

- @careerexample (2.2k❤): Career identity thread: the painful moment when a prestigious path stops fitting.
- @founderexample (640❤): Your income eventually tracks the quality of proof you can show, not the claims you make.

---

🌍 Culture & Notable

- @cultureexample (1.3k❤): Rainy-day joke paired with a photo from a canceled outdoor event.
- @writingexample: New essay on market cycles and how people mistake luck for strategy.

---

*Top engagement: @careerexample identity pivot (2.2k❤), @macroexample semi rotation (2k❤), @cultureexample rainy-day joke (1.3k❤), @fundexample acquisition critique (1.1k❤)*
```
