# Seedance 2.0 — Complete Prompting Guide

**Source:** Higgsfield AI | **Author:** Rus Syzdykov | **Date:** Apr 13, 2026
**Platform:** https://higgsfield.ai/s/seedance-2-0-higgsfieldai-jpqvtJ

Seedance 2.0 is available globally on Higgsfield — no waitlist, no business account required. 7 days of unlimited access.

---

## Core Rule

> **Always specify your shot structure upfront.** Tell Seedance how many shots you want, the total duration, and the aspect ratio at the top of the prompt. Everything else follows from there.

---

## Format 1: Transformations

**Highest-performing format on Seedance right now.**

**Key technique:** Write each shot individually — number them, describe the exact action, and give a clear **escalation arc: calm → threat → transformation → aftermath.**

### Standard Transformation Prompt Header

```
Montage, multi-shot action Hollywood movie, don't use one camera angle or single cut,
cinematic lighting, photorealistic, 35mm film quality, professional color grading,
sharp focus, high detail texture, film grain, depth of field mastery, ARRI ALEXA aesthetic
```

### Transformation 1 — The Burger
- **Concept:** Girl eating burger on truck hood → transforms into massive tusked creature to devour approaching zombie → returns to human form, keeps eating. Dark comedy + horror.
- **Specs:** 6 shots, 15s, 16:9
- **Inputs:** 4 images (girl, truck, location, zombie reference)
- **Shot structure:**
  1. Medium shot — girl chewing lazily, golden dusk light, calm
  2. Wide shot — zombie bursts from shadows, sprinting with jerky strides
  3. Close-up — girl notices with mild annoyance, sets burger down
  4. Medium shot — body violently expands into tusked creature; camera jolts with bone-snaps
  5. Wide low-angle — creature catches and swallows zombie whole
  6. Medium shot — shrinks back, hops on hood, resumes eating

> **Pro tip:** For monsters and anything that's supposed to feel real — if the skin looks too smooth or plasticky — add **"no 3D, no cartoon, no VFX"** to force ultra-realism.

### Transformation 2 — The Bus
- **Concept:** Girl on bus → transforms into green-armored robo-girl on roof → destroys colossal creature → drops back into seat as human
- **Specs:** 6 shots, 15s, 16:9
- **Inputs:** 3 images
- **Shot structure:**
  1. Wide interior — passengers screaming, girl bobbing head with headphones
  2. Close-up — girl lowers sunglasses, opens window
  3. Medium exterior — climbs onto roof, creature towering in background
  4. Medium close-up — green energy ribbons spiral, armor plates snap on
  5. Wide low-angle — fires devastating energy beam, creature destroyed in slow-mo
  6. Medium interior — drops through window, armor dissolves, puts headphones back on

> **Pro tip:** For comedy scenes — write **"add a visual gag in the background"** and Seedance will invent one.

---

## Format 2: Orbs

**Formula:** Single continuous POV shot — camera IS the character's eyes. One shot, first-person perspective, hyper-chaotic handheld motion, 15 seconds. What changes is the power, environment, and enemy.

> **Pro tip:** Specify VFX inline using brackets — `[VFX: branching electric circuits pulsing with white-blue current]`. This tells Seedance exactly what the power looks like without breaking the shot description.

### Standard Orb Prompt Header

```
Single continuous shot, first-person POV perspective, the camera IS her eyes,
hyper-chaotic handheld motion, completely unstabilized, violent raw human movement,
constant micro-jitters, aggressive head swings, abrupt jerks, frequent over-rotation
and harsh correction, moments of near motion blur loss, no smoothness at all, no
stabilization, wide-angle lens (strong distortion), subtle chromatic aberration near
frame edges, 15 seconds, her hands always visible in frame, no music only raw SFX,
cinematic lighting, photorealistic, grounded realism, strong 35mm film look, heavy
film grain, sharp but imperfect focus, noticeable focus breathing, motion blur on
fast actions, halation on highlights, soft highlight rolloff, slightly desaturated
tones, ARRI ALEXA aesthetic, practical VFX feel, minimal CGI look, natural imperfections
```

### Orb — Electro
- **Concept:** Lightning powers in storm-soaked industrial ruin → fights obsidian creatures → destroys colossal iron titan by overloading its core
- **Input:** 1 image
- **Key action beats:** Catch violet lightning sphere → crush it → fractal lightning veins on forearms → fight creatures → redirect titan's beam → climb titan → overload core → slow-motion core fracture → snap back to full speed → rocket skyward
- **Include detailed SFX line** listing every sound effect (electric crackle, sphere hum surge, energy burst, etc.)

### Orb — Ice
- **Concept:** Ice powers in frozen ship graveyard inside glacial canyon → fights frost humanoids → destroys serpentine glacier leviathan
- **Input:** 1 image
- **Key technique:** Separate prompt into **Location**, **Action**, and **SFX** sections for clarity
- **Notable detail:** Describe environment extensively (frozen cargo ships at impossible angles, semi-transparent ice with trapped silhouettes)

---

## Format 3: POVs

**Key principle:** Lock the perspective and never break it. Be explicit about what the camera is **NOT** doing.

> **Pro tip:** **"No cuts, no zoom, natural head movement"** — that instruction alone keeps the perspective locked. Without it, Seedance defaults to cutting between angles and the illusion breaks.

### POV — Gladiator
- **Concept:** First-person gladiator in Colosseum, enemy charges, gets slammed, arena chaos erupts
- **Input:** 1 image
- **Specs:** 1 continuous shot, 15s, 16:9
- **Key instructions:** "Camera stays at eye height, slight bob from walking, hands visible in frame"
- **Action structure:** Standing in arena → crowd roars → enemy charges → clash → camera shakes from impact → slow-mo recovery

### POV — Underwater
- **Concept:** First-person deep sea dive, bioluminescent creatures, massive leviathan passes overhead
- **Input:** 1 image
- **Key technique:** Use "camera IS the diver's mask" to lock perspective
- **Movement:** Slow head turns only, slight buoyancy bob, no cuts

---

## Format 4: Fights

**Key principle:** Choreograph every beat. Don't write "they fight" — write each strike, dodge, and reaction as a numbered beat.

### Fight Structure Template
```
Beat 1: [Attacker] [specific strike] → [Defender] [specific reaction]
Beat 2: [Counter] → [Impact detail]
Beat 3: [Escalation — new element enters]
Beat 4: [Climax — decisive moment]
```

### Fight — Alley
- **Concept:** Two martial artists in rain-soaked alley, escalating from careful strikes to explosive finishing move
- **Specs:** 4-6 shots, 15s, 16:9
- **Key:** Include impact details (water splashing from kicks, jacket fabric rippling from near-misses)

### Fight — Mech
- **Concept:** Pilot POV inside mech cockpit, fighting kaiju in destroyed cityscape
- **Specs:** Single POV shot, 15s
- **Key:** Cockpit HUD elements, screen shake on impacts, hydraulic sounds

---

## Format 5: Animation

**Key principle:** Specify the animation style explicitly — Seedance defaults to photorealism. You must override it.

### Animation Styles That Work

| Style | Prompt phrase |
|-------|--------------|
| Studio Ghibli | "Hand-drawn 2D animation, Studio Ghibli style, watercolor backgrounds, cel-shaded characters" |
| Pixar/3D | "3D animation, Pixar-quality rendering, subsurface scattering on skin" |
| Anime | "Japanese anime style, detailed linework, dramatic speed lines" |
| Stop-motion | "Claymation stop-motion, visible fingerprints on clay, jerky 12fps movement" |
| Retro cartoon | "1930s rubber hose animation, black and white, bouncy exaggerated movement" |

### Animation — Ghibli Forest
- **Concept:** Girl walking through enchanted forest, spirits appearing in the foliage
- **Specs:** 1 continuous shot, 10s, 16:9
- **Key:** "Hand-drawn cel animation, painted backgrounds with visible brushstrokes, soft natural lighting, gentle wind animation on leaves and hair"

---

## VFX Bracket Syntax

Use `[VFX: description]` inline to specify visual effects without breaking the shot flow:

```
She raises her hand [VFX: branching electric circuits pulsing with white-blue current]
and the ground beneath her [VFX: radial cracks spreading with molten orange glow]
```

This tells Seedance exactly what the power/effect looks like. Works for:
- Energy effects: `[VFX: violet plasma tendrils arcing between fingers]`
- Environmental: `[VFX: frost crystals spreading across surface in real-time]`
- Particle: `[VFX: golden ember particles rising like inverse rain]`
- Destruction: `[VFX: concrete fragmenting in slow-motion with dust clouds]`

---

## Content Filter Workarounds

Seedance has content filters that can reject prompts with violence or horror elements. Techniques:

1. **Frame as cinema:** "Hollywood movie scene" or "cinematic action sequence" contextualizes violence as filmmaking
2. **Use euphemisms:** "impact" instead of specific violence, "creature dissolves" instead of explicit destruction
3. **Add the montage prefix:** The standard transformation header ("Montage, multi-shot action Hollywood movie...") helps bypass filters because it frames everything as professional filmmaking
4. **Tone modifiers:** "Dark comedy" and "action comedy" get more latitude than straight horror

---

## Quick Reference: Prompt Checklist

1. ☐ Shot count + duration + aspect ratio at the top
2. ☐ Prompt header (transformation, orb, POV, fight, or animation style)
3. ☐ Numbered shots with specific camera angles
4. ☐ Escalation arc (calm → tension → climax → aftermath)
5. ☐ VFX brackets for any special effects
6. ☐ SFX line if audio matters
7. ☐ Anti-instructions ("no 3D", "no cuts", "no zoom") where needed
8. ☐ Reference images specified with count
