---
name: kling
description: Use when generate AI video prompts for Kling 3.0 using cinematic
  directing techniques.
metadata:
  version: 1.0.0
---

# Kling 3.0 Video Prompting

You generate prompts for Kling 3.0 AI video. Prompt like a film director, not a keyword dumper. Kling generates motion, so every prompt must describe how the shot moves, not just what it looks like.

## Prompt Structure

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

## Four Rules

1. **Cinematic motion verbs.** Use: dolly push, whip-pan, shoulder-cam drift, crash zoom, snap focus, rack focus. Never use: "moves", "goes", "walks around".

2. **Texture = credibility.** Include grain, lens flares, reflections, fabric sheen, condensation, smoke, sweat. Tactile details make output feel physically real.

3. **Describe temporal flow.** Tell Kling how the shot evolves: beginning → middle → end. Continuity produces coherent motion instead of a frozen moment.

4. **Name real light sources.** Not "dramatic lighting." Say: neon signs, candlelight, golden hour, LED panels, flickering fluorescent tubes. Real sources produce real results.

## Lead with the Camera

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

## Color and Film Tone

Color language should be literal but emotive. Not "blue" but "cool blue haze." Not "warm" but "amber nightclub strobe."

**Effective color direction:**
- "Cool blue haze filling the corridor"
- "Amber nightclub strobe cutting through smoke"
- "Magenta neon reflecting off wet asphalt"
- "Golden hour light catching dust particles"
- "Desaturated teal grade, crushed blacks"

Film stocks and grades work directly: "VHS camcorder aesthetic with heavy grain and chromatic aberration", "shot on 35mm film".

## Example Prompt (Annotated)

> Static tripod camera in narrow neon-lit ramen shop, condensation fogs the window, couple sits side by side under flickering magenta sign, steam rising from bowls as they eat noodles in slow synchronized rhythm, broth splattering gently, their faces softly illuminated by red neon glow, shot on 35mm film with shallow focus and glowing bokeh behind them.

- **Camera:** Static tripod, shot on 35mm film
- **Subject:** Couple eating noodles in synchronized rhythm
- **Environment:** Narrow neon-lit ramen shop
- **Lighting:** Flickering magenta sign, red neon glow
- **Texture:** Condensation, steam rising, broth splattering
- **Emotion:** Shallow focus and glowing bokeh (intimate, cinematic warmth)

Reads like a single continuous take, not a keyword list. That flow is what gives Kling coherent motion.

## Weak vs Strong

| Element | Weak | Strong |
|---------|------|--------|
| Camera | Camera follows person | Handheld shoulder-cam drifts behind subject with subtle sway |
| Subject | A woman walking | Woman in red dress, heels clicking on wet cobblestone |
| Environment | In a city | Narrow Tokyo alley, steam rising from grates, vending machines glowing |
| Lighting | Dramatic lighting | Flickering neon signs casting magenta and cyan across wet pavement |
| Texture | It looks realistic | Rain beading on leather jacket, condensation on glass, visible breath |
| Motion | She walks away | She turns slowly, hair catching the light, then disappears around the corner |

## Realistic vs Experimental

Same concept, different stylistic lens:

**Realistic:** "Handheld camcorder footage zooming in erratically on woman's face as she devours a messy slice of pizza, melting mozzarella stretching and dripping, bright red tomato sauce smearing across her lips, VHS aesthetic with heavy grain, dim party lighting with colored gels."

**Experimental:** "Handheld shoulder-cam drifting through endless mirror maze reflecting multiple versions of two women eating food infinitely, strobing pink and cyan light washing over reflections, dripping sauces morph into shimmering liquid chrome, camera performs continuous circular orbit as reflections distort in rhythm with pulsing ambient bass."

Both work because they give Kling specific visual instructions. Realistic leans on texture and physicality. Experimental leans on surrealism and abstract motion.

## Process

1. Ask what the user wants to create (or infer from context)
2. Pick the camera style and movement that fits the mood
3. Write the prompt as one flowing cinematic sentence
4. Offer 2-3 variants (different camera angles, moods, or stylistic approaches)
5. If the user has a reference video or image, match its visual language

---

## Generating Videos via higgsfield.ai (Browser Automation)

Eric has a Higgsfield **Creator subscription** at higgsfield.ai. Use the clawd browser to generate videos without spending API credits.

**Profile:** `clawd` — already logged in as `socials@promptpm.ai`

### Full Workflow

**Step 1: Generate start frame (if needed)**

Use nano banana skill to create a 9:16 PNG first frame. Save to `/tmp/`.

**Step 2: Open the video creation page**

```
browser navigate → https://higgsfield.ai/create/video
targetId: 8F12A1B11B683C4F5E3F387AD4A1AE31
```

**Step 3: Set 9:16 ratio**

Take a snapshot. Click the "16:9 Ratio" button → select "9:16" from the listbox.

**Step 4: Upload the start frame**

The "Start frame" button is a styled div over a hidden file input. Direct clicking is unreliable. Use `upload` action:

```
browser upload
selector: "input[type=file]:first-of-type"
paths: ["/tmp/your-frame.png"]
```

Then take a screenshot to confirm the thumbnail appears in the Start frame box.

**Step 5: Add the motion prompt**

Click the textbox (snapshot to get ref), then `type` the prompt.

**Step 6: Generate**

Click "Generate 9" button. Takes about 2-3 minutes. Poll with screenshots until the preview appears (the "Generating" spinner disappears and a video poster loads).

**Step 7: Download the video**

**Manual (browser UI):** Hover the generated video in the history list → a ♥ / ↓ / ⧉ / ⋯ overlay appears top-right → click ↓ to download. Works fine for humans, unreliable for automation (hover drops before click fires).

**Automation:** The video CDN URL is not in the DOM statically. Use the authenticated internal API:

```js
// In browser evaluate (page must be on higgsfield.ai):
const token = await window.Clerk?.session?.getToken();
const r = await fetch('https://fnf.higgsfield.ai/project?job_set_type=kling3_0&size=5', {
  headers: { 'Authorization': 'Bearer ' + token }
});
const d = await r.json();
// Video URL is at:
// d.job_sets[0].jobs[0].results.raw.url
console.log(d.job_sets[0].jobs[0].results.raw.url);
```

The URL format: `https://d8j0ntlcm91z4.cloudfront.net/user_{ID}/{filename}.mp4`

Then download with curl:
```bash
curl -L "https://d8j0ntlcm91z4.cloudfront.net/..." -o /tmp/bloom-ugc.mp4
```

**Note:** Assets page (`/asset/all`) only shows uploaded content, NOT generated videos. Don't waste time there.

### Notes

- Model: Kling 3.0 (9 credits per generation)
- Duration: 5s default, 10s costs more credits
- Resolution: 720p default (sufficient for TikTok/Reels)
- The `targetId` `8F12A1B11B683C4F5E3F387AD4A1AE31` may change across sessions — take a fresh snapshot if navigation fails
- Higgsfield Cloud API (`cloud.higgsfield.ai`) is **separate** from the subscription — pay-as-you-go, requires credit top-up
- `input[type=file]:first-of-type` = start frame; `nth-of-type(2)` = end frame
