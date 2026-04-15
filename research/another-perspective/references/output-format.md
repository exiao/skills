# Council Report Output Format

Choose format based on council size.

---

## Quick Format (2 perspectives)

```markdown
## Council Report: [Concise Title]

**Question:** [Original question, verbatim]
**Council:** [2 perspective names]
**Mode:** [Quick / Quick Deep]

---

### Verdict

[1-3 sentence bottom-line recommendation.]

---

### Analysis

**Agreement:**
[What both perspectives agree on]

**Disagreement:**
[Where they diverge, with each side's reasoning]

---

### Blind Spots

- [What neither perspective addressed]

---

### Recommended Next Steps

1. [Action 1]
2. [Action 2]

---

### Individual Perspectives

<details>
<summary>[Perspective 1]'s Analysis</summary>

[Full analysis]

</details>

<details>
<summary>[Perspective 2]'s Analysis</summary>

[Full analysis]

</details>
```

---

## Standard Format (3–6 perspectives)

```markdown
## Council Report: [Concise Title]

**Question:** [Original question, verbatim]
**Council ([N] perspectives):** [All selected perspective names]
**Mode:** [Default / Deep / Full / Full Deep]

---

### Verdict

[1-3 sentences. Actionable. No hedging without specifying what the decision depends on.]

---

### Consensus Points

- [Point 1]
- [Point 2]
- [Point 3]

---

### Key Tensions

**Tension: [Value A] vs. [Value B]**
- **[Perspective 1]** argues: [position and reasoning]
- **[Perspective 2]** counters: [position and reasoning]
- **Resolution:** [Synthesized recommendation, or "Genuine trade-off — choose based on whether you prioritize [X] or [Y]"]

[Repeat for 2-3 most significant tensions max.]

---

### Blind Spots

- [Blind spot 1]
- [Blind spot 2]

---

### Confidence Map

| Aspect | Confidence | Signal |
|--------|-----------|--------|
| [Aspect 1] | High / Medium / Low | [Why] |
| [Aspect 2] | High / Medium / Low | [Why] |

---

### Recommended Next Steps

1. [Most urgent / highest confidence action]
2. [Action that resolves the most uncertainty]
3. [Action informed by the key tension]
4. [Optional: longer-term action]

---

### Individual Perspectives

<details>
<summary>The User Advocate's Analysis</summary>

[Full analysis]

</details>

[Repeat <details> block for each perspective]
```

---

## Formatting Guidelines

- **Bold** perspective names, tension labels, key terms
- Tables for confidence map
- `<details>` tags for individual perspectives (keeps report scannable)
- Verdict: under 50 words
- Consensus Points: 3–5 bullets max
- Blind Spots: 2–4 items (quality over quantity)
- Next Steps: concrete enough to act on immediately
- At 5–6 perspectives: only surface structurally significant tensions
