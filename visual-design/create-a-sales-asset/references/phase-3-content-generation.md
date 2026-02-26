# Phase 3: Content Generation

### Principles

- Reference **specific pain points** from input or transcripts
- Use **prospect's language** (their terminology, stated priorities)
- Map **seller's product → prospect's needs** explicitly
- Include **proof points** where available
- Feel **tailored, not templated**

### Section Templates

**Hero / Intro:**
- Headline: "[Prospect's Goal] with [Seller's Product]"
- Subhead: tied to stated priority or industry challenge
- Metrics: 3-4 key facts about the prospect

**Their Priorities (discovery follow-up):**
- Reference specific pain points from conversation
- Use their exact words where possible
- Connect each to how you help

**Solution Mapping (per pain point):**
- The challenge (in their words)
- How [Product] addresses it
- Proof point or example
- Outcome / benefit

**ROI / Business Case:**
- Interactive calculator with inputs relevant to their business
- Annual value / savings, cost of solution, net ROI, payback period
- Assumptions clearly stated and editable

**Why Us / Differentiators:**
- Differentiators vs. alternatives they might consider
- Trust, security, compliance
- Support and partnership model
- Customer proof points

**Next Steps / CTA:**
- Clear action aligned to purpose
- Specific next step (not vague)
- Contact info, suggested timeline

### Workflow Demo Content

**Component definitions:**
```yaml
component:
  id: "snowflake"
  label: "Snowflake Data Warehouse"
  type: "database"  # database | api | ai | middleware | human | document | output
  description: "Financial performance data"
  brand_color: "#29B5E8"
```

**Flow steps:**
```yaml
step:
  number: 1
  from: "human"
  to: "claude"
  action: "Initiates performance review"
  description: "Sarah, a Brand Analyst at [Prospect], kicks off the quarterly review..."
  data_example: "Review request: Nike brand, Q4 2025"
  duration: "~1 second"
  value_note: "No manual data gathering required"
```

Write a specific scenario narrative walking through each step with real names, real data examples, and clear value callouts.

---
