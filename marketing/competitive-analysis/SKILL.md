---
name: competitive-analysis
description: Use when researching competitors and building interactive battlecards.
---

# Competitive Analysis

Research competitors extensively, analyze positioning and messaging, then generate an **interactive HTML battlecard** with comparison matrix and per-competitor deep-dives.

## Quick Reference

| Task | How |
|------|-----|
| Start analysis | Provide your company/product + list 1-5 competitors |
| Research scope | Features, pricing, messaging, recent releases (90 days), reviews, hiring signals |
| Key tools | Serper web search, Firecrawl for deep scraping |
| Primary output | Self-contained interactive HTML battlecard (dark theme) |
| Battlecard sections | Comparison matrix, per-competitor deep-dives, positioning map |
| Sales enablement | Talk tracks and landmine questions included per competitor |
| Save output | `~/marketing/competitive/[CompetitorName]-battlecard.html` |

## Execution Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                   COMPETITIVE ANALYSIS                           │
├─────────────────────────────────────────────────────────────────┤
│  RESEARCH (always, via web + tools)                              │
│  ✓ Product deep-dive: features, pricing, positioning            │
│  ✓ Messaging analysis: taglines, value props, narrative arcs    │
│  ✓ Recent releases: what they've shipped (last 90 days)         │
│  ✓ Content & SEO: topics, formats, keyword gaps                 │
│  ✓ Reviews & sentiment: G2, Capterra, app stores               │
│  ✓ Hiring signals: what roles reveal about strategy             │
├─────────────────────────────────────────────────────────────────┤
│  ANALYSIS                                                        │
│  ✓ Differentiation matrix: where you win vs. where they win     │
│  ✓ Positioning map: 2x2 on key market dimensions                │
│  ✓ Narrative comparison: villain, hero, transformation, stakes  │
│  ✓ Content gaps: topics/formats you're missing                  │
│  ✓ Messaging vulnerabilities: clarity, proof, consistency       │
│  ✓ Talk tracks & landmine questions                             │
├─────────────────────────────────────────────────────────────────┤
│  OUTPUT                                                          │
│  ✓ Interactive HTML battlecard (self-contained, dark theme)     │
│  ✓ Comparison matrix overview tab                                │
│  ✓ Clickable per-competitor cards                               │
│  ✓ Positioning map visualization                                │
│  ✓ Shareable: host anywhere or send as file                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Context Collection

### Identify Your Company

If not already known from user context:
1. Ask: "What company/product is this for?"
2. Ask: "Who are your main competitors? (1-5)"

Store for reuse:
```yaml
seller:
  company: "[Name]"
  product: "[Product/Service]"
  value_props: ["...", "...", "..."]
  differentiators: ["...", "..."]
  pricing_model: "[If known]"
```

### Optional Context
- Which competitor to focus on first?
- Specific deals where you're competing?
- Known customer pain points about competitors?
- Your recent releases or changelog?

---

## Phase 2: Research

### Tooling

Use available tools to gather real data:
- **web-search**: Google search for competitor pages, news, reviews
- **web_fetch**: Pull and analyze competitor websites, landing pages, blog posts
- **bird**: Monitor competitor Twitter/X presence and engagement
- **browser**: Deep-dive competitor apps, product pages, pricing pages
- **seo-research**: Keyword overlap and content gap analysis
- **appfigures**: App store rankings, ratings, reviews for competing apps

### Research Your Company

```
Web searches:
1. "[Your company] product" — current offerings
2. "[Your company] pricing" — pricing model
3. "[Your company] news" — recent announcements (90 days)
4. "[Your company] product updates OR changelog OR releases" — what you've shipped
5. "[Your company] vs [competitor]" — existing comparisons
```

### Research Each Competitor

```
For each competitor:
1. "[Competitor] product features" — what they offer
2. "[Competitor] pricing" — how they charge
3. "[Competitor] news" — recent announcements
4. "[Competitor] product updates OR changelog OR releases" — recent ships
5. "[Competitor] reviews G2 OR Capterra OR TrustRadius" — customer sentiment
6. "[Competitor] vs [alternatives]" — how they position
7. "[Competitor] customers" — who uses them
8. "[Competitor] careers" — hiring signals (growth areas)
```

### Research Sources

#### Primary Sources (Direct from Competitor)
- **Website**: homepage, product pages, pricing, about page, careers
- **Blog and resource center**: content themes, publishing frequency, depth
- **Social media**: messaging, engagement, content strategy
- **Product demos and free trials**: UX, features, onboarding
- **Press releases**: announcements, partnerships, milestones
- **Job postings**: hiring signals revealing strategic priorities

#### Secondary Sources (Third-Party)
- **Review sites**: G2, Capterra, TrustRadius, Product Hunt
- **Analyst reports**: Gartner, Forrester (if available)
- **News coverage**: TechCrunch, industry publications
- **SEO tools**: keyword rankings, organic traffic, content gaps, top traffic sources, backlink profiles
- **Financial filings**: revenue, growth (public companies)
- **Community forums**: Reddit, Discourse, Slack communities
- **App stores**: ratings, reviews, download trends (via appfigures)

---

## Phase 3: Analysis Frameworks

### Messaging Matrix

Compare messaging across competitors:

| Dimension | Your Company | Competitor A | Competitor B |
|-----------|-------------|--------------|--------------|
| Tagline/Headline | | | |
| Core value proposition | | | |
| Primary audience | | | |
| Key differentiator claim | | | |
| Tone/Voice | | | |
| Proof points used | | | |
| Category framing | | | |
| Primary CTA | | | |

### Value Proposition Comparison

For each competitor:
- **Promise**: what they promise the customer will achieve
- **Evidence**: how they prove it (data, testimonials, demos)
- **Mechanism**: how their product delivers (the "how it works")
- **Uniqueness**: what they claim only they can do

### Narrative Analysis

Identify each competitor's story arc:
- **Villain**: what problem or enemy they position against
- **Hero**: who is the hero (the customer? the product?)
- **Transformation**: what before/after do they promise?
- **Stakes**: what happens if you don't act?

### Messaging Vulnerabilities

For each competitor's messaging, assess:
- **Clarity**: can a visitor understand what they do in 5 seconds?
- **Differentiation**: distinct positioning or generic?
- **Proof**: claims backed by evidence?
- **Consistency**: messaging consistent across channels?
- **Resonance**: addresses real customer pain?

### Positioning Map

Plot competitors on a 2x2 using the two most important market dimensions:

Common axis pairs:
- Price vs. Capability
- Ease of Use vs. Power
- SMB vs. Enterprise Focus
- Point Solution vs. Platform
- Innovative vs. Established

Identify which quadrant is underserved or where your differentiation is strongest.

### Category Strategy Assessment

For each competitor (and yourself), identify their strategy:
- **Create a new category**: genuinely different, define and own it
- **Reframe existing category**: change evaluation criteria to favor strengths
- **Win existing category**: compete directly, out-execute
- **Niche within category**: own a specific segment or use case

### Content Gap Analysis

Map content across competitors:

| Topic/Theme | Your Content | Competitor A | Competitor B | Gap? |
|-------------|-------------|--------------|--------------|------|
| [Topic 1] | Blog post | Blog series, webinar | Nothing | Opportunity |
| [Topic 2] | Nothing | Whitepaper | Blog, video | Gap for you |

Identify:
1. Topics they cover that you don't
2. Topics you cover that they don't (amplify these)
3. Formats they use that you don't
4. Audience segments they address that you don't
5. Search terms they rank for that you don't

---

## Phase 4: Data Structure

Structure findings per competitor:

```yaml
competitor:
  name: "[Name]"
  website: "[URL]"
  profile:
    founded: "[Year]"
    funding: "[Stage + amount]"
    employees: "[Count]"
    target_market: "[Who they sell to]"
    pricing_model: "[Per seat / usage / etc.]"
    market_position: "[Leader / Challenger / Niche]"

  what_they_sell: "[Product summary]"
  their_positioning: "[How they describe themselves]"
  positioning_statement: "For [audience], [product] is the [category] that [benefit] because [reason]."

  narrative:
    villain: "[Enemy they position against]"
    hero: "[Who's the hero]"
    transformation: "[Before/after promise]"
    stakes: "[What if you don't act]"

  recent_releases:
    - date: "[Date]"
      release: "[Feature/Product]"
      impact: "[Why it matters]"

  where_they_win:
    - area: "[Area]"
      advantage: "[Their strength]"
      how_to_handle: "[Your counter]"

  where_you_win:
    - area: "[Area]"
      advantage: "[Your strength]"
      proof_point: "[Evidence]"

  pricing:
    model: "[How they charge]"
    entry_price: "[Starting price]"
    enterprise: "[Enterprise pricing]"
    hidden_costs: "[Implementation, etc.]"
    talk_track: "[How to discuss pricing]"

  messaging_assessment:
    clarity: "[1-5 + notes]"
    differentiation: "[1-5 + notes]"
    proof: "[1-5 + notes]"
    consistency: "[1-5 + notes]"
    resonance: "[1-5 + notes]"

  content_strategy:
    blog_frequency: "[Posts/month]"
    key_topics: ["...", "..."]
    formats: ["...", "..."]
    seo_strengths: ["...", "..."]

  talk_tracks:
    early_mention: "[If they come up early in conversation]"
    displacement: "[If customer currently uses them]"
    late_addition: "[If added late to evaluation]"

  objections:
    - objection: "[What customer says]"
      response: "[How to handle]"

  landmines:
    - "[Question that exposes their weakness]"
```

---

## Phase 5: Build HTML Battlecard

Generate a self-contained HTML file with:

### 1. Comparison Matrix (Landing View)
- Feature comparison grid
- Pricing comparison
- Market positioning overview
- Color-coded: green = you win, red = they win, yellow = tie

### 2. Positioning Map
- Interactive 2x2 plot
- Each competitor as a labeled dot
- Axis labels based on chosen dimensions

### 3. Competitor Tabs (Click to Expand)
Each competitor gets a card showing:
- Company profile (size, funding, target market)
- Their positioning and narrative
- Recent releases (last 90 days)
- Where they win vs. where you win
- Pricing intel
- Talk tracks by scenario
- Objection handling
- Landmine questions
- Messaging vulnerability assessment

### 4. Your Company Card
- Your recent releases (last 90 days)
- Key differentiators with proof points
- Content gaps and opportunities

### HTML Structure

```html
<!DOCTYPE html>
<html>
<head>
    <title>Battlecard: [Company] vs Competitors</title>
    <style>
        :root {
            --bg-primary: #0a0d14;
            --bg-elevated: #0f131c;
            --bg-surface: #161b28;
            --bg-hover: #1e2536;
            --text-primary: #ffffff;
            --text-secondary: rgba(255, 255, 255, 0.7);
            --text-muted: rgba(255, 255, 255, 0.5);
            --accent: #3b82f6;
            --accent-hover: #2563eb;
            --you-win: #10b981;
            --they-win: #ef4444;
            --tie: #f59e0b;
        }
        /* Dark theme, tabbed nav, expandable cards, responsive */
    </style>
</head>
<body>
    <header>
        <h1>[Company] Competitive Battlecard</h1>
        <p>Generated: [Date] | Competitors: [List]</p>
    </header>

    <nav class="tabs">
        <button class="tab active" data-tab="matrix">Comparison Matrix</button>
        <button class="tab" data-tab="positioning">Positioning Map</button>
        <button class="tab" data-tab="competitor-1">[Competitor 1]</button>
        <button class="tab" data-tab="competitor-2">[Competitor 2]</button>
    </nav>

    <section id="matrix" class="tab-content active">
        <h2>Head-to-Head Comparison</h2>
        <table class="comparison-matrix">
            <!-- Feature rows, color-coded winners -->
        </table>
    </section>

    <section id="positioning" class="tab-content">
        <h2>Market Positioning</h2>
        <!-- 2x2 positioning map -->
    </section>

    <section id="competitor-1" class="tab-content">
        <div class="battlecard">
            <div class="profile"><!-- Company info --></div>
            <div class="narrative"><!-- Villain/hero/transformation --></div>
            <div class="differentiation"><!-- Win/loss areas --></div>
            <div class="messaging"><!-- Vulnerability assessment --></div>
            <div class="talk-tracks"><!-- Scenario positioning --></div>
            <div class="objections"><!-- Objection handling --></div>
            <div class="landmines"><!-- Questions to ask --></div>
        </div>
    </section>

    <script>
        // Tab switching, expand/collapse, positioning map rendering
    </script>
</body>
</html>
```

### Card Design
- Rounded corners (12px)
- Subtle borders (1px, low opacity)
- Hover states with slight elevation
- Smooth transitions (200ms)
- Sticky header row on comparison table

---

## Delivery

```markdown
## ✓ Battlecard Created

[View your battlecard](file path or hosted URL)

**Summary**
- **Your Company**: [Name]
- **Competitors Analyzed**: [List]
- **Data Sources**: Web research [+ app store data] [+ SEO data]

**Key Findings**
- [Top 3 insights from the analysis]

**Content Gaps Identified**
- [Top opportunities you're missing]

**How to Use**
- Before a call: open the relevant competitor tab, review talk tracks
- During a call: reference landmine questions
- For content: check content gaps tab for topic ideas

**Keep it Fresh**
Run again to refresh. Recommended: monthly or before major campaigns.
```

---

## Refresh Cadence

| Trigger | Action |
|---------|--------|
| **Monthly** | Quick refresh: new releases, news, pricing changes |
| **Quarterly** | Deep analysis: full research across all sources |
| **Before major campaign** | Focused refresh for positioning decisions |
| **Competitor announcement** | Immediate update on that competitor |
| **After app store review trends shift** | Update sentiment analysis |

---

## Competitor Comparison Pages (SEO Assets)

Beyond internal battlecards, competitive analysis feeds SEO-targeted comparison pages. Four formats:

### Format 1: [Competitor] Alternative (Singular)
**Target:** "alternative to [Competitor]"
**Structure:** Why people look for alternatives → You as the alternative → Detailed comparison → Who should switch (and who shouldn't) → Migration path → Switcher testimonials → CTA

### Format 2: [Competitor] Alternatives (Plural)
**Target:** "best [Competitor] alternatives"
**Structure:** Common pain points → Evaluation criteria → List of 4-7 real alternatives (you first, but include genuine options) → Comparison table → Recommendation by use case → CTA
**Key:** Being genuinely helpful builds trust and ranks better.

### Format 3: You vs [Competitor]
**Target:** "[You] vs [Competitor]"
**Structure:** TL;DR (2-3 sentences) → At-a-glance table → Detailed comparison by category → Who each is best for (be honest) → Switcher testimonials → CTA

### Format 4: [Competitor A] vs [Competitor B]
**Target:** Capture traffic for competitor-vs-competitor searches.
**Structure:** Overview of both → Comparison by category → Who each is best for → "The third option" (introduce yourself) → Three-way table → CTA

### Page Quality Rules
- Go beyond feature checklists. Explain why differences matter.
- Acknowledge competitor strengths honestly. Readers will verify.
- Include pricing comparisons with hidden costs.
- Add FAQ schema for common comparison questions.
- Update quarterly with fresh pricing, feature changes, and screenshots.

### Content Architecture
Centralize competitor data so updates propagate to all pages:
- One source of truth per competitor (pricing, features, strengths/weaknesses)
- Modular sections that can be reused across page formats
- Internal linking between related comparison pages

---

## Common Mistakes

1. **Researching features, not outcomes** — Listing what competitors have instead of what customers achieve with them. Outcome-level differentiation is what wins sales conversations.
2. **Stale intel** — Competitive landscapes shift quarterly. Using 6-month-old data on pricing or feature parity leads to embarrassing sales calls. Date-stamp everything.
3. **Skipping hiring signals** — Job postings reveal roadmap priorities more reliably than marketing copy. Missing this layer means missing strategic intent.
4. **Generic vs. specific** — Writing "they have a strong UX" instead of citing real G2 review quotes or specific UI patterns. Specificity is credibility.
5. **Forgetting talk tracks** — Producing a research doc without the corresponding "how to handle objection X" language. Battlecards without talk tracks don't get used.

## Principles

1. **Be honest about weaknesses.** Credibility comes from acknowledging where competitors are strong.
2. **Outcomes over features.** "They have X feature" matters less than "customers achieve Y result."
3. **Plant landmines, don't badmouth.** Ask questions that expose weaknesses naturally.
4. **Track releases religiously.** What they ship tells you their strategy.
5. **Date-stamp everything.** Competitive intel has a short shelf life.
6. **Specific beats generic.** Real numbers, real quotes, real examples. Never "they're a strong competitor."

## Reference Files

| File | Contents |
|------|----------|
| `references/seo-competitor-pages.md` | Templates for "X vs Y" comparison pages, "alternatives to X" pages, feature matrices, schema markup (Product, SoftwareApplication, ItemList), keyword targeting patterns, conversion-optimized layouts, fairness guidelines |
