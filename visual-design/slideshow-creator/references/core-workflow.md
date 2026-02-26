# Core Workflow

### 1. Generate Slideshow Images

Use `scripts/generate-slides.js`:

```bash
node scripts/generate-slides.js --config tiktok-marketing/config.json --output tiktok-marketing/posts/YYYY-MM-DD-HHmm/ --prompts prompts.json
```

The script auto-routes to the correct provider based on `config.imageGen.provider`. Supports OpenAI, Stability AI, Replicate, or local images.

**⚠️ Timeout warning:** Generating 6 images takes 2-6 minutes total with Nano Banana 2 (Gemini), or 3-9 minutes with gpt-image-1.5 (OpenAI). Set your exec timeout to at least **600 seconds (10 minutes)**. If you get `spawnSync ETIMEDOUT`, the exec timeout is too short. The script supports resume — if it fails partway, re-run it and completed slides will be skipped.

**Critical image rules (all providers):**
- ALWAYS portrait aspect ratio (1024x1536 or 9:16 equivalent) — fills TikTok screen
- Include "iPhone photo" and "realistic lighting" in prompts (for AI providers)
- ALL 6 slides share the EXACT same base description (only style/feature changes)
- Lock key elements across all slides (architecture, face shape, camera angle)
- See [references/slide-structure.md](references/slide-structure.md) for the 6-slide formula

### 2. Add Text Overlays

This step uses `node-canvas` to render text directly onto your slide images. This is how Larry produces slides that have hit **1M+ views on TikTok** — the text sizing, positioning, and styling are dialled in from hundreds of posts.

#### Setting Up node-canvas

Before you can add text overlays, your human needs to install `node-canvas`. Prompt them:

> "To add text overlays to the slides, I need a library called node-canvas. It renders text directly onto images with full control over sizing, positioning, and styling — this is what Larry uses for his viral TikTok slides.
>
> Can you run this in your terminal?"
>
> ```bash
> npm install canvas
> ```
>
> "If that fails, it's because node-canvas needs some system libraries. Here's what to install first:"
>
> **macOS:**
> ```bash
> brew install pkg-config cairo pango libpng jpeg giflib librsvg
> npm install canvas
> ```
>
> **Ubuntu/Debian:**
> ```bash
> sudo apt-get install build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev
> npm install canvas
> ```
>
> **Windows:**
> ```bash
> # node-canvas auto-downloads prebuilt binaries on Windows
> npm install canvas
> ```
>
> "Once installed, I can handle everything else — generating the overlays, sizing the text, positioning it perfectly. You won't need to touch this again."

**Don't skip this step.** Without node-canvas, the text overlays won't work. If installation fails, help them troubleshoot — it's usually a missing system library. Once it's installed once, it stays.

#### How Larry's Text Overlay Process Works

1. **Load the raw slide image** into a node-canvas
2. **Configure text settings** based on the text length for that specific slide
3. **Draw the text** with white fill and thick black outline
4. **Review the output** — check sizing, positioning, readability
5. **Adjust and re-render** if anything looks off
6. **Save the final image** once it looks right

**Exact code Larry uses:**

```javascript
const { createCanvas, loadImage } = require('canvas');
const fs = require('fs');

async function addOverlay(imagePath, text, outputPath) {
  const img = await loadImage(imagePath);
  const canvas = createCanvas(img.width, img.height);
  const ctx = canvas.getContext('2d');
  ctx.drawImage(img, 0, 0);

  // ─── Adjust font size based on text length ───
  const wordCount = text.split(/\s+/).length;
  let fontSizePercent;
  if (wordCount <= 5)       fontSizePercent = 0.075;  // Short: 75px on 1024w
  else if (wordCount <= 12) fontSizePercent = 0.065;  // Medium: 66px
  else                      fontSizePercent = 0.050;  // Long: 51px

  const fontSize = Math.round(img.width * fontSizePercent);
  const outlineWidth = Math.round(fontSize * 0.15);
  const maxWidth = img.width * 0.75;
  const lineHeight = fontSize * 1.3;

  ctx.font = `bold ${fontSize}px Arial`;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'top';

  // ─── Word wrap ───
  const lines = [];
  const manualLines = text.split('\n');
  for (const ml of manualLines) {
    const words = ml.trim().split(/\s+/);
    let current = '';
    for (const word of words) {
      const test = current ? `${current} ${word}` : word;
      if (ctx.measureText(test).width <= maxWidth) {
        current = test;
      } else {
        if (current) lines.push(current);
        current = word;
      }
    }
    if (current) lines.push(current);
  }

  // ─── Position: centered at ~28% from top ───
  const totalHeight = lines.length * lineHeight;
  const startY = (img.height * 0.28) - (totalHeight / 2);
  const x = img.width / 2;

  // ─── Draw each line ───
  for (let i = 0; i < lines.length; i++) {
    const y = startY + (i * lineHeight);

    // Black outline
    ctx.strokeStyle = '#000000';
    ctx.lineWidth = outlineWidth;
    ctx.lineJoin = 'round';
    ctx.miterLimit = 2;
    ctx.strokeText(lines[i], x, y);

    // White fill
    ctx.fillStyle = '#FFFFFF';
    ctx.fillText(lines[i], x, y);
  }

  fs.writeFileSync(outputPath, canvas.toBuffer('image/png'));
}
```

**Key details that make Larry's slides look professional:**

- **Dynamic font sizing** — short text gets bigger (75px), long text gets smaller (51px). Every slide is optimized.
- **Word wrap** — respects manual `\n` breaks but also auto-wraps lines that exceed 75% width. No squashing.
- **Centered at 28% from top** — text block is vertically centered around this point, not pinned to it. Stays in the safe zone regardless of line count.
- **Thick outline** — 15% of font size. Makes text readable on ANY background.
- **Manual line breaks preferred** — use `\n` in your text for control. Keep lines to 4-6 words.

**Text content rules:**
- **REACTIONS not labels** — "Wait... this is actually nice??" not "Modern minimalist"
- **4-6 words per line** — short lines are scannable at a glance
- **3-4 lines per slide is ideal**
- **No emoji** — canvas can't render them reliably
- **Safe zones:** No text in bottom 20% (TikTok controls) or top 10% (status bar)

**The difference between OK slides and viral slides is in these details.** Larry's slides consistently hit 50K-150K+ views because the text is sized right, positioned right, and readable at a glance while scrolling.

**⚠️ LINE BREAKS ARE CRITICAL — Read This:**

The `texts.json` file must contain text with `\n` line breaks to control where lines wrap. If you pass a single long string without line breaks, the script will auto-wrap, but **manual breaks look much better** because you control the rhythm.

**Good (manual breaks, 4-6 words per line):**
```json
[
  "I showed my landlord\nwhat AI thinks our\nkitchen should look like",
  "She said you can't\nchange anything\nchallenge accepted",
  "So I downloaded\nthis app and\ntook one photo",
  "Wait... is this\nactually the same\nkitchen??",
  "Okay I'm literally\nobsessed with\nthis one",
  "Snugly showed me\nwhat's possible\nlink in bio"
]
```

**Bad (no breaks — will auto-wrap but looks worse):**
```json
[
  "I showed my landlord what AI thinks our kitchen should look like",
  ...
]
```

**Rules for writing overlay text:**
1. **4-6 words per line MAX** — short lines are scannable at a glance
2. **Use `\n` to break lines** — gives you control over the rhythm
3. **3-4 lines per slide is ideal** — more lines are fine, they won't overflow
4. **Read it out loud** — each line should feel like a natural pause
5. **No emoji** — canvas can't render them, they'll show as blank
6. **REACTIONS not labels** — "Wait... this is nice??" not "Modern minimalist"

The script auto-wraps any line that exceeds 75% width as a safety net, but always prefer manual `\n` breaks for the best visual result.

### 3. Post to TikTok

Use `scripts/post-to-tiktok.js`:

```bash
node scripts/post-to-tiktok.js --config tiktok-marketing/config.json --dir tiktok-marketing/posts/YYYY-MM-DD-HHmm/ --caption "caption" --title "title"
```

### Why We Post as Drafts (SELF_ONLY) — Best Practice

Posts go to your TikTok inbox as drafts, NOT published directly. This is intentional and critical:

1. **Music is everything on TikTok.** Trending sounds massively boost reach. The algorithm favours posts using popular audio. An API can't pick the right trending sound — you need to browse TikTok's sound library and pick what's hot RIGHT NOW in your niche.
2. **You add the music manually**, then publish from your TikTok inbox. Takes 30 seconds per post.
3. **Posts without music get buried.** Silent slideshows look like ads and get skipped. A trending sound makes your content feel native.
4. **Creative control.** You can preview the final slideshow with music before it goes live. If something looks off, fix it before publishing.

This is the workflow that helped us hit 1M+ TikTok views and $670/month MRR. Don't skip the music step.

**Tell the user during onboarding:** "Posts will land in your TikTok inbox as drafts. Before publishing each one, add a trending sound from TikTok's library — this is the single biggest factor in reach. It takes 30 seconds and makes a massive difference."

Cross-posts to any connected platforms (Instagram, YouTube, etc.) automatically via Postiz.

**Caption rules:** Long storytelling captions (3x more views). Structure: Hook → Problem → Discovery → What it does → Result → max 5 hashtags. Conversational tone.

### 4. Connect Post Analytics (After User Publishes)

After the user publishes from their TikTok inbox, the post needs to be connected to its TikTok video ID before per-post analytics work.

**⚠️ CRITICAL: Wait at least 1-2 hours after publishing before connecting.** TikTok's API has an indexing delay — if you try to connect immediately, the new video won't be in the list yet, and you might connect to the wrong video. This mistake is hard to undo (Postiz doesn't easily allow overwriting a release ID once set).

Use `scripts/check-analytics.js` to automate the connection:

```bash
node scripts/check-analytics.js --config tiktok-marketing/config.json --days 3 --connect
```

The script:
1. Fetches all Postiz posts from the last N days
2. Skips posts published less than 2 hours ago (indexing delay)
3. For unconnected posts, calls `GET /posts/{id}/missing` to get all TikTok videos on the account
4. Matches posts to videos chronologically (TikTok IDs are sequential: higher number = newer video)
5. Excludes already-connected video IDs to avoid duplicates
6. Connects each post via `PUT /posts/{id}/release-id`
7. Pulls per-post analytics (views, likes, comments, shares)

**How the matching works:**
- TikTok video IDs are sequential integers (e.g. `7605531854921354518`, `7605630185727118614`)
- Higher number = more recently published
- Sort both Postiz posts (by publish date) and TikTok IDs (numerically) in the same order
- Match them up: oldest post → lowest unconnected ID, newest post → highest unconnected ID
- This is reliable because both Postiz and TikTok maintain chronological order

**Manual connection (if needed):**
1. `GET /posts/{id}/missing` — returns all TikTok videos with thumbnail URLs
2. Identify the correct video by thumbnail or timing
3. `PUT /posts/{id}/release-id` with `{"releaseId": "tiktok-video-id"}`
4. `GET /analytics/post/{id}` now returns views/likes/comments/shares

**The daily cron handles all of this automatically.** It runs in the morning, checks posts from the last 3 days (all well past the 2-hour indexing window), connects any unconnected posts, and generates the report.

### ⚠️ Known Issue: Release ID Cannot Be Overwritten

Once a Postiz post is connected to a TikTok video ID via `PUT /posts/{id}/release-id`, **it cannot be changed**. If you connect the wrong video, the analytics will permanently show the wrong video's stats for that post. The PUT endpoint appears to accept the update but silently keeps the original ID.

**This is why the 2-hour wait is non-negotiable.** If you connect too early (before TikTok has indexed the new video), the `missing` endpoint will show older videos and you'll connect the wrong one. There is no undo.

**Best practice:**
1. Post as draft → user publishes with music
2. Wait at least 2 hours (the daily morning cron handles this naturally)
3. The newest unconnected TikTok video ID (highest number) corresponds to the most recently published video
4. Always verify: the number of unconnected Postiz posts should match the number of new TikTok video IDs since the last connection run
5. If something looks wrong, ask the user to confirm by checking the video thumbnail

See [references/analytics-loop.md](references/analytics-loop.md) for full Postiz analytics API docs.

---
