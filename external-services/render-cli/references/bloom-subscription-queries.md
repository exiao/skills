# Bloom Subscription Database Queries

Quick-reference queries for investigating subscription state in Bloom's production Postgres.

## Setup

```bash
source ~/.hermes/.env
RENDER_API_KEY=$RENDER_API_KEY_BLOOM render workspace set tea-bpfklfr4ttth01lbtse0 -o json --confirm
# Bloom DB ID: dpg-cuqga3l2ng1s73ercck0-a (name: bloom-db)
```

## Check for duplicate subscriptions

All three tables enforce uniqueness at the DB level, so true duplicates are impossible:

```sql
-- UserSubscription: user field has unique=True
SELECT COUNT(*) as total, COUNT(DISTINCT "user") as unique_users
FROM bloom_backend_usersubscription;

-- WhatsAppSubscription: whatsapp_number has unique=True
SELECT COUNT(*) as total, COUNT(DISTINCT whatsapp_number) as unique_numbers
FROM bloom_backend_whatsappsubscription;

-- WhatsAppCommunityMember: user field has unique=True
SELECT COUNT(*) as total, COUNT(DISTINCT "user") as unique_users
FROM bloom_backend_whatsappcommunityMember;
```

## WinbackAttempt dedup check

Billing issue events intentionally create TWO non-cancelled attempts per user (immediate + 48h followup). This is by design, NOT a bug.

```sql
SELECT revenuecat_user_id, event_type, COUNT(*) as cnt
FROM bloom_backend_winbackattempt
WHERE cancelled = false
GROUP BY revenuecat_user_id, event_type
HAVING COUNT(*) > 1
LIMIT 20;
```

## Architecture notes

- `UserSubscription.user` is the FCM token (unique), subscription_type is always 'free' (trial notification tracking only)
- `register_user_subscription` uses `update_or_create` on user field
- RevenueCat webhook uses Postgres advisory locks + `_attempt_already_handled()` for idempotency
- WhatsApp subscriptions use `get_or_create` on whatsapp_number
- Actual Pro/free state is determined by RevenueCat entitlements on the client, not the UserSubscription table

## Frontend double-purchase guard checklist

When auditing purchase flows for duplicate subscription risk:

1. **Button `disabled` prop is NOT sufficient.** React state updates are async; a fast double-tap can fire the `onClick` handler twice before `setIsLoading(true)` re-renders and disables the button.
2. **The async handler itself must guard.** Add `if (isLoading) return;` at the top of purchase handler functions, not just on the button's `disabled` prop.
3. **RevenueCat's `Purchases.purchasePackage()` is a secondary guard** because the native OS payment sheet blocks concurrent purchases. But without the handler guard, you still get duplicate analytics events, duplicate backend API calls, and duplicate toasts.
4. **Key files:** `PaymentModalByPreference.tsx` (`handleStartTrial`), `OneTimeOfferPage/index.tsx`, `userSubscriptionService.ts`
