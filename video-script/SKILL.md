---
name: video-script
description: Generate structured scene-by-scene video scripts with production metadata (visuals, audio, sources, transitions, captions) ready to feed into the video-production pipeline (Sora, Kling, ElevenLabs, InfiniteTalk, Remotion, stock-footage, auto-captions, video-editor). Use when asked to "write a video script", "script for TikTok", "video outline", "plan a video", "storyboard", "scene breakdown", "video concept", "content brief for video", "shooting script", or whenever the video-production pipeline needs a structured script before production begins. Also trigger for "Reels script", "Shorts script", "YouTube script", "video idea with scenes", or any request that implies breaking a video concept into timed scenes with production directions.
---

# Video Script Generator

Takes a topic, hook, or concept and produces a scene-by-scene video script with production metadata. Every field in the output is designed to be machine-readable by downstream pipeline skills (Sora for AI video, stock-footage for B-roll, ElevenLabs/InfiniteTalk for voiceover, auto-captions for subtitle highlights, Remotion/video-editor for assembly).

## Output Format

Save each script as a markdown file. The header block captures global metadata; each scene block captures per-scene production instructions.

```markdown
# [Video Title]
**Platform:** TikTok | Reels | Shorts | YouTube
**Aspect:** 9:16 | 16:9 | 1:1
**Duration:** ~30s | ~60s | ~90s
**Style:** talking-head | slideshow | explainer | demo | montage
**Character:** [slug from the character-creation skill, or "none"]
**Music mood:** upbeat | dramatic | chill | corporate | none

---

## SCENE 1 — HOOK [0:00-0:03]
**Visual:** Close-up of phone showing portfolio down 3%
**Source:** stock-footage "portfolio red screen" | sora "close up of phone..." | screen-recording
**Audio:** "The market just crashed. Here's what smart investors do."
**Voice:** elevenlabs | character-voice | none
**Caption highlight:** "crashed", "smart investors"
**Transition:** cut | crossfade 0.5s | zoom

## SCENE 2 — POINT 1 [0:03-0:08]
**Visual:** B-roll of trading floor
**Source:** stock-footage "trading floor busy"
**Audio:** "Move one: stop checking every hour."
**Voice:** elevenlabs
**Caption highlight:** "stop checking"
**Transition:** crossfade 0.5s

...

## SCENE N — CTA [0:25-0:30]
**Visual:** App screenshot with Bloom logo
**Source:** screen-recording | image overlay
**Audio:** "Download Bloom. Link in bio."
**Voice:** elevenlabs
**Caption highlight:** "Download Bloom"
**Transition:** fade-out 1s
```

### Field reference

| Field | Purpose | Values |
|-------|---------|--------|
| **Platform** | Target distribution channel | TikTok, Reels, Shorts, YouTube |
| **Aspect** | Frame ratio | 9:16 (vertical), 16:9 (landscape), 1:1 (square) |
| **Duration** | Total target length | ~15s, ~30s, ~60s, ~90s, ~2min, ~5min |
| **Style** | Production approach | talking-head, slideshow, explainer, demo, montage |
| **Character** | AI character slug | Slug from the character-creation skill, or "none" |
| **Music mood** | Background music direction | upbeat, dramatic, chill, corporate, none |
| **Visual** | What the viewer sees | Plain-language description of the shot |
| **Source** | How to produce the visual | `stock-footage "query"`, `sora "prompt"`, `kling "prompt"`, `screen-recording`, `image overlay`, `talking-head` |
| **Audio** | Voiceover line or sound description | Quoted dialogue, or sound direction like "[upbeat music kicks in]" |
| **Voice** | Voice synthesis method | elevenlabs, character-voice, none |
| **Caption highlight** | Words to emphasize in auto-captions | Comma-separated quoted words/phrases for karaoke-style highlighting |
| **Transition** | Scene-to-scene transition | cut, crossfade Xs, zoom, fade-out Xs, wipe |

## How to Write a Good Script

### Start with the hook

The hook is the single most important element. If the first 1-3 seconds don't stop the scroll, nothing else matters.

**Hook patterns that work:**

- **Question:** "Did you know most investors lose money in their first year?" (creates curiosity gap)
- **Shock stat:** "90% of day traders lose money. Here's what the other 10% do differently." (specific number = credibility)
- **Contrarian:** "Stop dollar-cost averaging. Here's why." (pattern interrupt, challenges common wisdom)
- **Story:** "I lost $10,000 in one day. Then I learned this one thing." (personal stakes create investment)
- **Visual hook:** Open on the most visually striking moment of the video, then rewind. Show the result before the process.

Pick the hook pattern that matches the emotional core of the topic. Stats work for educational content. Stories work for personal content. Contrarian works for opinion content. Visual hooks work for demos and montages.

### Structure by style

Each style has a natural rhythm. Don't fight it.

**Talking head (30-60s)**
Hook → Point 1 → Point 2 → Point 3 → CTA
Keep each point to one sentence. The value is in the person's delivery and authority, not in packing information. 3 points max for 60s. 1-2 for 30s.

**Slideshow (15-30s)**
Hook slide → 3-5 content slides → CTA slide
Each slide gets 3-5 seconds. Text on screen carries the message (assume audio-off viewing). One idea per slide, large text, high contrast. Think "Instagram carousel but animated."

**Explainer (60-90s)**
Hook → Problem → Solution → Proof → CTA
The problem section needs to make the viewer feel the pain. The solution should be surprising or non-obvious. Proof is a specific example, screenshot, or data point. This structure works for "how to" and "why X happens" content.

**Demo (30-60s)**
Hook → Show feature → Show result → CTA
Screen recordings or product walkthroughs. The hook should show the end result first ("Watch me find the best stock in 10 seconds"), then walk through the steps. Speed up boring parts. Slow down the payoff moment.

**Montage (15-30s)**
Hook → rapid clips → CTA
2-3 second clips cut to music. Works for mood pieces, product showcases, before/after compilations. Every clip should be visually interesting on its own. No filler shots.

### Timing rules

- **Scene 1 (Hook):** 1-3 seconds. Ruthlessly short. If you can say it in 1 second, don't use 3.
- **Middle scenes:** 3-8 seconds each. One idea per scene. If a scene needs more than 8 seconds, split it.
- **CTA scene:** 3-5 seconds. Clear, single action. "Download Bloom. Link in bio." not "Check out our app Bloom, it's available on iOS and Android, you can find it..."
- **Total scenes:** 3-5 for short-form (15-30s), 5-8 for medium (30-60s), 8-12 for long (60-90s).
- Timecodes in scene headers must be continuous and add up to the target duration.

### Writing the audio lines

Write conversational, not scripted. Read every line out loud (mentally). If it sounds like a press release, rewrite it.

- Short sentences. 5-12 words per line is the sweet spot.
- One idea per line. Never compound with "and" or "but" across ideas.
- Use "you" not "we" or "one." Direct address keeps attention.
- Numbers are concrete. "3 stocks" beats "a few stocks." "$500" beats "a small amount."
- End lines on strong words. "Here's what actually works" not "Here's what works, actually."

### Source selection guidance

Choose the source type based on what the visual demands:

- **stock-footage:** Real-world B-roll. Use descriptive search queries: "woman looking at phone worried," "stock market ticker green." Best for establishing shots and emotional context.
- **sora / kling:** AI-generated video. Use when you need something specific that stock footage won't have. Write the prompt as a detailed visual description: "slow motion close-up of coins falling onto a desk, warm lighting, shallow depth of field."
- **screen-recording:** Product demos, app walkthroughs. Use for any scene showing the actual product.
- **image overlay:** Static images, logos, screenshots, text cards. Use for data slides, app store screenshots, brand moments.
- **talking-head:** Character or person on camera. Requires a character slug or live footage.

### Caption highlights

Pick 1-3 words per scene that carry the emotional or informational weight. These become the karaoke-highlight words in auto-captions.

Good highlights: the surprising word, the number, the action verb, the brand name.
Bad highlights: articles, prepositions, filler words.

Example: "90% of investors lose money in their first year"
Highlight: "90%", "lose money" (not "of", "in", "their")

## Platform-Specific Guidance

### TikTok
- First 1 second determines whether people stay. The visual hook matters more than the audio hook because most viewers haven't unmuted yet.
- Text on screen for every scene. Assume audio-off viewing.
- Fast cuts (2-3s per scene). Anything longer feels slow.
- Vertical 9:16 only. No letterboxing.
- 15-60s is the sweet spot. Under 30s gets more completions (which helps the algorithm).

### Instagram Reels
- Hook within 3 seconds. Slightly more forgiving than TikTok.
- Trending audio helps discovery, but original audio works if the content is strong.
- 30-60s is the sweet spot. Can go to 90s for educational content.
- 9:16 vertical. Square 1:1 also works but gets less reach.
- Polished visual quality expected. Instagram's audience notices production value.

### YouTube Shorts
- Similar to TikTok in format and pacing.
- Add "#Shorts" in the description (not title).
- 9:16 vertical, under 60s.
- YouTube's audience skews slightly older and more intentional. Educational content performs well.

### YouTube (long-form)
- Thumbnail and title do the work of the hook. The video itself can take 5-10 seconds to set up.
- 16:9 landscape. Higher production value expected.
- Can go 2-20 minutes. Structure matters more than raw length.
- Chapters/timestamps help retention. Mark scene boundaries.
- End screens and cards for CTA instead of "link in bio."

## Product Context (Example: Bloom)

> **This section is an example template.** Replace with your own product details. If no product is specified, write scripts without product-specific CTAs.

When writing scripts for a specific product, define these fields. Here's an example using Bloom:

- **App:** Bloom is an investing research and trading app for iOS and Android.
- **Audience:** Retail investors, beginners to intermediate. People who want to learn, not day-trade.
- **Tone:** Builder-educator. Show the work, explain the thinking, share real numbers. Not hype, not "finance bro," not get-rich-quick.
- **Disclaimer:** Any video touching on stock picks, returns, or investment strategy needs "Not financial advice" either spoken or on screen. Place it in the first or last scene, not buried in the middle.
- **CTA patterns:** "Download [App]. Link in bio." / "Try [App] free. Link in bio." / "Search '[App]' on the App Store."
- **Visual assets:** App screenshots, screen recordings, logo. Use `screen-recording` source type for product demos.

Adapt these fields to whatever product or brand the script is for. If the user doesn't specify a product, omit the CTA scene or use a generic engagement CTA ("Follow for more").

## Process

1. **Clarify the brief.** If the user gives a topic but no platform/style/duration, ask. If they give everything, proceed.
2. **Pick the hook pattern** that fits the topic's emotional core.
3. **Choose the structure template** based on style.
4. **Write all scenes** with complete metadata for every field.
5. **Check timing.** Timecodes must be continuous. Total must match target duration (within 5 seconds).
6. **Check sources.** Every scene needs a concrete source directive. No "TBD" or vague descriptions.
7. **Save the script** as a markdown file. Suggest a filename based on the topic (e.g., `stop-dca-tiktok-30s.md`).

If the user wants multiple variants (e.g., same topic in 30s and 60s, or TikTok and YouTube versions), produce separate scripts for each. Don't try to make one script serve multiple formats.
