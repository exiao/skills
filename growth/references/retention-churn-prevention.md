# Retention & Churn Prevention

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
