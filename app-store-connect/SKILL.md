---
name: app-store-connect
description: Use the asc CLI for all App Store Connect tasks — releases, TestFlight, builds, metadata, screenshots, signing, subscriptions, IAPs, pricing, analytics, users, notarization, and more. Primary catch-all for any App Store Connect work. For deep workflows, also see specialized asc-* skills.
---

# App Store Connect (asc CLI)

Router skill. The `asc` CLI covers the full surface area of App Store Connect. Read the sub-skill that matches the task.

## Sub-skills

| Sub-skill | Use when |
|-----------|---------|
| `release-flow` | Uploading a build, distributing to TestFlight, or submitting to App Store review |
| `crash-triage` | Triaging TestFlight crashes and beta feedback |
| `shots-pipeline` | Automated screenshot capture + frame + upload |
| `metadata-sync` | Bulk metadata sync and legacy format migration |
| `localize-metadata` | Translating metadata to multiple languages |
| `signing-setup` | Onboarding a new app or rotating signing assets |
| `submission-health` | Preflight checks before submission |
| `testflight-orchestration` | Complex TF group / tester management |
| `ppp-pricing` | Territory-specific / PPP pricing |
| `revenuecat-catalog-sync` | Syncing ASC subs with RevenueCat |
| `xcode-build` | Building / archiving with xcodebuild |
| `notarization` | macOS Developer ID notarization |
| `subscription-localization` | Bulk-localizing subscription display names |
| `app-create-ui` | Creating a new app record (no public API, browser automation) |
| `workflow` | Multi-step asc workflow automations |
| `wall-submit` | Submitting to the Wall of Apps |
| `build-lifecycle` | Tracking build processing, finding latest builds, cleaning old builds |
| `id-resolver` | Resolving IDs (apps, builds, groups) from human-friendly names |
| `cli-usage` | asc CLI flags, output formats, pagination, auth, and discovery |

## Capability Map

| Area | Commands |
|------|----------|
| **Release** | `asc publish`, `asc submit`, `asc release` |
| **TestFlight** | `asc testflight`, `asc builds`, `asc build-localizations` |
| **Metadata** | `asc metadata`, `asc localizations`, `asc versions`, `asc app-info` |
| **Screenshots** | `asc screenshots`, `asc video-previews` |
| **Signing** | `asc signing`, `asc certificates`, `asc profiles`, `asc bundle-ids` |
| **Subscriptions / IAP** | `asc subscriptions`, `asc iap` |
| **Pricing** | `asc pricing` |
| **Analytics** | `asc analytics`, `asc insights`, `asc performance` |
| **Users** | `asc users`, `asc devices` |
| **Notarization** | `asc notarization` |
| **Workflows** | `asc workflow` |
| **Status** | `asc status --app <APP_ID>` |

Always run `asc <subcommand> --help` to verify flags. Output: `--output table` for humans, default JSON for scripts.
