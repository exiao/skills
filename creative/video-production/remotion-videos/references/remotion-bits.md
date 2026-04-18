# Remotion Bits — Component Kit

Open-source animation component library for Remotion. Pre-built, production-ready building blocks.

**Install:** `npm install remotion-bits` (requires React 18+, Remotion 4.0+)

**Or copy individual components:**
```bash
npx jsrepo init https://unpkg.com/remotion-bits/registry.json
npx jsrepo add animated-text
npx jsrepo add gradient-transition
```

**Docs:** https://remotion-bits.dev

## Components

### AnimatedText
Animate text character-by-character, word-by-word, or by line with configurable staggering and easing.

```tsx
import { AnimatedText } from 'remotion-bits';

<AnimatedText
  transition={{
    split: 'word',        // 'character' | 'word' | 'line'
    opacity: [0, 1],
    y: [50, 0],
    blur: [10, 0],        // Optional blur effect
    rotate: [45, 0],      // Optional rotation
    stagger: 3,           // Frames between each unit
    duration: 30,
    easing: 'easeOutQuad'
  }}
  style={{ fontSize: '4rem', color: 'white', fontWeight: 'bold' }}
>
  Hello Remotion Bits!
</AnimatedText>
```

### StaggeredMotion
Coordinated animations across multiple child elements with directional timing.

### GradientTransition
Smooth interpolation between CSS gradients (linear, radial, conic).

### ParticleSystem
Physics-based particle engine. Configurable gravity, drag, wiggle. Pre-built: snow, fountain, confetti, grid, fireflies.

### Scene3D
3D scenes with camera controls, sequential step animations, and 3D element transforms. Ken Burns effect, cube navigation, flying text.

### Typewriter
Typing animation with cursor. Supports multi-text sequences, variable speed, typo simulation, CLI simulation.

### CodeBlock
Syntax-highlighted code with line-by-line reveal or typing effect.

### Counter
Animated number interpolation with optional confetti burst.

## Catalog of Pre-Built Bits

### Text Animations
- Fade In, Blur In, Slide from Left
- Word by Word, Character by Character
- Glitch In, Glitch Cycle (random character transition)
- Staggered Fade In

### Motion
- Grid Stagger (scale + opacity from center)
- List Reveal (vertical items scaling into place)
- 3D Card Stack
- Easings Visualizer

### Backgrounds
- Linear/Radial/Conic gradient transitions
- Matrix Rain

### Particles
- Snow, Fountain, Grid Particles, Fireflies
- Counter Confetti

### 3D
- Basic 3D Scene (impress.js style camera steps)
- Flying Through Words
- Scrolling Columns (parallax panning)
- Cube Navigation
- 3D Carousel, 3D Terminal
- Ken Burns Effect (slow camera pan over images)
- Transform3D Showcase (chainable matrix transforms, quaternion rotations)

### Code/Terminal
- Basic Code Block (line-by-line reveal)
- Typing Code Block
- CLI Simulation (user typing + system output)
- Cursor Flyover (camera flies over screenshot, cursor highlights areas)

### Interactive
- Basic Typewriter, Multi-Text Typewriter
- Variable Speed & Typos typewriter

## Utility Functions

```tsx
import { interpolate } from 'remotion-bits';

// Interpolate with named easing functions
const scale = interpolate(frame, 0, 60, 0.5, 1.5, {
  easing: 'easeOutBounce'
});
```

## When to Use

Use remotion-bits instead of raw Remotion `interpolate()` when you need:
- Text reveal animations (word-by-word, character-by-character, blur-in)
- Particle effects (confetti, snow, fireflies)
- Gradient transitions between scenes
- 3D camera movements or element transforms
- Typewriter/terminal typing effects
- Code block animations with syntax highlighting

The components handle all the interpolation math, staggering, and easing internally. You just declare what you want.
