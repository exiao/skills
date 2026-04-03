# Skill Audit Checklist

## Structure (4 points)

### S1: Frontmatter Quality
- Has YAML frontmatter with `name` and `description`
- Description includes BOTH what the skill does AND when to trigger it (specific phrases, scenarios)
- No extra frontmatter fields beyond name/description
- **Pass:** Description reads like a routing instruction, not a summary
- **Fail:** Description only says what the skill does, not when to use it

### S2: Progressive Disclosure
- SKILL.md is under 500 lines
- Detailed docs live in `references/`, not inline
- Deterministic/repeated code lives in `scripts/`
- Output resources (templates, images) live in `assets/`
- References are one level deep from SKILL.md (no chains)
- Long reference files (100+ lines) have a table of contents
- **Pass:** SKILL.md is lean; details are discoverable but not loaded by default
- **Fail:** SKILL.md is a wall of text, or references chain 3+ levels deep

### S3: No Extraneous Files
- No README.md, CHANGELOG.md, INSTALLATION_GUIDE.md, QUICK_REFERENCE.md
- No user-facing docs (the skill IS the documentation for the agent)
- **Pass:** Every file serves the agent directly
- **Fail:** Contains files meant for humans, not agents

### S4: Clean Organization
- Skill directory named in lowercase-hyphen format
- Only uses scripts/, references/, assets/ subdirectories (plus SKILL.md at root)
- No empty directories
- **Pass:** Clean tree with no surprises
- **Fail:** Random files at root, empty dirs, mixed naming

## Content Quality (4 points)

### C1: Gotchas Section
- Has an explicit "Gotchas" or equivalent section documenting known failure patterns
- Gotchas are specific (not "be careful with X" but "X fails when Y because Z")
- **Pass:** Reader learns from past failures without hitting them
- **Fail:** No gotchas, or gotchas are vague warnings

### C2: Signal-to-Noise Ratio
- Only includes info the model doesn't already know
- No explanations of common libraries/APIs the model is trained on
- Prefers concise examples over verbose explanations
- Uses imperative/infinitive form
- **Pass:** Every paragraph justifies its token cost
- **Fail:** Explains things like "OAuth is an authorization framework..." or pads with filler

### C3: Degrees of Freedom
- High freedom for tasks where multiple approaches are valid
- Low freedom (specific scripts, exact sequences) for fragile operations
- Not over-railroading (too specific for variable tasks)
- Not too vague (no guidance for fragile operations)
- **Pass:** Specificity matches the task's fragility
- **Fail:** Either micromanages flexible tasks or hand-waves critical steps

### C4: No Duplication
- Information lives in ONE place (SKILL.md or references, not both)
- No repeated instructions across sections
- **Pass:** Single source of truth for each piece of info
- **Fail:** Same guidance appears in SKILL.md and a reference file

## Design Patterns (2 points)

### D1: Skill Type Clarity
Does the skill fall cleanly into one of these types?
- **Library & API Reference:** How to use a specific lib/CLI/SDK. Includes code snippets + gotchas.
- **Product Verification:** Test/verify code works. Paired with playwright, tmux, etc. Includes assertion scripts.
- **Data Fetching & Analysis:** Connect to data/monitoring. Includes credentials, dashboard IDs, query workflows.
- **Business Process & Team Automation:** Automate repetitive workflows (standups, tickets, recaps). Saves logs for consistency.
- **Code Scaffolding & Templates:** Generate framework boilerplate. Composable scripts.
- **Pass:** Clearly one type, or intentionally combines two with good reason
- **Fail:** Tries to do everything, unclear purpose

### D2: Advanced Patterns (where applicable)
- **Config pattern:** If skill needs user-specific config, uses config.json (not hardcoded values)
- **Memory/state:** If skill tracks state across runs, uses stable paths (not skill dir which gets wiped on upgrade)
- **Composability:** Scripts are helper libraries the agent composes, not monolithic
- **Skill references:** References other skills by name where dependencies exist
- **Pass:** Uses appropriate patterns for its needs
- **Fail:** Hardcodes config, loses state on upgrade, or has monolithic scripts

## Scoring

| Score | Rating |
|-------|--------|
| 9-10  | Excellent — production quality, could go in a marketplace |
| 7-8   | Good — works well, minor improvements possible |
| 5-6   | Average — typical first draft, needs iteration |
| 3-4   | Below average — missing key patterns, needs rework |
| 1-2   | Poor — fundamentally misstructured |
