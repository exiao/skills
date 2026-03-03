---
name: synthetic-userstudies
description: Run synthetic user research sessions natively — no backend required. The agent plays an AI-generated persona and simulates a user interview based on the 4 Ps framework (Persona, Problem, Promise, Product). Use when a user wants to run a user research session, interview a synthetic persona, validate product ideas, generate user personas, or simulate customer conversations. Triggers on "user research", "synthetic persona", "simulate a user", "userstudies", "interview a persona", "validate my idea", or "talk to a user".
---

# Synthetic UX Research

Run user research sessions natively. No backend calls. The agent plays the persona, generates characters, and runs interviews using the same prompts as userstudies.ai.

## Session Flow

### 1. Setup Phase
Collect the 4 Ps. Ask for any that are missing:

| Field | Description |
|---|---|
| **Persona** | Short description of target user (e.g. "Primary care doctor, US, recently graduated") |
| **Problem** | What they're struggling with — in their words |
| **Promise** | Value prop in <7 words (e.g. "Single-serve coffee") |
| **Product** | Key features / what you're building |

If any field is blank or weak, offer to autofill it. See **Autofill** section below.

Once all 4 Ps are set, confirm them and note the research phase (default: **Right Problems** — problem discovery). Load [principles.md](references/principles.md) for the phase framework. Then move to character generation.

### 2. Character Generation
Generate a `Character` from the Persona description. Follow the schema in [schema.md](references/schema.md). Output the character as a JSON block so it can be referenced later.

Example prompt to yourself: *"Create the most realistic character possible for: [persona]"*

### 3. Interview Mode
Once the character is generated, enter interview mode. You are now the character.

**Load [prompts.md](references/prompts.md) and follow `USER_RESEARCH_PARTICIPANT_PROMPT` exactly.**

Rules while in character:
- Respond as the character would via SMS: casual, personal, specific
- Use contractions, abbreviations, light emotion — vary length (few words to ~100)
- Share specific stories with sequencing, feelings, and decisions — what they did, not what they think
- If the topic isn't relevant to the character, say so in character
- Never break character unless the researcher explicitly steps out (see below)

**After every response**, append a `---` separator and list 3 suggested follow-up questions the researcher could ask. Use the `suggested_questions` format from [schema.md](references/schema.md).

**Question guidance:** Load [questions.md](references/questions.md) to seed the interview. Follow the interview structure in [principles.md](references/principles.md): open → get specifics → current behavior → pain → patterns. Suggested questions must be behavioral ("walk me through..."), never hypothetical or leading.

### 4. Auto-Interview Mode
If the researcher says "conduct interview" or "run the interview", run up to 6 turns autonomously:
- Follow the interview structure from [principles.md](references/principles.md): setup → specifics → current behavior → pain → patterns
- Pick the next best question from [questions.md](references/questions.md) or the current `suggestedQuestions`
- Ask it, respond in character, generate next suggested questions
- Stay in problem space — don't drift into solution validation
- Continue until 6 turns or the researcher interrupts
- Then deliver a concise findings summary: behavior patterns first, supporting quotes second

### 5. Stepping Out of Character
The researcher can say things like:
- "Autofill [field]" → run autofill, stay out of character until done
- "Change the persona" → restart setup
- "Show me the character" → print the Character JSON
- "Let's wrap up" → summarize key insights from the interview

After handling an out-of-character request, ask: *"Ready to continue the interview?"* before re-entering character.

## Autofill

When asked to autofill a field, load [prompts.md](references/prompts.md) and follow the corresponding `AUTOFILL_*_PROMPT`. Format the current conversation as:
```
user: [message]
persona: [response]
user: [message]
...
```

Return 1–3 suggestions for the field. Let the researcher pick or edit before locking it in.

Autofill is available at any point — during setup or mid-interview.

## State to Maintain

Track these across the session:
- **Character JSON** (generated in step 2, may evolve mid-interview if clarified)
- **4 Ps** (may be updated via autofill)
- **Conversation history** (researcher + persona turns only, not meta discussion)
