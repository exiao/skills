# README and Catalog Generation Pattern

Use this when the skills repo README gets too long because it lists every skill.

## Target structure

- `README.md`: short public landing page only.
  - repo purpose
  - install instructions
  - category table with counts
  - skill folder structure
  - links to `INSTALL.md`, `CATALOG.md`, and `CLAUDE.md`
- `CATALOG.md`: generated full index of every skill grouped by category.
- `scripts/generate_catalog.py`: deterministic generator that reads `**/SKILL.md` frontmatter and writes `CATALOG.md`.
- `CLAUDE.md`: repo convention should say to regenerate catalog after adding, removing, or renaming skills.

## Implementation notes

1. Create a worktree from `origin/main`; do not edit the main checkout.
2. Count skills by walking `**/SKILL.md`, skipping `.git`, `.github`, and `node_modules`.
3. Parse only the `name` and `description` frontmatter fields.
4. Generate tables with category anchors and skill links to each skill directory.
5. Truncate long descriptions in the catalog so the generated file is browsable.
6. Keep README category counts in sync with the generator output.
7. Update `CLAUDE.md`/repo agent instructions so future additions run the generator instead of manually editing a giant README.

## Verification

Run:

```bash
python -m py_compile scripts/generate_catalog.py
python scripts/generate_catalog.py
git diff --exit-code -- CATALOG.md
git diff --check
```

Also verify every catalog skill link points to an existing skill directory and every `SKILL.md` directory appears exactly once in the catalog.

A simple Python link check:

```python
from pathlib import Path
import re
root = Path.cwd()
cat = (root / 'CATALOG.md').read_text()
links = re.findall(r'\[[^\]]+\]\(([^)]+/)\)', cat)
skill_dirs = {
    p.parent.relative_to(root).as_posix() + '/'
    for p in root.glob('**/SKILL.md')
    if 'node_modules' not in p.parts and '.git' not in p.parts
}
catalog_links = {href for href in links if not href.startswith('#')}
assert not [href for href in catalog_links if not (root / href).exists()]
assert skill_dirs == catalog_links
```

## Pitfalls

- Collapsible README sections improve visual length but not file size. Prefer moving the full list out.
- Do not hand-edit `CATALOG.md` after generation.
- Do not create per-skill README files. Skill directories should use `SKILL.md`, `references/`, `scripts/`, and `assets/`.
- Do not make this a cleanup PR plus unrelated skill changes. Keep it one logical docs/catalog change.
