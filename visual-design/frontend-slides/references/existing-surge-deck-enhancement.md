# Existing Surge Deck Enhancement

Use this when improving an existing HTML slide deck that is already deployed to Surge, especially when copying visual language from another deck.

## Pressure scenarios this reference prevents

1. User asks to "try it" on a live Surge deck and requests a backup. Baseline failure: edit directly, deploy, and only mention screenshots afterward.
2. User points at a Google Slides deck and says to use the correct visuals. Baseline failure: read only extracted text and miss the actual visual language.
3. User asks for live validation. Baseline failure: trust local browser state, fail to screenshot the live URL, or miss viewport overflow.

## Workflow

1. Load the existing deck skill and inspect the source HTML before editing.
2. Make a timestamped backup before touching the deck:
   ```bash
   mkdir -p backups
   cp index.html backups/index.html.backup-$(date +%Y%m%d-%H%M%S)
   ```
3. If the source visual is a Google Slides deck, use both text extraction and visual inspection:
   - `https://docs.google.com/presentation/d/<id>/htmlpresent` for text and slide order.
   - Browser screenshot or vision pass for actual style: background, typeface, color, layout, spacing, diagrams.
4. Recreate the visual language in native HTML/CSS when possible instead of embedding screenshots. Screenshots are useful as references, but editable HTML keeps the deck responsive and easier to maintain.
5. If replacing a carousel or interactive block, remove the now-dead JavaScript too. Do not leave event handlers that query deleted IDs.
6. Verify locally with Playwright or browser tools:
   - screenshot target slides at presentation viewport, usually `1440x900`.
   - check each modified slide has `scrollHeight === clientHeight` and `scrollWidth === clientWidth`.
   - inspect for console errors.
7. Deploy with Surge from the deck directory:
   ```bash
   npx surge ./ <domain>.surge.sh
   ```
8. Verify the live URL after deploy, not just localhost. Capture screenshots of changed slides from the live site and send them back when useful.

## Notes and pitfalls

- Browser automation may report `window.scrollTo()` against `documentElement` as no-op for some decks. If `scrollIntoView()` does not move the viewport, set `document.body.scrollTop = el.offsetTop` or use Playwright `locator(...).scrollIntoViewIfNeeded()`.
- Google Slides `htmlpresent` often exposes the text but not all visuals. Use `browser_vision` or screenshots before deciding what "correct visuals" means.
- Dark presentation aesthetics can look good locally but fail on projectors. Run a vision/readability pass and brighten low-contrast heading colors if needed.
- Signal/file gateway requires final replies to include `MEDIA:/absolute/path` lines for screenshots to attach.
