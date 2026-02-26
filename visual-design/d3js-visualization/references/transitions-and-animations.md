# Transitions and animations

Add smooth transitions to visual changes:

```javascript
// Basic transition
circles
  .transition()
  .duration(750)
  .attr("r", 10);

// Chained transitions
circles
  .transition()
  .duration(500)
  .attr("fill", "orange")
  .transition()
  .duration(500)
  .attr("r", 15);

// Staggered transitions
circles
  .transition()
  .delay((d, i) => i * 50)
  .duration(500)
  .attr("cy", d => yScale(d.value));

// Custom easing
circles
  .transition()
  .duration(1000)
  .ease(d3.easeBounceOut)
  .attr("r", 10);
```
