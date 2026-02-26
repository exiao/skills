# 5. Push Notifications

Push notifications are the highest-converting channel you have. They're also the fastest way to get uninstalled. Respect them.

### Rules

1. **Every push must deliver value or trigger action.** No "We miss you!" garbage.
2. **Personalize.** "NVDA just got upgraded to Buy" > "Check out new analyst ratings"
3. **Timing matters.** Market hours for market events. Never push at 3 AM.
4. **Frequency cap.** Max 1-2/day for engaged users. Max 2-3/week for casual users.
5. **Deep link to the relevant screen.** Don't push about insider trades and drop them on the home screen.

### Templates by Type

#### Trigger-Based (Highest Value)

Fired by real events on stocks the user watches.

```
ANALYST UPGRADE:
Title: "NVDA Upgraded to Buy"
Body: "Goldman Sachs upgraded NVIDIA with a $180 price target. See the full analysis."

INSIDER TRADE:
Title: "AAPL CEO just bought $10M in stock"  
Body: "Tim Cook purchased 50,000 shares at $198. Largest insider buy this quarter."

EARNINGS BEAT:
Title: "TSLA beat earnings by 15%"
Body: "Revenue $25.7B vs $24.2B expected. AI breaks down the call highlights."

PRICE ALERT:
Title: "AMZN hit your $200 target"
Body: "Amazon crossed $200 for the first time since March. Tap to see what changed."
```

#### Feature Announcements

```
NEW FEATURE:
Title: "New: AI Earnings Analysis"
Body: "Bloom now breaks down earnings calls in real-time. Try it with AAPL's report tonight."

IMPROVEMENT:
Title: "Stock search is 2x faster"
Body: "We rebuilt search from scratch. Try it — search any of 6,000+ tickers."
```

#### Re-engagement

Only send after 7+ days of inactivity. Require a hook.

```
MARKET EVENT:
Title: "Markets dropped 3% today"
Body: "Your watchlist has 4 stocks down over 5%. Tap to see which analysts are upgrading."

MISSED ALERT:
Title: "2 stocks on your watchlist got upgraded"  
Body: "While you were away, MSFT and GOOGL received analyst upgrades. See details."

SEASONAL:
Title: "Earnings season starts Monday"
Body: "243 companies report this week, including 3 on your watchlist. Set your alerts."
```

#### Push Anti-Patterns

- ❌ "We miss you! Come back!" (guilt trip, zero value)
- ❌ "Check out what's new in Bloom" (what IS new? be specific)
- ❌ "Investing tip of the day" (unsolicited, not personalized)
- ❌ Pushing the same message to all users (segment or don't push)
- ❌ More than 3 pushes in a day (instant uninstall territory)
- ❌ Pushing at 2 AM about non-urgent features

---
