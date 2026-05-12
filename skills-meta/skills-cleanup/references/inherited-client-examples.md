# Inherited Client Examples Cleanup

Skills templated from a client project (e.g., an education client's ad frameworks reused for a finance app) accumulate dead examples: wrong audience segments, irrelevant search queries, product-specific copy. These look like real content but actively mislead the agent during creative generation.

## Detection

```bash
grep -rci 'ClientName\|client-specific-term' ~/.hermes/skills/marketing/ --include="*.md" | grep -v ':0$'
```

Replace `ClientName` and `client-specific-term` with the actual client name and domain terms (e.g., `OpenEd`, `homeschool`, `curriculum`, `tuition`).

## Cleanup Rules

1. **Entire file is client-specific** (e.g., audience segments for a different product): delete it and remove all references from parent SKILL.md files.
2. **File mixes universal frameworks with client examples** (e.g., PAS formula with education-specific copy): strip only the client examples. Keep the framework structures intact. Do not replace with generic placeholders like "[PRODUCT]" — those are equally useless for generation.
3. **Duplicated reference files** (e.g., same `copywriting-formulas.md` in both `meta-ads-creative/` and `content-strategy/`): clean one, copy to the other.
4. **SKILL.md references**: after deleting a reference file, remove the load-on-demand pointer and any client-specific sections (brand voice, key messages, naming conventions mentioning the client).
5. **Final verification**: `grep -rci` again to confirm zero remaining references.

## Real Example: OpenEd cleanup (2026-05-12)

- `audience-segments.md` was 100% OpenEd homeschool content (149 lines). Deleted from both `meta-ads-creative/` and `content-strategy/`.
- `copywriting-formulas.md` had PAS/AIDA/BAB frameworks (useful) with OpenEd example copy throughout. Stripped examples, kept frameworks.
- `creative-research-methods.md` had "homeschool curriculum" search queries. Replaced with generic category terms.
- `6-elements-framework.md` had OpenEd headline/CTA examples. Removed.
- `meta-ads-creative/SKILL.md` had an "OpenEd-Specific Notes" section with brand voice and key messages. Deleted entire section.
- All 5 reference files were duplicated identically between `meta-ads-creative/` and `content-strategy/`. Cleaned once, copied to both.
