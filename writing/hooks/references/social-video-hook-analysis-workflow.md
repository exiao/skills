# Social Video Hook Analysis Workflow

Use when the user shares a Reel, TikTok, Short, or other short-form video and asks why it worked or how to improve hook guidance from it.

## Workflow

1. Fetch the source with the lightest reliable tool first. Prefer `yt-dlp --dump-json <url>` for Instagram/Reels metadata, then download the mp4 only if analysis needs visuals or audio.
2. Capture metadata: creator, caption, duration, likes/comments/views if available, post date, and source URL.
3. Extract the first-frame and first-3-second evidence. Make a contact sheet or sample frames at 1 fps. The first frame matters more than the spoken script for Reels because many viewers start muted.
4. Transcribe audio with local Whisper or another available tool. Treat transcript errors as clues, not truth. Cross-check against on-screen text and captions.
5. Analyze three hook layers separately:
   - Stated hook: what the overlay says
   - Visual hook: what the viewer sees before listening
   - Audio hook: what the creator says in the first 3 seconds
6. Identify the retention architecture: hook, context, framework reveal, demonstration, payoff, CTA.
7. Extract reusable principles, not a summary of the clip. Convert observations into formulas, rules, examples, and failure modes.
8. Patch the owning reference file. Use the platform reference for platform mechanics, remix strategy for copied-shell patterns, and content-strategy for broader content mechanics like shareability.

## What to preserve

For each learned pattern, save:
- Source and date
- The exact hook shell
- Why it worked
- When to use it
- 2-3 examples adapted to the user's domain

## Common pitfalls

- Do not summarize the video and stop. The skill library needs reusable operating principles.
- Do not over-index on view count when the format itself is weak or irrelevant.
- Do not treat production quality as the cause unless the hook evidence supports it. Often the real mechanism is audience fit, social stakes, or a clear system promise.
- Do not put every finding into hooks. If the learning is about channel strategy, share mechanics, repeatable formats, or content pillars, patch content-strategy instead.
