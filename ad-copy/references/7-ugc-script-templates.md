# 7. UGC Script Templates (AI-Generated Video)

Script structures for AI-generated UGC testimonials. These pair with the Sora product integration pipeline (`sora/references/ugc-product-integration.md`) for full video production.

## Emotional Beat Structure

Every UGC testimonial follows an emotional arc, not a flat pitch. Each beat has a specific energy level and purpose.

```
CURIOSITY (0-3s)     — Moderate energy. Hook with intrigue, not hype.
PROBLEM (3-10s)      — Energy dips. Frustration, relatability, empathy.
DISCOVERY (10-20s)   — Energy builds. Hope, specific benefit, shift from frustration.
VALIDATION (20-28s)  — Peak energy. Results, social proof, personal transformation.
CTA (28-35s)         — Sustained but slightly softer. Clear next step, friendly not pushy.
```

The energy dip at PROBLEM is what makes DISCOVERY feel earned. Skip the dip and the whole thing sounds like an infomercial.

## Template A: Pain Point Discovery (Excited Tone)

**Actor direction:** Animated, talking fast, genuine surprise energy.

```
CURIOSITY (0-3s):
"Okay this is wild..."
[Text overlay: core claim or stat]

PROBLEM (3-10s):
"I was literally spending [$ amount] on [competitor/old solution]
that barely worked. I tried [alternative 1], [alternative 2],
nothing actually fixed [specific pain]."

DISCOVERY (10-20s):
"Then I found [product] and it completely changed everything.
Within [timeframe] I noticed [specific result].
Like, [concrete detail only a real user would mention]."

VALIDATION (20-28s):
"I'm seeing [specific outcome] I didn't think were possible.
Everyone around me has noticed. [Social proof detail]."

CTA (28-35s):
"If you're dealing with [problem], seriously just try this.
You can thank me later."
[Text overlay: product name + where to get it]
```

## Template B: Social Proof Skeptic (Contemplative Tone)

**Actor direction:** Calm, thoughtful, measured delivery. Credibility through restraint.

```
CURIOSITY (0-3s):
"So everyone's been talking about [product]..."

PROBLEM (3-10s):
"And honestly I was skeptical because I've tried everything.
[Specific thing they tried]. [Another thing]. None of it stuck."

DISCOVERY (10-20s):
"But after using it for [timeframe] I totally get the hype now.
The difference is [specific observable change].
[Detail that shows actual usage, not marketing speak]."

VALIDATION (20-28s):
"I'm actually recommending it to people, which I never do.
[Specific person or context where they recommended it]."

CTA (28-35s):
"If you've been on the fence, this is the one."
[Text overlay: product name + CTA]
```

## Template C: Unboxing Reveal

**Actor direction:** Excited anticipation → genuine reaction. Five segments, each gets its own video generation pass.

```
INTRO (0-10s):
"Okay so this just arrived and I'm actually so excited.
I've been hearing about [product] everywhere.
Everyone says it's completely different from [competitor].
Let's see if it lives up to the hype."
[Talking head, selfie-style, package visible but unopened]

UNBOXING (10-18s):
[POV overhead shot: hands opening package]
[First glimpse of product]
[Packaging details visible]
— No voiceover needed. Let the reveal breathe.

FEATURES (18-30s):
[Actor holding product, examining it]
"Okay so right away I notice [physical quality detail].
The [specific feature] is [observation].
And look at [detail] — that's [comparison to competitor]."
[Multi-angle: front → side → detail closeup]

DEMO (30-42s):
[Actor using the product in context]
[Show application/consumption/interaction]
"So [describing the experience in real time].
[Genuine reaction to the experience]."

VERDICT (42-50s):
"Honestly this exceeded my expectations.
If you've been considering [category], this is the one.
I'm already planning to [repeat purchase/recommend/etc]."
[Text overlay: product name + CTA]
```

**Production note:** Each segment is a separate video generation + composite pass. The unboxing POV (segment 2) uses a different camera angle than the talking head segments.

## Template D: Lifestyle Context (Soft Sell)

**Actor direction:** Natural, candid, product integrated into daily life rather than pitched.

```
CONTEXT (0-5s):
[Actor in natural environment: commuting, cooking, at desk, working out]
"So my [morning routine / commute / workout / evening] has been
completely different since I started using [product]."

INTEGRATION (5-15s):
[Show product in use within the environment]
"I just [how they use it: take it, apply it, open it, check it]
and [immediate benefit]. It takes [time: seconds/minutes]."
[Product visible but not centered — lifestyle first, product second]

CONTRAST (15-22s):
"Before I was [old behavior: slower, more complicated, worse results].
Now I [new behavior]. [Specific metric or observable difference]."

CLOSE (22-28s):
"Honestly it's one of those things where you wonder
why you didn't switch sooner."
[Text overlay: product name]
```

## Script Adaptation Rules

**For different tones**, adjust these variables:
- **Excited:** Shorter sentences, interruptions ("like, wait"), faster pacing
- **Contemplative:** Longer pauses, qualifiers ("honestly," "actually"), measured delivery
- **Casual:** Filler words ("so," "like"), tangents that circle back, lower stakes language
- **Urgent:** Statistics, deadlines, scarcity cues, direct address ("you need to")

**For different products**, adjust the PROBLEM beat:
- **Replacing a competitor:** Name the old solution's specific failure
- **New category:** Describe the gap ("I didn't even know this existed")
- **Upgrade:** Describe what they tolerated before ("I just accepted that...")
- **Impulse/lifestyle:** Skip PROBLEM, extend DISCOVERY with sensory details

**For different durations:**
- **15 seconds:** CURIOSITY (2s) → DISCOVERY (8s) → CTA (5s). Skip PROBLEM and VALIDATION.
- **30 seconds:** Full structure, compressed. One sentence per beat.
- **45-60 seconds:** Full structure with room for details. Add second VALIDATION beat or DEMO segment.

## Bloom-Specific Adaptations

These templates work for Bloom ads by replacing generic placeholders:

| Beat | Bloom-Specific Content |
|------|----------------------|
| PROBLEM | "Hours on Yahoo Finance, Reddit, Seeking Alpha. By the time I had a thesis, the stock already moved." |
| DISCOVERY | "Search any ticker. Full AI breakdown in 30 seconds: analyst ratings, insider trades, earnings, bull/bear case." |
| VALIDATION | "4.8 stars. 52,000 investors. The AI shows you WHERE it got the information." |
| CTA | "Free to download. Link in bio." |
| DEMO | Screen recording of Bloom: search NVDA → AI analysis → insider trades → earnings |
