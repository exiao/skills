---
name: growth
description: "Use when optimizing growth across the full funnel: in-product CRO
  (signup, onboarding, paywalls, churn) and go-to-market strategy (launches,
  pricing, email, referrals, A/B tests, psychology)."
metadata:
  version: 1.0.0
---

# Growth

You are an expert in SaaS growth — both in-product conversion rate optimization and go-to-market strategy. This skill covers ten domains across the full funnel. Identify which domain the user needs, then apply the relevant section. For deep-dive reference material, see the `references/` directory.

## Routing Table

| Domain | When to Use |
|--------|-------------|
| **Signup** | Optimize registration, form fields, social auth, trial activation |
| **Onboarding** | Post-signup activation, first-run experience, time-to-value |
| **Paywall** | In-app upgrade screens, feature gates, trial expiration |
| **Retention** | Cancel flows, save offers, dunning, win-back |
| **Launches** | Product launches, feature releases, Product Hunt, go-to-market |
| **Pricing** | Tiers, packaging, value metrics, price increases, monetization |
| **Email** | Drip campaigns, welcome sequences, nurture, re-engagement |
| **Referrals** | Referral programs, affiliates, viral loops, word-of-mouth |
| **Experimentation** | A/B tests, hypothesis design, sample sizing, analysis |
| **Psychology** | Mental models, cognitive biases, persuasion, behavioral science |

## Before Starting

Check `~/clawd/SOUL.md` and `~/clawd/USER.md` for product context.

---

# Stage 1: Signup Flow

Reduce friction, increase completion rates, set users up for activation.

## Assessment

1. **Flow type**: Free trial, freemium, paid, waitlist, B2B vs B2C?
2. **Current state**: How many steps/screens? Where do users drop off?
3. **Constraints**: What data is genuinely needed before they can use the product?

## Core Principles

- **Minimize fields.** Every field reduces conversion. Defer what you can.
- **Value before commitment.** Show product value before requiring signup.
- **Reduce perceived effort.** Progress bars, smart defaults, pre-fill.
- **Remove uncertainty.** Clear expectations, no surprises.

## Field Optimization

| Field | Best Practice |
|-------|---------------|
| Email | Single field, inline validation, typo detection (gmial→gmail) |
| Password | Show toggle, real-time strength meter, allow paste |
| Name | Single "Full name" unless personalization requires split |
| Social auth | Place prominently; B2C: Google/Apple; B2B: Google/Microsoft/SSO |
| Phone | Defer unless essential (SMS verify, calling leads) |
| Company | Defer; infer from email domain when possible |

## Single vs. Multi-Step

- **Single step**: ≤3 fields, simple B2C, high-intent visitors
- **Multi-step**: 4+ fields, B2B needing segmentation. Lead with easy questions, save hard ones for later. Show progress, save state.

## Post-Submit

- Clear confirmation with immediate next step
- If email verification: explain, easy resend, check-spam reminder
- Consider delaying verification until necessary

## Key Metrics

- Form start rate, completion rate, field-level drop-off
- Time to complete, error rate by field, mobile vs. desktop

---

# Stage 2: Onboarding

Get users to their "aha moment" as fast as possible.

## Assessment

1. **Activation definition**: What action correlates most with retention?
2. **Current state**: What happens after signup? Where do users drop off?
3. **Product type**: B2B SaaS, marketplace, mobile app, content platform?

## Core Principles

- **Time-to-value is everything.** Remove every step between signup and core value.
- **One goal per session.** First session = one successful outcome.
- **Do, don't show.** Interactive > tutorial. Doing > learning about doing.
- **Progress creates motivation.** Show advancement, celebrate completions.

## Flow Design

| Approach | Best For |
|----------|----------|
| Product-first | Simple products, B2C, mobile |
| Guided setup | Products needing personalization |
| Value-first (demo data) | Products where empty state overwhelms |

### Checklist Pattern (3-7 items)
- Order by value (most impactful first)
- Start with quick wins
- Progress bar, celebration on completion, dismissable

### Empty States
- Explain what this area is for
- Show what it looks like with data
- Clear primary action to add first item

## Multi-Channel Coordination

Trigger-based emails: welcome (immediate), incomplete onboarding (24h, 72h), activation achieved (celebration + next step), feature discovery (days 3, 7, 14).

## Key Metrics

- Activation rate, time to activation, onboarding completion
- Day 1/7/30 retention, step-by-step funnel drop-off

---

# Stage 3: Paywall & Upgrade

Convert free users to paid at moments of experienced value.

## Assessment

1. **Upgrade context**: Freemium→paid? Trial→paid? Tier upgrade? Feature upsell?
2. **Product model**: What's free vs. paywalled? What triggers prompts?
3. **User journey**: When does this appear? What have they experienced?

## Core Principles

- **Value before ask.** User should have experienced real value first.
- **Show, don't just tell.** Demonstrate paid feature value, preview what's missing.
- **Friction-free path.** Easy to upgrade when ready.
- **Respect the no.** Easy to continue free. Maintain trust.

## Trigger Points

| Trigger | Approach |
|---------|----------|
| Feature gate | Explain why it's paid, show what it does, quick unlock path |
| Usage limit | Clear indication, show what upgrading provides, don't block abruptly |
| Trial expiration | Early warnings (7, 3, 1 day), summarize value received |
| Time-based | Gentle reminder, highlight unused paid features |

## Paywall Screen Components

1. **Headline**: "Unlock [Feature] to [Benefit]"
2. **Value demo**: Preview, before/after
3. **Feature comparison**: Key differences, current plan marked
4. **Pricing**: Clear, annual vs. monthly
5. **Social proof**: Customer quotes, user count
6. **CTA**: Value-oriented ("Start Getting [Benefit]")
7. **Escape hatch**: Clear "Not now" or "Continue with Free"

## Timing Rules

- Show after value moment, not during onboarding or mid-flow
- Limit per session, cool-down after dismiss (days, not hours)
- Track annoyance signals

## Key Metrics

- Paywall impression rate, click-through, completion rate
- Revenue per user, churn rate post-upgrade

---

# Stage 4: Retention & Churn Prevention

Reduce voluntary churn (cancel flows, save offers) and involuntary churn (dunning, payment recovery).

## Assessment

1. **Churn situation**: Monthly rate? Voluntary vs. involuntary split?
2. **Billing**: Provider (Stripe, Chargebee, Paddle)? Monthly/annual?
3. **Usage data**: Feature usage tracking? Engagement drop-off detection?
4. **Constraints**: B2B or B2C? Self-serve cancel required?

## Cancel Flow Structure

```
Trigger → Exit Survey → Dynamic Save Offer → Confirmation → Post-Cancel
```

### Exit Survey (1 question, single-select, 5-8 options)

| Reason | Primary Offer | Fallback |
|--------|---------------|----------|
| Too expensive | Discount 20-30% for 2-3 months | Downgrade |
| Not using enough | Pause 1-3 months | Onboarding help |
| Missing feature | Roadmap preview + timeline | Workaround guide |
| Switching competitor | Competitive comparison + discount | Feedback call |
| Technical issues | Escalate to support | Credit + priority fix |
| Temporary/seasonal | Pause subscription | Downgrade temporarily |
| Business closed | Skip offer, respect the situation | — |

### Save Offer Rules
- Max 2 offers per session (primary + fallback)
- Never exceed 30% discount (avoids cancel-for-discount training)
- Time-limit discounts (2-3 months)
- Pause max 3 months (longer rarely reactivates)
- Route high-MRR accounts to customer success

### Post-Cancel
- Confirm with end-of-billing-period access
- Data preserved for 90 days
- Easy reactivation path
- Win-back emails: day 7 (survey), day 30 (what's new), day 60 (address their reason), day 90 (final offer)

## Churn Prediction

### Risk Signals
- Login frequency drops 50%+, key feature usage stops
- Support tickets spike then stop, billing page visits increase
- Data export initiated, team seats removed

### Proactive Interventions
- Usage drop >50% for 2 weeks → "Need help with [feature]?" email
- No login 14 days → re-engagement with product updates
- NPS detractor → personal follow-up within 24h
- Annual renewal in 30 days → value recap email

## Involuntary Churn: Dunning

### Pre-Dunning
- Card expiry alerts (30, 15, 7 days before)
- Backup payment method prompt
- Card updater services (Visa/MC auto-update, 30-50% fewer hard declines)

### Smart Retry by Decline Type
| Type | Examples | Strategy |
|------|----------|----------|
| Soft (temporary) | Insufficient funds, timeout | Retry 3-5× over 7-10 days |
| Hard (permanent) | Stolen card, closed account | Don't retry, ask for new card |
| Auth required | 3DS/SCA | Send customer to authenticate |

### Dunning Email Sequence
| Email | Day | Tone |
|-------|-----|------|
| 1 | 0 | Friendly alert, "payment didn't go through" |
| 2 | 3 | Helpful reminder |
| 3 | 7 | Urgency, "account paused in 3 days" |
| 4 | 10 | Final warning |

### Key Metrics
- Monthly churn rate (<5% B2C, <2% B2B target)
- Cancel flow save rate (25-35% target)
- Pause reactivation rate (60-80% target)
- Dunning recovery rate (50-60% target)

---

# CRO Output Format

For any CRO stage, deliver:

### Audit
For each issue: **Issue** → **Impact** → **Fix** → **Priority** (High/Medium/Low)

### Recommendations
1. Quick wins (same-day fixes)
2. High-impact changes (week-level effort)
3. Test hypotheses (A/B test ideas)

For detailed experiment ideas, see the references directory.

---

# Domain 5: Launch Strategy

Structure launches across Owned (email, blog, community), Rented (social, app stores), and Borrowed (guests, influencers, collabs) channels. Everything funnels back to owned.

## Five-Phase Approach

| Phase | Goal | Actions |
|-------|------|---------|
| **Internal** | Validate core | Recruit testers, collect feedback, fix major issues |
| **Alpha** | First external users | Landing page, waitlist, invite-only |
| **Beta** | Build buzz | Work through early access list, teasers, recruit influencers |
| **Early Access** | Validate at scale | Leak details, screenshots, demos. Batch invites or open EA |
| **Full Launch** | Max visibility | Self-serve signups, charge, announce across all channels |

## Full Launch Touchpoints
- Customer emails, in-app popups, website banner
- Blog post, social posts across platforms
- Product Hunt, BetaList, Hacker News
- Onboarding email sequence for new signups

## Product Hunt Tips
- Build relationships with supporters before launch
- Compelling tagline, polished visuals, short demo video
- Treat launch day as all-day engagement (respond to every comment)
- Convert PH traffic into owned relationships (email signups)

## Post-Launch
- Automated onboarding email sequence
- Comparison pages vs. competitors
- Interactive demo (Navattic-style)
- Regular feature announcements to sustain momentum

---

# Domain 6: Pricing Strategy

## Three Pricing Axes

1. **Packaging**: What's included at each tier
2. **Pricing metric**: What you charge for (per user, usage, flat)
3. **Price point**: The actual dollar amounts

Price between the **next best alternative** (floor) and **customer's perceived value** (ceiling).

## Value Metrics

Good value metrics: align with value, easy to understand, scale with growth, hard to game.

| Metric | Best For | Example |
|--------|----------|---------|
| Per seat | Collaboration tools | Slack, Notion |
| Per usage | Variable consumption | AWS, Twilio |
| Per feature | Modular products | HubSpot add-ons |
| Per contact | CRM, email tools | Mailchimp |
| Flat fee | Simple products | Basecamp |

## Good-Better-Best Framework

- **Good** (Entry): Core features, limited usage, low price
- **Better** (Recommended): Full features, reasonable limits, anchor price
- **Best** (Premium): Everything, advanced features, 2-3x Better price

## When to Raise Prices
- Competitors raised prices, prospects don't flinch, "it's so cheap!" feedback
- Very high conversion (>40%), very low churn (<3%), significant value added

## Pricing Page Best Practices
- Recommended tier highlighted, monthly/annual toggle
- Anchoring (show expensive first), decoy effect (middle = best value)
- FAQ, annual discount callout (17-20%), money-back guarantee

See `references/pricing-research-methods.md` and `references/pricing-tier-structure.md` for deep dives.

---

# Domain 7: Email Sequences

## Core Principles
- **One email, one job.** One primary CTA per email.
- **Value before ask.** Lead with usefulness, earn the right to sell.
- **Relevance over volume.** Fewer, better emails win.

## Sequence Types

| Type | Length | Timing | Goal |
|------|--------|--------|------|
| Welcome/onboarding | 5-7 emails / 14 days | Immediate → day 14 | Activate, convert |
| Lead nurture | 6-8 emails / 3 weeks | Day 0 → day 21 | Build trust, convert |
| Re-engagement | 3-4 emails / 2 weeks | 30-60 days inactive | Win back or clean list |
| Post-purchase | 5-7 emails / 14 days | Immediate → day 14 | Activate, expand |

## Welcome Sequence Template
1. Welcome + deliver promised value (immediate)
2. Quick win (day 1-2)
3. Story/Why (day 3-4)
4. Social proof (day 5-6)
5. Overcome objection (day 7-8)
6. Core feature highlight (day 9-11)
7. Conversion CTA (day 12-14)

## Email Copy
- **Structure**: Hook → Context → Value → CTA → Sign-off
- **Length**: 50-125 words (transactional), 150-300 (educational), 300-500 (story)
- **Subject lines**: Clear > clever, 40-60 chars, benefit or curiosity-driven

See `references/email-sequence-templates.md`, `references/email-copy-guidelines.md`, `references/email-types.md` for templates.

---

# Domain 8: Referral Programs

## The Referral Loop

```
Trigger Moment → Share Action → Convert Referred → Reward → Loop
```

## Design

1. **Trigger at high-intent moments**: After aha moment, milestone, great support
2. **Share mechanism** (ranked): In-product sharing > personalized link > email invite > social > code
3. **Incentive structure**: Double-sided rewards (both parties) convert highest

## Key Metrics
- Active referrers (referred in last 30 days)
- Referral conversion rate
- % new customers from referrals
- LTV of referred vs. non-referred customers

## Typical Results
- Referred customers: 16-25% higher LTV, 18-37% lower churn
- Referred customers refer others at 2-3x rate

See `references/referral-program-examples.md` and `references/affiliate-programs.md`.

---

# Domain 9: A/B Testing

## Hypothesis Framework

```
Because [observation/data],
we believe [change]
will cause [expected outcome]
for [audience].
We'll know this is true when [metrics].
```

## Sample Size Quick Reference

| Baseline | 10% Lift | 20% Lift | 50% Lift |
|----------|----------|----------|----------|
| 1% | 150k/variant | 39k/variant | 6k/variant |
| 5% | 27k/variant | 7k/variant | 1.2k/variant |
| 10% | 12k/variant | 3k/variant | 550/variant |

## Running Tests
- **Pre-commit** to sample size. Don't peek and stop early.
- **Metrics**: One primary (calls the test), secondaries (explain why), guardrails (shouldn't get worse)
- **95% confidence** = p < 0.05. Not a guarantee, just a threshold.

## Common Mistakes
- Testing too small a change (undetectable)
- Stopping early (inflated false positives)
- Cherry-picking segments after the fact

See `references/ab-test-sample-size.md` and `references/ab-test-templates.md`.

---

# Domain 10: Marketing Psychology

70+ mental models organized by application. Use the quick reference below to find relevant models, then apply with specific recommendations.

## Quick Reference

| Challenge | Models to Apply |
|-----------|-----------------|
| Low conversions | Hick's Law, Activation Energy, BJ Fogg, Friction reduction |
| Price objections | Anchoring, Framing, Mental Accounting, Loss Aversion |
| Building trust | Authority, Social Proof, Reciprocity, Pratfall Effect |
| Increasing urgency | Scarcity, Loss Aversion, Zeigarnik Effect |
| Retention/churn | Endowment Effect, Switching Costs, Status-Quo Bias |
| Growth stalling | Theory of Constraints, Local vs Global Optima, Compounding |
| Decision paralysis | Paradox of Choice, Default Effect, Nudge Theory |
| Onboarding | Goal-Gradient, IKEA Effect, Commitment & Consistency |

## Key Models (Most Used)

**Buyer behavior**: Jobs to Be Done, Loss Aversion, Social Proof, Endowment Effect, Status-Quo Bias, Zero-Price Effect, Paradox of Choice

**Persuasion**: Reciprocity, Commitment & Consistency, Authority, Scarcity, Anchoring, Framing, Decoy Effect

**Strategy**: First Principles, Pareto (80/20), Theory of Constraints, Inversion, Second-Order Thinking, Flywheel Effect

**Pricing psychology**: Charm pricing ($99 vs $100), rounded prices for premium, Rule of 100 (% off under $100, $ off over), mental accounting ("$1/day")

**Design**: Hick's Law (fewer choices = faster decisions), BJ Fogg (Behavior = Motivation × Ability × Prompt), EAST (Easy, Attractive, Social, Timely)

For full model descriptions with marketing applications, see `references/psychology-models.md`.
