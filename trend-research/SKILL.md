---
name: trend-research
description: Use when finding trending content on TikTok, YouTube, Instagram, Twitter, and other platforms.
---

# Trend Scout

Discover what's going viral across social platforms. Extract the signal: thumbnail, title, caption, view count, comments, ranking.

## Supported Platforms

| Platform | Method | Auth Needed | Best For |
|----------|--------|-------------|----------|
| **X/Twitter** | `bird` CLI (trending, search) | Cookie auth (configured) | Real-time trends, hot takes |
| **YouTube** | Firecrawl scrape + browser | None | Thumbnails, view velocity |
| **TikTok** | Firecrawl scrape + browser | None | Short-form trends, sounds |
| **Instagram** | Firecrawl scrape + browser | None | Reels, carousel trends |
| **Substack** | Firecrawl scrape | None | Newsletter trends in niche |
| **LinkedIn** | Firecrawl scrape + browser | None | B2B/professional virality |
| **Lemon8** | Firecrawl scrape + browser | None | Lifestyle/aesthetic trends |
| **RedNote (Xiaohongshu)** | Firecrawl scrape + browser | None | CN crossover trends |

## Data to Extract Per Post

For every trending item, capture ALL of these:

```
- title: The headline or first line
- caption: Full post text / description
- thumbnail_url: Image or video thumbnail (download to marketing/trends/)
- view_count: Views, plays, impressions
- like_count: Likes, hearts
- comment_count: Number of comments
- share_count: Shares, reposts, retweets (if available)
- engagement_rate: (likes + comments + shares) / views
- creator: Handle/username
- creator_followers: Follower count of creator
- post_url: Direct link
- posted_at: When it was published
- platform: Which platform
- ranking: Position in trending/explore feed
- category: Topic/niche tag
- hashtags: Relevant hashtags
- sound/audio: (TikTok/Reels) trending sound name if applicable
```

## Process

### Step 1 — Pick Platform(s)

If user specifies a platform, scout that one. Otherwise, default to scanning:
1. X/Twitter (fastest signal)
2. YouTube (highest intent)
3. TikTok (culture engine)

For niche-specific scouting, also check Substack + LinkedIn.

### Step 2 — Fetch Trending Content

#### X/Twitter
```bash
# Get trending topics
bird trending --json -n 20

# Get trending with related tweets
bird trending --json -n 10 --with-tweets

# Search a specific niche for viral content
bird search "investing min_faves:500" --json -n 20
bird search "AI finance min_retweets:100" --json -n 20

# Check what's performing on specific accounts
bird user-tweets <handle> --json -n 10
```

#### YouTube
Use Firecrawl to scrape YouTube trending page or niche search results:
```bash
# Trending page
firecrawl scrape "https://www.youtube.com/feed/trending" markdown

# Niche search sorted by view count
firecrawl scrape "https://www.youtube.com/results?search_query=investing+tips&sp=CAMSAhAB" markdown
```

For richer data (view counts, thumbnails), use **browser automation**:
```
browser → navigate to youtube.com/feed/trending
browser → snapshot to extract video cards
```

Or use the YouTube Data API via web_fetch:
```
# Trending videos (no auth needed for basic data)
web_fetch "https://www.youtube.com/feed/trending"
```

#### TikTok
TikTok trending is harder without API access. Use Firecrawl + browser:
```bash
# Discover page
firecrawl scrape "https://www.tiktok.com/discover" markdown

# Hashtag trends
firecrawl scrape "https://www.tiktok.com/tag/investing" markdown
```

Browser automation for richer extraction:
```
browser → navigate to tiktok.com/discover
browser → snapshot for trending hashtags and videos
browser → extract view counts from video cards
```

#### TikTok Creative Center (ads.tiktok.com/business/creativecenter)
The best free source for TikTok trend intelligence. No account needed for basic access.

**Top Ads:** See highest-performing paid content by vertical.
```
browser → navigate to https://ads.tiktok.com/business/creativecenter/inspiration/topads/pc/en
# Filter by: Industry (Finance), Region, Time period, Ad format
# Extract: ad creative, CTR, engagement, hooks used, CTA style
browser → snapshot to extract ad cards with performance metrics
```

**Trending Hashtags:** Real-time hashtag popularity with view counts.
```
browser → navigate to https://ads.tiktok.com/business/creativecenter/hashtag/pc/en
# Filter by: Industry, Country, Time period
# Extract: hashtag name, total views, trend direction (rising/falling), related hashtags
browser → snapshot for hashtag table
```

**Trending Songs/Sounds:** Which audio is driving virality.
```
browser → navigate to https://ads.tiktok.com/business/creativecenter/music/pc/en
# Extract: sound name, usage count, trend velocity
```

**Keyword Insights:** Search volume and trending keywords.
```
browser → navigate to https://ads.tiktok.com/business/creativecenter/keyword-insight/pc/en
# Search: "investing", "stocks", "portfolio", "finance"
# Extract: search volume, trend, related keywords, top videos using keyword
```

**Top Products (e-commerce):** What products are selling via TikTok.
```
browser → navigate to https://ads.tiktok.com/business/creativecenter/topProducts/pc/en
# Useful for understanding what finance/fintech products advertise on TikTok
```

**How to use Creative Center data:**
1. Check top ads in Finance vertical weekly to see what hooks/formats competitors use
2. Cross-reference trending hashtags with your content calendar
3. Use trending sounds in ReelFarm/CapCut productions (audio matters more than visuals on TikTok)
4. Monitor keyword insights for emerging topics before they peak
5. Save winning ad creatives to `marketing/trends/YYYY-MM-DD/tiktok-cc/` for reference

#### Instagram
```bash
# Explore page (requires browser — no public API)
# Use browser automation:
browser → navigate to instagram.com/explore/
browser → snapshot for trending reels and posts

# Specific hashtag
firecrawl scrape "https://www.instagram.com/explore/tags/investing/" markdown
```

#### Substack
```bash
# Leaderboard by category
firecrawl scrape "https://substack.com/charts/finance" markdown
firecrawl scrape "https://substack.com/charts/technology" markdown

# Specific newsletter trending posts
firecrawl scrape "https://substack.com/search/investing?searching=all_posts&sort=top" markdown
```

#### LinkedIn
```bash
# LinkedIn trending articles (public)
firecrawl scrape "https://www.linkedin.com/pulse/trending/" markdown

# Niche content via search (needs browser for login)
browser → navigate to linkedin.com/search/results/content/?keywords=investing
browser → snapshot to extract post cards with engagement
```

#### Lemon8
```bash
firecrawl scrape "https://www.lemon8-app.com/discover" markdown

# Or browser for dynamic content
browser → navigate to lemon8-app.com/discover
browser → snapshot
```

#### RedNote (Xiaohongshu)
```bash
firecrawl scrape "https://www.xiaohongshu.com/explore" markdown

# Browser for dynamic loading
browser → navigate to xiaohongshu.com/explore
browser → snapshot
```

### Step 3 — Rank and Score

Score each post using a **virality index**:

```
Virality Score = (views × 0.3) + (likes × 0.25) + (comments × 0.25) + (shares × 0.2)
```

Normalize across platforms (YouTube views ≠ TikTok views). Use relative ranking within each platform.

Additional signals:
- **Velocity**: Views per hour since posting (newer + high views = more viral)
- **Engagement rate**: (likes + comments) / views — >5% is strong, >10% is exceptional
- **Creator size ratio**: Small creator + big numbers = breakout content
- **Cross-platform appearance**: Same topic trending on 2+ platforms = real trend

### Step 4 — Download Thumbnails

Save thumbnails and key visuals:
```bash
# Create output directory
mkdir -p marketing/trends/$(date +%Y-%m-%d)

# Download thumbnails using gallery-dl or curl
gallery-dl -d marketing/trends/$(date +%Y-%m-%d)/ <url>
# or
curl -o marketing/trends/$(date +%Y-%m-%d)/thumb-1.jpg <thumbnail_url>
```

### Step 5 — Generate Report

Save the scouting report to:
```
marketing/trends/$(date +%Y-%m-%d)/trend-report.md
```

Report format:

```markdown
# Trend Scout Report — [Date]

## Platform: [Name]
### Query/Feed: [What was searched]

| # | Title | Creator | Views | Likes | Comments | Eng Rate | Velocity | Score |
|---|-------|---------|-------|-------|----------|----------|----------|-------|
| 1 | ...   | ...     | ...   | ...   | ...      | ...      | ...      | ...   |

### Top 3 Detailed Breakdown

#### 1. [Title]
- **Creator:** @handle (Xk followers)
- **Caption:** [full text]
- **Thumbnail:** ![thumb](./thumb-1.jpg)
- **Views:** X | **Likes:** X | **Comments:** X | **Shares:** X
- **Posted:** [time ago]
- **URL:** [link]
- **Why it's working:** [analysis — hook, format, timing, emotion]
- **Remixable angle for Bloom:** [how we could adapt this]

---

## Cross-Platform Themes
- Theme 1: [what's trending across multiple platforms]
- Theme 2: ...

## Content Ideas for Bloom
Based on what's trending, here are angles we could write about:
1. ...
2. ...
3. ...
```

## Niche Filters

When scouting for Bloom content specifically, use these search terms:
- investing, personal finance, stock market, ETFs, portfolio
- AI investing, robo-advisor, fintech
- money tips, budgeting, financial independence, FIRE
- Gen Z investing, millennial finance

Combine with virality filters:
- X: `min_faves:500`, `min_retweets:100`
- YouTube: sort by view count, filter to last 7 days
- TikTok: sort by trending, check hashtag view counts

## Scheduling

Can be run as a cron job or heartbeat task:
- **Daily quick scan**: X trending + YouTube trending (5 min)
- **Weekly deep dive**: All platforms, full report (20 min)
- **On-demand**: User asks "what's trending in [niche]?"

## Output

- **Trend reports**: `marketing/trends/YYYY-MM-DD/trend-report.md`
- **Thumbnails**: `marketing/trends/YYYY-MM-DD/*.jpg`
- **Raw data**: `marketing/trends/YYYY-MM-DD/raw-data.json`

## References

- Fed into **headlines skill** — remix trending hooks
- Fed into **outline-generator** — write about trending topics
- Fed into **distribution skill** — ride trending waves
- Uses **bird skill** for X/Twitter data
- Uses **firecrawl** for web scraping
- Uses **browser** for dynamic content extraction
