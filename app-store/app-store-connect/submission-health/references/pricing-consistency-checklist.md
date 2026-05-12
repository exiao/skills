# Subscription Pricing Consistency Checklist

When a Google Play or App Store submission is rejected for "inconsistent pricing" or "misleading subscription information," audit these areas.

## 1. Hardcoded currency symbols in i18n strings
Search translation files (`.json`, `.xml`, `.strings`) for literal `$`, `€`, `£`, `¥`, etc. near price values.

**Common pattern:** Free trial CTAs that say `$0.00` while the rest of the paywall uses dynamic currency from RevenueCat/StoreKit.

Fix: replace with interpolation parameters:
```json
// Before
"startForFree": "Start for $0.00"
// After  
"startForFree": "Start for {{freePrice}}"
```

Call site must pass the dynamic currency:
```typescript
t('startForFree', { freePrice: `${currencySymbol}0.00` })
```

## 2. Fallback prices with assumed USD
Check constants like `FALLBACK_PRICES` that provide default values when the store SDK hasn't loaded. If these display to the user while the SDK loads, they'll show USD amounts even for non-USD users.

Options:
- Show a loading spinner until real prices arrive (preferred)
- Use the resolved `currencySymbol` even with fallback amounts
- Never display fallback prices to the user; only use them for layout calculations

## 3. Multiple price display locations out of sync
Audit all places that show subscription pricing:
- CTA button text (e.g., "Start for €0.00")
- Fine print / legal text (e.g., "Free today, then €104/year")
- Plan selection cards (weekly vs yearly comparison)
- One-time offer / discount screens
- Pricing cards (annual price, weekly equivalent)
- Bottom sheet plan selector

All must use the same `currencySymbol` source. In Bloom, this is:
```typescript
const currencySymbol = annualPackage?.product?.priceString?.[0] 
  || weeklyPackageFromAllOfferings?.product?.priceString?.[0] 
  || '$';
```

## 4. Currency symbol extraction pitfall
Taking `priceString[0]` works for `$`, `€`, `£`, `¥` but fails for multi-char symbols like `R$` (BRL), `HK$`, `CA$`, `Rp` (IDR). If supporting these markets, use RevenueCat's `currencyCode` with a lookup table (see `pricing.ts` `getCurrencySymbol()`).

## 5. Discount screens
One-time offer and discount screens often have their own price rendering. Verify they also use dynamic currency, not hardcoded. Check:
- Original price (strikethrough)
- Discount price
- Savings percentage badge
- "After free trial" text

## 6. Purchase flow double-tap guard
The purchase handler (e.g., `handleStartTrial`) must check `isLoading` at the top of the function, not just rely on the button's `disabled` prop. Without this, a fast double-tap can fire the function twice before `setIsLoading(true)` takes effect, causing:
- Duplicate analytics events (PostHog, AppsFlyer)
- Duplicate backend registration calls
- Duplicate toast messages

RevenueCat's native payment sheet blocks actual duplicate charges, but the side effects are real.

```typescript
const handleStartTrial = async (...) => {
  // Guard against double-tap AND fetching race conditions
  if (isLoading || isFetchingOfferings) return;
  // ... rest of purchase flow
  setIsLoading(true);
```

## Bloom-specific files to audit
- `frontend/src/locales/en/translation.json` — search for `$` near `subscription.`
- `frontend/src/locales/es/translation.json` — same
- `frontend/src/utils/subscriptionUtils.ts` — `FALLBACK_PRICES`
- `frontend/src/utils/pricing.ts` — `getCurrencySymbol()`, `CURRENCY_SYMBOLS`
- `frontend/src/components/PaymentModalByPreference/PaymentModalByPreference.tsx`
- `frontend/src/components/PaymentModalByPreference/OneTimeOfferScreen.tsx`
- `frontend/src/components/PaymentModalByPreference/PlanSelectionSheet.tsx`
- `frontend/src/components/PaymentModalByPreference/AnnualPricingCard.tsx`
