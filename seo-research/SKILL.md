---
name: seo-research
description: "Use when doing SEO research: keyword research, AI search optimization, technical audits, schema markup."
---

# SEO Research & Optimization

Unified SEO skill covering keyword research, AI search optimization, programmatic SEO, technical audits, and content quality. Read the relevant reference file based on the task.

## Quick Router

| Task | Read This Reference |
|------|-------------------|
| Keyword research, competitor keywords, search volume, difficulty | This file (below) — uses DataForSEO skill |
| AI search optimization, GEO, getting cited by LLMs | `references/ai-seo.md` |
| Building SEO pages at scale from templates/data | `references/programmatic-seo.md` |
| Technical SEO audit (crawlability, indexation, security, CWV) | `references/seo-technical.md` — use DataForSEO On-Page API (endpoint 13) for automated audits |
| Schema.org structured data (JSON-LD) | `references/seo-schema.md` |
| E-E-A-T analysis, content quality scoring | `references/seo-content-eeat.md` |
| AI platform ranking factors | `references/platform-ranking-factors.md` |
| Content block patterns for AI citability | `references/content-patterns.md` |
| Programmatic SEO playbook details | `references/playbooks.md` |
| Schema type status (active/deprecated) | `references/schema-types.md` |
| E-E-A-T detailed criteria | `references/eeat-framework.md` |
| Content quality thresholds | `references/quality-gates.md` |
| Core Web Vitals thresholds | `references/cwv-thresholds.md` |
| Bloom keyword seeds | `references/keyword-seeds.md` |

---

## Pipeline Position

```
THIS SKILL (what to write about) → headlines → outline-generator → article-writer → image-generator → substack-draft → distribution
```

---

## Keyword Research Tools

### Primary: DataForSEO (API)
Auth: Basic `c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5`  
Skill: `dataforseo` — read it for full endpoint reference and cost table.

Key operations:
1. **Search volume + CPC + competition** — up to 700 keywords per call, $0.075/batch
2. **Keyword ideas from seeds** — 1000+ suggestions from 2–5 seed terms, $0.075/batch
3. **Keyword difficulty** — bulk scoring (0–100), ~$0.003/keyword
4. **SERP results** — who ranks on Google for a keyword, $0.002/query
5. **App Store rankings** — where Bloom ranks in App Store search, $0.0012/keyword

```bash
# Volume for known keywords
curl -s -X POST "https://api.dataforseo.com/v3/keywords_data/google_ads/search_volume/live" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"keywords": ["ai investing app", "stock screener"], "location_code": 2840, "language_code": "en"}]'

# Keyword ideas from seeds
curl -s -X POST "https://api.dataforseo.com/v3/keywords_data/google_ads/keywords_for_keywords/live" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"keywords": ["stock research", "ai investing"], "location_code": 2840, "language_code": "en", "limit": 100}]'
```

### Supplemental: Serper + Firecrawl
```bash
mcporter call serper.google_search q="best value stocks 2026" num=10
firecrawl scrape "https://[top-ranking-url]" --formats markdown --limit 5000
```

### Rank Tracking
DataForSEO returns current SERP positions but has no historical time series. For rank tracking over time, log results manually or use the SERP endpoint on a schedule.

---

## Keyword Research Process

### Step 1 — Seed Keywords
Start with broad seeds. Check `references/keyword-seeds.md` for the Bloom starter list.

### Step 2 — Expand via DataForSEO
For each seed:
1. Run keyword ideas endpoint → get 1000+ related keywords with volume + KD
2. Filter: volume > 500, KD < 50 (sweet spot for new domains)
3. Run SERP endpoint on target keywords → analyze who ranks, what they cover, gaps

```bash
# Step 2a: Ideas
curl -s -X POST "https://api.dataforseo.com/v3/keywords_data/google_ads/keywords_for_keywords/live" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"keywords": ["SEED_KEYWORD"], "location_code": 2840, "language_code": "en", "limit": 200}]'

# Step 2b: Difficulty on filtered candidates
curl -s -X POST "https://api.dataforseo.com/v3/dataforseo_labs/google/bulk_keyword_difficulty/live" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"keywords": ["keyword1", "keyword2"], "location_code": 2840, "language_code": "en"}]'

# Step 2c: SERP check on winners
curl -s -X POST "https://api.dataforseo.com/v3/serp/google/organic/live/advanced" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"keyword": "TARGET_KEYWORD", "location_code": 2840, "language_code": "en", "depth": 10}]'
```

### Step 3 — Competitor Analysis
1. Use DataForSEO `competitors_domain` (endpoint 9) to find domains with keyword overlap
2. Use DataForSEO `ranked_keywords` (endpoint 8) on those domains to see what they rank for
3. Use SERP results from Step 2c to identify top-ranking content for target keywords
4. Firecrawl to scrape top-ranking content
5. Identify: What they cover, what they miss, where we can be better

### Step 4 — Semantic Content Brief
```markdown
# Content Brief: [Primary Keyword]

## Target Keywords
- Primary: [keyword] (vol: X, KD: X)
- Secondary: [keyword1], [keyword2], [keyword3]
- Long-tail: [keyword1], [keyword2]

## Semantic Map
- Core concept: [central idea this content must demonstrate mastery of]
- Related concepts (10): [extracted from top 10 SERP analysis]
- Required entities (10): [products, people, companies to mention]
- Co-occurring term pairs: [terms that appear together in top results]
- Questions to answer (10): [from PAA + SERP analysis]
- Semantic gaps in competition: [concepts top results miss or undercover]

## Concept Depth Allocation
- High-value concepts (300-400 words): [2-3 concepts]
- Supporting concepts (150-200 words): [4-6 concepts]
- Tertiary concepts (50-100 words): [5-8 concepts]

## SERP Analysis
- Top 3 results: [urls + what they cover]
- Gap/angle: [what's missing that we can own]

## Recommended Approach
- Article type: [guide / listicle / opinion / analysis]
- Word count target: [based on competing content]
- Unique angle: [our differentiated take]
```

Save to `marketing/substack/research/[slug].md`.

### Keyword Cluster Structure
- **Primary**: High volume, moderate competition
- **Secondary**: 3-5 related terms
- **Long-tail**: 5-10 specific phrases

---

## SEO Monitoring

### DataForSEO (SERP snapshots)
```bash
# Check current ranking for a keyword
curl -s -X POST "https://api.dataforseo.com/v3/serp/google/organic/live/advanced" \
  -H "Authorization: Basic c29jaWFsc0Bwcm9tcHRwbS5haTo3YjBiN2M2YzE1MmRjNDA5" \
  -H "Content-Type: application/json" \
  -d '[{"keyword": "TARGET_KEYWORD", "location_code": 2840, "language_code": "en", "depth": 100}]'
```
Filter results for `getbloom.app` or `investwithbloom.com` in `domain` field.

### Serper (supplemental)
```bash
mcporter call serper.google_search q="site:[publication].substack.com [title]" num=5
```

Log in `marketing/substack/research/seo-tracker.md`.

---

## Content Strategy Guidelines

- 3 posts/week minimum first 2 months (domain authority building)
- Content mix: 40% evergreen, 30% timely, 30% listicles
- Pillar + cluster: 1 comprehensive pillar (3000+), 5-8 cluster posts linking back
- **Feature landing pages:** create keywordable product feature pages with clear slugs and use cases
- **Directories/listings:** only if you can add real differentiation. Track outcomes, prune fast
- **Keyword mix:** combine winnable terms with 1-2 competitive stretch terms per cluster

---

## Semantic Optimization

Target concept clusters, not individual keywords. Articles covering 15+ related concepts rank ~3x better than those covering 5.

### Semantic Concept Extraction

Use AI to analyze top-ranking pages and extract the concept universe:

```
Prompt: "Analyze top 10 results for [keyword]. Extract:
- Main concepts covered
- Related subtopics
- Technical terms used
- Questions answered
- Entities mentioned (products, people, companies)
- User problems addressed
Create semantic map."
```

### Co-Occurrence Analysis

Find term pairs that frequently appear together in top results:

```
Prompt: "Find terms that frequently co-occur with [topic].
Analyze top 30 results. List term pairs that appear together."
```

Include these pairs naturally in content (e.g., "pipeline + visualization", "automation + workflows").

### Semantic Audit (Content Refresh)

Audit existing articles for concept coverage gaps:

```
Prompt: "Audit this article for semantic completeness:
[paste article]

What concepts are:
✅ Well covered
⚠️ Partially covered
❌ Missing entirely
🔴 Covered too deeply (unnecessary)

Suggest improvements to concept coverage."
```

Use this when refreshing underperforming content. Fill ❌ gaps, trim 🔴 excess.

### Internal Linking by Semantic Relationship

Link to conceptually related content, not just keyword-related. Example for a "HubSpot CRM" article:

- ✅ Pipeline management best practices (related concept)
- ✅ Email tracking technology explained (feature deep-dive)
- ✅ CRM data migration guide (related process)
- ❌ Another "best CRM" listicle (same keyword, not same concept)

---

## On-Page SEO Quick Reference

- Unique title tags: 50-60 chars, keyword near beginning
- Unique meta descriptions: 150-160 chars, includes CTA
- One H1 per page with primary keyword
- Logical heading hierarchy (H1 → H2 → H3)
- Alt text on all images
- Internal links with descriptive anchor text
- Canonical tags present and self-referencing

---

## AI Search Quick Reference

For full strategy, read `references/ai-seo.md`. To get actual AI search volume data for keywords, use the DataForSEO `dataforseo` skill (endpoint 8 — AI Search Volume). Tracks how often queries are asked in ChatGPT/Perplexity/etc. with 12-month trend. Key principles:
- Lead every section with direct answer (40-60 words)
- Include statistics with cited sources (+37-40% citation boost)
- Expert attribution and author bios
- Comparison tables for "X vs Y" content
- "Last updated: [date]" prominently displayed
- Don't block AI bots (GPTBot, PerplexityBot, ClaudeBot)
- Optimal AI citation passage: 134-167 words
- Brand mentions correlate 3x more with AI visibility than backlinks
- **AI share buttons:** add “Summarize with AI” buttons that open ChatGPT/Perplexity with a brand-framed prompt
- **LLMs.txt:** not a priority. Do standard SEO well before touching this
- **Engagement signals:** high bounce and low session duration can suppress rankings. Fix UX before more content

---

## Schema Quick Reference

For full guide, read `references/seo-schema.md`. Key types for Bloom:
- `Article` / `BlogPosting`: headline, image, datePublished, author
- `SoftwareApplication`: app pages (name, offers, aggregateRating)
- `Organization`: homepage (name, url, logo, sameAs)
- `BreadcrumbList`: navigation context
- `Product`: with Certification markup (April 2025+)

Use JSON-LD format. Validate with Rich Results Test. Never recommend FAQ schema (restricted to gov/health since Aug 2023) or HowTo (deprecated Sept 2023).

---

## Technical SEO Quick Reference

For full audit checklist, read `references/seo-technical.md`. Critical items:
- robots.txt: no unintentional blocks
- XML sitemap: exists, accessible, submitted
- HTTPS enforced, no mixed content
- Core Web Vitals: LCP < 2.5s, INP < 200ms, CLS < 0.1
- Mobile-first indexing: 100% complete since July 2024
- AI crawler management: allow GPTBot, ClaudeBot, PerplexityBot for visibility
- JS rendering: serve critical SEO elements in initial HTML, not JS-injected

---

## Reference Files

| File | Contents |
|------|----------|
| `references/ai-seo.md` | Full AI search optimization strategy: audit, 3 pillars, GEO benchmarks, content types, monitoring tools |
| `references/programmatic-seo.md` | Full programmatic SEO guide: 12 playbooks, quality gates, scaled content abuse enforcement, implementation |
| `references/seo-technical.md` | Technical audit: crawlability, indexability, security, URL structure, mobile, CWV, JS rendering, AI crawlers |
| `references/seo-schema.md` | Schema.org: detection, validation, JSON-LD generation, current type status (Feb 2026) |
| `references/seo-content-eeat.md` | E-E-A-T framework, content metrics, AI content assessment, citation readiness |
| `references/seo-competitor-pages.md` | "X vs Y" and "alternatives" page templates (in competitive-analysis/references/) |
| `references/platform-ranking-factors.md` | How each AI platform selects sources |
| `references/content-patterns.md` | Content block templates for AI citability |
| `references/playbooks.md` | Detailed programmatic SEO playbook specs |
| `references/schema-types.md` | Full schema type reference |
| `references/eeat-framework.md` | Detailed E-E-A-T criteria |
| `references/quality-gates.md` | Content quality thresholds |
| `references/cwv-thresholds.md` | Core Web Vitals thresholds |
| `references/keyword-seeds.md` | Bloom keyword seed list |

---

## Related Skills

- **trend-scout** — viral content signals (complements SEO)
- **headlines** — turns keyword research into titles
- **content-calendar** — tracks research → written → published
- **competitive-analysis** — competitor comparison pages (see references/seo-competitor-pages.md)
