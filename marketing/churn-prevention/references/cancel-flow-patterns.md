<!-- Adapted from coreyhaines31/marketingskills. Customize further for Bloom's mobile app context. -->

# Cancel Flow Patterns

Detailed cancel flow patterns by business type, billing provider, and industry.

---

## Cancel Flow by Business Type

### B2C / Self-Serve SaaS

High volume, low touch. The flow must work without human intervention.

**Flow structure:**
```
Cancel button → Exit survey (1 question) → Dynamic offer → Confirm → Post-cancel
```

**Characteristics:**
- Fully automated, no human in the loop
- Quick — 2-3 screens maximum
- One offer + one fallback, not a menu of options
- Mobile-optimized (significant cancellations on mobile)
- Clear "continue cancelling" at every step

**Typical save rate:** 20-30%

**Example flow for a $29/mo productivity app:**
1. "What's the main reason?" → 6 options
2. Selected "Too expensive" → "Get 25% off for 3 months (save $21.75)"
3. Declined → "Or switch to our Starter plan at $12/mo"
4. Declined → "We're sorry to see you go. Your access continues until [date]."

---

### B2B / Team Plans

Lower volume, higher stakes. Personal outreach is worth the cost.

**Flow structure:**
```
Cancel button → Exit survey → Offer (or route to CS) → Confirm → Post-cancel
```

**Characteristics:**
- Route accounts above MRR threshold to customer success
- Show team impact ("Your 8 team members will lose access")
- Offer admin-to-admin call for enterprise accounts
- Longer consideration — allow "schedule a call" as a save option
- Require admin/owner role to cancel (not any team member)

**Typical save rate:** 30-45% (higher because of personal touch)

**MRR-based routing:**

| Account MRR | Cancel Flow |
|-------------|-------------|
| <$100/mo | Automated flow with offers |
| $100-$500/mo | Automated + flag for CS follow-up |
| $500-$2,000/mo | Route to CS before cancel completes |
| $2,000+/mo | Block self-serve cancel, require CS call |

---

### Freemium / Free-to-Paid

Users cancelling paid to return to free tier. Different psychology — they're not leaving, they're downgrading.

**Flow structure:**
```
Cancel button → "Switch to Free?" prompt → Exit survey (if still cancelling) → Offer → Confirm
```

**Characteristics:**
- Lead with the free tier as the first option (not a save offer)
- Show what they keep on free vs. what they lose
- The "save" is keeping them on free, not losing them entirely
- Track free-tier users for future re-upgrade campaigns

---

## Cancel Flow by Billing Interval

### Monthly Subscribers

- More price-sensitive, shorter commitment
- Discount offers work well (20-30% for 2-3 months)
- Pause is effective (1-2 months)
- Suggest annual plan at a discount as an alternative

**Offer priority:**
1. Discount (if reason = price)
2. Pause (if reason = not using / temporary)
3. Annual plan switch (if engaged but price-sensitive)

### Annual Subscribers

- Higher commitment, often cancelling for stronger reasons
- Prorate refund expectations matter
- Longer save window (they've already paid)
- Personal outreach more justified (higher LTV at stake)

**Offer priority:**
1. Pause remainder of term (if temporary)
2. Plan adjustment + credit for next renewal
3. Personal outreach from CS
4. Partial refund + downgrade (better than full refund + cancel)

**Refund handling:**
- Offer prorated refund if significant time remaining
- "Pause until renewal" if less than 3 months left
- Be generous — bad refund experiences create vocal detractors

---

## Save Offer Patterns

### The Discount Ladder

Don't lead with your biggest discount. Escalate:

```
Cancel click → 15% off → Still cancelling → 25% off → Still cancelling → Let them go
```

**Rules:**
- Maximum 2 discount offers per cancel session
- Never exceed 30% (higher trains cancel-for-discount behavior)
- Time-limit discounts (2-3 months, then full price resumes)
- Track discount accepters — if they cancel again at full price, don't re-offer

### The Pause Playbook

Pause is often better than a discount because it doesn't devalue your product.

**Implementation:**

| Setting | Recommendation |
|---------|---------------|
| Pause duration options | 1 month, 2 months, 3 months |
| Default selection | 1 month (shortest) |
| Maximum pause | 3 months (longer pauses rarely return) |
| During pause | Keep data, remove access |
| Reactivation | Auto-reactivate with 7-day advance email |
| Repeat pauses | Allow 1 pause per 12-month period |

**Pause reactivation sequence:**
- Day -7: "Your pause ends in 7 days. We've been busy — here's what's new."
- Day -1: "Welcome back tomorrow! Here's what's waiting for you."
- Day 0: "You're back! Here's a quick tour of what's new."

### The Downgrade Path

For multi-plan products, downgrade is the strongest save:

```
┌─────────────────────────────────────────┐
│  Before you go, what about right-sizing │
│  your plan?                             │
│                                         │
│  Current: Pro ($49/mo)                  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ Switch to Starter ($19/mo)      │    │
│  │                                 │    │
│  │ ✓ Keep: Projects, integrations  │    │
│  │ ✗ Lose: Advanced analytics,     │    │
│  │         team features           │    │
│  │                                 │    │
│  │ [Switch to Starter]             │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [No thanks, continue cancelling]       │
└─────────────────────────────────────────┘
```

**Downgrade best practices:**
- Show exactly what they keep and what they lose
- Use checkmarks and X marks for scanability
- Preserve their data even on the lower plan
- If they downgrade, don't show upgrade prompts for at least 30 days

### The Competitor Switch Handler

When the cancel reason is "switching to competitor":

1. **Ask which competitor** (optional, don't force it)
2. **Show a comparison** if you have one
3. **Offer a migration credit** ("We'll match their price for 3 months")
4. **Request a feedback call** ("15 minutes to understand what we're missing")

This data is gold for product and marketing teams.

---

## Post-Cancel Experience

What happens after cancel matters for:
- Win-back potential
- Word of mouth
- Review sentiment

### Confirmation Page

```
Your subscription has been cancelled.

What happens next:
• Your access continues until [billing period end date]
• Your data will be preserved for 90 days
• You can reactivate anytime from your account settings

[Reactivate My Account]

We'd love to have you back. We'll keep improving based on feedback
from users like you.
```

### Post-Cancel Sequence

| Timing | Action |
|--------|--------|
| Immediately | Confirmation push notification with access end date |
| Day 1 | (Nothing — don't be desperate) |
| Day 7 | NPS/satisfaction survey (in-app on next open) |
| Day 30 | Push: "What's new" with recent improvements |
| Day 60 | Push: Address their specific cancel reason if resolved |
| Day 90 | Final win-back push with special offer |

---

## Segmentation Rules

The most effective cancel flows use segmentation to show different offers to different users.

### Segmentation Dimensions

| Dimension | Why It Matters |
|-----------|---------------|
| Plan / price | Higher-value subscribers get more generous offers |
| Tenure | Long-term users get different messaging than new ones |
| Usage level | High-usage users get different messaging than dormant ones |
| Billing interval | Monthly vs. annual need different approaches |
| Previous saves | Don't re-offer the same discount to a repeat canceller |
| Cancel reason | Drives which offer to show (core mapping) |

### Segment-Specific Flows

**New user (< 30 days):**
- They haven't activated. The save is onboarding, not discounts.
- Offer: Feature tour, setup help, guided first steps
- Ask: "What were you hoping to accomplish?" (learn what's missing)

**Engaged user cancelling on price:**
- They love the product but can't justify the cost.
- Offer: Annual plan switch, promotional pricing
- High save potential

**Dormant user (no app open 30+ days):**
- They forgot about you. A discount won't bring them back.
- Offer: "What changed?" conversation, value reminder
- Low save potential — focus on learning why

**Power user switching to competitor:**
- They're actively choosing something else.
- Offer: Competitive comparison, feedback request, roadmap preview
- Medium save potential — depends on reason

---

## Implementation Checklist

### Phase 1: Foundation (Week 1)
- [ ] Enable Billing Grace Period in App Store Connect
- [ ] Configure Google Play grace period (7 days) + account hold (30 days)
- [ ] Add pre-cancel flow (value stats + survey + 1 offer + Settings redirect)
- [ ] Set up exit survey with 5-7 reason categories
- [ ] Map one offer per reason (simple 1:1 mapping)
- [ ] Track cancel reasons and save rate in PostHog

### Phase 2: Optimization (Weeks 2-4)
- [ ] Add fallback offers (primary + secondary per reason)
- [ ] Set up billing issue push notification sequence (3 pushes over 7 days)
- [ ] Add in-app billing issue banner
- [ ] Implement health score model with PostHog user properties
- [ ] Build RevenueCat webhook handlers for billing events

### Phase 3: Advanced (Month 2+)
- [ ] Proactive intervention triggers based on health score
- [ ] A/B test pre-cancel flow variants with PostHog feature flags
- [ ] Segment flows by plan, tenure, and usage
- [ ] Post-cancel win-back push sequence
- [ ] Cohort analysis: churn by channel, plan, tenure, platform
- [ ] RevenueCat Experiments for offer pricing tests

---

## Compliance Notes

### Apple App Store Guidelines
- Cancellation must be easy — never hide the path to Settings
- Apps cannot require in-app cancellation if the subscription was purchased via App Store
- Save offers and surveys before redirecting to Settings are allowed
- Promotional offers require proper signing and entitlement

### Google Play Policies
- Similar to Apple: cancellation must be straightforward
- Deep-linking to Play Store subscription management is encouraged
- Grace period and account hold must be configured properly

### FTC Click-to-Cancel Rule (US)
- Cancellation must be as easy as signup
- Cannot require a phone call to cancel if signup was online
- Save offers are allowed but "continue cancelling" must be clear

### General Best Practices
- Always show a clear path to complete cancellation
- Never hide the cancel option (dark pattern)
- Process cancellation gracefully even if save flow has errors
- Confirm cancellation with in-app message or push notification
