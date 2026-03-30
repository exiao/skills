# Copy Guidelines

Guidelines for writing push notifications and email copy for lifecycle messaging.

---

## Brand Voice

- Direct, not corporate
- Helpful, not salesy
- Confident, not hype-y
- Treats users as capable adults, not beginners (unless they are)
- No AI slop patterns (vague superlatives, filler phrases, hollow enthusiasm)

**Do:** "Your tracked item dropped to $49 today."
**Don't:** "Great news! 🎉 We're thrilled to let you know that your amazing account has some exciting updates!"

---

## Push Notification Copy

### Constraints
- **Title:** 40-50 characters max (truncated on lock screen)
- **Body:** 100-150 characters ideal (truncated varies by device)
- **Deep link:** Every push should open to a specific screen, not home

### Structure
1. What happened or what to do (the hook)
2. Why it matters (brief context)
3. Implied action (the deep link handles this)

### Patterns That Work

**Data-driven:**
- "[Item] hit your target price" (specific, relevant)
- "You reached your weekly goal" (personalized milestone)
- "3 of your tracked items have updates" (aggregated insight)

**Feature education:**
- "Ask [Product] any question" (clear, actionable)
- "Connect your account to track everything" (specific benefit)

**Timely:**
- "[Event] just happened. See the summary." (timely)
- "Weekly update is ready." (relevant)

### Patterns to Avoid

- Generic: "Check out what's new!" (no reason to tap)
- Desperate: "We miss you! Come back!" (cringe)
- Clickbait: "You won't believe what happened!" (breaks trust)
- Guilt: "Your account feels lonely" (manipulative)
- Too frequent: More than 1 push per day for non-urgent content (push fatigue)

### Emoji in Push

- One emoji max per push, and only if it adds meaning
- ✅ "📊 Your report is ready" (emoji adds context)
- ❌ "🎉🚀💰 Great things happening!!!" (emoji spam)

---

## Email Copy

### Structure
1. **Hook**: First line grabs attention (no "Hi [Name], I hope you're well")
2. **Context**: Why this matters to them
3. **Value**: The useful content
4. **CTA**: What to do next (one primary CTA per email)
5. **Sign-off**: Simple. "— [Product Name]" is fine.

### Length
- Transactional (billing, alerts): 50-100 words
- Educational (features, tips): 150-250 words
- Story-driven (case study, update): 250-400 words
- Shorter is almost always better

### Subject Lines
- 40-60 characters
- Clear > clever
- Specific > vague
- Personalized when possible ("[Item] moved X% today")

**Patterns that work:**
- Data: "You hit your goal this month"
- Question: "Have you tried [feature]?"
- Direct: "Payment issue with your subscription"
- Update: "New in [Product]: [feature name]"

**Patterns to avoid:**
- Vague: "Important update" (about what?)
- Urgent when not urgent: "URGENT: Your account" (for a feature announcement)
- All caps anything
- Multiple punctuation: "Don't miss this!!!"

### Preview Text
- Extends the subject line, doesn't repeat it
- 90-140 characters
- Complete the thought or add useful context
- Don't leave it as auto-pulled body text

### CTA Guidelines
- One primary CTA per email (button)
- Button text: Action verb + destination ("See Full Report", "Update Payment", "Add an Item")
- Links for secondary actions (in-text)
- Every CTA deep links to the relevant app screen or web page

---

## Personalization

### Data to Use
- Names or identifiers from their profile (items tracked, activity)
- Performance numbers or stats relevant to them
- Feature usage patterns (actions taken, content consumed)
- Subscription tenure
- Platform (iOS/Android) for correct settings deep links

### Dynamic Content
- Personalize based on segment (free vs. paid, new vs. long-term)
- Personalize based on behavior (active vs. dormant, features used)
- Personalize based on their actual data (tracked items, history)

### Fallbacks
- No user-specific data? Use aggregate or default content
- No name? Skip the greeting or use "there"
- No activity data? Focus on feature discovery

---

## Segmentation

### By Engagement
- **Active**: Opens app 3+ times per week. Light touch, value-add only.
- **Moderate**: Opens 1-2 times per week. Feature education, gentle nudges.
- **Dormant**: No open in 7+ days. Re-engagement sequence.
- **Churned**: Subscription expired. Win-back sequence.

### By Lifecycle Stage
- **New free user**: Onboarding, activation
- **New subscriber**: Reinforce value, expand usage
- **Established subscriber**: Reduce to maintenance, ask for reviews
- **At-risk**: Proactive intervention (see churn-prevention skill)

### By Platform
- iOS and Android have different subscription management flows
- Deep links differ ("Update payment" routes to different settings)
- Push token staleness differs (Android worse than iOS)

---

## Testing

### What to Test
- Push: title copy, send time, personalized vs. generic
- Email: subject lines (highest impact), send time, length, CTA copy
- Sequence: timing between messages, number of messages, exit conditions

### How to Test
- Use feature flags for A/B tests
- One variable at a time
- Sufficient sample size before declaring a winner
- Document every test and result

### Metrics to Track

**Push:**
- Delivery rate (expect some loss due to token staleness)
- Open/tap rate (5-15% is normal for mobile push)
- Conversion rate (action taken after tap)
- Opt-out rate (keep under 0.5% per push)

**Email:**
- Open rate (target: 25-40%)
- Click rate (target: 3-5%)
- Unsubscribe rate (keep under 0.5%)
- Conversion rate (specific to sequence goal)
