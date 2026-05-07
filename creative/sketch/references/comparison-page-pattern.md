# Comparison Page Pattern

When comparing multiple design options (e.g., onboarding flows, layout variants, feature approaches), go beyond just placing mockups side by side. Build a structured comparison artifact that helps stakeholders decide.

## Key Components

### 1. Sticky Navigation
Jump-to-section nav at top. Highlight active section on scroll via IntersectionObserver. Include scorecard, each option, and summary as nav targets.

### 2. Comparison Scorecard Table
Place near the top, before the detailed mockups. Matrix format:
- **Rows**: Key evaluation criteria (steps to value, personalization depth, aha moment timing, paywall placement, cognitive load, social proof, etc.)
- **Columns**: Each option
- **Ratings**: Color-coded dots (green/yellow/red) or descriptive labels. Highlight the recommended column with a subtle background tint.

This lets stakeholders form an opinion before diving into details.

### 3. Horizontal Scroll Rows with Phone Mockups
Each option gets a row of phone-frame mockups. Key UX:
- Scroll arrows (left/right) that appear on hover, auto-hide at boundaries
- "Scroll for more" indicator when screens overflow
- Step labels above each phone (e.g., "1. WELCOME", "2. PERSONALIZE")
- Arrow connectors between screens to show flow

### 4. Click-to-Enlarge Modal
Clicking any phone mockup opens it at 1.5x in a modal with:
- Backdrop blur
- Option name + screen label in modal header
- Close on click-outside or Escape

### 5. Annotation Badges
Small colored callout badges on specific screens to highlight key design decisions:
- **Green**: Positive patterns ("Immediate value demo", "Aha moment!", "Personalized to user's picks")
- **Orange/Warning**: Issues ("Feature dump", "Generic, not personalized")
- **Blue/Info**: Structural notes ("2 steps combined into 1")

Position below the phone frame, never inside it.

### 6. Recommendation Summary
Section at the bottom with:
- Clear winner callout with rationale
- "Why X Wins" box listing concrete advantages
- "What to Watch" box with risks and test suggestions
- Tradeoff comparisons referencing specific options

## Visual Treatment
- Dark background (gradient, not flat black) to make white phone mockups pop
- Section dividers with thin lines and emoji icons
- Phone hover lift effect (subtle translateY + shadow increase)
- "Recommended" ribbon/badge with glow on the winning option
- Teal/brand-color accent on CTAs and highlights

## Phone Mockup Structure (HTML)
```html
<div class="phone" style="width:280px;height:560px;border-radius:32px;border:4px solid #333;">
  <div class="notch"><!-- iOS-style notch --></div>
  <div class="status-bar">9:41</div>
  <div class="screen">
    <!-- Actual UI content here -->
  </div>
</div>
```

## Deployment
Single self-contained HTML file (inline CSS + JS). Deploy to Surge:
```bash
# Always create both index.html and 200.html for Surge SPA support
cp index.html 200.html
npx surge . <project-name>.surge.sh
```

## When to Use This vs Plain Sketch Variants
- **Plain sketch**: Exploring visual directions for a single screen (layout, density, aesthetic)
- **Comparison page**: Comparing complete multi-step flows or feature approaches where stakeholders need structured criteria to decide
