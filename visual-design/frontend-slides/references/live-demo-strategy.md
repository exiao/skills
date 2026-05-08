# Live Demo Strategy for Presentation Decks

When a deck includes live demos (running the product on stage), the demo selection matters more than the slide design. Bad demos undersell real capabilities.

## The "Toy vs Factory" Anti-Pattern

The most common mistake: demoing simple one-step actions (e.g. "generate an image from a prompt") when the platform actually runs complex multi-step autonomous workflows. If every PM in the audience has already seen a capability, it's not a demo — it's a reminder.

**Audit before planning demos:**
1. List what the product ACTUALLY does daily (cron jobs, automations, real workflows)
2. List what the current demos show
3. Gap = missed opportunity

## Demo Selection Principles

1. **Each demo should showcase a different primitive** (skill, browser, cron, memory, delegation, etc.)
2. **Escalate complexity:** simple → compound → autonomous → personal life
3. **Every demo should make the audience think "I need this"** — not "that's cool"
4. **Target real headcount replacement:** "this replaces a media buyer's morning" > "this makes a sticker"
5. **Include one personal-life demo** as a closer — gets laughs, shows breadth, makes it relatable

## Demo Sequencing Pattern

| Slot | Theme | Example | Why |
|------|-------|---------|-----|
| 1 | Fix a real problem | Scan Sentry → diagnose → open PR | Universal pain point (bugs), shows technical depth |
| 2 | Replace a role | Pull ad metrics → kill losers → generate + upload creatives | Replaces expensive headcount |
| 3 | Multi-step chain | Browser audit → analysis → plan → deploy | Shows orchestration across tools |
| 4 | Autonomous agent | Create a cron that runs forever, delivers to phone | The "while you sleep" moment |
| 5 | Personal life | Apartment search, travel booking, meal planning | Humanizes the tool, gets laughs |
| 6 | Meta/self-referential | "Write a tweet about what we just built" | Crowd-pleaser, references the demo itself |

## Live Demo Risk Management

- **Always have a GIF/screenshot fallback** for each demo in case of live failure
- **Pre-seed reproducible scenarios** (e.g. plant a Sentry issue you know the tool can fix)
- **Time-box:** if a demo takes >2 min on stage, it should be partially pre-baked
- **Phone notification moment:** if the product delivers to mobile, show the notification arriving on a projected phone screen — this is the single highest-impact visual in any agent demo
- **Test the full chain end-to-end** in a dry run the day before

## Slide Structure for Demo Slides

Each demo slide should have:
1. **Demo badge** (e.g. "Live Demo 01")
2. **Title** that names the capability, not the tool (e.g. "Fix a production bug" not "Sentry integration")
3. **Prompt** shown as a quoted user message — the audience should be able to picture themselves typing it
4. **Flow diagram** showing the chain of steps (skill → analysis → action → delivery)
5. **Footnote** connecting to real usage ("This runs autonomously twice a day via cron")

The footnote is important: it proves the demo isn't a party trick but something that actually runs in production.

## Updating the Recap Slide

If there's a meta-demo (e.g. "write a tweet about the demo"), update its content to reference the actual demos shown. Stale recap content that references old demos breaks the self-referential magic.
