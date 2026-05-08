# Reference Video + Anti-AI Post-Processing

Use this when making UGC-style or influencer-style ad videos from references.

## Why It Matters

Pure AI video often looks too smooth, plastic, and generic. The stronger workflow is reference-first:

1. Pick a proven reference video with the motion, structure, and pacing you want
2. Create or select a first frame that matches the reference pose and setting
3. Generate with reference video / Ad Reference so the model copies the format rather than inventing motion
4. Add light post-processing to make the result look like phone-native content

## Reference Selection

Good reference videos have:
- Strong hook in the first 1-3 seconds
- Expressive face and body movement
- Clear product/demo beat
- Natural smartphone framing
- High engagement or known ad performance
- Presenter visually close to the generated avatar when using identity transfer

Avoid references with:
- Complex hand-object interactions
- Fast camera cuts every second
- Heavy text overlays unless you will recreate them in post
- Hair/clothing/body type very different from the target avatar

## Prompt Pattern for Motion Transfer

Use this language when asking for motion consistency:

```text
Use the attached reference video as the motion and pacing blueprint. Preserve the character identity, body proportions, face, hair, skin texture, clothing fit, and silhouette. Match timing, speed, weight shifts, hand paths, head turns, eye line, micro-expressions, and pauses. Keep realistic biomechanics, natural momentum, correct contact with the ground, no foot sliding, no limb stretching, no jitter, no teleporting, no sudden snaps, no invented gestures, no extra transitions, no style drift, no double-imaging, no flicker.
```

## Marketing Studio Ad Reference

For ad-style remixes, prefer Marketing Studio Ad Reference over raw video models:

```bash
# reference can be a local path or previous job/upload id
higgsfield generate create marketing_studio_video \
  --prompt "Recreate this winning ad format for $APP_NAME" \
  --ad_reference_id "<reference_video_id>" \
  --product_ids @"$PRODUCT_IDS_JSON" \
  --mode ugc \
  --duration 15 \
  --resolution 1080p \
  --aspect_ratio 9:16 \
  --wait --json
```

Use Ad Reference when you have a winning Meta/TikTok/YouTube ad format and want variations.

## First-Frame Technique

If the model needs a starting frame:

1. Extract first frame from reference video
2. Generate an image using the avatar/person plus that first-frame pose/background
3. Use that image as `--start-image`

Prompt for first-frame creation:

```text
Use the person from image 1 and the pose, emotion, camera angle, and background from image 2. Preserve the person's identity exactly while matching the reference frame's expression and body language. Make it look like a candid iPhone video frame, natural skin texture, not plastic, not doll-like.
```

## Anti-AI Post-Processing

If the result looks too synthetic, apply light smartphone-style processing:

- Grain: 25-40
- Sharpness: +10 to +20
- Brightness: -5 to -10 if scene is too flat
- Vignette: 5-15
- Slight compression or export through a mobile editor can help content feel native

Do not overdo it. Finance ads still need to look credible.

## App Ad Guidance

Use this for:
- UGC testimonial ads
- Founder/explainer ads
- TikTok/Reels style creative tests
- Remixing a proven Meta ad into a new variant
- Ad Reference from a winning competitor ad

Do not use this for:
- Clean Google App Campaign image assets
- App Store screenshots
- Compliance-sensitive claims
- Anything implying guaranteed returns or investment advice
