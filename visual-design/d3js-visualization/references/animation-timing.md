# D3.js Animation Timing Reference

Disney's 12 principles applied to data visualization. Timing, easing, and patterns for charts and dashboards.

## Timing by Chart Type

| Visualization | Entry | Update | Hover |
|--------------|-------|--------|-------|
| Bar chart | 400ms stagger | 300ms | 100ms |
| Line chart | 600ms draw | 400ms | 150ms |
| Pie chart | 500ms sweep | 300ms | 100ms |
| Scatter plot | 300ms stagger | 200ms | 100ms |
| Dashboard | 500-800ms cascade | 300ms | 150ms |
| Filter transition | 400-600ms | — | — |

## D3 Patterns

### Staggered Bar Entry
```js
bars.transition()
  .duration(500)
  .delay((d, i) => i * 50)
  .ease(d3.easeCubicOut)
  .attr("height", d => yScale(d.value))
  .attr("y", d => height - yScale(d.value));
```

### Smooth Data Updates
```js
bars.transition()
  .duration(300)
  .ease(d3.easeCubicInOut)
  .attr("height", d => yScale(d.value));
```

### Pie Chart Sweep
```js
arcs.transition()
  .duration(500)
  .attrTween("d", function(d) {
    const i = d3.interpolate({ startAngle: 0, endAngle: 0 }, d);
    return t => arc(i(t));
  });
```

### Line Chart Draw
```js
path.attr("stroke-dasharray", totalLength)
  .attr("stroke-dashoffset", totalLength)
  .transition()
  .duration(600)
  .ease(d3.easeLinear)
  .attr("stroke-dashoffset", 0);
```

## Principle Applications

**Squash & Stretch:** Bars overshoot target height then settle. Pie slices expand slightly on hover. Keep total values accurate; animation is transitional only.

**Anticipation:** Brief loading state before data appears. Counter pauses before rapid counting.

**Staging:** Reveal in meaningful sequence: most important data first. Highlight active series, dim unrelated elements.

**Follow Through:** Data points enter staggered. Labels settle after their elements. Grid lines appear before data. Legends animate with slight delay.

**Slow In / Slow Out:** Use `d3.easeCubicInOut` for value changes. No jarring jumps. Counters accelerate then decelerate. Progress bars ease to completion.

**Arc:** Pie charts sweep clockwise from 12 o'clock. Sankey flows follow curved paths. Network graphs use force-directed arcs. Radial charts expand from center.

**Secondary Action:** Tooltips follow data point movement. Value labels count up as bars grow. Axis ticks respond to scale changes.

**Exaggeration:** Pulse or glow outliers. Threshold crossings trigger emphasis. Anomalies animate more dramatically. Never exaggerate the data itself.

## Recommended Easings

| Context | D3 Easing | Notes |
|---------|-----------|-------|
| Entry (bars, points) | `d3.easeCubicOut` | Fast start, gentle landing |
| Updates | `d3.easeCubicInOut` | Smooth between states |
| Exit | `d3.easeCubicIn` | Accelerate away |
| Bounce (emphasis) | `d3.easeElasticOut` | Overshoot and settle |
| Draw (lines) | `d3.easeLinear` | Constant speed draw |

## Accessibility

Always respect `prefers-reduced-motion`. Provide instant-state fallback. Data viz animation should aid comprehension, not hinder it.
