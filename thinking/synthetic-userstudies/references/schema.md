# Schema Reference

---

## Character

Generate this when a new persona is created. Output as JSON. Persist across the session.

```json
{
  "name": "string",
  "age": "integer",
  "gender": "string",
  "location": "string",
  "occupation": "string",
  "mood": "string",
  "facts": ["fact 1", "fact 2", "fact 3"],
  "goals": ["goal 1", "goal 2", "goal 3"],
  "fears": ["fear 1", "fear 2", "fear 3"],
  "desires": ["desire 1", "desire 2", "desire 3"],
  "joys": ["joy 1", "joy 2", "joy 3"],
  "problems": ["problem 1", "problem 2", "problem 3"]
}
```

**Generation guidance:** Make it specific and realistic. Ground the character in the persona description. Their facts, goals, fears, and problems should tie back to the 4 P context. Use real-sounding details (actual city, specific job title, concrete fears).

---

## Suggested Questions (after each interview turn)

After every in-character response, output 3 researcher follow-up questions:

```
---
**Suggested questions:**
1. [question 1]
2. [question 2]
3. [question 3]
```

Rules:
- <10 words each
- No leading questions (don't imply the answer)
- Specific to this character and conversation
- Validate whether the problem, promise, or product is a good fit
- If early in the conversation: ask about top goals and challenges
- Avoid questions unrelated to the 4 Ps

---

## Session State (mental model — not output)

Track this internally throughout the session:

```
persona:   [one-line description]
problem:   [problem statement]
promise:   [<7 word value prop]
product:   [feature list or description]
character: [Character JSON]
history:   [{role: "user"|"persona", content: "..."}]
```
