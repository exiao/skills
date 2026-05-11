# Seedance 2.0 — Complete Prompting Guide

**Source:** https://higgsfield.ai/blog/seedance-prompting-guide
**Author:** Rus Syzdykov | Apr 13, 2026

## Universal Rule

Always specify shot structure upfront: number of shots, total duration, aspect ratio.

Every individual Seedance 2.0 generation tops out at 15 seconds. Do not prompt for a 30s or 60s video. Build longer pieces by generating separate 15s-or-shorter clips, carrying identity/location forward with a reference frame, then stitching in post.

For single continuous clips, keep the scene to one location, one camera move, and 1-2 primary actions. If you need cuts, location changes, app-screen inserts, or captions, generate clean footage and composite those parts later.

---

## Format 0: AI UGC / Talking-Head Ads

**Source:** @adriansolarzz, May 2026.

Use this format for selfie ads, creator testimonials, product demos, app pitches, or any UGC-style clip where realism matters more than cinematic spectacle.

### 5-Beat Formula

1. **Subject:** age, hair, outfit, accessories, ethnicity, and any identity-locking details.
2. **Setting:** one concrete environment with real objects, not abstract mood words.
3. **Action:** 1 primary action plus 1-2 secondary beats for 5-8s clips; max 2 primary actions for 15s clips.
4. **Camera:** named camera behavior: front-facing selfie camera, locked-off, handheld natural shake, dolly push-in, arc, tracking shot.
5. **Lighting/style/mood:** put lighting at the end. For UGC, prefer plain language like "soft window light" over polished cinema tags.

### Dialogue Embedding Rule

Embed dialogue inline with the matching visual beat. Do not add a separate "voiceover script" block.

Wrong:
> A woman in a kitchen takes a sip of coffee. Voiceover: "I use Bloom every morning."

Right:
> A 28-year-old woman in a sunlit kitchen takes a sip of coffee, sets the cup down, looks directly into the lens, and says, "I use Bloom every morning before the market opens."

Use "says" / "asks" / "finishes" attribution every time. Put brand names on visible-speaker beats where the mouth is on camera. Avoid brand names during cutaways because pronunciation gets mushier without lip-sync pressure.

### Brand Name Pronunciation Defense

For brand names, acronyms, or unusual product names:

1. Spell acronyms phonetically: "A. I.", "U G Cee", "C. E. O.".
2. Add enunciation direction before the line: "she slows down slightly and clearly enunciates...".
3. Repeat the name naturally in the middle of the clip with a comma, not as a forced CTA: "It's called Bloom, Bloom, and it tracks the stocks I actually care about."

### Selfie POV That Does Not Render a Phone

Do not write "phone held at arm's length" unless you want the phone visible. Use:

> The camera IS her phone's front-facing selfie camera. We see her face filling the frame from the phone's perspective, no phone visible in the shot, just her looking directly into the lens as if talking to her followers. Subtle natural shake mimicking a propped-up phone.

Stability choices:
- Propped phone: "subtle natural shake mimicking a propped-up phone"
- Locked off: "steady locked-off front-facing camera view"
- Vlog handheld: "subtle handheld shake, organic camera movement"

### Real-Brand Prop Strategy

Name 2-4 specific real-world props in the scene to prevent generic AI backgrounds. Use recognizable shape/color signals even if logos are imperfect.

Examples:
- Bedroom/vanity: sage green Stanley tumbler, Sephora bag, AirPods case, Celsius can, Glossier products
- Kitchen: Starbucks cup, Trader Joe's salad container, stickered MacBook, Whole Foods bag, Brita pitcher
- Car: Liquid Death can in cup holder, AirPods case on dashboard, iPhone charger cable, Whole Foods bag on passenger seat
- Street: Starbucks cup, Whole Foods storefront, Sephora tote, New Balance sneakers, yellow cab
- Podcast/studio: Celsius can, Stanley tumbler, stickered MacBook, AirPods Max, LED strip lighting

### On-Screen Text Rule

Seedance cannot spell reliably. Do not ask it to render captions, URLs, app UI text, readable logos, or subtitles. Generate text-free footage, then add captions/logos/app screens in CapCut, Premiere, Final Cut, or After Effects. For app reveals, screen-record the actual app and composite it into the insert beat.

### Trademark/Censorship Workaround

If a trademarked game, brand, or franchise blocks/degrades output, describe the visual DNA instead of naming the property: proportions, shading, lighting, color grade, environment, and genre. Example: use "open-world crime drama video game cutscene in a sun-bleached West Coast city with palm trees" instead of naming GTA.

### UGC Prompt Template

```text
[Subject with specific visual details] in [one concrete setting with 2-4 real-world props]. [Primary action plus 1-2 secondary beats]. The camera IS [specific camera perspective], [framing], [stability], [what must not be visible if relevant]. [Subject] says, "[short exact dialogue embedded at the visual moment]." [Lighting/style/mood]. Total: [5/10/15]s / [1 continuous shot or N stitched clips] / [aspect ratio].
```

---

## Format 1: Transformations

**Highest-performing format on Seedance currently.**

### Structure Rules:
- Write each shot individually and number them
- Give a clear **escalation arc**: calm → threat → transformation → aftermath
- Describe exact action in each shot

### Opening Formula (reuse for all transformation prompts):

> "Montage, multi-shot action Hollywood movie, don't use one camera angle or single cut, cinematic lighting, photorealistic, 35mm film quality, professional color grading, sharp focus, high detail texture, film grain, depth of field mastery, ARRI ALEXA aesthetic"

### Pro Tips:
- For monsters/realism: add **"no 3D, no cartoon, no VFX"** to force ultra-realism when skin looks too smooth
- For comedy: write **"add a visual gag in the background"** and Seedance will invent one

### Example — The Burger (6 shots / 15s / 16:9)
Inputs: 4 images (girl, truck, location, zombie reference)

Full prompt:

"Montage, multi-shot action Hollywood movie, don't use one camera angle or single cut, cinematic lighting, photorealistic, 35mm film quality, professional color grading, sharp focus, high detail texture, film grain, depth of field mastery, ARRI ALEXA aesthetic

A pink-haired girl with glasses, cream top and jeans sits on the hood of a white pickup truck under a concrete overpass at dusk, casually eating a burger. A shallow river channel stretches behind her, power lines and distant bridges framing the golden sky. A pale zombie with wet dark hair, bruised eyes and a blood-stained white shirt sprints toward her from the shadows of the channel. The girl calmly sets down the burger, her body erupts into a massive pale tusked creature with elongated limbs and clawed hands, devours the zombie whole, then shrinks back to human form and picks up the burger. Handheld shake throughout, dark comedy pacing with horror undertones.

Shot 1: Medium shot of the girl sitting cross-legged on the truck hood, chewing the burger lazily, golden dusk light catching her glasses and pink hair. Camera sways gently, ambient and calm.

Shot 2: Wide shot of the concrete channel as the zombie bursts from the shadows under the bridge, sprinting with jerky unnatural strides across the dry riverbed toward the truck. Camera shakes tracking the approaching threat.

Shot 3: Close-up on the girl's face as she notices the zombie, chewing slows, eyebrows rise with mild annoyance rather than fear. She sets the burger down on the hood beside her.

Shot 4: Medium shot as the girl drops off the hood and her body violently expands and twists upward into the massive pale tusked creature, spine cracking, limbs stretching, jaws splitting open wide, towering over the truck. Camera jolts with each bone-snap of the transformation.

Shot 5: Wide low-angle as the creature lunges forward and catches the charging zombie in its enormous clawed hand, lifts it off the ground and swallows it whole in one grotesque bite, jaw unhinging. Camera shudders with the impact.

Shot 6: Medium shot as the creature rapidly shrinks back into the girl, standing calmly beside the truck. She hops back onto the hood, picks up the burger, takes another bite and keeps chewing as if nothing happened.

Total: 15s / 6 shots / 16:9"

---

## Format 2: Orbs

**Formula:** Single continuous POV shot, first-person perspective, hyper-chaotic handheld motion, 15 seconds. What changes is the power, environment, and enemy.

**Pro tip:** Specify VFX inline using brackets:
```
[VFX: branching electric circuits pulsing with white-blue current]
```

### Standard Orb Opening Block (reuse for all orb prompts):

"Single continuous shot, first-person POV perspective, the camera IS her eyes, hyper-chaotic handheld motion, completely unstabilized, violent raw human movement, constant micro-jitters, aggressive head swings, abrupt jerks, frequent over-rotation and harsh correction, moments of near motion blur loss, no smoothness at all, no stabilization, wide-angle lens (strong distortion), subtle chromatic aberration near frame edges, 15 seconds, her hands always visible in frame, no music only raw SFX, cinematic lighting, photorealistic, grounded realism, strong 35mm film look, heavy film grain, sharp but imperfect focus, noticeable focus breathing, motion blur on fast actions, halation on highlights, soft highlight rolloff, slightly desaturated tones, ARRI ALEXA aesthetic, practical VFX feel, minimal CGI look, natural imperfections"

### Key Techniques:
- Use "RAMPS TO SLOW MOTION" and "SNAPS BACK" for temporal control
- Include SFX descriptions at the end
- Separate Location, Action, and SFX sections for complex environments
- Describe enemy movement style (e.g., "sharp, unnatural jerks like broken stop-motion")

### Example — Electro (1 shot / 15s / 16:9)
Input: 1 image. Setting: Storm-soaked industrial ruin. Arc: Catch lightning sphere → fight obsidian creatures → destroy iron titan by overloading core.

### Example — Ice (1 shot / 15s / 16:9)
Input: 1 image. Setting: Frozen ship graveyard in glacial canyon. Arc: Ice powers → fight frost humanoids → destroy glacier leviathan.

---

## Format 3: POVs

**Core principle:** Lock the perspective and never break it.

**Pro tip:** Be explicit about what the camera is NOT doing:
> "No cuts, no zoom, natural head movement"

Without this, Seedance defaults to cutting between angles and the illusion breaks.

### Example — Gladiator (1 shot / 15s / 16:9)
Input: 1 image.
Key instruction: "One continuous shot, POV gladiator perspective in the Colosseum arena, no cuts, no zoom, natural head movement"

### Example — Horses
Input: 1 image. Intentionally minimal prompt:
> "A single-frame POV video of a medieval knight riding a horse with a sledgehammer in his hands, riding and fighting epically, smashing his opponents with a sledgehammer while riding a horse, to make it look realistic with blood."

**Lesson:** Sometimes the shortest prompts hit hardest.

---

## Format 4: Fights

**Three requirements:** Clear location, clear power mismatch, defined escalation arc. Describe exact choreography beat by beat.

### Key Techniques:
- Detailed camera movement instructions (FPV arm, 360-degree orbit)
- Speed ramping: Guy Ritchie speed-ramping with Snyder impact slow-motion
- Environment transitions (train roof → air → underwater)
- Size-mismatch comedy (petite fighter vs massive opponent)

### Example — Train (1 shot / 15s / 16:9)
Inputs: 2 images. Two female samurai on speeding train → clash → slow-motion dodge (hair-severing) → both fall into river → fight continues underwater.

### Example — Lollipop (1 shot / 15s / 16:9)
Inputs: 2 images. Petite woman with lollipop takes down massive painted fighter in dark industrial warehouse. Classic size-mismatch comedy.

---

## Format 5: Animation

Animation prompts work best when you break the 15 seconds into timed segments and describe each one explicitly.

### Structure:
- Use a keyframe image as style reference
- Specify the animation aesthetic in the opening line
- Describe physics: particle simulation, dust, energy VFX
- Break into timed segments: 0-3s, 3-6s, 6-9s, 9-12s, 12-15s

### Example — Desert Hero (1 shot / 15s / 16:9)
Input: 1 image (keyframe + style reference).
Opening: "Cinematic stylized 3D animation, photorealistic desert environment, stylized characters."
Arc: confrontation → discovery → climax → resolution.

### Minimal Example — 3D vs 2D
No image input needed. Full prompt: "Fight of a 3D person with 2D"

---

## Summary of Prompt Patterns

| Format | Shots | Key Instruction | Typical Inputs |
|--------|-------|-----------------|----------------|
| AI UGC / Talking-Head Ads | 1 continuous shot per clip | 5-beat formula, inline dialogue, visible-speaker brand names, real-brand props | Optional avatar/product refs, app screen composited later |
| Transformations | 4-6 | Numbered shots, escalation arc | 3-4 images |
| Orbs | 1 | POV opening block + VFX brackets | 1 image |
| POVs | 1 | "No cuts, no zoom, natural head movement" | 1 image |
| Fights | 1 | Beat-by-beat choreography, speed ramping | 1-2 images |
| Animation | 1 | Timed segments (0-3s, 3-6s...), keyframe ref | 1 image |

## Universal Tips

1. Always specify shot structure upfront (shots, duration, aspect ratio)
2. Keep each generation at 15 seconds max; stitch separate clips for longer pieces
3. For UGC, use the 5-beat formula: subject, setting, action, camera, lighting/style/mood
4. Embed dialogue inline with "says [exact line]" rather than a separate script block
5. Put brand names on visible-speaker beats; use phonetic spelling and enunciation direction when needed
6. For selfie POV, say the camera IS the phone's front-facing camera and explicitly say no phone is visible
7. Add 2-4 real-world brand props for realism, but composite readable logos/text in post
8. Never ask Seedance to spell captions, URLs, app UI text, or subtitles; add those in editing
9. Use "ARRI ALEXA aesthetic" for cinematic realism, but avoid polished cinema language for casual UGC
10. "No 3D, no cartoon, no VFX" forces ultra-realism
11. VFX brackets `[VFX: description]` for inline effects
12. "RAMPS TO SLOW MOTION... SNAPS BACK" for temporal control
13. Include SFX descriptions for richer output
14. Be explicit about what the camera is NOT doing
15. Sometimes the shortest prompt hits hardest
