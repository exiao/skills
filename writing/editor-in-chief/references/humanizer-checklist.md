# Humanizer Checklist

Based on [Wikipedia's "Signs of AI writing"](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) guide (WikiProject AI Cleanup). Use during Voice WEAK/NEEDS WORK passes to systematically remove AI tells.

## How to Use

Scan the draft for each of the 24 patterns below. For every match: apply the fix, then continue. Run this as a diagnostic pass — collect all hits first, then fix in the consolidated rewrite (do not rewrite after each pattern).

After applying the checklist, run a final "obviously AI-generated" audit: read the draft as a skeptical editor and ask "would a sharp human writer ever write this sentence?" If no, cut or rewrite it.

---

## 24 Patterns

### Content Patterns

| # | Pattern | AI Example | Fix |
|---|---------|-----------|-----|
| 1 | **Significance inflation** | "marking a pivotal moment in the evolution of..." | Replace with plain fact: "was established in 1989 to collect..." |
| 2 | **Notability name-dropping** | "cited in NYT, BBC, FT, and The Hindu" | Make it specific: "In a 2024 NYT interview, she argued..." |
| 3 | **Superficial -ing analyses** | "symbolizing... reflecting... showcasing..." | Remove entirely, or expand with actual sources |
| 4 | **Promotional language** | "nestled within the breathtaking region" | "is a town in the Gonder region" |
| 5 | **Vague attributions** | "Experts believe it plays a crucial role" | "according to a 2019 survey by..." |
| 6 | **Formulaic challenges** | "Despite challenges... continues to thrive" | Replace with specific facts about actual challenges |

### Language Patterns

| # | Pattern | AI Example | Fix |
|---|---------|-----------|-----|
| 7 | **AI vocabulary** | "Additionally... testament... landscape... showcasing" | "also... remain common" — use plain words |
| 8 | **Copula avoidance** | "serves as... features... boasts" | "is... has" |
| 9 | **Negative parallelisms** | "It's not just X, it's Y" | State the point directly |
| 10 | **Rule of three** | "innovation, inspiration, and insights" | Use natural number of items (one or two if that's all there is) |
| 11 | **Synonym cycling** | "protagonist... main character... central figure... hero" | Pick the clearest word and repeat it |
| 12 | **False ranges** | "from the Big Bang to dark matter" | List topics directly |

### Style Patterns

| # | Pattern | AI Example | Fix |
|---|---------|-----------|-----|
| 13 | **Em dash overuse** | "institutions—not the people—yet this continues—" | Use commas or periods |
| 14 | **Boldface overuse** | Bolding random terms mid-sentence | Bold only if the word is a defined term or critical scannable anchor |
| 15 | **Inline-header lists** | "Performance: Performance improved" | Convert to prose |
| 16 | **Title Case Headings** | "Strategic Negotiations And Partnerships" | "Strategic negotiations and partnerships" |
| 17 | **Emojis** | "🚀 Launch Phase: 💡 Key Insight:" | Remove emojis (unless the piece explicitly uses them as style) |
| 18 | **Curly quotes** | said "the project" (curly) | Normalize to straight quotes if inconsistent |

### Communication Patterns

| # | Pattern | AI Example | Fix |
|---|---------|-----------|-----|
| 19 | **Chatbot artifacts** | "I hope this helps! Let me know if..." | Remove entirely |
| 20 | **Cutoff disclaimers** | "While details are limited in available sources..." | Find sources or cut the claim |
| 21 | **Sycophantic tone** | "Great question! You're absolutely right!" | Respond directly |

### Filler and Hedging

| # | Pattern | AI Example | Fix |
|---|---------|-----------|-----|
| 22 | **Filler phrases** | "In order to", "Due to the fact that" | "To", "Because" |
| 23 | **Excessive hedging** | "could potentially possibly" | "may" |
| 24 | **Generic conclusions** | "The future looks bright" | Specific plans or facts only |

---

## Final Audit Prompt

After applying the 24 patterns, do one read-through with this question in mind:

> "Would a sharp human writer — someone with a strong voice and specific opinions — ever write this sentence?"

If the answer is no, rewrite or cut. This catches patterns not covered by the 24 above.

---

*Source: [blader/humanizer](https://github.com/blader/humanizer) · Based on Wikipedia Signs of AI Writing*
