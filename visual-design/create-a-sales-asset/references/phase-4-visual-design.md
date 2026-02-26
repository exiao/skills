# Phase 4: Visual Design

### Color System

```css
:root {
    /* Prospect Brand (extracted from research) */
    --brand-primary: #[extracted];
    --brand-secondary: #[extracted];
    --brand-primary-rgb: [r, g, b];

    /* Dark Theme Base */
    --bg-primary: #0a0d14;
    --bg-elevated: #0f131c;
    --bg-surface: #161b28;
    --bg-hover: #1e2536;

    /* Text */
    --text-primary: #ffffff;
    --text-secondary: rgba(255, 255, 255, 0.7);
    --text-muted: rgba(255, 255, 255, 0.5);

    /* Accent (prospect brand) */
    --accent: var(--brand-primary);
    --accent-hover: var(--brand-secondary);
    --accent-glow: rgba(var(--brand-primary-rgb), 0.3);

    /* Status */
    --success: #10b981;
    --warning: #f59e0b;
    --error: #ef4444;
}
```

### Brand Color Fallbacks

If brand colors can't be extracted:

| Industry | Primary | Secondary |
|----------|---------|-----------|
| Technology | #2563eb | #7c3aed |
| Finance | #0f172a | #3b82f6 |
| Healthcare | #0891b2 | #06b6d4 |
| Manufacturing | #ea580c | #f97316 |
| Retail | #db2777 | #ec4899 |
| Default | #3b82f6 | #8b5cf6 |

### Typography

```css
font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
h1: 2.5rem / 700;  h2: 1.75rem / 600;  h3: 1.25rem / 600;
body: 1rem / 400, line-height 1.6;  small: 0.875rem / 500;
```

### Component Styling

**Cards:** bg-surface, 1px border rgba(255,255,255,0.1), 12px radius, subtle shadow, hover elevation.

**Buttons:** primary = accent bg + white text, secondary = transparent + accent border.

**Animations:** 200-300ms ease transitions, smooth tab switches, subtle hover states.

**Workflow nodes:**
- Default: bg-surface, 2px brand-primary border, 12px radius
- Active: accent-glow box-shadow
- Human nodes: warm border (#f59e0b)
- AI nodes: gradient bg, accent border
- Flow arrows: dashed animation when active

---
