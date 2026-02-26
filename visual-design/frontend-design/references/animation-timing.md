# Animation Timing Reference

Micro-interaction and page transition timing for web UI. Based on Disney's 12 principles.

## Micro-Interaction Timing

| Interaction | Duration | Easing |
|-------------|----------|--------|
| Hover | 100ms | ease-out |
| Click/tap | 100ms | ease-out |
| Toggle | 150-200ms | spring/elastic |
| Checkbox | 150ms | ease-out |
| Focus ring | 100ms | ease-out |
| Tooltip show | 150ms | ease-out |
| Tooltip hide | 100ms | ease-in |
| Badge update | 200ms | elastic |
| Form error | 200ms | ease-out |

## Page Transition Timing

| Transition | Duration | Exit | Enter |
|-----------|----------|------|-------|
| Crossfade | 200-300ms | ease-in | ease-out |
| Slide forward | 300-400ms | ease-in | ease-out |
| Slide back | 250-350ms | ease-in | ease-out |
| Modal open | 250-350ms | — | ease-out |
| Modal close | 200-300ms | ease-in | — |
| Shared element | 300-400ms | n/a | ease-in-out |
| Tab switch | 150-200ms | instant | ease-out |

## Duration Scale

| Category | Duration | Use Case |
|----------|----------|----------|
| Micro | 100-200ms | Tooltips, hovers, icon states |
| Small | 200-300ms | Modals, card expansions, nav transitions |
| Medium | 300-500ms | Page transitions, complex reveals |
| Large | 500-800ms | Hero transitions, storytelling reveals |
| Deliberate | 1200-2000ms | App intros, loading sequences |
| Dramatic | 2000ms+ | Cinematic intros, premium experiences |

## Component Patterns

### Button States
```css
.button {
  transition: transform 100ms ease-out, box-shadow 100ms ease-out;
}
.button:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0,0,0,0.15);
}
.button:active {
  transform: translateY(0) scale(0.98);
  box-shadow: 0 1px 2px rgba(0,0,0,0.1);
}
```

### Toggle Switch
```css
.toggle-thumb {
  transition: transform 200ms cubic-bezier(0.34, 1.56, 0.64, 1);
}
```

### Checkbox (SVG stroke draw)
```css
.checkmark {
  stroke-dasharray: 20;
  stroke-dashoffset: 20;
  transition: stroke-dashoffset 200ms ease-out 50ms;
}
.checkbox:checked + .checkmark {
  stroke-dashoffset: 0;
}
```

### Page Crossfade
```css
.page-exit-active { opacity: 0; transition: opacity 200ms ease-in; }
.page-enter { opacity: 0; }
.page-enter-active { opacity: 1; transition: opacity 200ms ease-out; }
```

### Page Slide (Hierarchical)
```css
/* Forward */
.page-enter { transform: translateX(100%); }
.page-enter-active { transform: translateX(0); transition: transform 300ms ease-out; }
.page-exit-active { transform: translateX(-30%); transition: transform 300ms ease-in; }

/* Back: reversed */
.page-enter { transform: translateX(-30%); }
.page-exit-active { transform: translateX(100%); }
```

### Shared Element (View Transitions API)
```js
document.startViewTransition(() => updateDOM());
```
```css
.hero { view-transition-name: hero; }
::view-transition-old(hero),
::view-transition-new(hero) { animation-duration: 300ms; }
```

### Scroll Reveal
```css
.reveal { opacity: 0; transform: translateY(30px); transition: opacity 500ms ease-out, transform 600ms ease-out; }
.reveal.visible { opacity: 1; transform: translateY(0); }
```
```js
new IntersectionObserver(entries => {
  entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
}, { threshold: 0.2 });
```

## Navigation Spatial Model

| Pattern | Transition | Direction |
|---------|-----------|-----------|
| Drill-down (list→detail) | Slide left / shared element | Right = forward |
| Tab bar | Fade / slide | Horizontal |
| Bottom sheet | Slide up | Vertical |
| Modal | Scale + fade | Z-axis |
| Back button | Reverse of forward | Left = back |

## Exaggeration Scale

| Context | Scale | Rotation | Notes |
|---------|-------|----------|-------|
| Micro (buttons) | 0.95-1.05 | — | Subtle, felt not seen |
| Error shake | 3-5px | — | Not 20px |
| Success | 1.05-1.1 | — | Not 1.5 |
| Bouncy overshoot | 110-120% | — | Settle quickly |
| Dramatic (onboarding) | up to 150% | up to 720° | Rare, intentional |

## Performance Rules

- Only animate `transform` and `opacity` (GPU-accelerated, skip layout/paint)
- Use `will-change` sparingly (hints to browser)
- Keep simultaneous animations under 3-4
- Stagger start times by 50-100ms to reduce concurrent calculations
- Pause off-screen animations (Intersection Observer)
- Always respect `prefers-reduced-motion`
- Test with CPU throttling on lowest-spec target device
