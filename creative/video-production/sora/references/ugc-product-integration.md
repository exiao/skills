# UGC Product Integration Pipeline

Generate AI UGC ads where an actor holds, uses, or demonstrates a real product. The pipeline chains three tools: video generation → image compositing → reference-frame animation.

## When to Use

- Product testimonial videos where the actor interacts with a physical product
- Unboxing or demonstration content
- Lifestyle shots with product placement
- Any UGC where hands + product must look natural

## The Three-Step Pipeline

### Step 1: Generate the Actor Video (Sora or Kling)

Create the talking-head or lifestyle clip WITHOUT the product first. This avoids the distortion, scale, and physics problems that come from trying to generate actor + product together.

Use the UGC realism template (`ugc-realism.md`) for organic style, or standard templates for polished ads.

Key: have the actor's hands visible and positioned where the product will go. Prompt for "hand extended at chest height" or "hands cupped together at waist" depending on product type.

```
Use case: UGC testimonial (actor base)
Primary request: person talking to camera in home kitchen, right hand extended at chest height as if holding a small can, left hand gesturing naturally
Camera: iPhone front camera, vertical 1080x1920, slightly off-center
Lighting/mood: warm natural window light from left, casual morning energy
Style/format: UGC selfie-style, slight camera shake
Constraints: hand must be clearly visible and open/gripping at chest height, no product in frame yet
```

### Step 2: Composite the Product (Nano Banana Pro)

Extract the best frame from the Step 1 video, then use Nano Banana Pro to composite your product photography into the actor's hand.

**Frame extraction:**
```bash
# Extract frame at 2-second mark
ffmpeg -ss 2 -i actor_base.mp4 -frames:v 1 -q:v 2 reference_frame.jpg
```

**Compositing prompt structure:**
```
Realistic photograph, [actor description] in [environment] holding [product] in [which hand] at [position].
Product label facing camera, [brand details] clearly visible.
Natural grip with fingers wrapped around [product shape].
Lighting consistent with [match the source]: [direction and quality].
Product appears [real-world size reference].
Photorealistic integration, no compositing artifacts.
```

**Example:**
```bash
uv run {baseDir}/../nano-banana-pro/scripts/generate_image.py \
  --prompt "Realistic photograph of young woman in casual home kitchen holding green energy drink can in her right hand at chest height. Product label facing camera showing 'BLOOM' brand. Natural grip with fingers comfortably around can. Warm window light from left side matching environment. Can appears standard 12oz size. Photorealistic, no visible editing." \
  --input-image reference_frame.jpg \
  --filename 2026-02-25-product-composite.png \
  --resolution 2K
```

**Validation checklist:**
- [ ] Hand grip looks anatomically correct (fingers wrap naturally)
- [ ] Product scale matches real-world expectations
- [ ] Lighting direction is consistent with the source frame
- [ ] Shadows fall in the right direction
- [ ] No obvious edge artifacts or color mismatch

If the composite looks off, iterate: adjust the prompt for grip angle, lighting direction, or scale. Usually takes 2-3 generations to nail.

### Step 3: Animate from Reference Frame (Kling or Veo)

Use the composited image as a reference frame for video generation. This produces 5-12 seconds of the actor naturally holding/using the product.

**For Kling** (reference-image animation):
```
Shoulder-cam drift, young woman examining green energy drink can in her right hand, 
rotating it slightly to show the label, warm kitchen light from left, 
natural head movement and subtle smile, iPhone selfie aesthetic, 5 seconds
```

**For Sora** (if no reference image needed, text-to-video):
Use the composited frame as visual direction only. Describe the scene precisely in the structured prompt, matching all details from the composite.

### Assembly

Combine the pieces in sequence:

```
1. Talking head (Step 1 video)     — 8-15 seconds, actor speaking
2. Product interaction (Step 3)     — 5-8 seconds, holding/examining product  
3. Return to talking head           — 5-8 seconds, recommendation + CTA
```

Add captions, music, and branding in post (CapCut, Remotion, or Premiere).

## Multi-Angle Product Showcase

For stronger product visibility, generate multiple composites from different angles and animate each separately:

| Angle | Duration | Purpose |
|-------|----------|---------|
| Front-facing | 3-5s | Product label/branding clearly visible |
| Side profile | 3-5s | Shape, depth, actor examining it |
| Detail closeup | 2-4s | Texture, quality, design elements |

Sequence: front → side → detail → return to front for CTA. Total 12-18 seconds of product coverage.

**Side profile prompt adjustment:**
```
...holding [product] turned 90 degrees showing side profile, 
actor looking down at product examining it closely...
```

**Detail closeup:**
Use clean product photography directly (no actor). Apply subtle motion (slow zoom or pan) via Kling or Sora for 2-4 seconds.

## Product Integration by Category

| Product Type | Hand Position | Environment | Notes |
|-------------|---------------|-------------|-------|
| Beverages/cans | Right hand, chest height | Kitchen, desk, outdoor | Show label facing camera |
| Supplements/bottles | Either hand, waist-chest | Bathroom counter, gym bag | Cap visible for recognition |
| Skincare/cosmetics | Fingertips, face-adjacent | Bathroom mirror, vanity | Show application motion |
| Phone/tablet | Both hands or single | Couch, desk, commute | Screen content matters |
| Clothing/accessories | Worn on body | Full-body lifestyle shot | Skip hand compositing, composite onto body |
| Food/packaged goods | Cupped hands or counter | Kitchen, dining table | Scale relative to hands is critical |

## Common Failures and Fixes

| Problem | Cause | Fix |
|---------|-------|-----|
| Product floats above hand | Compositing didn't match grip | Re-prompt with "fingers wrapped tightly around [shape]" |
| Wrong scale | Product too big/small vs hand | Add explicit size reference: "standard 12oz can" or "fits in palm" |
| Lighting mismatch | Composite lit differently than scene | Match light direction: "warm light from LEFT matching environment" |
| Stiff animation | Reference frame too posed | Choose a mid-gesture frame, not a posed one |
| Product disappears in video | Video model ignored reference | Use Kling (stronger reference adherence) instead of Sora |

## Cost Per Final Video

| Step | Tool | Time | Cost |
|------|------|------|------|
| Actor base video | Sora | 2-5 min | $0.20-0.50 |
| Frame extraction | ffmpeg | 5 sec | Free |
| Product composite | Nano Banana Pro | 1-3 min | ~$0.01 |
| Product animation | Kling/Veo | 2-5 min | $0.10-0.20 |
| Assembly | CapCut/Remotion | 5-10 min | Free |
| **Total** | | **10-25 min** | **$0.30-0.70** |
