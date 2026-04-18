---
name: kling
description: Generate AI videos with Kling 3.0 using cinematic directing techniques. Supports direct API execution (text-to-video, image-to-video, multi-shot, elements), Higgsfield browser automation, and prompt engineering.
metadata:
  version: 2.0.0
  primaryEnv: KLING_TOKEN
---

# Kling 3.0 Video Generation

Generate videos with Kling 3.0. Two parts: (1) write the prompt like a film director, (2) execute via API or Higgsfield browser.

---

## Part 1: Prompt Engineering

Prompt like a film director, not a keyword dumper. Kling generates motion, so every prompt must describe how the shot moves, not just what it looks like.

### Prompt Structure

Write prompts as one flowing sentence covering these elements:

| Element | What to describe | Examples |
|---------|-----------------|----------|
| **Camera** | Shot type + movement | Dolly push-in, handheld drift, whip-pan, crash zoom, rack focus, static tripod |
| **Subject** | Who/what + action | Woman in red dress turning slowly, chef plating a dish with precise hands |
| **Environment** | Where it happens | Narrow Tokyo alley with vending machines, rain-soaked rooftop at dusk |
| **Lighting** | Real light sources | Flickering neon signs, golden hour through dusty windows, LED panels |
| **Texture** | Physical details | Condensation on glass, rain beading on leather, visible breath, film grain |
| **Emotion** | Mood/tone | Shallow focus with glowing bokeh (intimacy), desaturated teal (tension) |

You don't need all six every time, but the more you include, the more control you get.

### Four Rules

1. **Cinematic motion verbs.** Use: dolly push, whip-pan, shoulder-cam drift, crash zoom, snap focus, rack focus. Never use: "moves", "goes", "walks around".

2. **Texture = credibility.** Include grain, lens flares, reflections, fabric sheen, condensation, smoke, sweat. Tactile details make output feel physically real.

3. **Describe temporal flow.** Tell Kling how the shot evolves: beginning, middle, end. Continuity produces coherent motion instead of a frozen moment.

4. **Name real light sources.** Not "dramatic lighting." Say: neon signs, candlelight, golden hour, LED panels, flickering fluorescent tubes. Real sources produce real results.

### Lead with the Camera

Always open the prompt with how the shot is captured. Camera language defines the entire visual feel.

**Camera movements:**
- Handheld drift, shoulder-cam sway
- Dolly push-in, slow tracking shot
- Whip-pan, crash zoom, snap focus
- Static tripod, locked-off wide
- Rack focus between foreground and background

**Lens details (use when it matters):**
- "Shot on 35mm film" — warm grain, organic feel
- "Macro 85mm lens" — tight detail, shallow depth
- "Handheld camcorder" — raw, VHS-style energy
- "Wide-angle steadicam" — smooth, immersive movement

### Color and Film Tone

Color language should be literal but emotive. Not "blue" but "cool blue haze." Not "warm" but "amber nightclub strobe."

**Effective color direction:**
- "Cool blue haze filling the corridor"
- "Amber nightclub strobe cutting through smoke"
- "Magenta neon reflecting off wet asphalt"
- "Golden hour light catching dust particles"
- "Desaturated teal grade, crushed blacks"

Film stocks and grades work directly: "VHS camcorder aesthetic with heavy grain and chromatic aberration", "shot on 35mm film".

### Example Prompt (Annotated)

> Static tripod camera in narrow neon-lit ramen shop, condensation fogs the window, couple sits side by side under flickering magenta sign, steam rising from bowls as they eat noodles in slow synchronized rhythm, broth splattering gently, their faces softly illuminated by red neon glow, shot on 35mm film with shallow focus and glowing bokeh behind them.

- **Camera:** Static tripod, shot on 35mm film
- **Subject:** Couple eating noodles in synchronized rhythm
- **Environment:** Narrow neon-lit ramen shop
- **Lighting:** Flickering magenta sign, red neon glow
- **Texture:** Condensation, steam rising, broth splattering
- **Emotion:** Shallow focus and glowing bokeh (intimate, cinematic warmth)

### Weak vs Strong

| Element | Weak | Strong |
|---------|------|--------|
| Camera | Camera follows person | Handheld shoulder-cam drifts behind subject with subtle sway |
| Subject | A woman walking | Woman in red dress, heels clicking on wet cobblestone |
| Environment | In a city | Narrow Tokyo alley, steam rising from grates, vending machines glowing |
| Lighting | Dramatic lighting | Flickering neon signs casting magenta and cyan across wet pavement |
| Texture | It looks realistic | Rain beading on leather jacket, condensation on glass, visible breath |
| Motion | She walks away | She turns slowly, hair catching the light, then disappears around the corner |

### Realistic vs Experimental

**Realistic:** "Handheld camcorder footage zooming in erratically on woman's face as she devours a messy slice of pizza, melting mozzarella stretching and dripping, bright red tomato sauce smearing across her lips, VHS aesthetic with heavy grain, dim party lighting with colored gels."

**Experimental:** "Handheld shoulder-cam drifting through endless mirror maze reflecting multiple versions of two women eating food infinitely, strobing pink and cyan light washing over reflections, dripping sauces morph into shimmering liquid chrome, camera performs continuous circular orbit as reflections distort in rhythm with pulsing ambient bass."

Both work because they give Kling specific visual instructions. Realistic leans on texture and physicality. Experimental leans on surrealism and abstract motion.

---

## Part 2: Execution

Two backends: **Kling API** (direct, billed per task) and **Higgsfield browser** (uses Creator subscription credits). Choose based on context.

| Backend | When to use |
|---------|-------------|
| **Kling API** | Multi-shot, elements/subjects, reference video, image generation, 4K, programmatic pipelines |
| **Higgsfield** | Simple text-to-video or image-to-video when conserving API credits, browser already open |

### Backend A: Kling API (via klingai CLI)

Uses the `klingai` skill scripts. Requires `KLING_TOKEN` (Bearer) or `KLING_API_KEY` (accessKey|secretKey).

```bash
# Base path for all commands
node skills/klingai/scripts/kling.mjs <video|image|element> [options]
```

#### Intent Routing

| User intent | Subcommand |
|-------------|------------|
| Video (text-to-video, image-to-video, multi-shot, reference video) | `video` |
| Image (text-to-image, image-to-image, 4K) | `image` |
| Subject/element (create, manage, list characters) | `element` |

#### Video Generation

```bash
# Text-to-video
node skills/klingai/scripts/kling.mjs video --prompt "YOUR CINEMATIC PROMPT" --duration 5 --mode pro --aspect_ratio 9:16 --output_dir ./output

# Image-to-video (animate a start frame)
node skills/klingai/scripts/kling.mjs video --image ./frame.png --prompt "Wind blowing hair, slow dolly push-in" --output_dir ./output

# First + last frame
node skills/klingai/scripts/kling.mjs video --image ./start.png --image_tail ./end.png --prompt "Smooth transition" --output_dir ./output

# Reference video (copy camera motion/style from existing video)
node skills/klingai/scripts/kling.mjs video --video ./reference.mp4 --video_refer_type feature --prompt "Same camera movement, new subject" --aspect_ratio 9:16

# Multi-shot (max 6 scenes)
node skills/klingai/scripts/kling.mjs video --multi_shot --shot_type customize --multi_prompt '[{"index":1,"prompt":"Sunrise over mountains, slow pan right","duration":"5"},{"index":2,"prompt":"Cut to close-up of coffee cup, steam rising","duration":"5"}]' --duration 10

# With sound
node skills/klingai/scripts/kling.mjs video --prompt "Street musician playing guitar" --sound on

# With reusable character/element
node skills/klingai/scripts/kling.mjs video --prompt "<<<element_1>>> walks through rain" --element_ids 123456
```

#### Key Video Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--prompt` | Cinematic description (use Part 1 rules) | required |
| `--image` | Start frame image (comma-separated for multiple, triggers Omni) | -- |
| `--image_tail` | End frame image | -- |
| `--video` | Reference video for motion/style transfer | -- |
| `--video_refer_type` | `feature` (copy motion) / `base` (edit content) | feature |
| `--duration` | 3-15 seconds | 5 |
| `--mode` | `pro` (1080p) / `std` (720p) | pro |
| `--aspect_ratio` | 16:9 / 9:16 / 1:1 | 16:9 |
| `--sound` | on / off (incompatible with --video) | off |
| `--model` | kling-v3 / kling-v3-omni / kling-v2-6 | auto |
| `--multi_shot` | Enable multi-shot mode | false |
| `--element_ids` | Reusable subject IDs, comma-separated (max 3) | -- |

#### Image Generation

```bash
# Text-to-image
node skills/klingai/scripts/kling.mjs image --prompt "Cyberpunk street at night, neon reflections on wet asphalt" --resolution 2k

# 4K image (uses Omni)
node skills/klingai/scripts/kling.mjs image --prompt "Mountain landscape" --resolution 4k

# With character element
node skills/klingai/scripts/kling.mjs image --prompt "<<<element_1>>> on the beach" --element_ids 123456

# Image series
node skills/klingai/scripts/kling.mjs image --prompt "Cat in different poses" --result_type series --series_amount 4
```

#### Element/Subject Management

Create reusable characters that stay consistent across generations:

```bash
# Create from image
node skills/klingai/scripts/kling.mjs element --action create --name "Bloom Guy" --description "Young man in blue hoodie" --ref_type image_refer --frontal_image ./face.jpg

# Create from video
node skills/klingai/scripts/kling.mjs element --action create --name "Bloom Guy" --description "Young man in blue hoodie" --ref_type video_refer --video ./clip.mp4

# List your elements
node skills/klingai/scripts/kling.mjs element --action list

# Delete
node skills/klingai/scripts/kling.mjs element --action delete --element_id 123456
```

#### Prompt Template Syntax (Omni)

Reference inputs in prompts with `<<<>>>`:
- `<<<image_1>>>` — first image from --image
- `<<<element_1>>>` — first subject from --element_ids
- `<<<video_1>>>` — video from --video

#### Task Polling

Generation is async. Poll with the same subcommand + `--task_id`:

```bash
node skills/klingai/scripts/kling.mjs video --task_id <id> --download
```

Timing: video 1-5 min, image 20-60s, element 30s-2min.

#### When to Use Omni

The script auto-routes to Omni when it detects: multiple images, element_ids, reference video, multi-shot, 4K, or series. For simple text-to-video or single-image-to-video, it uses the standard v3 endpoint.

#### Cost Rules

Every submission is billed. Confirm with the user before submitting. On failure, ask before retrying. Never auto-resubmit.

---

### Backend B: Higgsfield Browser Automation

Eric has a Higgsfield **Creator subscription** at higgsfield.ai. Use the clawd browser to generate videos without spending API credits.

**Profile:** `clawd` — already logged in via browser profile

#### Full Workflow

**Step 1: Generate start frame (if needed)**

Use nano banana skill to create a 9:16 PNG first frame. Save to `/tmp/`.

**Step 2: Open the video creation page**

```
browser navigate → https://higgsfield.ai/create/video
```

**Step 3: Set 9:16 ratio**

Take a snapshot. Click the "16:9 Ratio" button, select "9:16" from the listbox.

**Step 4: Upload the start frame**

```
browser upload
selector: "input[type=file]:first-of-type"
paths: ["/tmp/your-frame.png"]
```

Screenshot to confirm the thumbnail appears in the Start frame box.

**Step 5: Add the motion prompt**

Click the textbox (snapshot to get ref), then `type` the prompt.

**Step 6: Generate**

Click "Generate 9" button. Takes about 2-3 minutes. Poll with screenshots until the preview appears.

**Step 7: Download the video**

Use the authenticated internal API:

```js
// In browser evaluate (page must be on higgsfield.ai):
const token = await window.Clerk?.session?.getToken();
const r = await fetch('https://fnf.higgsfield.ai/project?job_set_type=kling3_0&size=5', {
  headers: { 'Authorization': 'Bearer ' + token }
});
const d = await r.json();
console.log(d.job_sets[0].jobs[0].results.raw.url);
```

Then download: `curl -L "<url>" -o /tmp/output.mp4`

#### Higgsfield Notes

- Model: Kling 3.0 (9 credits per generation)
- Duration: 5s default, 10s costs more
- Resolution: 720p (sufficient for TikTok/Reels)
- `input[type=file]:first-of-type` = start frame; `nth-of-type(2)` = end frame
- Assets page (`/asset/all`) only shows uploaded content, NOT generated videos

---

## Process (End to End)

1. Understand what the user wants to create (or infer from context)
2. Pick the camera style and movement that fits the mood (Part 1)
3. Write the prompt as one flowing cinematic sentence
4. Offer 2-3 variants (different camera angles, moods, or stylistic approaches)
5. If the user has a reference video or image, match its visual language
6. Choose backend: API for advanced features (multi-shot, elements, reference video), Higgsfield for simple jobs
7. Execute, poll for completion, download and deliver the result
