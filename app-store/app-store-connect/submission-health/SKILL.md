---
name: submission-health
description: "Preflight App Store and Google Play submissions, submit builds, monitor review status, and troubleshoot rejection causes (pricing inconsistencies, compliance, metadata). Use when shipping, troubleshooting review submissions, or fixing store rejections."
---

# asc submission health

Use this skill to reduce review submission failures and monitor status.

## Preconditions
- Auth configured and app/version/build IDs resolved.
- Build is processed (not in processing state).
- All required metadata is complete.

## Pre-submission Checklist

### 1. Verify Build Status
```bash
asc builds info --build "BUILD_ID"
```
Check:
- `processingState` is `VALID`
- `usesNonExemptEncryption` - if `true`, requires encryption declaration

### 2. Encryption Compliance
If `usesNonExemptEncryption: true`:
```bash
# List existing declarations
asc encryption declarations list --app "APP_ID"

# Create declaration if needed
asc encryption declarations create \
  --app "APP_ID" \
  --app-description "Uses standard HTTPS/TLS" \
  --contains-proprietary-cryptography=false \
  --contains-third-party-cryptography=true \
  --available-on-french-store=true

# Assign to build
asc encryption declarations assign-builds \
  --id "DECLARATION_ID" \
  --build "BUILD_ID"
```

**Better approach:** Add `ITSAppUsesNonExemptEncryption = NO` to Info.plist and rebuild.

### 3. Content Rights Declaration
Required for all App Store submissions:
```bash
# Check current status
asc apps get --id "APP_ID" --output json | jq '.data.attributes.contentRightsDeclaration'

# Set if missing
asc apps update --id "APP_ID" --content-rights "DOES_NOT_USE_THIRD_PARTY_CONTENT"
```
Valid values:
- `DOES_NOT_USE_THIRD_PARTY_CONTENT`
- `USES_THIRD_PARTY_CONTENT`

### 4. Version Metadata
```bash
# Check version details
asc versions get --version-id "VERSION_ID" --include-build

# Verify copyright is set
asc versions update --version-id "VERSION_ID" --copyright "2026 Your Company"
```

### 5. Localizations Complete
```bash
# List version localizations
asc localizations list --version "VERSION_ID"

# Check required fields: description, keywords, whatsNew, supportUrl
```

### 6. Screenshots Present
Each locale needs screenshots for the target platform.

### 7. App Info Localizations (Privacy Policy)
```bash
# List app info IDs (if multiple exist)
asc app-infos list --app "APP_ID"

# Check privacy policy URL
asc localizations list --app "APP_ID" --type app-info --app-info "APP_INFO_ID"
```

## Submit

### Using Review Submissions API (Recommended)
```bash
# Create submission
asc review submissions-create --app "APP_ID" --platform IOS

# Add version to submission
asc review items-add \
  --submission "SUBMISSION_ID" \
  --item-type appStoreVersions \
  --item-id "VERSION_ID"

# Submit for review
asc review submissions-submit --id "SUBMISSION_ID" --confirm
```

### Using Submit Command
```bash
asc submit create --app "APP_ID" --version "1.2.3" --build "BUILD_ID" --confirm
```
Use `--platform` when multiple platforms exist.

## Monitor
```bash
# Check submission status
asc submit status --id "SUBMISSION_ID"
asc submit status --version-id "VERSION_ID"

# List all submissions
asc review submissions-list --app "APP_ID" --paginate
```

## Cancel / Retry
```bash
# Cancel submission
asc submit cancel --id "SUBMISSION_ID" --confirm

# Or via review API
asc review submissions-cancel --id "SUBMISSION_ID" --confirm
```
Fix issues, then re-submit.

## Common Submission Errors

### Google Play: Inconsistent subscription pricing display
Google Play rejects updates when the paywall shows mixed currency symbols (e.g., CTA says "Start for $0.00" but fine print says "€104/year"). This happens when i18n translation strings hardcode `$` while the rest of the paywall dynamically uses the user's currency from RevenueCat/BillingClient.

**Fix pattern:** Never hardcode currency symbols in translation strings. Use interpolation parameters that reference the same `currencySymbol` derived from the store SDK's package data:
```
// BAD
"startForFree": "Start for $0.00"
// GOOD
"startForFree": "Start for {{freePrice}}"
// Call site: t('startForFree', { freePrice: `${currencySymbol}0.00` })
```

Also check fallback prices (e.g., `FALLBACK_PRICES` constants). If RevenueCat hasn't loaded yet, ensure fallback display still uses a consistent currency symbol, not hardcoded `$`.

See `references/pricing-consistency-checklist.md` for the full audit checklist.

### "Version is not in valid state"
Check:
1. Build is attached and VALID
2. Encryption declaration approved (or exempt)
3. Content rights declaration set
4. All localizations complete
5. Screenshots present for all locales

### "Export compliance must be approved"
The build has `usesNonExemptEncryption: true`. Either:
- Upload export compliance documentation
- Or rebuild with `ITSAppUsesNonExemptEncryption = NO` in Info.plist

### "Multiple app infos found"
Use `--app-info` flag with the correct app info ID:
```bash
asc app-infos list --app "APP_ID"
```

## Notes
- `asc submit create` uses the new reviewSubmissions API automatically.
- Use `--output table` when you want human-readable status.
- macOS submissions follow the same process but use `--platform MAC_OS`.
