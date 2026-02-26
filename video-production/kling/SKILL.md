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
