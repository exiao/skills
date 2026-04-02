---
name: paid-ads
description: "When the user wants help with paid advertising campaigns on Google Ads, Meta, LinkedIn, Twitter/X, or other platforms. Use when someone mentions 'PPC,' 'paid media,' 'ROAS,' 'CPA,' 'ad campaign,' 'retargeting,' 'Google Ads,' 'Facebook ads,' 'ad budget,' or 'should I run ads.' For Meta API operations, see meta-ads."
metadata:
  version: 1.0.0
---

# Paid Ads

Expert performance marketer. Create, optimize, and scale paid advertising campaigns for efficient customer acquisition.

## Before Starting

Read `.agents/product-marketing-context.md` if it exists — it contains product name, audience, and brand voice.

Gather this context (ask if not provided):

### 1. Campaign Goals
- Primary objective? (Awareness, traffic, leads, sales, app installs)
- Target CPA or ROAS?
- Monthly/weekly budget?

### 2. Product & Offer
- What are you promoting?
- Landing page URL?

### 3. Audience
- Ideal customer?
- What are they searching for or interested in?
- Existing customer data for lookalikes?

### 4. Current State
- Previous ad experience? What worked?
- Pixel/conversion data?

---

## Platform Selection Guide

| Platform | Best For | Use When |
|----------|----------|----------|
| **Google Ads** | High-intent search traffic | People actively search for your solution |
| **Meta** | Demand generation, visual products | Creating demand, strong creative assets |
| **LinkedIn** | B2B, decision-makers | Job title/company targeting matters |
| **Twitter/X** | Tech audiences, thought leadership | Audience is active on X |
| **TikTok** | Younger demographics, viral creative | Audience skews 18-34, video capacity |

---

## Campaign Structure

```
Account
├── Campaign 1: [Objective] - [Audience/Product]
│   ├── Ad Set 1: [Targeting variation]
│   │   ├── Ad 1-3: [Creative variations]
│   └── Ad Set 2: [Targeting variation]
└── Campaign 2...
```

### Naming Convention
```
[Platform]_[Objective]_[Audience]_[Offer]_[Date]
META_Conv_Lookalike-Customers_FreeTrial_2024Q1
```

### Budget Allocation

**Testing phase (first 2-4 weeks):** 70% proven/safe, 30% testing new audiences/creative.

**Scaling phase:** Consolidate into winners. Increase budgets 20-30% at a time. Wait 3-5 days between increases.

---

## Ad Copy Frameworks

**Problem-Agitate-Solve (PAS):** [Problem] → [Agitate the pain] → [Introduce solution] → [CTA]

**Before-After-Bridge (BAB):** [Current painful state] → [Desired future state] → [Your product as bridge]

**Social Proof Lead:** [Impressive stat or testimonial] → [What you do] → [CTA]

---

## Audience Targeting

| Platform | Key Targeting | Best Signals |
|----------|---------------|--------------|
| Google | Keywords, search intent | What they're searching |
| Meta | Interests, behaviors, lookalikes | Engagement patterns |
| LinkedIn | Job titles, companies, industries | Professional identity |

- **Lookalikes**: Base on best customers (by LTV), not all customers
- **Retargeting**: Segment by funnel stage
- **Exclusions**: Exclude existing customers and recent converters

---

## Creative Best Practices

### Image Ads
- Clear product screenshots, before/after comparisons
- Stats and numbers as focal point
- Human faces (real, not stock)
- Bold readable text overlay (under 20%)

### Video Ads (15-30 sec)
1. Hook (0-3 sec): Pattern interrupt or bold statement
2. Problem (3-8 sec): Relatable pain point
3. Solution (8-20 sec): Show product/benefit
4. CTA (20-30 sec): Clear next step

Captions always (85% watch without sound). Native feel outperforms polished.

### Testing Hierarchy
1. Concept/angle (biggest impact)
2. Hook/headline
3. Visual style
4. Body copy
5. CTA

---

## Campaign Optimization

**If CPA is too high:** Check landing page, tighten targeting, test new creative, improve quality score, adjust bid strategy.

**If CTR is low:** New hooks/angles, refine targeting, refresh creative.

**If CPM is high:** Expand targeting, try different placements, improve creative fit.

### Bid Strategy Progression
1. Start with manual or cost caps
2. Gather 50+ conversions
3. Switch to automated with targets
4. Monitor and adjust

---

## Retargeting

| Funnel Stage | Audience | Message |
|--------------|----------|---------|
| Top | Blog readers, video viewers | Educational, social proof |
| Middle | Pricing/feature visitors | Case studies, demos |
| Bottom | Cart abandoners, trial users | Urgency, objection handling |

### Windows
- Hot (cart/trial): 1-7 days, higher frequency OK
- Warm (key pages): 7-30 days, 3-5x/week
- Cold (any visit): 30-90 days, 1-2x/week

---

## Reporting

### Weekly Review
- Spend vs. budget pacing
- CPA/ROAS vs. targets
- Top/bottom performing ads
- Frequency check (fatigue risk)
- Landing page conversion rate

### Attribution
- Platform attribution is inflated
- Use UTM parameters consistently
- Look at blended CAC, not just platform CPA

---

## Pre-Launch Checklist

- [ ] Conversion tracking tested with real conversion
- [ ] Landing page loads fast (<3 sec) and is mobile-friendly
- [ ] UTM parameters working
- [ ] Budget set correctly
- [ ] Targeting matches intended audience

---

## Common Mistakes

- Launching without conversion tracking
- Too many campaigns (fragmenting budget)
- Not giving algorithms enough learning time
- Only one ad per ad set
- Not refreshing creative (fatigue)
- Mismatch between ad and landing page
- Spreading budget too thin

---

## Related Skills

- **meta-ads**: For Meta Marketing API operations
- **google-ads**: For Google Ads API operations
- **copywriting**: For landing page and ad copy
- **growth**: For post-click conversion optimization
- **marketing-psychology**: For ad psychology principles
