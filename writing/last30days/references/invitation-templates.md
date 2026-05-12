# Invitation Templates

## Post-Research Invitations (by QUERY_TYPE)

**CRITICAL: Every invitation MUST include 2-3 specific example suggestions based on what you ACTUALLY learned from the research.** Don't be generic — show the user you absorbed the content by referencing real things from the results.

**If QUERY_TYPE = PROMPTING:**
```
---
I'm now an expert on {TOPIC} for {TARGET_TOOL}. What do you want to make? For example:
- [specific idea based on popular technique from research]
- [specific idea based on trending style/approach from research]
- [specific idea riffing on what people are actually creating]

Just describe your vision and I'll write a prompt you can paste straight into {TARGET_TOOL}.
```

**If QUERY_TYPE = RECOMMENDATIONS:**
```
---
I'm now an expert on {TOPIC}. Want me to go deeper? For example:
- [Compare specific item A vs item B from the results]
- [Explain why item C is trending right now]
- [Help you get started with item D]
```

**If QUERY_TYPE = NEWS:**
```
---
I'm now an expert on {TOPIC}. Some things you could ask:
- [Specific follow-up question about the biggest story]
- [Question about implications of a key development]
- [Question about what might happen next based on current trajectory]
```

**If QUERY_TYPE = GENERAL:**
```
---
I'm now an expert on {TOPIC}. Some things I can help with:
- [Specific question based on the most discussed aspect]
- [Specific creative/practical application of what you learned]
- [Deeper dive into a pattern or debate from the research]
```

**Example invitations (to show the quality bar):**

For `/last30days nano banana pro prompts for Gemini`:
> I'm now an expert on Nano Banana Pro for Gemini. What do you want to make? For example:
> - Photorealistic product shots with natural lighting (the most requested style right now)
> - Logo designs with embedded text (Gemini's new strength per the research)
> - Multi-reference style transfer from a mood board
>
> Just describe your vision and I'll write a prompt you can paste straight into Gemini.

For `/last30days kanye west` (GENERAL):
> I'm now an expert on Kanye West. Some things I can help with:
> - What's the real story behind the apology letter — genuine or PR move?
> - Break down the BULLY tracklist reactions and what fans are expecting
> - Compare how Reddit vs X are reacting to the Bianca narrative

For `/last30days war in Iran` (NEWS):
> I'm now an expert on the Iran situation. Some things you could ask:
> - What are the realistic escalation scenarios from here?
> - How is this playing differently in US vs international media?
> - What's the economic impact on oil markets so far?

## Post-Prompt Follow-Up

After delivering a prompt, offer to write more:

> Want another prompt? Just tell me what you're creating next.

## Output Summary Footer (After Each Prompt)

After delivering a prompt, end with:

```
---
📚 Expert in: {TOPIC} for {TARGET_TOOL}
📊 Based on: {n} Reddit threads ({sum} upvotes) + {n} X posts ({sum} likes) + {n} YouTube videos ({sum} views) + {n} web pages

Want another prompt? Just tell me what you're creating next.
```
