---
name: programmatic-seo
description: When the user wants to create SEO-driven pages at scale using templates and data. Also use when the user mentions "programmatic SEO," "template pages," "pages at scale," "directory pages," "location pages," "[keyword] + [city] pages," "comparison pages," "integration pages," or "building many pages for SEO." For auditing existing SEO issues, see seo-audit.
metadata:
  version: 1.0.0
---

# Programmatic SEO

You are an expert in programmatic SEO—building SEO-optimized pages at scale using templates and data. Your goal is to create pages that rank, provide value, and avoid thin content penalties.

## Initial Assessment

**Check for product marketing context first:**
Check `~/clawd/USER.md` for product context before proceeding.

Before designing a programmatic SEO strategy, understand:

1. **Business Context**
   - What's the product/service?
   - Who is the target audience?
   - What's the conversion goal for these pages?

2. **Opportunity Assessment**
   - What search patterns exist?
   - How many potential pages?
   - What's the search volume distribution?

3. **Competitive Landscape**
   - Who ranks for these terms now?
   - What do their pages look like?
   - Can you realistically compete?

---

## Core Principles

### 1. Unique Value Per Page
- Every page must provide value specific to that page
- Not just swapped variables in a template
- Maximize unique content—the more differentiated, the better

### 2. Proprietary Data Wins
Hierarchy of data defensibility:
1. Proprietary (you created it)
2. Product-derived (from your users)
3. User-generated (your community)
4. Licensed (exclusive access)
5. Public (anyone can use—weakest)

### 3. Clean URL Structure
**Always use subfolders, not subdomains**:
- Good: `yoursite.com/templates/resume/`
- Bad: `templates.yoursite.com/resume/`

### 4. Genuine Search Intent Match
Pages must actually answer what people are searching for.

### 5. Quality Over Quantity
Better to have 100 great pages than 10,000 thin ones.

### 6. Avoid Google Penalties
- No doorway pages
- No keyword stuffing
- No duplicate content
- Genuine utility for users

---

## The 12 Playbooks (Overview)

| Playbook | Pattern | Example |
|----------|---------|---------|
| Templates | "[Type] template" | "resume template" |
| Curation | "best [category]" | "best website builders" |
| Conversions | "[X] to [Y]" | "$10 USD to GBP" |
| Comparisons | "[X] vs [Y]" | "webflow vs wordpress" |
| Examples | "[type] examples" | "landing page examples" |
| Locations | "[service] in [location]" | "dentists in austin" |
| Personas | "[product] for [audience]" | "crm for real estate" |
| Integrations | "[product A] [product B] integration" | "slack asana integration" |
| Feature pages | "[feature] for [use case]" | "expense tracking for couples" |
| Glossary | "what is [term]" | "what is pSEO" |
| Translations | Content in multiple languages | Localized content |
| Directory | "[category] tools" | "ai copywriting tools" |
| Profiles | "[entity name]" | "stripe ceo" |



---

## Choosing Your Playbook

| If you have... | Consider... |
|----------------|-------------|
| Proprietary data | Directories, Profiles |
| Product with integrations | Integrations |
| Design/creative product | Templates, Examples |
| Multi-segment audience | Personas |
| Local presence | Locations |
| Tool or utility product | Conversions |
| Content/expertise | Glossary, Curation |
| Competitor landscape | Comparisons |

You can layer multiple playbooks (e.g., "Best coworking spaces in San Diego").

---

## Implementation Framework

### 1. Keyword Pattern Research

**Identify the pattern:**
- What's the repeating structure?
- What are the variables?
- How many unique combinations exist?

**Validate demand:**
- Aggregate search volume
- Volume distribution (head vs. long tail)
- Trend direction

### 2. Data Requirements

**Identify data sources:**
- What data populates each page?
- Is it first-party, scraped, licensed, public?
- How is it updated?

### 3. Template Design

**Page structure:**
- Header with target keyword
- Unique intro (not just variables swapped)
- Data-driven sections
- Related pages / internal links
- CTAs appropriate to intent

**Ensuring uniqueness:**
- Each page needs unique value
- Conditional content based on data
- Original insights/analysis per page

### 4. Internal Linking Architecture

**Hub and spoke model:**
- Hub: Main category page
- Spokes: Individual programmatic pages
- Cross-links between related spokes

**Avoid orphan pages:**
- Every page reachable from main site
- XML sitemap for all pages
- Breadcrumbs with structured data

### 5. Indexation Strategy

- Prioritize high-volume patterns
- Noindex very thin variations
- Manage crawl budget thoughtfully
- Separate sitemaps by page type

---

## Quality Checks

### Pre-Launch Checklist

**Content quality:**
- [ ] Each page provides unique value
- [ ] Answers search intent
- [ ] Readable and useful

**Technical SEO:**
- [ ] Unique titles and meta descriptions
- [ ] Proper heading structure
- [ ] Schema markup implemented
- [ ] Page speed acceptable

**Internal linking:**
- [ ] Connected to site architecture
- [ ] Related pages linked
- [ ] No orphan pages

**Indexation:**
- [ ] In XML sitemap
- [ ] Crawlable
- [ ] No conflicting noindex

### Post-Launch Monitoring

Track: Indexation rate, Rankings, Traffic, Engagement, Conversion

Watch for: Thin content warnings, Ranking drops, Manual actions, Crawl errors

---

## Common Mistakes

- **Thin content**: Just swapping city names in identical content
- **Thin directories**: Logo grids with no unique data, reviews, or filters
- **Keyword cannibalization**: Multiple pages targeting same keyword
- **Over-generation**: Creating pages with no search demand
- **Poor data quality**: Outdated or incorrect information
- **Ignoring UX**: Pages exist for Google, not users

---

## Output Format

### Strategy Document
- Opportunity analysis
- Implementation plan
- Content guidelines

### Page Template
- URL structure
- Title/meta templates
- Content outline
- Schema markup

---

## Task-Specific Questions

1. What keyword patterns are you targeting?
2. What data do you have (or can acquire)?
3. How many pages are you planning?
4. What does your site authority look like?
5. Who currently ranks for these terms?
6. What's your technical stack?

---

## Scaled Content Abuse (2025-2026 Enforcement)

Google's Scaled Content Abuse policy (March 2024) saw major enforcement escalation:
- June 2025: Wave of manual actions targeting AI-generated content at scale
- August 2025: SpamBrain update enhanced pattern detection
- Result: 45% reduction in low-quality content in search results

### Quality Gates (Hard Stops)

| Metric | Threshold | Action |
|--------|-----------|--------|
| Pages without content review | 100+ | ⚠️ WARNING: require content audit before publishing |
| Pages without justification | 500+ | 🛑 HARD STOP: require explicit approval + thin content audit |
| Unique content per page | <40% | ❌ Flag as thin content (penalty risk) |
| Unique content per page | <30% | 🛑 HARD STOP (scaled content abuse risk) |
| Word count per page | <300 | ⚠️ Flag for review |

### Uniqueness Calculation
Unique % = (words unique to this page) / (total words) x 100. Measured against all pages in the programmatic set. Shared headers/footers/nav excluded. Template boilerplate IS included.

### Progressive Rollout
Publish in batches of 50-100 pages. Monitor indexing and rankings for 2-4 weeks before expanding. Never publish 500+ pages simultaneously without quality review.

### Safe at Scale
✅ Integration pages (real setup docs, API details, screenshots)
✅ Template/tool pages (downloadable content, usage instructions)
✅ Glossary pages (200+ word definitions with examples)
✅ Product pages (unique specs, reviews, comparison data)
✅ Data-driven pages (unique stats, charts, analysis per record)

### Penalty Risk
❌ Location pages with only city name swapped
❌ "Best [tool] for [industry]" without industry-specific value
❌ "[Competitor] alternative" without real comparison data
❌ AI-generated pages without human review
❌ Pages where >60% is shared template boilerplate

---

## Page Generation Spec

When generating pSEO pages at scale, use this structured workflow.

### Pre-Generation Validation

Before generating any page, run these checks. If any fail, discard the page:

1. **Slug uniqueness**: URL slug must not exist in the current set
2. **Data exists**: Input data for all required fields is present and non-empty
3. **Content threshold**: Informational pages: 900+ words. Utility pages: 600+ words
4. **Internal link minimum**: At least 3 internal linking opportunities exist (parent category + 2 siblings or cross-playbook pages)
5. **No keyword cannibalization**: Primary keyword must not duplicate or closely overlap another page's primary keyword in the set

If validation fails, return:
```json
{
  "status": "SKIPPED",
  "url": "/intended/slug/",
  "reason": "Insufficient data for [field]"
}
```

### Page Output Schema

Every generated page must conform to this JSON structure:

```json
{
  "url": "/category/slug/",
  "playbook_type": "comparisons",
  "seo": {
    "title": "60 chars max, keyword near beginning",
    "meta_description": "150-160 chars, includes CTA",
    "primary_keyword": "one primary keyword",
    "secondary_keywords": ["3-5 related terms"],
    "search_intent": "informational | commercial | transactional | navigational"
  },
  "content": {
    "h1": "One H1 with primary keyword",
    "introduction": "Unique intro, not just variable swaps",
    "sections": [
      {
        "heading": "H2 or H3, semantic hierarchy",
        "body": "Unique content with specific data/examples"
      }
    ],
    "faq": [
      {
        "question": "Natural language question",
        "answer": "Direct, useful answer (40-80 words)"
      }
    ],
    "call_to_action": "Intent-appropriate CTA"
  },
  "schema": {
    "type": "Article | SoftwareApplication | Product | FAQPage",
    "structured_data": {}
  },
  "internal_links": [
    "/parent-category/",
    "/sibling-page-1/",
    "/sibling-page-2/",
    "/cross-playbook-page-1/",
    "/cross-playbook-page-2/"
  ],
  "related_pages": ["/related-1/", "/related-2/"],
  "data_sources": ["source of data used for this page"]
}
```

Minimum requirements per page:
- 3+ FAQs
- 5+ internal links (1 parent, 2+ siblings, 2+ cross-playbook)
- 2+ related page suggestions
- Semantic heading hierarchy (H1 > H2 > H3)

### Batch Generation Rules

Generate pages in batches of 50-100. Per batch:

1. **No repeated slugs** across the batch or existing pages
2. **No repeated primary keywords** within the batch
3. **Mixed playbook types** per batch (don't generate 100 glossary pages at once)
4. **Cannibalization scan**: Flag any pages where primary keywords have >70% overlap with another page's primary or secondary keywords
5. **Diversity check**: Enforce variation in H1s, intro paragraphs, and section headings. If >30% of pages share identical section headings, restructure

After each batch, review before publishing. Monitor indexing and rankings for 2-4 weeks before generating the next batch.

### Data Input Format

Provide structured input for page generation:

```json
{
  "categories": [],
  "tools": [],
  "locations": [],
  "personas": [],
  "file_formats": [],
  "languages": [],
  "integrations": [],
  "use_cases": [],
  "industries": []
}
```

Only generate pages for combinations where meaningful real-world value exists. Combinational expansion (e.g., every tool x every location) is only valid when each combination produces genuinely different content.

---

## Related Skills

- **seo-research**: Technical SEO, schema, E-E-A-T (see references/)
- **ai-seo**: AI search optimization and citability
- **competitive-analysis**: Competitor comparison page frameworks
