---
name: slideshow-creator
description: Create and post TikTok slideshows via ReelFarm. Use for generating slideshow content, setting up automations, and publishing to TikTok. For strategy, scheduling, analytics, and optimization — use the content-management skill first.
---
# TikTok Slideshow Creator

Generate and post TikTok slideshows via ReelFarm. This skill is production only.

**Before using this skill:** Read the **content-management** skill to determine what to make, for which niche, and at what volume.

## References

- [Prerequisites](references/prerequisites.md)
- [First Run — Onboarding](references/first-run-onboarding.md)
- [Core Workflow](references/core-workflow.md)
- [Slide Structure](references/slide-structure.md)
- [App Category Templates](references/app-category-templates.md)
- [Cross-Posting](references/cross-posting.md)
- [Common Mistakes](references/common-mistakes.md)
- [Hard-Won Lessons (Read This Before You Start)](references/hard-won-lessons-read-this-before-you-start.md)

## Posting via ReelFarm

ReelFarm (reel.farm) creates, schedules, and automates TikTok slideshow posts. No API — browser automation only.

### Account
- **Login**: Google sign-in with `socials@promptpm.ai`
- **Dashboard**: `https://reel.farm/dashboard`
- **Browser profile**: `profile=clawd`

### Dashboard Sections

| Section | URL | Purpose |
|---------|-----|---------|
| Home | `/dashboard` | Slideshow library (5400+ templates) |
| Library | `/dashboard/library` | Your created slideshows |
| Schedule | `/dashboard/schedule` | Scheduled posts calendar |
| Automations | `/dashboard/automations` | Set-and-forget posting rules |

### Creating a Slideshow
1. Navigate to `https://reel.farm/dashboard`
2. Click **"+ New Automation"** or find a template
3. Set hook/narrative text, images (auto-sources from Pinterest), caption, hashtags
4. Preview, then schedule or publish

### Automations
1. Click **"+ New Automation"**
2. Configure niche, hook style, posting frequency, TikTok account, image source
3. Let it run on schedule

### Bloom-Specific
- **TikTok**: @invest.with.bloom (established, no warmup needed)
- **Niche**: finance/investing, personal finance, stock market
- **Hooks**: "5 investing mistakes beginners make", "What I learned losing money in stocks"
- **CTA**: "Search Bloom on the App Store" or soft caption mention

### Browser Automation Notes
- Use `profile=clawd` for all browser actions
- ReelFarm is a React SPA — wait for elements to load after navigation
- Use `targetId` from initial open for subsequent tab actions
