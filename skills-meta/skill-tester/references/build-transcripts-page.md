# Build the transcripts page

`build_transcripts.py` converts a `test-output/sectionN/*.md` tree of self-play transcripts
into one static HTML page: collapsible per lesson, grouped by section, with a SYNTHETIC
warning header. It does minimal markdown rendering and styles `**INSTRUCTOR:**` /
`**STUDENT:**` turns as distinct bubbles.

## Layout it expects
```
<worktree>/
  build_transcripts.py
  test-output/
    section1/01-*.md 02-*.md 03-*.md 04-*.md
    section2/05-*.md ... etc
```
Edit the `SECTIONS` list at the top (title, dir, one-line description) to match the course.

## Run
```
python3 build_transcripts.py     # writes index.html
cp index.html 200.html           # SPA fallback for hosts that need it
# deploy index.html + 200.html to any static host
```
Verify the live page with a real rendered screenshot; static CDNs can return a transient
error on the first cold hit, retry after a few seconds.

## Styling
The page ships with a clean default theme, but the look is yours to set. Pick a palette and
type system that matches the project's brand (define CSS custom properties at `:root` and
reference them throughout). Guidance that holds regardless of theme:

- Headlines and body can use different families (e.g. a serif display face + a sans body
  face). Load web fonts via `<link>` with a system fallback.
- Each lesson is a `<details>` accordion with a `+`/`–` marker and a number badge.
- Instructor and student turns get two visually distinct bubble styles so the conversation
  is easy to scan.
- Code/pre use `white-space:pre-wrap; word-break:break-word` and inline code uses
  `overflow-wrap:anywhere` so long URLs wrap on mobile instead of forcing horizontal scroll.
- Constrain content width (~820px) for readability.

If your project has a documented visual identity (palette, fonts, components), apply it
here instead of the default theme. The working script in `scripts/build_transcripts.py`
has the full `<style>` block — edit the `:root` tokens to rebrand.

## The script
The complete, runnable build script is in `scripts/build_transcripts.py`. Copy it into your
worktree, edit the `SECTIONS` list and the `:root` design tokens, then run it. Its renderer
handles headings, lists, code fences, blockquotes, and the `**INSTRUCTOR:**` /
`**STUDENT:**` speaker turns.
