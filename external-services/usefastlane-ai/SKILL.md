---
name: usefastlane-ai
description: Use for Fastlane AI at usefastlane.ai, the short-form content platform and REST API for generating, remixing, scheduling, and analyzing organic TikTok, Instagram Reels, YouTube Shorts, and related content. Use when an agent needs to plan or automate Fastlane campaigns, call the Fastlane API, create content angles, tune Blitz preferences, generate content, schedule/cancel posts, inspect analytics, design account warmup/posting strategy, or build reusable prompt/workflow files for Fastlane. Do not use for fastlane.tools mobile app deployment automation.
---

# UseFastlane AI

This skill is an operational index. It gives the model enough context to start safely, then tells it to use the Fastlane API as the live source of truth for workspace data, schemas, states, and examples. It is meant to work from `SKILL.md` alone in any agent that can read Markdown and call HTTP APIs.

## What Fastlane Is

Fastlane (`usefastlane.ai`) is an AI short-form marketing platform. It learns a product/business from its website and profile, generates or remixes short-form content, and schedules it across TikTok, Instagram Reels, YouTube Shorts, and API-supported destinations.

Core concepts:

- **Workspace**: company context. API keys are scoped to the active workspace when created.
- **Blitz**: content generation loop. Fastlane keeps a discovery queue of AI suggestions. `POST /blitz` pops one suggestion and starts async rendered media generation.
- **Angles**: reusable personas/framing prompts that guide generation.
- **Preferences**: format mix, remix ratio, own-media ratio, product mention rate, gender filter, and per-angle weights.
- **Content**: generated/rendered media in the library.
- **Connections**: active social accounts.
- **Posts**: scheduled, inbox-delivered, published, failed, or deleted records.
- **Analytics**: synced engagement metrics for posts.

Core formats:

- `slideshow`: structured value slides with strong hook.
- `wall-of-text`: bold overlay text where the hook is the content.
- `video-hook`: hook plus product demo.
- `green-screen`: meme/reaction structure adapted to the niche.
- `custom`: uploaded or custom content where supported.

Use this for `usefastlane.ai`, not `fastlane.tools`.

## Safety

Use `FASTLANE_API_KEY`; never store API keys in files or print them. If the user pasted a key, treat it as compromised after the session and recommend rotation.

Confirm before destructive or externally visible actions unless the user already explicitly requested them:

- `DELETE /content/:id`
- `POST /posts/cancel`
- `POST /content/:id/schedule`

`POST /blitz` consumes one Blitz swipe but is not destructive. Use it when the user asks to generate content. Avoid it for read-only research.

Send a real `User-Agent`; Python `urllib` defaults can receive Cloudflare `403` before reaching Fastlane.

## API Starting Point

Base URL:

```text
https://api.usefastlane.ai/api/v1
```

Headers:

```text
Authorization: Bearer $FASTLANE_API_KEY
Accept: application/json
Content-Type: application/json; charset=utf-8
User-Agent: usefastlane-ai-agent/1.0
```

Envelopes:

```json
{ "data": {} }
```

```json
{ "data": [], "pagination": { "cursor": "opaque_or_null", "hasMore": true } }
```

```json
{ "error": { "code": "...", "message": "...", "details": {} } }
```

Rate limit: 20 requests/minute per workspace. On `429`, respect `Retry-After` or `details.retryAfterMs`. Platform limits may appear as `tiktok_post_limit_exceeded`, `youtube_post_limit_exceeded`, or `instagram_post_limit_exceeded`.

## Endpoint Index

Use this index first. If more detail is needed, inspect the live API with safe read calls.

| Area | Endpoint | Purpose |
| --- | --- | --- |
| Blitz | `POST /blitz` | Pop suggestion and start async content build |
| Blitz | `GET /blitz/preferences` | Read generation preferences |
| Blitz | `PATCH /blitz/preferences` | Update generation preferences |
| Angles | `GET /blitz/angles` | List active/inactive angles |
| Angles | `POST /blitz/angles` | Create angle |
| Angles | `PATCH /blitz/angles/:id` | Update angle |
| Angles | `DELETE /blitz/angles/:id` | Delete angle |
| Connections | `GET /connections` | List active social accounts |
| Content | `GET /content` | List content |
| Content | `GET /content/:id` | Fetch content item |
| Content | `DELETE /content/:id` | Delete content |
| Content | `POST /content/:id/schedule` | Schedule content |
| Posts | `GET /posts` | List posts |
| Posts | `GET /posts/:id` | Fetch post |
| Posts | `POST /posts/cancel` | Cancel scheduled posts |
| Analytics | `POST /analytics/posts` | Batch post metrics |

## Live Discovery Protocol

When the model needs more knowledge than this index provides, connect to the API and learn from safe reads. Do not guess fields when the API can show them.

Recommended first pass:

1. `GET /blitz/preferences`
2. `GET /blitz/angles`
3. `GET /connections`
4. `GET /content?limit=5`
5. `GET /posts?limit=5`
6. If content exists, `GET /content/:id` for one representative item.
7. If posts exist, `GET /posts/:id` and `POST /analytics/posts` for known post ids.

Summarize schema by field names, enum/status values, counts, and error codes. Avoid exposing private ids, usernames, captions, generated text, or media URLs unless the user needs them.

Use live data to infer:

- Available platforms and connected accounts.
- Current content/post statuses.
- Content types actually present.
- Preference fields and active angles.
- Pagination behavior and cursors.
- Error envelope details.

Do not use write endpoints as "schema probes" unless the user asked to mutate state. If a write fails during a real task, use the returned `error.code`, `message`, and `details` to update the plan.

## Minimal Request Shapes

These shapes are enough to start; verify live if behavior matters.

Create angle:

```json
{
  "title": "Product education",
  "description": "Explain how the product solves a specific problem.",
  "targetAudience": "Small business owners"
}
```

Patch preferences:

```json
{
  "slideshowWeight": 40,
  "wallOfTextWeight": 20,
  "greenScreenWeight": 20,
  "videoHookWeight": 20,
  "remixPercentage": 50,
  "ownMediaPercentage": 50,
  "mentionBusinessPercentage": 30,
  "genderFilter": null,
  "angleWeights": { "<angleId>": 100 }
}
```

Rules:

- If any format weight is sent, send all four and sum to 100.
- `angleWeights` must cover every active angle exactly once and sum to 100.
- Changing format weights or `remixPercentage` can flush the generation queue.

Schedule content:

```json
{
  "platform": "tiktok",
  "utc_datetime": "2026-05-01T18:00:00Z",
  "caption": "...",
  "description": "...",
  "connectionId": "..."
}
```

`connectionId` is optional only when exactly one active connection exists for the platform.

Cancel posts:

```json
{ "postIds": ["..."] }
```

Analytics:

```json
{ "postIds": ["..."] }
```

## Automation Artifacts

When building an autonomous campaign in a local project, create:

```text
fastlane/
  campaign-brief.md
  prompts.md
  angles.json
  preferences.json
  schedule.json
  api-log.jsonl
  metrics-snapshot.json
  scripts/
    fastlane_api.py
    inspect_workspace.py
    configure_generation.py
    generate_blitz_batch.py
    poll_content.py
    download_media.py
    qa_slideshow.py
    schedule_content.py
```

Never store API keys. Keep `api-log.jsonl` sanitized: endpoint, method, status, counts, ids only if needed.

For real generation work, prefer creating this local toolkit instead of doing one-off manual HTTP calls. Keep it generic enough to rerun:

- `fastlane_api.py`: shared HTTP client, auth headers, JSON handling, pagination, rate-limit backoff, and sanitized logging.
- `inspect_workspace.py`: safe reads for preferences, angles, connections, recent content, recent posts.
- `configure_generation.py`: snapshot current preferences, patch angle/preference weights, and restore the snapshot after generation.
- `generate_blitz_batch.py`: call `POST /blitz` repeatedly, record `contentId`, suggestion text, status, and errors.
- `poll_content.py`: poll content ids until `CREATED` or `FAILED`.
- `download_media.py`: download rendered media with a browser-like `User-Agent`; media hosts may reject default Python `urllib`.
- `qa_slideshow.py`: verify type, file count, line count, campaign keywords, missing/extra cover slides, and visual/manual-review paths.
- `schedule_content.py`: schedule only after explicit user approval and post-schedule verification.

The scripts should read `FASTLANE_API_KEY` from the environment, write results into `fastlane/runs/<timestamp>/`, and be safe to rerun without losing the original preference snapshot.

## Workflow: Inspect Workspace

1. Run the Live Discovery Protocol.
2. Report connected platforms, number of accounts, active angles, preferences, content counts by type/status, post counts by platform/status.
3. Flag likely issues: no connections, no active angles, failed content, scheduled posts near limits, weak format mix, missing analytics.

## Workflow: Generate Content

1. Inspect preferences and angles.
2. Optionally create/update campaign angles.
3. Optionally patch preferences, stopping for approval if it flushes the queue.
4. Call `POST /blitz` for requested quantity.
5. Poll `GET /content/:id` every ~10 seconds until not `BUILDING`.
6. QA `CREATED` items by type, files count, thumbnail, generated text if available, and campaign fit.
7. If `FAILED`, report and decide whether to retry.

Blitz findings from live use:

- A newly patched angle/preference mix may still produce an older queued suggestion. Do not trust the first render blindly.
- `POST /blitz` can return `202` with `data.contentId`, but some responses may use `data.contentId` instead of `data.id`.
- If Blitz returns `202` without a content id, or then returns `404`, treat it as no usable suggestion/content for that call. Wait and retry or adjust the angle/preference setup.
- For slideshows, verify both the suggestion text and the rendered images. A five-line suggestion can become one cover plus four advice slides; if the user asked for five actual tips, prompt/configure "no cover, exactly five slides, each slide is one numbered tip".
- If the content should feel native or custom rather than product-heavy, do not set `mentionBusinessPercentage` too high by default. Use a soft-sell pattern: make most slides useful on their own, then mention the product only in the final slide, caption, or CTA. For product-led tests, raise the mention rate deliberately and expect more brand-centric copy.
- For custom prompts in languages other than English, be more explicit about copy quality. English tends to behave better by default; Spanish and other languages may need direct instructions for punctuation, rhythm, and readability.
- "Gen Z" tone should not mean sloppy text. Ask for native, casual, scroll-stopping copy with correct punctuation, commas where they help, natural line breaks, and no run-on sentences. Avoid all-lowercase walls if they reduce readability.
- For slideshow text, keep each slide short enough to read at a glance. Prefer one clear sentence or two short lines per slide, with punctuation preserved in the rendered text.
- Always restore the previous preferences after a focused generation run unless the user explicitly wants the workspace left tuned for that campaign.

## Workflow: Automatic Campaign Engine

Use when asked for a weekly workflow, content engine, or "do it all" campaign.

1. **Brief**: product, ICP, pains, outcomes, proof, offer, tone, claims to avoid, platforms.
2. **Prompts**: write `fastlane/prompts.md` from the Prompt Library.
3. **Angles**: produce 3-8 angle objects and create/update via `/blitz/angles` if live setup is desired.
4. **Preferences**: choose format weights and remix/own-media/mention rates.
5. **Generate**: call Blitz for requested volume, respecting rate limit and swipe cap.
6. **Poll**: wait for `CREATED`/`FAILED`.
7. **QA**: schedule, regenerate, or discard recommendations.
8. **Schedule**: use `/connections`, convert times to UTC, call schedule endpoint if explicitly requested.
9. **Monitor**: fetch posts and analytics.
10. **Iterate**: adjust angles/preferences based on winners.

## Workflow: Schedule Existing Content

1. `GET /connections`; confirm active target platform connection.
2. `GET /content/:id`; require `CREATED`.
3. Convert local time to UTC ISO-8601.
4. Include `connectionId` if multiple accounts exist on platform.
5. `POST /content/:id/schedule`.
6. Verify with `GET /posts/:postId`.

## Workflow: Cancel And Analyze

Cancel: list `SCHEDULED` posts, match intended posts, confirm, call `POST /posts/cancel`, verify.

Analyze: list posted posts or use known ids, call `POST /analytics/posts`, group by platform/content type/status/metrics, treat recent zeros as possibly pre-sync, recommend next 7-day plan.

## Strategy Index

Account warmup:

- First 3-5 days: complete profile, add photo/bio, spend 10-20 min/day scrolling, watching full videos, liking, commenting, and engaging in niche. Do not post.
- Then post once/day for first week while continuing engagement.
- Second posting week: post twice/day.
- If videos average 500+ views, treat account as warmed.
- For TikTok, use "Post to Inbox" for roughly first 5 Fastlane posts.

Growth defaults:

- Commit to 30 days before judging.
- After warmup, post 1-3 times/day per account/platform.
- For more volume, add warmed accounts instead of overposting one account.
- Cross-post to TikTok, Instagram Reels, and YouTube Shorts when appropriate.
- Start with value-first soft sells; add direct CTAs after audience/format fit appears.
- Test multiple formats for at least a month, then double down on winners.

Posting limits from Fastlane FAQ:

- TikTok: 10 Direct posts/day and 5 Post to Inbox posts/day per workspace; local midnight reset.
- Instagram: 25 posts per rolling 24-hour window per workspace.
- YouTube: 10 videos/day per workspace; reset at midnight Pacific Time.

## Prompt Library

Campaign brief:

```text
Create a Fastlane campaign brief for [PRODUCT]. Include ICP, pains, desired outcome, proof points, objections, tone, claims to avoid, target platforms, and conversion goal. Make it operational enough to create angles and scheduling rules.
```

Angles:

```text
Generate 6 Fastlane content angles for [PRODUCT]. Return JSON with title, description, targetAudience, bestFormats, exampleHooks, and CTAStyle. Make angles distinct: education, pain-point, founder/building, comparison, trend/meme, and demo/use-case.
```

Preferences:

```text
Given this brief and angle list, choose Fastlane Blitz preferences: slideshowWeight, wallOfTextWeight, greenScreenWeight, videoHookWeight, remixPercentage, ownMediaPercentage, mentionBusinessPercentage, genderFilter, and angleWeights. Format weights must sum to 100. angleWeights must cover every active angle and sum to 100.
```

QA:

```text
Review this Fastlane content item for campaign fit. Check hook strength, format fit, product mention style, copyright risk, clarity, platform-native feel, and whether to schedule, regenerate, or delete. Return verdict and caption edits.
```

Non-English custom copy:

```text
Write this in natural [LANGUAGE] for a Gen Z short-form audience, but keep it well written and easy to read. Use casual phrasing, correct punctuation, commas where helpful, and clean line breaks. Do not remove accents or punctuation. Avoid run-on sentences, awkward literal translations from English, and all-lowercase text if it hurts readability.
```

Slideshow copy control:

```text
Create exactly [N] slideshow slides. No cover slide unless requested. Each slide must be one readable sentence or two short lines, with punctuation preserved. Tone: casual Gen Z, but polished and clear. Product mention style: [none / soft final-slide mention / direct CTA].
```

Scheduling:

```text
Build a posting schedule for these Fastlane content items. Inputs: platforms, connections, timezone, daily caps, warmup status, campaign dates. Return UTC ISO timestamps, platform, connectionId if needed, caption, and rationale.
```

Analytics:

```text
Analyze these Fastlane post metrics. Group by platform, contentType, angle, hook pattern, and status. Identify winners, losers, likely causes, preference changes, and next 7-day generation plan.
```

## HTTP Examples

```bash
export FASTLANE_BASE="https://api.usefastlane.ai/api/v1"
```

```bash
curl -sS "$FASTLANE_BASE/blitz/preferences" \
  -H "Authorization: Bearer $FASTLANE_API_KEY" \
  -H "User-Agent: usefastlane-ai-agent/1.0" | jq .
```

```bash
curl -sS -X POST "$FASTLANE_BASE/blitz" \
  -H "Authorization: Bearer $FASTLANE_API_KEY" \
  -H "User-Agent: usefastlane-ai-agent/1.0" | jq .
```

```bash
curl -sS -X POST "$FASTLANE_BASE/content/$CONTENT_ID/schedule" \
  -H "Authorization: Bearer $FASTLANE_API_KEY" \
  -H "Content-Type: application/json" \
  -H "User-Agent: usefastlane-ai-agent/1.0" \
  -d '{"platform":"tiktok","utc_datetime":"2026-05-01T18:00:00Z","caption":"...","connectionId":"..."}' | jq .
```

Plain HTTP and live API discovery are authoritative for cross-agent compatibility.