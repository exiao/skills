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

## Variant Panel Mode (parallel copy/UX testing)

When the goal is comparing N copy/UX variants (welcome messages, paywall copy, chip labels) rather than problem discovery, run a **parallel persona panel** instead of a single interview:

1. Build 4-6 personas spanning the REAL segment axes: experience level (true beginner → power user with their own existing tooling), trust posture (scam-wary, sales-wary, data-privacy-wary), language/locale (include a native speaker of each shipped localization), and channel-nativeness. Adversarial personas (skeptic with substitutes, scared beginner) are the most informative — a variant that converts BOTH extremes is a strong signal.
2. Dispatch one `delegate_task` subagent per persona (respect the concurrency cap; batch if needed). Each goal must be fully self-contained: full persona bio incl. texting style and core fear, the complete text of EVERY variant, and a fixed output format (`VARIANT N: [reaction] | TAPS: [choice] | SCORE: n/10`, then RANKING and INSIGHT).
3. Require each persona to (a) react think-aloud in their own voice, (b) pick the chip they'd tap OR what they'd type instead (typing-instead-of-tapping is itself a finding), (c) score 1-10, then step out of character for a ranking + one segment insight.
4. For localized products, ask the native-speaker persona to flag clunky translations and suggest natural phrasing — this surfaces real localization bugs (gendered greetings, false-friend verbs) that copy review misses.
5. Synthesize across personas: look for (a) variants that win everywhere (rare, strong), (b) variants that flip meaning by segment (same words read as protection vs. noise vs. exclusion), (c) variants that are "nobody's enemy" (safe floors). Cross-check against third-party research (e.g. NN/g) before recommending.
6. Always state the caveat: N LLM role-plays are directional, not proof. Unanimity across adversarial personas + converging third-party research is the strongest pre-launch evidence available, but say so explicitly.

## State to Maintain

Track these across the session:
- **Character JSON** (generated in step 2, may evolve mid-interview if clarified)
- **4 Ps** (may be updated via autofill)
- **Conversation history** (researcher + persona turns only, not meta discussion)

## Copy-Variant Panel Mode (parallel A/B/n testing)

For testing N copy variants (welcome messages, paywall bullets, chip wording) against multiple personas, skip the interview flow and run a parallel panel via delegate_task:

- **One persona per delegated task**, ALL variants inside each task. Personas must span the real segment spread (e.g. for a consumer app: budget-conscious mainstream user, anxious late adopter, non-English WhatsApp native, skeptical power user with existing tooling, true beginner with no prior setup). Include at least one persona the copy might EXCLUDE and one with a competing tool — they surface failures the median persona can't.
- **Task prompt shape:** persona description with texting style + core fear, then for EACH variant: (1) think-aloud reaction 2-3 sentences, (2) which option they tap OR what they type instead, (3) gut score 1-10. Then step out of character: rank all variants for THIS persona + single biggest insight.
- **Output format line is mandatory** (`VARIANT N: [reaction] | TAPS: [...] | SCORE: n/10 ... then RANKING and INSIGHT`) or results don't aggregate.
- For localized copy, give one persona the localized strings and ask for translation-naturalness notes — this catches gendered greetings and register problems (e.g. "vigilar" reading surveillance-y) that translation review misses.
- **Aggregate by convergence, not average score.** A variant that wins/places across ALL personas (including the adversarial ones) is the signal; a variant that spikes for one persona and tanks for another is a segmentation finding, not a winner. Proven result: post-answer contextual offers beat every upfront wording for all 5 personas — sequencing beats wording.
- Always state the caveat: N LLM role-plays, directional not proof. Strongest when it agrees with independent evidence (real-user research like NN/g, viral hook data).
