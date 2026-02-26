# Mobile Touch Animation Principles

iOS/Android gesture, haptic, and touch animation reference. Disney's 12 principles applied to mobile.

## Touch Timing

| Action | Duration | Notes |
|--------|----------|-------|
| Touch acknowledgment | <100ms | Immediate feedback required |
| Quick actions | 150-250ms | Button presses, toggles |
| View transitions | 250-350ms | Push, present, dismiss |
| Complex animations | 350-500ms | Multi-element choreography |

Target: 60fps minimum, 120fps on ProMotion displays.

## iOS Spring Physics

```swift
// Standard spring with follow-through
UIView.animate(withDuration: 0.5,
  delay: 0,
  usingSpringWithDamping: 0.7,      // Lower = more bounce
  initialSpringVelocity: 0.5,
  options: .curveEaseOut)

// Haptic pairing
let feedback = UIImpactFeedbackGenerator(style: .medium)
feedback.impactOccurred()
```

## Android Spring Physics

```kotlin
SpringAnimation(view, DynamicAnimation.TRANSLATION_Y)
  .setSpring(SpringForce()
    .setStiffness(SpringForce.STIFFNESS_MEDIUM)
    .setDampingRatio(SpringForce.DAMPING_RATIO_MEDIUM_BOUNCY))
  .start()
```

## Haptic Guidelines

| Action | iOS | Android |
|--------|-----|---------|
| Selection | `.selection` | `EFFECT_TICK` |
| Success | `.success` | `EFFECT_CLICK` |
| Warning | `.warning` | `EFFECT_DOUBLE_CLICK` |
| Error | `.error` | `EFFECT_HEAVY_CLICK` |

Haptics are secondary action: always pair with visual confirmation. Sync precisely with visual.

## Principle Applications

**Squash & Stretch:** Rubber-band at scroll boundaries. Pull-to-refresh stretches content. Buttons compress on touch (scaleY: 0.95).

**Anticipation:** Long-press shows preview before action. Drag threshold provides visual hint before item lifts. Swipe shows edge of destination.

**Follow Through:** Content continues after finger lifts (momentum). Navigation bar animates slightly after main content. List items settle with stagger.

**Slow In / Slow Out:** iOS uses spring physics (mass, stiffness, damping). Android uses FastOutSlowIn. Never linear for user-initiated motion.

**Arc:** Thrown cards follow parabolic arcs. Swipe-to-dismiss curves based on velocity. FAB expand follows natural arc.

**Staging:** Sheet presentations maintain context. Dim and scale background during modal. Hero transitions connect views.

## Key Rules

- Gesture-driven animation must feel connected to finger
- All animations must be interruptible
- Respect device safe areas during animation
- Account for notch/Dynamic Island in motion paths
- Never use linear easing for user-initiated motion
