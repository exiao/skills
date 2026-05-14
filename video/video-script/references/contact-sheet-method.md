# Contact Sheet Method for AI Video Consistency

Source: @OriSilver, "The Master Prompt Behind Viral AI Storyboard Videos" (May 2026)

## What It Is

A contact sheet is a single 16:9 image showing all shots for a video in a grid (typically 2 rows × 5 columns = 10 frames). Each frame locks character, product, lighting, style, and camera angle. When fed to a video model (Seedance 2.0, Kling, etc.) alongside per-shot prompts, the model treats the sheet as source of truth. Every generated frame adheres to its corresponding grid cell.

This is why viral AI-generated videos look consistent across cuts. The sheet does the work, not the prompts alone.

## Why It Matters

Without a contact sheet, each AI-generated shot is independent. The model reinvents the character, lighting, and style per prompt. Results drift. Skin tones shift, hair changes, products look different frame to frame.

With a contact sheet, the model has a single visual reference that constrains all shots simultaneously. Consistency rate goes from ~40% (prompt-only) to 90%+ (sheet-guided).

## What a Contact Sheet Contains

Single image, 16:9 landscape, cream/neutral background:

- **Title bar** — Video title in all caps at top
- **Grid** — 2 rows × 5 columns, 10 numbered frames
- **Per frame:** small label, duration tag (e.g. "1.5s"), 1-2 icons, square illustration of the action, short caption below
- **Footer** — 4 columns: video flow notes, camera tips, light/style direction, topic-specific notes

The sheet defines the entire video before any video generation happens.

## Workflow

### Step 1: Script (video-script skill)
Write the scene-by-scene script as usual using the video-script skill. This produces the narrative structure, timing, audio lines, and source directives.

### Step 2: Contact Sheet Prompt
Convert the script into a contact sheet generation prompt. The prompt must specify:

- Grid layout (2×5 or as needed)
- Character description (locked across all frames: skin tone, hair, clothing, build)
- Product appearance (exact visual description, consistent across frames)
- Style block (see "Style Blocks" below)
- Per-frame: action, camera angle, lighting, duration label
- Background/setting consistency rules

Generate the sheet using an image model (GPT Image, Midjourney, Gemini). The output is one image.

### Step 3: Per-Shot Video Prompts
Take the contact sheet image + write individual video prompts for each frame. Each prompt references the specific grid cell ("Frame 3 of the contact sheet") and adds motion/action direction.

Feed each prompt + the full contact sheet to Seedance 2.0 or equivalent. The model uses the grid cell as visual reference while the prompt adds temporal information (motion, transitions, speed).

### Step 4: Assembly
Stitch the generated clips using the video-editor or Remotion pipeline. The contact sheet guarantees visual consistency, so cuts between shots feel like one continuous video.

## Style Blocks

Pre-built aesthetic profiles for the sheet generation prompt. Each block is a set of rendering instructions for the image model.

| Style | Look | Best For |
|-------|------|----------|
| **Premium 3D Animation** | Polished animated film, soft lighting, clean surfaces | Product showcases, brand videos, explainers |
| **Claymation** | Handcrafted stop-motion, textured surfaces, warm palette | Approachable/playful products, food, lifestyle |
| **Realistic UGC** | Phone-shot authenticity, natural lighting, slight grain | Social proof, testimonials, "real person" feel |
| **POV** | First-person camera, immersive framing, hand-in-frame | Unboxing, tutorials, "day in my life" |

To add custom styles (crochet, pixel art, watercolor, anime, etc.): write a new style block following the same structure (rendering instructions, lighting rules, texture notes, color palette constraints) and include it in the contact sheet prompt.

## Series Continuity

The contact sheet's biggest compound value: multi-video series with locked characters.

1. Generate Contact Sheet 1 (e.g., "morning routine" scene)
2. Generate Contact Sheet 2 in the same session referencing the same character description (e.g., "gym session")
3. Both sheets share identical character rendering
4. Result: two 15-second clips that feel like one continuous 30-second piece

Repeat for a full series. The character description is the continuity anchor. Keep it in the same chat/project session so the model maintains reference.

## Integration with video-script Skill

The contact sheet adds a step between script and video generation. Updated pipeline:

```
Topic → video-script (scenes + metadata) → contact sheet prompt → image model → contact sheet image → per-shot Seedance/Kling prompts (with sheet as reference) → video clips → assembly
```

### New Source Type

In the video-script scene format, use `contact-sheet` as a source directive when the video will be AI-generated with consistency requirements:

```markdown
## SCENE 3 — POINT 1 [0:06-0:10]
**Visual:** Character picks up product from desk, examines it
**Source:** contact-sheet frame-3 + seedance "character picks up [product] from desk, turns it in hand, warm side lighting"
**Audio:** "This is the part nobody talks about."
```

This tells the pipeline: generate this shot using Frame 3 of the contact sheet as visual reference, with the Seedance prompt for motion.

### When to Use Contact Sheets vs Direct Prompting

| Scenario | Method |
|----------|--------|
| Single character appearing in 3+ shots | Contact sheet (consistency critical) |
| Product visible in multiple shots | Contact sheet (product appearance must match) |
| B-roll / atmosphere shots with no recurring elements | Direct prompting (no consistency needed) |
| Screen recordings / real footage | N/A (contact sheet is for AI-generated video only) |
| Mixed real + AI footage | Contact sheet for AI shots only |

### When NOT to Use

- Talking-head videos (real person on camera)
- Screen recording demos
- Stock footage compilations
- Videos under 3 shots (not enough frames to justify the sheet)

## Prompt System Architecture

The contact sheet generation works best as a multi-file system (not one mega-prompt):

1. **Instructions** — Controls the planning conversation: question order, how to handle ambiguity, escape hatch for "just build it"
2. **Anatomy** — Defines the sheet structure: title bar, legend, grid format, footer columns, icon/label placement
3. **Styles** — Pre-built style blocks (see above), each tested to render correctly
4. **Quick start** — Example of a successful end-to-end conversation (few-shot priming)

Split into files so each concern is independently editable. Changing a style doesn't risk breaking the grid structure. Adding a new anatomy element doesn't touch the conversation flow.

This maps naturally to a Claude Project, ChatGPT Custom GPT, or a skill's `references/` directory.

## Bloom Adaptations

Bloom AI-generated video series using contact sheets:

- **Character:** Young professional investor (locked appearance across all videos in series)
- **Product:** Phone showing Bloom app (consistent UI screenshot in every product shot)
- **Repeatable format:** "I ran [ticker] through Bloom's AI" — same character, same phone, same desk setup, only the ticker and results change per video
- **Style:** Realistic UGC (matches organic TikTok/Reels feel, avoids "ad smell")
- **Series continuity:** Same character across "morning research routine," "market open reaction," "end of day review" — feels like following one investor's day
