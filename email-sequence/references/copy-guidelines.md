# Copy Guidelines (Bloom)

Guidelines for writing push notifications and email copy for Bloom's lifecycle messaging.

---

## Bloom's Voice

- Direct, not corporate
- Helpful, not salesy
- Confident, not hype-y
- Treats users as smart investors, not beginners (unless they are)
- No AI slop patterns (see SOUL.md for the full kill list)

**Do:** "Your watchlist stock AAPL is up 3% today."
**Don't:** "Great news! 🎉 We're thrilled to let you know that your amazing portfolio has some exciting updates!"

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
- "[Stock] is up 5% today" (specific, relevant)
- "Your portfolio gained $X this week" (personalized)
- "3 of your stocks hit new highs" (aggregated insight)

**Feature education:**
- "Ask Bloom about any stock" (clear, actionable)
- "Connect your brokerage to track everything" (specific benefit)

**FOMO (use sparingly):**
- "[Stock] just reported earnings. See the analysis." (timely)
- "Markets opened down 2%. Your watchlist update is ready." (relevant)

### Patterns to Avoid

- Generic: "Check out what's new!" (no reason to tap)
- Desperate: "We miss you! Come back!" (cringe)
- Clickbait: "You won't believe what happened to your stock!" (breaks trust)
- Guilt: "Your watchlist is lonely" (manipulative)
- Too frequent: More than 1 push per day for non-urgent content (push fatigue)

### Emoji in Push

- One emoji max per push, and only if it adds meaning
- ✅ "📊 AAPL earnings are out" (emoji adds context)
- ❌ "🎉🚀💰 Your portfolio is up!!!" (emoji spam)

---

## Email Copy (Future)

### Structure
1. **Hook**: First line grabs attention (no "Hi [Name], I hope you're well")
2. **Context**: Why this matters to them
3. **Value**: The useful content
4. **CTA**: What to do next (one primary CTA per email)
5. **Sign-off**: Simple. "— Bloom" is fine.

### Length
- Transactional (billing, alerts): 50-100 words
- Educational (features, tips): 150-250 words
- Story-driven (case study, update): 250-400 words
- Shorter is almost always better

### Subject Lines
- 40-60 characters
- Clear > clever
- Specific > vague
- Personalized when possible ("[Stock] moved X% today")

**Patterns that work:**
- Data: "Your portfolio is up 8% this month"
- Question: "Have you tried AI stock analysis?"
- Direct: "Payment issue with your Bloom subscription"
- Update: "New in Bloom: [feature name]"

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
- Button text: Action verb + destination ("See Full Report", "Update Payment", "Add a Stock")
- Links for secondary actions (in-text)
- Every CTA deep links to the relevant app screen or web page

---

## Personalization

### Data to Use
- Stock names from their watchlist
- Portfolio performance numbers
- Feature usage stats (insights received, stocks tracked)
- Subscription tenure
- Platform (iOS/Android) for correct settings deep links

### Dynamic Content
- Personalize based on segment (free vs. paid, new vs. long-term)
- Personalize based on behavior (active vs. dormant, features used)
- Personalize based on their actual data (watchlist, portfolio)

### Fallbacks
- No watchlist data? Use market index data instead
- No name? Skip the greeting or use "there"
- No portfolio? Focus on watchlist or discovery features

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
- Use PostHog feature flags for A/B tests
- One variable at a time
- Sufficient sample size before declaring a winner
- Document every test and result

### Metrics to Track

**Push:**
- Delivery rate (expect low due to token staleness)
- Open/tap rate (5-15% is normal for mobile push)
- Conversion rate (action taken after tap)
- Opt-out rate (keep under 0.5% per push)

**Email (future):**
- Open rate (target: 25-40%)
- Click rate (target: 3-5%)
- Unsubscribe rate (keep under 0.5%)
- Conversion rate (specific to sequence goal)
