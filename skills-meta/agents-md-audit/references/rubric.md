# Content Rubric: completeness + line lints

Run this AFTER the Hermes loading checks (H1-H7 in SKILL.md). A file can pass every content check and still be a hard fail because it's over the 20KB cap. Loading verdict comes first.

## Part 1: Karpathy 12-rule completeness

Adapted from Andrej Karpathy's coding-agent failure modes (Jan 2026), community-extended to twelve. Each rule maps to a specific failure it prevents. Score pass/fail by whether the file addresses the rule at all; report a count out of 12. Most first-draft AGENTS.md files score 3-5.

This rubric is for a **coding-repo context file**. If the file governs a non-code project, skip the rules that don't apply (don't penalize a content repo for lacking a test-gate rule) and say which you skipped.

**Karpathy's original four:**
1. **Think before coding** — the file tells the agent to plan / surface tradeoffs before editing. Prevents diving into edits then thrashing on the first surprise.
2. **Simplicity first** — smallest change that works, no premature abstraction. Prevents over-engineering to look "professional."
3. **Surgical changes** — touch only what the task names, no drive-by refactors. Prevents rewriting a working file while fixing one line.
4. **Goal-driven execution** — define done up front, loop until verified. Prevents stopping at "no error right now" instead of "feature works."

**Community extension:**
5. **Avoid silent assumptions** — ask when the spec is ambiguous, don't guess and ship the guess. (Karpathy called this the most expensive failure mode.)
6. **No orthogonal damage** — stay in the scope the request named.
7. **Tests as truth** — suite must be green before "done"; don't exclude the failing ones. (Skip for non-code repos.)
8. **Concise output** — bias to short answers, no recap of what was just done.
9. **Stack awareness** — name the language, framework, package manager, runtime so the agent stops inferring. (The rule most AGENTS.md files already pass.)
10. **Tool preference** — spell out prefer-X-over-Y, name the repo's standardized libraries.
11. **Failure-mode coverage** — record the specific mistakes that burned you before, by name. This is the "what NOT to do" / "Important Notes" section. Most-failed rule; also the highest-value one. Maps to skill-audit's Gotchas.
12. **Self-improvement loop** — tell the agent to write corrections back (into AGENTS.md, or via Hermes memory). What turns a static file into one that compounds.

Report as `X/12 (missing: 1, 5, 11, 12)`. The two most commonly missing and most worth adding: **#11 (name your past incidents)** and **#5 (ask instead of guessing)**.

## Part 2: Per-line instruction lints

Same lints as skill-audit's C5, applied to the context file's imperative content. These predict which rules the agent will silently ignore. Greppable where noted.

- **Missing-why prohibitions.** Every `NEVER` / `DO NOT` / `don't` line states its reason within ~2 lines (`because`, `Reason:`, a named incident). A bare ban gets followed until an edge case, then the agent guesses. This is also the SOUL convention (every rule carries its reason). **Fail:** a hard prohibition with no why.
  ```bash
  grep -nE "NEVER|DO NOT|Don't|don't" AGENTS.md
  ```
  Then eyeball each hit for a nearby reason. "Never modify migration files directly — use Alembic" passes (the alternative IS the why). "Never do X" alone fails.

- **Over-long instruction lines.** A single directive over ~28 words gets read as one signal and its back half skimmed. **Fail:** a fragile step buries its critical clause in a 30+ word run-on. Fix = split into 2-3 short directives, not just shorten.
  ```bash
  awk 'NF>28 && !/^```/ {print NR": "NF" words"}' AGENTS.md
  ```
  (Rough; counts headers and prose too. Use it to find candidates, then judge whether the long line is an actual operational directive vs. a descriptive sentence. Only precise steps need to be short.)

- **Vague terms.** Untestable words in steps meant to be precise: appropriate(ly), properly, carefully, thoughtfully, cleanly, as needed, where applicable, when possible, good, best. The agent can't tell when it succeeded. **Fail:** "handle errors appropriately" instead of naming the condition or tool.
  ```bash
  grep -niE "\b(appropriate|appropriately|properly|carefully|thoughtfully|cleanly|as needed|where applicable|when possible)\b" AGENTS.md
  ```

- **Unescaped absolutes.** `always` / `never` / `must` on a precise step with no escape clause (`unless`, `except`, `when X then`). Real workflows have exceptions; a naked absolute gets rounded off. **Fail:** an absolute the file's own body later contradicts or that obviously needs an "unless." A genuinely inviolable safety ban WITH a why is correct, keep it.

Report a tally: `missing-why: N, 28-word: N, vague: N, bare-absolute: N`. Don't double-count a line already flagged under H4 (SOUL placement) or under another lint.

## Part 2b: Readability (if a section is hard to understand, it's a bad AGENTS.md)

The line-lints above are mechanical. This one is comprehension: **can a fresh agent read a section ONCE and act correctly, without re-reading?** If not, the section is a defect no matter how complete or correct it is. An instruction the agent has to decode is an instruction it will get wrong under load. This is often the single biggest quality gap in a long AGENTS.md, and it's the one grep can't find.

Read the file as if you're the agent seeing it for the first time. Flag any section where the meaning isn't clear on one pass. The recurring causes:

- **Wall-of-prose rules.** A paragraph that buries three separate directives in flowing sentences. The agent extracts one and misses the others. Fix: break into a bulleted list, one directive per line.
- **Nested qualification.** "Do X, except when Y, unless Z, but if W then V." By the third clause the rule is unparseable. Fix: state the default, then the exceptions as separate lines, or split into a short decision list.
- **Buried lead.** The actual instruction sits at the end of a paragraph of rationale/context. The agent reads the setup and skims the payload. Fix: lead with the directive, then the why.
- **Undefined jargon / codenames / acronyms.** A repo-specific term, feature codename, or acronym used before it's defined (or never defined). The agent can't ground it. Fix: define on first use, or link where it's defined.
- **Ambiguous referents.** "It", "this", "that", "the above" where more than one antecedent is possible. Fix: name the thing.
- **Contradiction across sections.** Two sections that give conflicting guidance the agent can't reconcile (related to the H-checks but here it's a comprehension failure: the reader can't tell which wins). Fix: reconcile, or scope each explicitly.
- **Meta-heavy framing.** Long preamble about how to read the file, why the section exists, or who the audience is, before any actual instruction. The signal is diluted. Fix: cut to the operational content.

The test to apply per section: **"If I had to act on only this section, right now, would I know exactly what to do?"** If the honest answer is "I'd have to re-read it" or "it depends what they mean by X," flag it. Quote the specific hard-to-parse passage, say why it's hard (which cause above), and give the rewritten version. Don't just say "this is unclear"; show the clearer version.

Severity: a hard-to-understand section that governs a **fragile or high-stakes** operation (deploy, migrations, money, security, data integrity) is a real fail. A dense section on something low-stakes is a warning. Weight by what breaks if the agent misreads it.

Report the count of flagged sections and, for each, one line: `<section/heading>: <cause> — <the specific passage>`.

## Part 3: Hermes best-practice checks (from the docs)

The context-files doc lists six best practices; three are already covered by H1 (concise/under cap) and Part 1 (#11 what-NOT-to-do, stack). The remaining ones worth a quick pass:

- **Structured with `##` headers** — architecture / conventions / important-notes sections, not a wall of prose. Helps the agent (and helps H1: a sectioned file is easier to split when over-cap).
- **Concrete examples** — preferred code patterns, API shapes, naming. A file that only states rules abstractly scores lower than one that shows the shape.
- **Key paths and ports listed** — the agent uses these directly in terminal commands. Missing them forces guessing (ties to rule #5).
- **Not stale** — "stale context is worse than no context" (the doc says this outright). If the file references paths/commands/versions that no longer exist, that's a drift fail. Cross-check a few paths against the actual repo (`ls` them) — this is the same drift audit skill-audit runs on skills.
