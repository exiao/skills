# Inline SVG Diagrams for Web Pages

When embedding technical diagrams (architecture, flowcharts, pipelines) in a web page, prefer inline SVG over Excalidraw screenshots or third-party images. Inline SVG matches the page aesthetic, scales perfectly, and avoids image loading issues.

## When to use
- Architecture diagrams embedded in a landing page or report
- Flowcharts showing pipelines, eval loops, decision trees
- Any diagram where the visual style should match surrounding CSS (fonts, colors, borders)

## Template structure

```html
<div class="diagram-container reveal">
  <svg class="diagram-svg" viewBox="0 0 800 500" fill="none" xmlns="http://www.w3.org/2000/svg">
    <!-- Use the page's own font families in font-family attributes -->
    
    <!-- Boxes with bound text -->
    <rect x="40" y="10" width="180" height="50" rx="8" fill="#f5f3ed" stroke="#ddd9d0" stroke-width="1.5"/>
    <text x="130" y="42" text-anchor="middle" font-size="14" font-weight="600" fill="#1a1a1a" font-family="DM Sans, sans-serif">Label</text>

    <!-- Connecting arrows (line + polygon arrowhead) -->
    <line x1="130" y1="60" x2="130" y2="90" stroke="#ddd9d0" stroke-width="1.5"/>
    <polygon points="125,87 135,87 130,95" fill="#ddd9d0"/>

    <!-- Dashed containers for grouping -->
    <rect x="20" y="100" width="760" height="200" rx="10" fill="#fafaf7" stroke="#ddd9d0" stroke-width="1" stroke-dasharray="6,4"/>

    <!-- Decision diamonds -->
    <polygon points="400,300 460,340 400,380 340,340" fill="#fafaf7" stroke="#ddd9d0" stroke-width="1.5"/>

    <!-- Retry/feedback loops — route OUTSIDE all content boxes -->
    <path d="M100 380 L100 440 Q100 455 115 455 L700 455 Q715 455 715 440 L715 30 Q715 15 700 15 L300 15" 
          stroke="#c5221f" stroke-width="1.5" fill="none" stroke-dasharray="6,4"/>
  </svg>
</div>
```

## Key pitfalls
- **Retry loop paths cutting through content**: Always widen the viewBox so the loop routes outside all boxes. Go down, far right (past all content), up, then back left.
- **Font rendering**: Always specify `font-family` on every `<text>` element. SVG doesn't inherit from page CSS.
- **Text alignment**: Use `text-anchor="middle"` with x at the center of the containing rect.
- **Responsive**: Set `width: 100%; height: auto; max-width: 800px` in CSS. Wrap in `overflow-x: auto` for mobile with `min-width` on the SVG.
- **Color consistency**: Use hex values matching the page, not CSS variables (SVG can't resolve them).
- **Decorative inconsistency**: Don't add decorative elements (bars, icons) to only some boxes in a grid. All or none.

## Sizing guidelines
- Box heights: 48-60px simple labels, 130-140px for 4-5 line detail boxes
- Arrow gaps: 20-30px between boxes
- Font sizes: 13-14px headings, 10-11px detail, 9px labels
- Decision diamonds: ~70px wide x 70px tall
