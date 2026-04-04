---
name: trip-planner
description: "Generate detailed day-by-day travel itineraries with neighborhood-by-neighborhood routing, budget scaling, dietary-aware meal picks, proximity checks, and post-generation quality validation. Use when: plan a trip, travel itinerary, trip to [destination], vacation planning, travel planner."
---

# Trip Planner Skill

Generate structured, day-by-day travel itineraries that minimize transit and maximize exploration. Inspired by TripSketch AI's routing-first approach.

## Core Philosophy

**Minimize transit, maximize exploration.** The traveler explores one neighborhood thoroughly before moving to the next. No zigzagging across the city.

---

## Step 1: Gather Trip Details

Ask the user for (or extract from their message):

| Field | Required | Default | Options |
|-------|----------|---------|---------|
| Destination | Yes | — | Any city/region |
| Trip length | Yes | — | 1-14 days |
| Budget | No | Moderate | Budget, Moderate, Premium, Luxury |
| Travel style | No | General | Solo, Couple, Family, Friends, Culinary, Adventure, Cultural, Relaxed |
| Interests | No | General sightseeing | Up to 5 (e.g. food, history, art, nightlife, nature, photography, shopping) |
| Pace | No | Balanced | Relaxed, Balanced, Packed |
| Season/dates | No | Not specified | Any season or specific dates |
| First visit? | No | First visit | First visit, Returning visitor |
| Must-see places | No | None | Comma-separated list |
| Dietary needs | No | None | Vegetarian, vegan, halal, kosher, gluten-free, etc. |
| Notes | No | None | Free text (late starts, early departure, kids, accessibility, etc.) |

If the user gives a casual request like "plan me 5 days in Tokyo," fill in reasonable defaults and go. Don't interrogate them.

---

## Step 2: Generate the Itinerary

Use the following system prompt structure when generating the itinerary. You ARE the planner, so apply these rules directly to your output:

### Routing Rules (High Priority)

1. **Neighborhood by neighborhood.** Plan each day so the traveler explores one area or cluster of nearby areas before moving on.
2. **Never double back.** If the day starts in the north and moves south, don't send them back north later.
3. **Minimize major transit.** A couple short rides are fine. Repeatedly crossing the city is not.
4. **Meals near the action.** Place restaurants near the day's current area. Exception: if the style is Culinary/Fine Dining, prioritize food quality but still try to keep meals reasonably close.
5. **Spread must-see places.** If must-see places are in different parts of the city, put them on different days and build nearby activities around each one.

### Content Rules

1. **4-7 items per day** covering Morning, Lunch, Afternoon, Dinner, and optionally Evening.
2. **Name specific restaurants** with what they're known for. Not "have lunch." Pick places locals actually go to.
3. **Realistic cost estimates** in USD for the stated budget level.
4. **Creative day themes** that capture the vibe (e.g. "Temples & Teahouses," "Harbor to Hilltop").
5. **Vivid 1-2 sentence descriptions.** What makes this place special + any practical tips.
6. **Season-aware.** Mention weather, crowds, seasonal events, and closures naturally in descriptions.
7. **Returning visitors** skip obvious tourist spots for deeper, lesser-known alternatives.

### Budget Multipliers

Scale the LLM's base (Moderate) estimates:

| Budget | Activities | Meals | Daily Transit |
|--------|-----------|-------|---------------|
| Budget | 0.6x | 0.55x | $8 |
| Moderate | 1.0x | 1.0x | $15 |
| Premium | 1.7x | 1.8x | $30 |
| Luxury | 2.5x | 2.8x | $50 |

---

## Step 3: Output Format

Present the itinerary in this structure:

```
## [Destination] — [N]-Day Itinerary
**Budget:** [level] | **Pace:** [pace] | **Style:** [styles]
**Estimated total:** $[amount] (~$[daily avg]/day)

[2-3 sentence trip overview]

---

### Day 1: [Creative Theme]
**Area:** [neighborhood/district] | **Est. cost:** $[amount]

🌅 **Morning** — [Place Name]
[Description with practical tip] — ~$[cost]

🍜 **Lunch** — [Restaurant Name]
[What to order / what it's known for] — ~$[cost]

🏛️ **Afternoon** — [Place Name]
[Description] — ~$[cost]

🍽️ **Dinner** — [Restaurant Name]
[Description] — ~$[cost]

🌙 **Evening** — [Place/Activity Name]
[Description] — ~$[cost]

---
[Repeat for each day]
```

Use these emojis for time blocks: 🌅 Morning, 🍜 Lunch, 🏛️ Afternoon, 🍽️ Dinner, 🌙 Evening.

---

## Step 4: Post-Generation Quality Checks

After generating, run these validation checks and append warnings to the output:

### Dietary Compliance
If the user stated dietary preferences, scan all meal items for violations:

| Preference | Flag if description contains |
|-----------|------------------------------|
| Vegetarian | steak, beef, pork, chicken, lamb, duck, bacon, ribs, fish, seafood, shrimp, sushi, sashimi |
| Vegan | All vegetarian flags + cheese, cream, butter, egg, milk, yogurt, honey, kaiseki |
| Halal | pork, bacon, ham, prosciutto, salami, lard |
| Kosher | pork, bacon, ham, shellfish, shrimp, lobster, crab |
| Gluten-free | ramen, pasta, bread, pizza, noodle, soba, udon |

### Proximity Check
Flag any consecutive items on the same day that are more than ~8km apart (use your knowledge of the city's geography). Include a ⚠️ warning with the estimated distance.

### Timing Checks
- If notes mention "late start" / "sleep in" / "not a morning person" → warn about Morning items
- If notes mention "early departure" / "afternoon flight" on last day → warn about Dinner/Evening items on the final day

### Trip Length Match
Verify the number of days generated matches what was requested.

### Destination Match
Verify all suggested places are actually in the requested destination.

### Warnings Format
If any issues found, append at the end:

```
---
### ⚠️ Quality Checks
- [Warning 1]
- [Warning 2]
```

If all checks pass, append: ✅ **All quality checks passed.**

---

## Step 5: Modifications

If the user wants to swap an item:

1. Keep the same general area as the day's other items
2. Match the budget level
3. Respect dietary needs and notes
4. Never suggest something already in the itinerary
5. Keep the replacement in context with surrounding activities

If the user wants a rainy day alternative:

1. Replace outdoor activities with indoor alternatives (museums, workshops, markets, indoor dining)
2. Keep the same neighborhood routing
3. Maintain budget level

---

## Tips

- For trips 7+ days, group by districts/regions and note transit between areas
- For multi-city trips, allocate days per city and add transit days
- When the user says "surprise me," lean into local hidden gems over tourist standards
- Cost estimates should include the activity/meal only, not accommodation (unless asked)
