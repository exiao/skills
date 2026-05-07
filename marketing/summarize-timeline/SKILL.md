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
Twitter Reader, last 24h digest from Following timeline.

Pulled via bird successfully. [N] timeline items fetched, [M] top-level items inside the last 24h.
```

**Theme sections:**

Use `## Top themes` as the section header, then `###` for each theme.

For each theme:
- **Theme title** should be a specific, opinionated one-liner (not just "AI & Tech"). Good: "AI compute is the feed's main character". Bad: "Technology updates".
- **Bullet points** for each notable tweet/thread. Include @handle and core take in 1-2 sentences.
- Add engagement counts (likes) when notably high (500+) to signal what resonated.
- **Notable links** at the end of each theme section: include 2-4 direct tweet URLs (`https://x.com/handle/status/id`) for the most interesting items. These let the reader click through.

**Footer sections:**

```
## Best individual reads

Numbered list of 3-5 tweets worth reading in full. One sentence each explaining why.

## One-line read

Single paragraph (2-3 sentences max) capturing the day's feed in a snapshot. What was the dominant mood, narrative, or signal?
```

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
Twitter Reader, last 24h digest from Following timeline.

Pulled via bird successfully. 500 timeline items fetched, 312 top-level items inside the last 24h.

## Top themes

### Samsung pulls forward HBM fab construction, memory supercycle narrative intensifies
- @handle1: core take in 1-2 sentences
- @handle2: related angle or counter-take

Notable links:
- https://x.com/handle1/status/123
- https://x.com/handle2/status/456

### OpenAI internal texts surface from the 2023 firing crisis
- @handle3: what the texts revealed
- @handle4: reaction/analysis

Notable links:
- https://x.com/handle3/status/789

[... more themes ...]

## Best individual reads

1. @handle on [topic]: why it's worth reading in full.
2. ...

## One-line read

The feed was dominated by [X]. The most actionable signal was [Y].
```
