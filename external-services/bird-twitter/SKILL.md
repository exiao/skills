---
name: bird-twitter
preloaded: true
description: Read X/Twitter timelines, tweets, and threads using the bird CLI (cookie-based GraphQL). Use when the user mentions "bird", wants to read their Following/For You timeline, fetch tweets, search X, or pull timeline data for summarization. Prefer over xitter (x-cli) for read-heavy workflows — bird uses browser cookies (zero API cost) while x-cli uses the paid official API.
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  runtime:
    tags: [twitter, x, bird, timeline, social-media]
prerequisites:
  commands: [bird]
---

# Bird — X/Twitter Cookie-Based CLI

`bird` is a fast X/Twitter CLI that uses browser cookies (GraphQL API) instead of the paid official API. It's the preferred tool for **reading** timelines, tweets, threads, and searches at zero API cost.

## When to Use

- Reading the home timeline (Following or For You feed)
- Fetching individual tweets by ID or URL
- Searching tweets
- Reading threads and replies
- Pulling timeline data for summarization or digest pipelines
- Any read-heavy X/Twitter workflow

## When NOT to Use

- Posting tweets, replying, or write operations (use xitter/x-cli instead for API-backed writes)
- When the user explicitly asks for x-cli or official API

## Cookie Auth

bird extracts cookies automatically from the user's browser. It checks Chrome by default.

Config file: `~/.config/bird/config.json5` or `./.birdrc.json5`

Supported config keys:
- `chromeProfile` — Chrome profile name
- `chromeProfileDir` — Chrome/Chromium profile directory or cookie DB path
- `firefoxProfile` — Firefox profile name
- `cookieSource` — Cookie source for browser extraction
- `cookieTimeoutMs` — Cookie extraction timeout
- `timeoutMs` — Request timeout
- `quoteDepth` — Max quoted tweet nesting depth

### Auth Failure Detection

If bird returns authentication errors (401, "not logged in", cookie extraction failures):
1. Check that the user is logged into X/Twitter in their browser
2. Try specifying a profile: `bird --chrome-profile "Profile 1" whoami`
3. Try Firefox: `bird --firefox-profile default-release whoami`
4. Cookies may have expired — user needs to visit x.com in their browser to refresh

**Important:** When running as a cron job, if auth fails, send a re-auth alert to the user rather than failing silently.

## Key Commands

### Timeline (most common for digest workflows)

```bash
# "Following" feed (chronological) — preferred for digests
bird home --following -n 50 --json --plain

# "For You" feed (algorithmic)
bird home -n 30 --json

# Specific user's tweets
bird user-tweets <handle> -n 20 --json
```

### Reading Tweets

```bash
# Read a single tweet (by URL or ID)
bird read <tweet-id-or-url> --json

# Read a thread
bird thread <tweet-id-or-url> --json

# Read replies
bird replies <tweet-id-or-url> --json
```

### Search

```bash
bird search "AI agents" -n 20 --json
```

### User Info

```bash
bird whoami                    # Check which account is authenticated
bird about <username> --json   # User profile info
bird following -n 50 --json    # Who you follow
bird followers -n 50 --json    # Who follows you
```

### Other Reads

```bash
bird mentions --json           # Your mentions
bird bookmarks --json          # Your bookmarks
bird likes --json              # Your liked tweets
bird lists --json              # Your lists
bird list-timeline <list-id-or-url> -n 30 --json
bird news --json               # Trending/Explore
```

## Output Modes

- `--json` — Machine-readable JSON (required for pipeline processing)
- `--json-full` — JSON with raw API response in `_raw` field
- `--plain` — No emoji, no color (stable for parsing)
- Default — Human-readable with emoji

**For pipelines, always use `--json --plain`.**

## JSON Output Structure

Each tweet in the JSON array contains:
```json
{
  "id": "tweet_id",
  "text": "tweet text content",
  "createdAt": "Thu Apr 30 12:02:10 +0000 2026",
  "replyCount": 0,
  "retweetCount": 5,
  "likeCount": 42,
  "conversationId": "thread_root_id",
  "inReplyToStatusId": "parent_tweet_id",
  "author": { "username": "handle", "name": "Display Name" },
  "authorId": "user_id",
  "media": [{ "type": "photo|video|animated_gif", "url": "..." }],
  "quotedTweet": { ... }
}
```

Key fields for filtering:
- `inReplyToStatusId` — present only on replies (filter these out for top-level-only digests)
- `text` starting with `RT @` — retweets
- `quotedTweet` — nested quote tweet object
- `media` — attached images/videos

## Timeline Digest Pipeline Pattern

Typical cron workflow for summarizing a timeline:

```bash
# 1. Pull timeline
bird home --following -n 50 --json --plain > /tmp/timeline.json

# 2. Filter to last 24h and deduplicate (in Python/jq)
# 3. Categorize and summarize tweets by topic
# 4. Deliver summary to Signal/Telegram/iMessage
```

When summarizing, group tweets by theme:
- Markets & Finance (tickers, earnings, macro)
- AI & Tech (models, tools, launches)
- Business & Strategy (positioning, growth, startups)
- Notable/Culture (viral tweets, observations)

## Combining with signal-cli for Delivery

See the signal-cli-daemon skill for sending summaries to Signal groups via JSON-RPC.
