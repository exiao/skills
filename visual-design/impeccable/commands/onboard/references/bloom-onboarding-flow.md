# Bloom Onboarding Flow (as of 2026-05-07)

Source files: `frontend/src/components/OnboardingView/`, `frontend/src/locales/en/translation.json`, `frontend/src/constants/onboarding.ts`

## Architecture

- **Welcome page** (`/welcome`) — standalone carousel, routes to `/onboarding/0`
- **Onboarding steps** (`/onboarding/:step`) — 5 slides (indices 0-4) in `OnboardingView.tsx`
- **Paywall** — triggered by `stores.showPaymentModalByPreference('onboarding_completion')` after final step
- **Skip path** — Welcome → `/one-time-offer` (OTO paywall variant)
- State: `localStorage` for `onboardingIndex`, `onboardingStartTime`, `onboardingMotivations`
- Analytics: PostHog + AppsFlyer events per step

## Screens

### 1. Welcome (Welcome.tsx)
- 6 rotating feature animations with auto-rotate + swipe + tap-to-select dots:
  - "Chat", "Copy trading", "Intel that moves markets", "Notifications to stay up to date", "Portfolio monitoring on autopilot", "Your personalized daily market update"
- Each animation is a real component (AIChatAnimation, DailyPicksAnimation, etc.)
- Heading: "Invest smarter with AI"
- Subheading: "Get expert guidance on your portfolio in 60 seconds"
- Feature badges: Fundamentals, Earnings, Technicals, Options, Sentiment, News
- CTA: "Get started" → `/onboarding/0`
- Skip: "Skip and explore" → `/one-time-offer`

### 2. Investor Style (slide index 0, id: 'motivation-selector')
- Title: "What's your investing style?" (highlight: "investing style")
- Description: "We'll personalize your stock picks based on your answer"
- Single-select radio cards:
  - 🌱 Learning the basics — "Get beginner-friendly explanations" (value: 'new-investor')
  - 📈 Active trading — "Focus on news, technicals, and momentum" (value: 'active-trader')
  - 🔍 Deep research — "Dive through earnings calls and fundamentals" (value: 'researcher')
- Saved to localStorage as `onboardingMotivations`

### 3. AI Arena (slide index 1, id: 'ai-arena-teaser')
- Title: "Our AI portfolio managers beat the market" (highlight: "beat the market")
- Description: "We use the leading AI models to research the market every day"
- Fetches real AI portfolio performance data from API
- Shows portfolio bars with rank + SPY benchmark ("S&P 500 YTD")
- Disclaimer: "Past performance doesn't guarantee future results" (tappable for full disclaimer modal)
- CTA: "Show me their portfolios"

### 4. Top Ideas (slide index 2, id: 'top-ideas')
- Title personalizes by investor type:
  - new-investor: "Top ideas for new investors"
  - active-trader: "Top ideas for active traders"
  - researcher: "Top ideas for researchers"
  - default: "Top ideas for you"
- Description: "Tap any stock to add it to your watchlist"
- Stock suggestions come from `getSuggestedStocksFromMotivations()` + AI portfolio holdings
- Section headers: "Good for new investors" / "Trending for active traders" / "Deep-dive picks" / "AI portfolios are buying"
- Selected stocks saved to state, later added to Watchlist portfolio
- CTA: "Add to my watchlist"

### 5. Live AI Chat (slide index 3, id: 'onboarding-chat')
- If user selected a stock (topSymbol):
  - Title: "Ask our AI about [TICKER]" (highlight: ticker)
  - Description: "Get AI-powered research in seconds"
  - Auto-suggested question: "What's the bull case and bear case for [TICKER]?"
- If no stock:
  - Title: "Research stocks with AI" (highlight: "Research stocks")
  - Description: "Hedge funds spend 40+ hours researching each trade. Now you can too — in seconds."
- **This is a LIVE interactive chat** using `useStreamingChat` hook — real AI response streamed in
- User can type custom questions or tap suggestions
- CTA: "Continue"

### 6. Alerts (slide index 4, id: 'smart-alerts')
- If topSymbol: Title = "Get alerted when [TICKER] moves" (highlight: ticker)
- If no stock: Title = "Stay informed" (highlight: "informed")
- Description: "Catch market moves early with intelligent alerts. Customize these anytime in settings."
- Shows notification preference toggles from `useNotificationPreferences()`
- Suggested defaults: smart_notifications, news_alerts, daily_alerts, ai_portfolio_trades, ai_trade_digest
- Each toggle shows a notification card preview with example content
- CTA: "Finish setup" → triggers paywall modal

## Key Design Decisions
- Single-select investor type (not multi-select) — simplifies personalization
- AI Arena uses real API data, not mocked
- Chat is live (streaming), not a canned demo
- Alerts screen uses user's top selected stock in title
- Skip from Welcome goes to OTO (paywall variant), not directly into the app
- 6 total screens (Welcome + 5 steps) — moderate funnel length
