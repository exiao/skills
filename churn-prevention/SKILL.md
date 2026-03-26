---
name: churn-prevention
description: "When the user wants to reduce churn, build cancellation flows, set up save offers, improve retention, or recover failed payments. Also use when the user mentions 'churn,' 'cancel flow,' 'offboarding,' 'save offer,' 'dunning,' 'failed payment recovery,' 'win-back,' 'retention,' 'exit survey,' 'pause subscription,' 'involuntary churn,' 'people keep canceling,' 'churn rate is too high,' 'how do I keep users,' or 'subscribers are leaving.' For post-cancel win-back sequences, see email-sequence."
metadata:
  version: 1.0.0
---

# Churn Prevention

You are an expert in subscription retention and churn prevention. Your goal is to help reduce both voluntary churn (users choosing to cancel) and involuntary churn (failed payments) through well-designed cancel flows, dynamic save offers, proactive retention, and dunning strategies.

## Before Starting

Read `product-marketing-context.md` in the workspace root if it exists.

Gather this context (ask if not provided):

### 1. Current Churn Situation
- What's your monthly churn rate? (Voluntary vs. involuntary if known)
- How many active subscribers?
- What's the MRR?
- Is there a cancel flow today, or does cancel happen instantly?

### 2. Billing & Platform
- What billing provider or platform? (Stripe, RevenueCat, App Store/Play Store, Chargebee, Paddle)
- Monthly, annual, or both billing intervals?
- Do you support plan pausing or downgrades?
- Any existing retention tooling? (Churnkey, ProsperStack, Raaft)

### 3. Product & Usage Data
- Do you track feature usage per user?
- Can you identify engagement drop-offs?
- Do you have cancellation reason data from past churns?
- What's the activation metric? (What do retained users do that churned users don't?)

### 4. Constraints
- B2B or B2C?
- Web app, mobile app, or both? (Mobile apps have platform-specific cancel flows)
- Do you collect user email? (Affects dunning and win-back options)
- Self-serve cancellation required? (Some regulations mandate easy cancel)
- Brand tone for offboarding? (Empathetic, direct, playful)

---

## How This Skill Works

Churn has two types requiring different strategies:

| Type | Cause | Solution |
|------|-------|----------|
| **Voluntary** | Customer chooses to cancel | Cancel flows, save offers, exit surveys |
| **Involuntary** | Payment fails | Dunning emails, smart retries, card updaters |

Voluntary churn is typically 50-70% of total churn. Involuntary churn is 30-50% but is often easier to fix.

This skill supports three modes:

1. **Build a cancel flow** — Design from scratch with survey, save offers, and confirmation
2. **Optimize an existing flow** — Analyze cancel data and improve save rates
3. **Set up dunning / billing recovery** — Failed payment recovery with retries and messaging sequences

---

## Cancel Flow Design

### Platform Considerations

**Web apps (Stripe, Chargebee, Paddle, etc.):** You fully control the cancel flow. The cancel button lives in your app. You design every step.

**Mobile apps (App Store / Google Play):** The actual cancel button lives in iOS Settings or Google Play. Apple and Google manage that UI. Your role is building a **pre-cancel interception flow** inside the app that catches users before they navigate to Settings. Apple requires cancellation be easy; you cannot add friction to the Settings path.

### The Cancel Flow Structure

Every cancel flow follows this sequence:

```
Trigger → Value Reminder → Survey → Dynamic Offer → Confirmation → Post-Cancel
```

**Step 1: Trigger**
Customer clicks "Cancel subscription" (web) or "Manage Subscription" (mobile).

**Step 2: Value Reminder**
Before showing the cancel path, remind them what they'd lose. Show personalized usage stats: features used, results achieved, data they'd lose access to.

**Step 3: Exit Survey**
Ask why they're cancelling. This determines which save offer to show.

**Step 4: Dynamic Save Offer**
Present a targeted offer based on their reason (discount, pause, downgrade, etc.)

**Step 5: Confirmation**
If they still want to cancel, confirm clearly with end-of-billing-period messaging. On mobile, route them to Settings with a clear link.

**Step 6: Post-Cancel**
Set expectations, offer easy reactivation path, trigger win-back sequence.

### Exit Survey Design

The exit survey is the foundation. Good reason categories:

| Reason | What It Tells You |
|--------|-------------------|
| Too expensive | Price sensitivity, may respond to discount or downgrade |
| Not using it enough | Low engagement, may respond to pause or onboarding help |
| Missing a feature | Product gap, show roadmap or workaround |
| Switching to competitor | Competitive pressure, understand what they offer |
| Technical issues / bugs | Product quality, escalate to support |
| Temporary / seasonal need | Usage pattern, offer pause |
| Business closed / changed | Unavoidable, learn and let go gracefully |
| Other | Catch-all, include free text field |

**Survey best practices:**
- 1 question, single-select with optional free text
- 5-8 reason options max (avoid decision fatigue)
- Put most common reasons first (review data quarterly)
- Don't make it feel like a guilt trip
- "Help us improve" framing works better than "Why are you leaving?"

### Dynamic Save Offers

The key insight: **match the offer to the reason.** A discount won't save someone who isn't using the product. A feature roadmap won't save someone who can't afford it.

**Offer-to-reason mapping:**

| Cancel Reason | Primary Offer | Fallback Offer |
|---------------|---------------|----------------|
| Too expensive | Discount (20-30% for 2-3 months) | Downgrade to lower plan |
| Not using it enough | Pause (1-3 months) | Free onboarding session / feature tour |
| Missing feature | Roadmap preview + timeline | Workaround guide |
| Switching to competitor | Competitive comparison + discount | Feedback session |
| Technical issues | Escalate to support immediately | Credit + priority fix |
| Temporary / seasonal | Pause subscription | Downgrade temporarily |
| Business closed | Skip offer (respect the situation) | — |

### Save Offer Types

**Discount**
- 20-30% off for 2-3 months is the sweet spot
- Avoid 50%+ discounts (trains customers to cancel for deals)
- Time-limit the offer ("This offer expires when you leave this page")
- Show the dollar amount saved, not just the percentage
- For mobile: Apple/Google promotional offers (RevenueCat supports these)

**Pause subscription**
- 1-3 month pause maximum (longer pauses rarely reactivate)
- 60-80% of pausers eventually return to active
- Auto-reactivation with advance notice
- Keep their data and settings intact

**Plan downgrade**
- Offer a lower tier instead of full cancellation
- Show what they keep vs. what they lose
- Position as "right-size your plan" not "downgrade"
- Easy path back up when ready

**Feature unlock / extension**
- Unlock a premium feature they haven't tried
- Extend trial of a higher tier
- Works best for "not getting enough value" reasons

**Personal outreach**
- For high-value accounts (top 10-20% by MRR)
- Route to customer success for a call
- Personal email from founder for smaller companies

### Cancel Flow UI Patterns

```
┌─────────────────────────────────────┐
│  Before you go...                   │
│                                     │
│  Here's what you've done with us:   │
│                                     │
│  📊 [personalized usage stat 1]     │
│  🔔 [personalized usage stat 2]     │
│  ⭐ [personalized usage stat 3]     │
│                                     │
│  [Keep My Subscription]             │
│  [I still want to cancel]           │
└─────────────────────────────────────┘
         ↓ (taps "I still want to cancel")
┌─────────────────────────────────────┐
│  What's the main reason?            │
│                                     │
│  ○ Too expensive                    │
│  ○ Not using it enough              │
│  ○ Missing a feature I need         │
│  ○ Switching to another tool        │
│  ○ Technical issues                 │
│  ○ Temporary / don't need right now │
│  ○ Other: [____________]            │
│                                     │
│  [Continue]                         │
│  [Never mind, keep my subscription] │
└─────────────────────────────────────┘
         ↓ (selects "Too expensive")
┌─────────────────────────────────────┐
│  What if we could help?             │
│                                     │
│  We'd love to keep you. Here's a    │
│  special offer:                     │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  25% off for the next 3 months│  │
│  │  Save $XX/month               │  │
│  │                               │  │
│  │  [Accept Offer]               │  │
│  └───────────────────────────────┘  │
│                                     │
│  Or switch to [Basic Plan] at       │
│  $X/month →                         │
│                                     │
│  [No thanks, continue cancelling]   │
└─────────────────────────────────────┘
```

**UI principles:**
- Keep the "continue cancelling" option visible at every step (no dark patterns)
- Apple, Google, and FTC Click-to-Cancel rules all require easy cancellation
- One primary offer + one fallback, not a wall of options
- Show specific dollar savings, not abstract percentages
- Use the customer's name and personalized data when possible
- Mobile-friendly (many cancellations happen on mobile)

For detailed cancel flow patterns by industry, see [references/cancel-flow-patterns.md](references/cancel-flow-patterns.md).

---

## Churn Prediction & Proactive Retention

The best save happens before the customer ever clicks "Cancel."

### Risk Signals

Track these leading indicators of churn:

| Signal | Risk Level | Timeframe |
|--------|-----------|-----------|
| Login frequency drops 50%+ | High | 2-4 weeks before cancel |
| Key feature usage stops | High | 1-3 weeks before cancel |
| Support tickets spike then stop | High | 1-2 weeks before cancel |
| Email/push open rates decline | Medium | 2-6 weeks before cancel |
| Billing/subscription page visits | High | Days before cancel |
| Team seats removed (B2B) | High | 1-2 weeks before cancel |
| Data export initiated | Critical | Days before cancel |
| NPS score drops below 6 | Medium | 1-3 months before cancel |
| No login for 14+ days | High | Immediate risk |

### Health Score Model

Build a simple health score (0-100) from weighted signals:

```
Health Score = (
  Login frequency score × 0.30 +
  Feature usage score   × 0.25 +
  Support sentiment     × 0.15 +
  Billing health        × 0.15 +
  Engagement score      × 0.15
)
```

Each component scored 0-100 based on the user's activity relative to healthy benchmarks.

| Score | Status | Action |
|-------|--------|--------|
| 80-100 | Healthy | Upsell opportunities |
| 60-79 | Needs attention | Proactive check-in |
| 40-59 | At risk | Intervention campaign |
| 0-39 | Critical | Personal outreach |

### Proactive Interventions

**Before they think about cancelling:**

| Trigger | Intervention |
|---------|-------------|
| Usage drop >50% for 2 weeks | "We noticed you haven't used [feature]. Need help?" |
| Approaching plan limit | Upgrade nudge (not a hard wall) |
| No login for 14 days | Re-engagement message with recent product updates |
| NPS detractor (0-6) | Personal follow-up within 24 hours |
| Support ticket unresolved >48h | Escalation + proactive status update |
| Annual renewal in 30 days | Value recap + renewal confirmation |
| Trial user with low activation | Guided onboarding / feature tour |

---

## Involuntary Churn: Payment Recovery

Failed payments cause 30-50% of all churn but are the most recoverable.

### Web Apps: The Dunning Stack

```
Pre-dunning → Smart retry → Dunning emails → Grace period → Hard cancel
```

**Pre-Dunning (Prevent Failures)**
- Card expiry alerts: 30, 15, and 7 days before expiry
- Backup payment method: prompt at signup
- Card updater services: Visa/Mastercard auto-update (reduces hard declines 30-50%)
- Pre-billing notification: 3-5 days before charge for annual plans

**Smart Retry Logic**

| Decline Type | Examples | Retry Strategy |
|-------------|----------|----------------|
| Soft decline (temporary) | Insufficient funds, processor timeout | Retry 3-5 times over 7-10 days |
| Hard decline (permanent) | Card stolen, account closed | Don't retry, ask for new card |
| Authentication required | 3D Secure, SCA | Send customer to update payment |

**Retry timing:**
- Retry 1: 24 hours after failure
- Retry 2: 3 days after failure
- Retry 3: 5 days after failure
- Retry 4: 7 days after failure (with dunning email escalation)
- After 4 retries: Hard cancel with reactivation path

**Dunning Email Sequence**

| Email | Timing | Tone | Content |
|-------|--------|------|---------|
| 1 | Day 0 (failure) | Friendly alert | "Your payment didn't go through. Update your card." |
| 2 | Day 3 | Helpful reminder | "Quick reminder. Update your payment to keep access." |
| 3 | Day 7 | Urgency | "Your account will be paused in 3 days. Update now." |
| 4 | Day 10 | Final warning | "Last chance to keep your account active." |

**Dunning best practices:**
- Direct link to payment update page (no login required if possible)
- Show what they'll lose
- Don't blame ("your payment failed" not "you failed to pay")
- Include support contact
- Plain text performs better than designed emails for dunning

### Mobile Apps: Platform-Managed Recovery

App Store and Google Play handle most dunning natively:

| Component | Web (Stripe etc.) | Mobile (App Store / Play Store) |
|-----------|-------------------|--------------------------------|
| Payment retries | You configure | Apple/Google retry automatically |
| Card updates | Card updater services | Handled via Apple Pay / Google Pay |
| Dunning emails | You build and send | Apple/Google send payment failure emails |
| Grace period | You configure | Apple: 16 days (annual). Google: 7/14/30 days configurable |

**Your role for mobile:** Detect billing issues (via RevenueCat or StoreKit) and supplement with push notifications and in-app banners. Enable billing grace periods in App Store Connect and Google Play Console.

### Recovery Benchmarks

| Metric | Poor | Average | Good |
|--------|------|---------|------|
| Soft decline recovery | <40% | 50-60% | 70%+ |
| Hard decline recovery | <10% | 20-30% | 40%+ |
| Overall payment recovery | <30% | 40-50% | 60%+ |
| Pre-dunning prevention | None | 10-15% | 20-30% |

For the complete dunning playbook, see [references/dunning-playbook.md](references/dunning-playbook.md).

---

## Metrics & Measurement

### Key Churn Metrics

| Metric | Formula | Target |
|--------|---------|--------|
| Monthly churn rate | Churned / Start-of-month customers | <5% B2C, <2% B2B |
| Revenue churn (net) | (Lost MRR - Expansion MRR) / Start MRR | Negative (net expansion) |
| Cancel flow save rate | Saved / Total cancel sessions | 25-35% |
| Offer acceptance rate | Accepted offers / Shown offers | 15-25% |
| Pause reactivation rate | Reactivated / Total paused | 60-80% |
| Dunning recovery rate | Recovered / Total failed payments | 50-60% |
| Time to cancel | Days from first churn signal to cancel | Track trend |

### Cohort Analysis

Segment churn by:
- **Acquisition channel** — Which channels bring stickier customers?
- **Plan type** — Which plans churn most?
- **Tenure** — When do most cancellations happen? (30, 60, 90 days?)
- **Cancel reason** — Which reasons are growing?
- **Save offer type** — Which offers work best for which segments?
- **Platform** — iOS vs. Android vs. web (if multi-platform)

### Cancel Flow A/B Tests

Test one variable at a time:

| Test | Hypothesis | Metric |
|------|-----------|--------|
| Discount % (20% vs 30%) | Higher discount saves more | Save rate, LTV impact |
| Pause duration (1 vs 3 months) | Longer pause increases return rate | Reactivation rate |
| Survey placement (before vs after offer) | Survey-first personalizes offers | Save rate |
| Offer presentation (modal vs full page) | Full page gets more attention | Save rate |
| Copy tone (empathetic vs direct) | Empathetic reduces friction | Save rate |
| Value stats shown vs not shown | Personalized stats reduce cancel intent | Save rate |

---

## Common Mistakes

- **No cancel flow at all** — Instant cancel leaves money on the table. Even a simple survey + one offer saves 10-15%
- **Making cancellation hard to find** — Hidden cancel buttons breed resentment and bad reviews. Many jurisdictions require easy cancellation (FTC Click-to-Cancel rule, Apple/Google policies)
- **Same offer for every reason** — A blanket discount doesn't address "missing feature" or "not using it"
- **Discounts too deep** — 50%+ discounts train customers to cancel-and-return for deals
- **Ignoring involuntary churn** — Often 30-50% of total churn and the easiest to fix
- **No dunning emails (web) / no grace period enabled (mobile)** — Free recovery improvements left on the table
- **Guilt-trip copy** — "Are you sure you want to abandon us?" damages brand trust
- **Not tracking save offer LTV** — A "saved" customer who churns 30 days later wasn't really saved
- **Pausing too long** — Pauses beyond 3 months rarely reactivate. Set limits.
- **No post-cancel path** — Make reactivation easy and trigger win-back sequences

---

## Tool Integrations

### Retention Platforms

| Tool | Best For | Key Feature |
|------|----------|-------------|
| **Churnkey** | Full cancel flow + dunning | AI-powered adaptive offers, ~34% avg save rate |
| **ProsperStack** | Cancel flows with analytics | Advanced rules engine |
| **Raaft** | Simple cancel flow builder | Easy setup, good for early-stage |

### Billing Providers (Dunning)

| Provider | Smart Retries | Dunning Emails | Card Updater |
|----------|:------------:|:--------------:|:------------:|
| **Stripe** | Built-in | Built-in | Automatic |
| **Chargebee** | Built-in | Built-in | Via gateway |
| **Paddle** | Built-in | Built-in | Managed |
| **RevenueCat** | Via App Store/Play Store | Via App Store/Play Store | Via Apple/Google |

### Mobile-Specific

| Tool | Use For |
|------|---------|
| **RevenueCat** | Subscription management, billing issue detection, promotional offers |
| **App Store Connect** | Billing grace period, subscription groups, offer codes |
| **Google Play Console** | Grace period config, account hold, win-back offers |

---

## Related Skills

- **email-sequence** — For win-back email/push sequences after cancellation
- **growth** — For acquisition, onboarding, and trial optimization
