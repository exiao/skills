---
name: d3js-visualization
description: Use when creating interactive D3.js data visualizations.
---
# D3.js Visualisation

## Purpose

Create custom, interactive, publication-quality data visualisations using D3.js (Data-Driven Documents). D3 binds data to DOM elements and applies data-driven transformations with precise control over every visual element. Works across vanilla JS, React, Vue, Svelte, and other frameworks.

## When to Use

**D3.js is the right choice for:**
- Custom chart types not available in standard libraries
- Interactive explorations: complex pan, zoom, brush behaviours
- Network/graph visualisations (force-directed, tree diagrams, chord)
- Geographic visualisations with custom projections
- Smooth, choreographed transitions and animations
- Fine-grained styling control (publication-quality output)

**Use alternatives instead for:**
- 3D visualisations → use Three.js
- Simple standard charts where Chart.js or Recharts suffice

## Core Workflow

### 1. Import D3
```javascript
import * as d3 from 'd3';
// Or CDN: <script src="https://d3js.org/d3.v7.min.js"></script>
```

### 2. Choose Integration Pattern

**Pattern A — Direct DOM (recommended for most cases):**
```javascript
function drawChart(data) {
  if (!data || data.length === 0) return;
  const svg = d3.select('#chart');
  svg.selectAll("*").remove(); // clear on redraw

  const width = 800, height = 400;
  const margin = { top: 20, right: 30, bottom: 40, left: 50 };
  const innerWidth = width - margin.left - margin.right;
  const innerHeight = height - margin.top - margin.bottom;

  const g = svg.append("g").attr("transform", `translate(${margin.left},${margin.top})`);
  // scales, axes, elements…
}
```

**Pattern B — Declarative (for framework templating):** Use D3 for data calculations (scales, layouts) and let the framework render elements. Best for simple charts tightly integrated with React/Vue state.

### 3. Standard Drawing Structure
1. Validate data (filter nulls/NaN)
2. Define dimensions & margins
3. Create main `<g>` group with margin transform
4. Build scales (`d3.scaleLinear`, `d3.scaleTime`, etc.)
5. Append axes via `.call(d3.axisBottom(scale))`
6. Bind data with `.data(data).join("element")`
7. Set attributes using scale functions

### 4. Responsive Sizing
Use `getBoundingClientRect()` on the container + `window.addEventListener('resize', ...)`, or a `ResizeObserver` for direct container monitoring. Redraw the entire chart on size change.

## Key Rules & Best Practices

### Data Preparation
- Always filter: `data.filter(d => d.value != null && !isNaN(d.value))`
- Parse dates before binding: `d3.timeParse("%Y-%m-%d")(d.date)`
- Don't mutate source data; map to new arrays

### Performance (large datasets >1000 elements)
- Prefer `<canvas>` over SVG for many elements
- Use `d3.quadtree` for collision detection
- Batch DOM updates; use `requestAnimationFrame` for custom animations

### Accessibility
```javascript
svg.attr("role", "img").attr("aria-label", "Chart description");
svg.append("title").text("Chart Title");
svg.append("desc").text("Longer description for screen readers");
```

### Styling
- Define a colour palette object upfront
- Apply consistent font family via `svg.selectAll("text").style("font-family", "...")`
- Use subtle dashed grid lines: `.attr("stroke-dasharray", "2,2")`

## Output Format

A self-contained JS function (or module) that:
- Accepts a data array and a selector/SVG element
- Clears and redraws on each call
- Handles empty/null data gracefully
- Is responsive (redraws on container resize)
- Includes ARIA attributes for accessibility

---

## References

This skill content is modularized into reference docs for readability.

- [Overview](references/overview.md)
- [When to use d3.js](references/when-to-use-d3-js.md)
- [Core workflow](references/core-workflow.md)
- [Common visualisation patterns](references/common-visualisation-patterns.md)
- [Adding interactivity](references/adding-interactivity.md)
- [Transitions and animations](references/transitions-and-animations.md)
- [Scales reference](references/scales-reference.md)
- [Best practices](references/best-practices.md)
- [Common issues and solutions](references/common-issues-and-solutions.md)
- [Resources](references/resources.md)
