# Proportional Scaling & Dynamic Color Systems

Two mathematical systems for producing visually harmonious interfaces without manual tuning. Use these when building design systems, component libraries, or any frontend where spacing/typography/color should feel "designed" rather than arbitrary.

Inspired by LiftKit's approach ([github.com/Chainlift/liftkit](https://github.com/Chainlift/liftkit)) and Material Design 3's dynamic color system.

---

## 1. Ratio-Based Proportional Scaling

Instead of picking arbitrary spacing/font values (12px, 16px, 24px, 32px...), derive every size from a single scale factor using exponential steps. The result: every measurement in the system is mathematically related, producing the kind of visual harmony you'd normally need a trained designer to achieve.

### The Core Formula

```
size(n) = base * scaleFactor^n
```

Where `n` is the step index (negative for smaller, positive for larger) and `base` is typically `1rem`.

### Choosing a Scale Factor

| Factor | Name | Character |
|--------|------|-----------|
| 1.250 | Major Third | Tight, compact UIs. Good for data-dense dashboards. |
| 1.333 | Perfect Fourth | Balanced. Works for most web apps. |
| 1.414 | Augmented Fourth | Slightly dramatic. Good contrast between heading levels. |
| 1.500 | Perfect Fifth | Strong hierarchy. Magazine/editorial layouts. |
| 1.618 | Golden Ratio | Maximum natural harmony. Spacious, elegant. Best for marketing/landing pages. |

### Sub-Steps for Fine Control

A single scale factor gives you whole steps. For finer control, use fractional exponents:

```
whole step    = scaleFactor^1.0    (e.g., 1.618)
half step     = scaleFactor^0.5    (e.g., 1.272)
quarter step  = scaleFactor^0.25   (e.g., 1.128)
eighth step   = scaleFactor^0.125  (e.g., 1.062)
```

This gives you 4x the precision while maintaining mathematical coherence. Every value still belongs to the same proportional family.

### CSS Implementation

```css
:root {
  --scale: 1.618;

  /* Step intervals */
  --step-whole: var(--scale);
  --step-half: calc(pow(var(--scale), 0.5));       /* sqrt */
  --step-quarter: calc(pow(var(--scale), 0.25));
  --step-eighth: calc(pow(var(--scale), 0.125));

  /* Size scale (spacing, padding, gaps) */
  --size-3xs: calc(1rem * pow(var(--scale), -3));   /* ~0.236rem */
  --size-2xs: calc(1rem * pow(var(--scale), -2));    /* ~0.382rem */
  --size-xs:  calc(1rem * pow(var(--scale), -1));    /* ~0.618rem */
  --size-sm:  calc(1rem / var(--scale));             /* ~0.618rem */
  --size-md:  1rem;                                   /* 1rem */
  --size-lg:  calc(1rem * var(--scale));             /* ~1.618rem */
  --size-xl:  calc(1rem * pow(var(--scale), 2));     /* ~2.618rem */
  --size-2xl: calc(1rem * pow(var(--scale), 3));     /* ~4.236rem */
  --size-3xl: calc(1rem * pow(var(--scale), 4));     /* ~6.854rem */
  --size-4xl: calc(1rem * pow(var(--scale), 5));     /* ~11.09rem */
}
```

### Typography Scale

Font sizes, line heights, and optical offsets all derive from the same factor:

```css
:root {
  /* Font sizes */
  --font-display1: calc(1rem * pow(var(--scale), 3));    /* ~4.24rem */
  --font-display2: calc(1rem * pow(var(--scale), 2));    /* ~2.62rem */
  --font-title1:   calc(1rem * var(--scale) * pow(var(--scale), 0.5)); /* ~2.06rem */
  --font-title2:   calc(1rem * var(--scale));             /* ~1.62rem */
  --font-title3:   calc(1rem * pow(var(--scale), 0.5));  /* ~1.27rem */
  --font-heading:  calc(1rem * pow(var(--scale), 0.25)); /* ~1.13rem */
  --font-body:     1rem;
  --font-caption:  calc(1rem / pow(var(--scale), 0.5));  /* ~0.79rem */
  --font-label:    calc(1rem / pow(var(--scale), 0.75)); /* ~0.70rem */

  /* Line heights (unitless, based on scale intervals) */
  --lh-display:  calc(pow(var(--scale), 0.25));  /* ~1.13 - tight for large text */
  --lh-title:    calc(pow(var(--scale), 0.5));   /* ~1.27 */
  --lh-body:     var(--scale);                    /* ~1.62 - generous for readability */
  --lh-caption:  calc(pow(var(--scale), 0.5));   /* ~1.27 */
}
```

### Optical Correction: Top Padding Offsets

Text inside containers looks vertically off-center even with equal padding because of how fonts render ascenders/descenders. The fix: compute an optical offset per font class.

```css
/* Offset = fontSize * (lineHeight / scaleFactor) */
--offset-display1: calc(var(--font-display1) * (var(--lh-display) / var(--scale)));
--offset-body:     calc(var(--font-body) / var(--scale));
```

Use these as `padding-top` adjustments on containers where text is the first child. This corrects the optical imbalance without eyeballing pixel values.

### Tailwind Integration

If using Tailwind, map the scale to the config:

```js
// tailwind.config.js
const scale = 1.618;
const step = (n) => `${Math.round(16 * Math.pow(scale, n) * 1000) / 1000}px`;

module.exports = {
  theme: {
    spacing: {
      '3xs': step(-3),  // ~3.8px
      '2xs': step(-2),  // ~6.1px
      'xs':  step(-1),  // ~9.9px
      'sm':  step(-0.5), // ~12.6px
      'md':  '1rem',     // 16px
      'lg':  step(1),   // ~25.9px
      'xl':  step(2),   // ~41.9px
      '2xl': step(3),   // ~67.8px
      '3xl': step(4),   // ~109.7px
    },
    fontSize: {
      'caption': step(-0.5),
      'body':    '1rem',
      'heading': step(0.25),
      'title3':  step(0.5),
      'title2':  step(1),
      'title1':  step(1.5),
      'display': step(2),
    }
  }
}
```

### When to Use Which Scale Factor

- **Dashboard/data app** (high density): 1.250 or 1.333
- **SaaS product** (balanced): 1.333 or 1.414
- **Marketing site** (editorial feel): 1.500 or 1.618
- **Portfolio/luxury** (maximum space): 1.618

You can also mix: use 1.333 for spacing and 1.5 for font sizes to get tight layouts with dramatic type hierarchy.

---

## 2. Dynamic Color from a Single Seed

Generate a complete, harmonious color system (light mode, dark mode, semantic colors, surface hierarchy) from one hex value. Based on Material Design 3's HCT (Hue, Chroma, Tone) color space.

### The Concept

One seed color produces:
- **Primary** palette (the seed color adjusted for accessibility)
- **Secondary** palette (desaturated version of primary)
- **Tertiary** palette (complementary hue shift)
- **Neutral** palette (for surfaces and backgrounds)
- **Error/Warning/Success/Info** semantic palettes

Each palette generates tonal variants at specific lightness levels for both light and dark modes, with guaranteed contrast ratios.

### Color Role Hierarchy

```
Surface layers (5 levels of elevation):
  surfaceContainerLowest  → surfaceContainerLow → surfaceContainer
  → surfaceContainerHigh → surfaceContainerHighest

On-surface text:
  onSurface (high emphasis) → onSurfaceVariant (medium) → outline (low)

Accent colors:
  primary / onPrimary           (buttons, active states)
  primaryContainer / onPrimaryContainer  (tinted backgrounds)
  secondary / onSecondary       (less prominent actions)
  tertiary / onTertiary         (accent/highlight)

Semantic:
  error / onError / errorContainer / onErrorContainer
  (same pattern for warning, success, info)
```

### JavaScript Implementation

Using `@material/material-color-utilities`:

```js
import { argbFromHex, themeFromSourceColor, hexFromArgb } from '@material/material-color-utilities';

function generatePalette(seedHex) {
  const theme = themeFromSourceColor(argbFromHex(seedHex));

  // theme.schemes.light and theme.schemes.dark contain all color roles
  const light = {};
  const dark = {};

  for (const [key, value] of Object.entries(theme.schemes.light.toJSON())) {
    light[key] = hexFromArgb(value);
  }
  for (const [key, value] of Object.entries(theme.schemes.dark.toJSON())) {
    dark[key] = hexFromArgb(value);
  }

  return { light, dark };
}

// Usage: generatePalette('#0051e0') returns ~30 color tokens per mode
```

### CSS Variable Output

The generator should produce variables in this pattern:

```css
:root {
  /* Light mode (default) */
  --color-primary: #0051e0;
  --color-on-primary: #ffffff;
  --color-primary-container: #dbe1ff;
  --color-on-primary-container: #00174d;
  --color-surface: #faf8ff;
  --color-on-surface: #171b27;
  --color-surface-container: #ebedfe;
  --color-surface-container-high: #e5e7f8;
  --color-outline: #777777;
  --color-error: #bb0e45;
  /* ... etc */
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-primary: #b5c4ff;
    --color-on-primary: #00297a;
    --color-surface: #222531;
    --color-on-surface: #c3c6d6;
    /* ... etc */
  }
}
```

### The "On" Color Rule

Every background color has a matching "on" color for text/icons placed on top of it. This guarantees WCAG contrast:

| Background | Text color |
|-----------|------------|
| `primary` | `onPrimary` |
| `primaryContainer` | `onPrimaryContainer` |
| `surface` | `onSurface` |
| `surfaceContainer*` | `onSurface` |
| `error` | `onError` |
| `inverseSurface` | `inverseOnSurface` |

Never pair colors outside this mapping. If you use `primary` as a background, text must be `onPrimary`.

### Surface Elevation via Color (Not Shadow)

Material 3 replaces shadow-based elevation with tinted surfaces. Higher elevation = slightly more tinted:

```
Level 0: surfaceContainerLowest  (deepest background)
Level 1: surfaceContainerLow     (cards at rest)
Level 2: surfaceContainer        (default card)
Level 3: surfaceContainerHigh    (raised card, hover)
Level 4: surfaceContainerHighest (modal, dialog)
```

This works in both light and dark mode. In dark mode especially, tinted elevation reads much better than dark-on-darker shadows.

### Custom Semantic Colors

To add colors beyond the default primary/secondary/tertiary:

```js
import { customColor, argbFromHex } from '@material/material-color-utilities';

const warningColor = customColor(argbFromHex('#7d5800'));
// Returns tonal palette you can extract light/dark variants from
```

### Practical Tips

1. **Pick your seed from brand guidelines.** The algorithm handles the rest. Don't manually override individual tokens unless you have a specific reason.
2. **Test with both modes.** The algorithm optimizes contrast for both, but edge cases exist with very low-chroma seeds.
3. **Surface containers replace card shadows.** Use `surfaceContainerHigh` for elevated cards instead of `box-shadow`. Add subtle shadows only for floating elements (dropdowns, modals).
4. **Neutral palette drives 80% of the UI.** Most of your interface is surface/onSurface. The accent colors (primary, secondary, tertiary) should be used sparingly for interactive elements and emphasis.

---

## 3. Combining Both Systems

The scaling system handles **size and space**. The color system handles **hue and contrast**. Together they cover the two hardest parts of visual design to get right without a designer.

Example: a card component using both:

```css
.card {
  padding: var(--size-lg);                          /* ratio-scaled */
  border-radius: var(--size-sm);                    /* ratio-scaled */
  background: var(--color-surface-container);        /* dynamic color */
  color: var(--color-on-surface);                   /* guaranteed contrast */
  gap: var(--size-md);                              /* ratio-scaled */
}

.card-title {
  font-size: var(--font-title3);                    /* ratio-scaled */
  line-height: var(--lh-title);                     /* ratio-scaled */
  color: var(--color-on-surface);
}

.card-action {
  font-size: var(--font-body);
  padding: var(--size-xs) var(--size-md);            /* ratio-scaled */
  background: var(--color-primary);                  /* dynamic color */
  color: var(--color-on-primary);                   /* guaranteed contrast */
  border-radius: calc(var(--size-xl) * 10);          /* pill shape */
}
```

Every value is derived. Nothing is arbitrary. The UI will look proportionally balanced and color-accessible by construction.
