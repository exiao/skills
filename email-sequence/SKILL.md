---
name: email-sequence
description: "When the user wants to create or optimize an email sequence, drip campaign, push notification flow, or lifecycle messaging program. Also use when the user mentions 'email sequence,' 'drip campaign,' 'onboarding emails,' 'welcome sequence,' 're-engagement emails,' 'lifecycle emails,' 'push notification sequence,' 'win-back emails,' 'trigger-based emails,' 'email cadence,' or 'what emails should I send.' For cancel flows and save offers, see churn-prevention."
metadata:
  version: 1.0.0
---

# Email & Lifecycle Sequence Design

Design lifecycle messaging sequences: email, push notifications, or both.

## Before Starting

Read `product-marketing-context.md` in the workspace root if it exists.

Gather this context (ask if not provided):

### 1. Sequence Type
- Welcome/onboarding sequence
- Re-engagement sequence
- Win-back sequence (post-cancel)
- Billing/payment sequence
- Usage summary / milestone sequence
- Trial expiration sequence
- Post-purchase sequence
- Educational sequence

### 2. Channels Available
- Email (what provider?)
- Push notifications
- In-app messaging
- SMS
- If no email collection, note this. Push can substitute for many sequences.

### 3. Audience Context
- Who are they?
- What triggered them into this sequence?
- What do they already know/believe?
- What's their current relationship with you?

### 4. Goals
- Primary conversion goal
- Relationship-building goals
- What defines success?

---

## Core Principles

### 1. One Message, One Job
Each email/push has one primary purpose and one main CTA. Don't try to do everything.

### 2. Value Before Ask
Lead with usefulness. Build trust through content. Earn the right to sell.

### 3. Relevance Over Volume
Fewer, better messages win. Segment for relevance. Quality > frequency.

### 4. Coordinate Channels
Email + push should complement, not duplicate. Use push for urgency, email for depth. If you send a push, don't send the same email.

### 5. Clear Path Forward
Every message moves them somewhere. Links should do something useful. Make next steps obvious.

---

## Sequence Types

### Welcome/Onboarding Sequence
**Length:** 5-7 messages over 14 days
**Trigger:** Signup / first app open
**Goal:** Activate, build trust, convert

| # | Timing | Purpose | Focus |
|---|--------|---------|-------|
| 1 | Immediate | Welcome + deliver value | First step / quick win |
| 2 | Day 1-2 | Quick win | Enable small success |
| 3 | Day 3-4 | Story / why | Origin story, emotional connection |
| 4 | Day 5-6 | Social proof | Case study or testimonial |
| 5 | Day 7-8 | Overcome objection | Address common hesitation |
| 6 | Day 9-11 | Core feature highlight | Underused capability |
| 7 | Day 12-14 | Conversion | Upgrade / commit |

**Push alternative:** Push works well for messages 1, 2, 4, and 7. Keep push short and action-oriented.

### Re-Engagement Sequence
**Length:** 3-4 messages over 2 weeks
**Trigger:** 14-30 days of inactivity
**Goal:** Win back or clean list

| # | Timing | Purpose | Focus |
|---|--------|---------|-------|
| 1 | Trigger | Check-in | Genuine concern, what's new |
| 2 | +7 days | Value reminder | Recent updates, what they're missing |
| 3 | +14 days | Incentive | Special offer or feature unlock |
| 4 | +21 days | Last chance | Stay or unsubscribe |

**Push alternative:** Messages 1 and 2 work as push. Deep-link to relevant content.

### Win-Back Sequence (Post-Cancel)
**Length:** 3 messages over 30 days
**Trigger:** Subscription cancelled
**Goal:** Resubscribe

| # | Timing | Purpose | Focus |
|---|--------|---------|-------|
| 1 | Day 1 | Value recap | "Here's what you accomplished" |
| 2 | Day 14 | What's new + offer | Updates since they left |
| 3 | Day 30 | Final + best offer | "We'd love to have you back" |

**Push alternative:** Push works for message 1 only (app still installed). After that, email is the only channel to reach churned users.

### Billing/Payment Sequence
**Length:** 3-4 messages
**Trigger:** Payment failure detected
**Goal:** Update payment method

| # | Timing | Tone | Content |
|---|--------|------|---------|
| 1 | Day 0 | Friendly alert | "Your payment didn't go through. Update your card." |
| 2 | Day 3 | Helpful reminder | "Quick reminder. Update to keep access." |
| 3 | Day 7 | Urgency | "Your account will be paused in 3 days." |
| 4 | Day 10 | Final warning | "Last chance to keep your account active." |

**Push alternative:** All work as push. Deep-link to payment settings.

Note: For mobile apps, App Store and Play Store handle payment retries natively. This sequence supplements their built-in dunning. See churn-prevention skill for full dunning strategy.

### Usage Summary / Milestone Sequence
**Length:** Ongoing, event-triggered
**Trigger:** Weekly/monthly milestones, achievement events
**Goal:** Reinforce value, build habit

Examples:
- Weekly/monthly usage summary
- Milestone celebrations ("You've done X 100 times")
- Activity alerts (relevant to their interests)
- Anniversary messages
- Personalized recommendations based on usage

**Push alternative:** Ideal for push. Short, data-driven, personalized.

### Trial Expiration Sequence
**Length:** 3 messages during trial
**Trigger:** Free trial started
**Goal:** Convert to paid

| # | Timing | Purpose | Focus |
|---|--------|---------|-------|
| 1 | Mid-trial | Value recap | "Here's what you've done so far" |
| 2 | 2 days before end | Loss aversion | What they'll lose, specific features |
| 3 | 1 day before end | Final + price anchoring | Clear CTA to subscribe |

**Push alternative:** All 3 work as push. Deep-link to paywall/upgrade screen.

---

## Email Sequence Strategy

### Timing & Delays
- Welcome email: Immediately
- Early sequence: 1-2 days apart
- Nurture: 2-4 days apart
- Long-term: Weekly or bi-weekly
- B2B: Avoid weekends
- B2C: Test weekends
- Time zones: Send at local time when possible

### Subject Line Strategy
- Clear > Clever
- Specific > Vague
- Benefit or curiosity-driven
- 40-60 characters ideal
- Test emoji (they're polarizing)

**Patterns that work:**
- Question: "Still struggling with X?"
- How-to: "How to [achieve outcome] in [timeframe]"
- Number: "3 ways to [benefit]"
- Direct: "[First name], your [thing] is ready"
- Story tease: "The mistake I made with [topic]"

### Preview Text
- Extends the subject line
- ~90-140 characters
- Don't repeat subject line
- Complete the thought or add intrigue

---

## Email Copy Guidelines

### Structure
1. **Hook**: First line grabs attention
2. **Context**: Why this matters to them
3. **Value**: The useful content
4. **CTA**: What to do next
5. **Sign-off**: Human, warm close

### Formatting
- Short paragraphs (1-3 sentences)
- White space between sections
- Bullet points for scanability
- Bold for emphasis (sparingly)
- Mobile-first (most read on phone)

### Tone
- Conversational, not formal
- First-person (I/we) and second-person (you)
- Active voice
- Read it aloud: does it sound human?

### Length
- Push notifications: 50-80 characters
- Transactional email: 50-125 words
- Educational email: 150-300 words
- Story-driven email: 300-500 words

### CTA Guidelines
- Buttons for primary actions
- Links for secondary actions
- One clear primary CTA per email
- Button text: Action + outcome ("Start researching" not "Click here")

---

## Push Notification Best Practices

For apps where push is a primary or supplementary channel:

- **Timing:** 9am-9pm local time only. Never overnight.
- **Frequency:** Max 3 push/week for marketing. Transactional (payment, alerts) exempt.
- **Personalization:** Include user-specific data when possible
- **Deep links:** Every push should open to a specific screen, not just the app
- **Rich push:** Use images or media when supported
- **Segmentation:** Segment by activity level, subscription status, and interests
- **Opt-in rate:** Track and optimize. Users who disable push are unreachable via this channel.

---

## Email Types by Category

### Onboarding Emails
- New user welcome series
- Getting started / quick win guides
- Feature highlight tours
- Activation milestone nudges

### Retention Emails
- Upgrade to paid / higher plan
- Ask for review (after value delivered)
- Usage reports and summaries
- NPS survey
- Referral program

### Billing Emails
- Switch to annual (if on monthly)
- Failed payment recovery (dunning)
- Cancellation survey
- Upcoming renewal reminders

### Win-Back Emails
- Expired trials
- Cancelled subscribers
- Lapsed users

### Campaign Emails
- Monthly newsletter / roundup
- Product updates
- Seasonal promotions

For detailed email type reference, see [references/email-types.md](references/email-types.md).

---

## Metrics

| Metric | Email Benchmark | Push Benchmark |
|--------|----------------|----------------|
| Open rate | 20-30% | 5-15% |
| Click rate | 2-5% | 3-8% |
| Unsubscribe | <0.5% per send | N/A (opt-out) |
| Conversion | 1-3% | 0.5-2% |

Track per sequence:
- Completion rate (how many get to the last message)
- Drop-off point (which message loses them)
- Conversion rate (did they take the goal action)
- Revenue attributed to sequence

---

## Output Format

### Sequence Overview
```
Sequence Name: [Name]
Trigger: [What starts it]
Goal: [Primary conversion goal]
Length: [Number of messages]
Channel: [Email / Push / Both]
Timing: [Delay between messages]
Exit Conditions: [When they leave the sequence]
```

### For Each Message
```
Message [#]: [Name/Purpose]
Channel: [Email / Push]
Send: [Timing]
Subject/Title: [Subject line or push title]
Preview: [Preview text]
Body: [Full copy]
CTA: [Button text] → [Link destination]
Segment/Conditions: [If applicable]
```

---

## Tool Integrations

| Provider | Best For | Notes |
|----------|----------|-------|
| **Customer.io** | Behavior-based automation, multi-channel | Push + email unified, strong for B2C |
| **Resend** | Developer-friendly transactional | React Email templates, good for solo devs |
| **Loops** | Product-led growth | Built for B2C SaaS, event-based |
| **Mailchimp** | SMB email marketing | Broad feature set |
| **SendGrid** | Transactional at scale | High volume |

---

## Related Skills

- **churn-prevention** — Cancel flows, save offers, dunning strategy (messaging supports this)
- **growth** — In-app onboarding and conversion optimization
- **evaluate-content** — Quality check on email/push copy

For detailed templates, see [references/sequence-templates.md](references/sequence-templates.md).
For copy and personalization guidelines, see [references/copy-guidelines.md](references/copy-guidelines.md).
