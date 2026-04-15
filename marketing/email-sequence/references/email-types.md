# Lifecycle Message Types (Bloom)

Reference for all lifecycle message types. Covers push notifications (available now) and email (future). Use as an audit checklist.

---

## Onboarding Messages

### New User Welcome Series
**Channel:** Push now, email when available
**Trigger:** User signs up (free or trial)
**Goal:** Activate user, drive to first meaningful action
**Typical sequence:** 4-5 messages over 7-10 days

- Message 1: Welcome + single next step (immediate)
- Message 2: Feature discovery (day 1, if action not taken)
- Message 3: Watchlist nudge (day 3, if watchlist empty)
- Message 4: Portfolio connection (day 5)
- Message 5: Personalized stock hook (day 7)

**Key metrics:** Activation rate, feature adoption rate

### New Subscriber Series
**Channel:** Push now, email when available
**Trigger:** User converts to paid
**Goal:** Reinforce purchase decision, expand feature usage
**Typical sequence:** 3 messages over 14 days

- Message 1: Thank you + what's unlocked (immediate)
- Message 2: Premium feature highlight (day 3)
- Message 3: Check-in + advanced tip (day 7)

**Different from new user series:** They've committed. Focus on expansion, not conversion.

### Key Action Reminder
**Channel:** Push
**Trigger:** User hasn't completed a critical setup step
**Goal:** Nudge completion of high-value action

**Example triggers:**
- Hasn't added a stock to watchlist after 48 hours
- Hasn't tried AI chat after 3 days
- Hasn't connected portfolio after 7 days

**Approach:**
- Remind what they started
- Explain why this step matters
- Deep link directly to the action

---

## Retention Messages

### Upgrade to Paid
**Channel:** Push + in-app, email when available
**Trigger:** Free user shows engagement, or trial ending
**Goal:** Convert free to paid

**Trigger options:**
- Time-based (trial day 5, 10, 14)
- Behavior-based (hit usage limit, used premium feature)
- Engagement-based (highly active free user)

**Sequence:**
- Value summary: What they've accomplished on free tier
- Feature comparison: What they're missing on premium
- Social proof: Results other subscribers see
- Urgency: Trial ending (if applicable)

### Ask for App Store Review
**Channel:** In-app prompt (not push)
**Trigger:** Positive milestone (portfolio up, 30-day subscriber, active user)
**Goal:** Generate App Store reviews

**Best timing:**
- After a positive experience (AI insight was useful, stock alert was timely)
- After 30+ days of active subscription
- NOT after billing issues, bugs, or low engagement

**Use iOS SKStoreReviewController / Android In-App Review API.**

### Product Usage Report
**Channel:** Push now (brief), email when available (detailed)
**Trigger:** Weekly or monthly cadence
**Goal:** Demonstrate value, drive engagement

**Push version:** "Your portfolio was up X% this week. Tap for the full recap."
**Email version:** Full weekly report with portfolio performance, watchlist movers, insights delivered, market context.

**This is one of the strongest retention messages because it's personalized and genuinely useful.**

### Proactive Support
**Channel:** In-app message
**Trigger:** Signs of struggle (errors, failed actions, repeated help page visits)
**Goal:** Save at-risk user

**Approach:**
- Genuine concern, not sales pitch
- Specific: "Looks like you're having trouble with [X]"
- Offer direct help
- Route to support if needed

---

## Billing Messages

### Failed Payment Recovery
**Channel:** Push now, email when available
**Trigger:** RevenueCat `BILLING_ISSUE` event
**Goal:** Recover revenue, retain subscriber

See [churn-prevention skill](../churn-prevention/SKILL.md) for the full billing issue sequence.

**Key point:** Apple/Google send their own billing emails. Your messages supplement theirs.

### Upcoming Renewal Reminder
**Channel:** Email when available (push optional)
**Trigger:** 7 days before annual renewal
**Goal:** No surprise charges, reduce involuntary churn

**Content:**
- Renewal date and amount
- What's included
- How to manage subscription
- Required for annual subscriptions (consumer protection best practice)

---

## Usage Messages

### Milestone Celebrations
**Channel:** Push + in-app
**Trigger:** Specific achievement
**Goal:** Reinforce engagement

**Examples:**
- First stock added
- 10 stocks in watchlist
- First AI analysis used
- 30/90/365 day subscriber
- Portfolio connected

See push notification templates in [sequence-templates.md](sequence-templates.md).

### Stock Alerts
**Channel:** Push
**Trigger:** Price target hit, significant movement, earnings
**Goal:** Drive engagement, demonstrate value

**These are the highest-value pushes.** Users set them up intentionally. Always deliver these reliably.

---

## Win-Back Messages

### Expired Subscription
**Channel:** Push now, email when available
**Trigger:** Subscription expired (RevenueCat `EXPIRATION`)
**Goal:** Re-subscribe

**Sequence:** 3 messages over 90 days (see sequence-templates.md)

**Segment by engagement level:**
- High engagement before cancel: Focus on what they're missing (value recap)
- Low engagement before cancel: Focus on what's new (product updates)
- Cancel reason known: Address that specific reason if resolved

---

## Campaign Messages (Future: Email Only)

### Product Updates
**Trigger:** Major feature release
**Goal:** Adoption, engagement, show momentum

**What to include:**
- What's new (clear and simple)
- Why it matters (benefit, not feature)
- How to use it (deep link)
- Brief: one feature per email

### Monthly / Quarterly Roundup
**Trigger:** Calendar cadence
**Goal:** Engagement, brand presence

**Content mix:**
- Product updates and tips
- Market insights
- User success highlights
- Upcoming features

**Best practices:**
- Consistent send day/time
- Scannable format
- One primary CTA
- Keep it short

---

## Lifecycle Message Audit Checklist

### Onboarding (Implement First)
- [ ] Welcome push sequence (4-5 pushes, 7 days)
- [ ] New subscriber push sequence (3 pushes, 14 days)
- [ ] Key action reminders (watchlist, AI chat, portfolio)

### Retention
- [ ] Feature education pushes (based on usage gaps)
- [ ] Milestone celebration pushes
- [ ] App Store review prompt (in-app, after positive moments)
- [ ] Weekly usage push ("Your portfolio was up X%")

### Billing
- [ ] Billing issue push sequence (during grace period)
- [ ] Renewal reminder (annual subscribers)

### Re-Engagement
- [ ] Dormant user push sequence (7-21 days of inactivity)

### Win-Back
- [ ] Post-expiration push sequence (7-90 days)
- [ ] Promotional offer push (90 days, if RevenueCat offer configured)

### Future (When Email Added)
- [ ] Welcome email sequence
- [ ] Weekly portfolio report email
- [ ] Billing issue email supplement
- [ ] Re-engagement email sequence
- [ ] Win-back email sequence
- [ ] Monthly product roundup
