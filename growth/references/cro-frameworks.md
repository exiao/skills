# CRO Frameworks Reference

Detailed conversion rate optimization frameworks for pages, signup flows, onboarding, paywalls, forms, and popups. Use this alongside the growth skill's core CRO stages.

---

## Page CRO: 7-Dimension Audit Framework

Analyze any marketing page across these dimensions, in order of impact:

### 1. Value Proposition Clarity (Highest Impact)

**Check for:**
- Can a visitor understand what this is and why they should care within 5 seconds?
- Is the primary benefit clear, specific, and differentiated?
- Is it written in the customer's language (not company jargon)?

**Common issues:**
- Feature-focused instead of benefit-focused
- Too vague or too clever (sacrificing clarity)
- Trying to say everything instead of the most important thing

### 2. Headline Effectiveness

**Evaluate:**
- Does it communicate the core value proposition?
- Is it specific enough to be meaningful?
- Does it match the traffic source's messaging?

**Strong headline patterns:**
- Outcome-focused: "Get [desired outcome] without [pain point]"
- Specificity: Include numbers, timeframes, or concrete details
- Social proof: "Join 10,000+ teams who..."

### 3. CTA Placement, Copy, and Hierarchy

**Primary CTA assessment:**
- Is there one clear primary action?
- Is it visible without scrolling?
- Does the button copy communicate value, not just action?
  - Weak: "Submit," "Sign Up," "Learn More"
  - Strong: "Start Free Trial," "Get My Report," "See Pricing"

**CTA hierarchy:**
- Is there a logical primary vs. secondary CTA structure?
- Are CTAs repeated at key decision points?

### 4. Visual Hierarchy and Scannability

**Check:**
- Can someone scanning get the main message?
- Are the most important elements visually prominent?
- Is there enough white space?
- Do images support or distract from the message?

### 5. Trust Signals and Social Proof

**Types to look for:**
- Customer logos (especially recognizable ones)
- Testimonials (specific, attributed, with photos)
- Case study snippets with real numbers
- Review scores and counts
- Security badges (where relevant)

**Placement:** Near CTAs and after benefit claims.

### 6. Objection Handling

**Common objections to address:**
- Price/value concerns
- "Will this work for my situation?"
- Implementation difficulty
- "What if it doesn't work?"

**Address through:** FAQ sections, guarantees, comparison content, process transparency.

### 7. Friction Points

**Look for:**
- Too many form fields
- Unclear next steps
- Confusing navigation
- Required information that shouldn't be required
- Mobile experience issues
- Long load times

### Page-Specific Frameworks

**Homepage CRO:** Clear positioning for cold visitors. Quick path to most common conversion. Handle both "ready to buy" and "still researching."

**Landing Page CRO:** Message match with traffic source. Single CTA (remove navigation if possible). Complete argument on one page.

**Pricing Page CRO:** Clear plan comparison. Recommended plan indication. Address "which plan is right for me?" anxiety.

**Feature Page CRO:** Connect feature to benefit. Use cases and examples. Clear path to try/buy.

**Blog Post CRO:** Contextual CTAs matching content topic. Inline CTAs at natural stopping points.

---

## Signup Flow CRO

### Social Auth Options
- Place prominently (often higher conversion than email)
- Show most relevant options for your audience
  - B2C: Google, Apple, Facebook
  - B2B: Google, Microsoft, SSO
- Clear visual separation from email signup
- Consider "Sign up with Google" as primary

### Password UX
- Show password toggle (eye icon)
- Show requirements upfront, not after failure
- Allow paste (don't disable)
- Show strength meter instead of rigid rules
- Consider passwordless options

### Mobile Signup Optimization
- Larger touch targets (44px+ height)
- Appropriate keyboard types (email, tel, etc.)
- Autofill support
- Reduce typing (social auth, pre-fill)
- Single column layout
- Sticky CTA button

### Post-Submit Experience

**Success state:**
- Clear confirmation
- Immediate next step
- If email verification required: explain what to do, easy resend, check spam reminder, option to change email

**Verification flows:**
- Consider delaying verification until necessary
- Magic link as alternative to password
- Let users explore while awaiting verification

### Common Signup Flow Patterns

| Pattern | Steps |
|---------|-------|
| B2B SaaS Trial | Email + Password (or Google auth) → Name + Company → Onboarding flow |
| B2C App | Google/Apple auth OR Email → Product experience → Profile completion later |
| Waitlist/Early Access | Email only → Optional: Role/use case question → Confirmation |
| E-commerce Account | Guest checkout as default → Account creation optional post-purchase |

---

## Onboarding CRO

### Defining Activation

**Find your aha moment:** The action that correlates most strongly with retention. What do retained users do that churned users don't?

**Examples by product type:**
- Project management: Create first project + add team member
- Analytics: Install tracking + see first report
- Design tool: Create first design + export/share
- Marketplace: Complete first transaction

### Onboarding Flow Design

| Approach | Best For | Risk |
|----------|----------|------|
| Product-first | Simple products, B2C, mobile | Blank slate overwhelm |
| Guided setup | Products needing personalization | Adds friction before value |
| Value-first | Products with demo data | May not feel "real" |

### Onboarding Checklist Pattern (3-7 items)
- Order by value (most impactful first)
- Start with quick wins
- Progress bar/completion %
- Celebration on completion
- Dismiss option (don't trap users)

### Empty States
Empty states are onboarding opportunities, not dead ends.

**Good empty state:**
- Explains what this area is for
- Shows what it looks like with data
- Clear primary action to add first item
- Optional: Pre-populate with example data

### Tooltips and Guided Tours
- Max 3-5 steps per tour
- Dismissable at any time
- Don't repeat for returning users

### Handling Stalled Users

**Detection:** Define "stalled" criteria (X days inactive, incomplete setup)

**Re-engagement tactics:**
1. Email sequence: reminder of value, address blockers, offer help
2. In-app recovery: welcome back, pick up where left off
3. Human touch: for high-value accounts, personal outreach

### Common Patterns by Product Type

| Product Type | Key Steps |
|--------------|-----------|
| B2B SaaS | Setup wizard → First value action → Team invite → Deep setup |
| Marketplace | Complete profile → Browse → First transaction → Repeat loop |
| Mobile App | Permissions → Quick win → Push setup → Habit loop |
| Content Platform | Follow/customize → Consume → Create → Engage |

---

## Paywall & Upgrade CRO

### Paywall Screen Templates

**Feature Lock Paywall:**
```
[Lock Icon]
This feature is available on Pro

[Feature preview/screenshot]

[Feature name] helps you [benefit]:
• [Capability]
• [Capability]

[Upgrade to Pro - $X/mo]
[Maybe Later]
```

**Usage Limit Paywall:**
```
You've reached your free limit

[Progress bar at 100%]

Free: 3 projects | Pro: Unlimited

[Upgrade to Pro]  [Delete a project]
```

**Trial Expiration Paywall:**
```
Your trial ends in 3 days

What you'll lose:
• [Feature used]
• [Data created]

What you've accomplished:
• Created X projects

[Continue with Pro]
[Remind me later]  [Downgrade]
```

### Timing Rules
- Show after value moment, before frustration
- After activation/aha moment
- When hitting genuine limits
- NOT during onboarding (too early)
- NOT when they're in a flow
- NOT repeatedly after dismissal
- Limit per session, cool-down after dismiss (days, not hours)

### Anti-Patterns to Avoid

**Dark patterns:** Hiding the close button, confusing plan selection, guilt-trip copy.

**Conversion killers:** Asking before value delivered, too frequent prompts, blocking critical flows, complicated upgrade process.

---

## Form CRO

### Field Cost Rule of Thumb
- 3 fields: Baseline
- 4-6 fields: 10-25% reduction
- 7+ fields: 25-50%+ reduction

For each field, ask: Is this absolutely necessary? Can we get this another way? Can we ask this later?

### Field Order
1. Start with easiest fields (name, email)
2. Build commitment before asking more
3. Sensitive fields last (phone, company size)
4. Logical grouping if many fields

### Labels and Placeholders
- Labels: Keep visible (not just placeholder). Placeholders disappear when typing, leaving users unsure what they're filling in.
- Placeholders: Examples, not labels
- Help text: Only when genuinely helpful

### Multi-Step Forms
- Progress indicator (step X of Y)
- Start with easy, end with sensitive
- One topic per step
- Allow back navigation
- Save progress (don't lose data on refresh)

### Submit Button Optimization

**Button copy:**
- Weak: "Submit" / "Send"
- Strong: "[Action] + [What they get]"
- Examples: "Get My Free Quote," "Download the Guide," "Request Demo"

### Error Handling
- Validate as they move to next field (not while typing)
- Clear visual indicators (green check, red border)
- Specific error messages near the field
- Don't clear form on error
- Focus on first error field on submit

### Form Types: Specific Guidance

| Type | Key Recommendations |
|------|-------------------|
| Lead Capture | Minimum fields (often just email), clear value prop for what they get |
| Contact Form | Email/Name + Message essential, phone optional, set response time expectations |
| Demo Request | Name, Email, Company required; phone optional with "preferred contact" choice |
| Quote/Estimate | Multi-step works well; start easy, technical details later |
| Survey | Progress bar essential, one question per screen, skip logic |

---

## Popup CRO

### Trigger Strategies

| Trigger | When | Best For |
|---------|------|----------|
| Time-based | After 30-60 seconds (not 5 seconds) | General site visitors |
| Scroll-based | 25-50% scroll depth | Blog posts, long-form content |
| Exit intent | Cursor moving to close/leave | E-commerce, lead gen |
| Click-triggered | User initiates (clicks button/link) | Lead magnets, gated content, demos |
| Page count | After visiting X pages | Multi-page journeys |
| Behavior-based | Cart abandonment, pricing page visits | High-intent segments |

### Popup Types

**Email Capture:** Clear value prop (not just "Subscribe"), specific benefit, single field, consider incentive.

**Lead Magnet:** Show what they get (cover image, preview), specific tangible promise, minimal fields.

**Discount/Promotion:** Clear discount amount, deadline creates urgency, single use per visitor.

**Exit Intent:** Acknowledge they're leaving, different offer than entry popup, address common objections.

**Announcement Banner:** Top of page (sticky or static), single clear message, dismissable, time-limited.

**Slide-In:** Enters from corner/bottom, doesn't block content, easy to dismiss.

### Copy Formulas

**Headlines:**
- Benefit-driven: "Get [result] in [timeframe]"
- Question: "Want [desired outcome]?"
- Social proof: "Join [X] people who..."
- Curiosity: "The one thing [audience] always get wrong about [topic]"

**CTA buttons:**
- First person works: "Get My Discount" vs "Get Your Discount"
- Specific: "Send Me the Guide" vs "Submit"
- Value-focused: "Claim My 10% Off" vs "Subscribe"

**Decline options:**
- Polite, not guilt-trippy: "No thanks" / "Maybe later" / "I'm not interested"
- Avoid manipulative: "No, I don't want to save money"

### Frequency and Rules
- Show maximum once per session
- Remember dismissals (cookie/localStorage)
- 7-30 days before showing again
- Exclude checkout/conversion flows
- Match offer to page context
- Exclude converted users

### Compliance and Accessibility
- GDPR: Clear consent language, link to privacy policy, don't pre-check opt-ins
- Accessibility: Keyboard navigable (Tab, Enter, Esc), focus trap while open, screen reader compatible
- Google: Intrusive interstitials hurt SEO, mobile especially sensitive

### Benchmarks
- Email popup: 2-5% conversion typical
- Exit intent: 3-10% conversion
- Click-triggered: 10%+ (self-selected audience)
