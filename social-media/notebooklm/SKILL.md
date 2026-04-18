---
name: notebooklm
description: Use this skill to query your Google NotebookLM notebooks directly from Claude Code for source-grounded, citation-backed answers from Gemini. Also use to generate slide decks, mind maps, audio overviews, and other Studio outputs from YouTube videos or any source. Two approaches available - CLI (notebooklm-py) for fast programmatic access, or browser automation for visual/interactive workflows.
---

# NotebookLM Research Assistant Skill

Interact with Google NotebookLM to query documentation with Gemini's source-grounded answers. Supports all Studio features: Slide Deck, Audio Overview, Video Overview, Mind Map, Flashcards, Quiz, Infographic, Data Table, and Reports.

**Two approaches are available:**
- **CLI (`notebooklm-py`)** — Fast, no browser overhead, supports everything including features the web UI doesn't expose. Preferred for most tasks.
- **Browser automation** — Useful when the CLI hits issues, for visual debugging, or when you need to interact with the web UI directly.

## When to Use This Skill

Trigger when user:
- Mentions NotebookLM explicitly
- Shares NotebookLM URL (`https://notebooklm.google.com/notebook/...`)
- Asks to query their notebooks/documentation
- Wants to add documentation to NotebookLM library
- Uses phrases like "ask my NotebookLM", "check my docs", "query my notebook"
- Wants to generate a slide deck, audio overview, mind map, podcast, video, etc. from a YouTube video or document
- Says "create a podcast about X", "summarize these URLs", "generate a quiz from my research"

---

## Approach 1: CLI (`notebooklm-py`) — Preferred

Reference: [github.com/teng-lin/notebooklm-py](https://github.com/teng-lin/notebooklm-py)

### Installation

```bash
pip install "notebooklm-py[browser]"
playwright install chromium
```

### Authentication

```bash
notebooklm login            # Opens browser for Google OAuth (one-time)
notebooklm auth check --test  # Diagnose auth issues
notebooklm list             # Verify auth works
```

For CI/CD or parallel agents, set `NOTEBOOKLM_AUTH_JSON` (inline auth JSON) or use separate `NOTEBOOKLM_HOME` directories per agent.

### Core Workflow

```bash
# Create notebook and add sources
notebooklm create "My Research"
notebooklm use <notebook_id>
notebooklm source add "https://en.wikipedia.org/wiki/Artificial_intelligence"
notebooklm source add "./paper.pdf"
notebooklm source add "https://youtube.com/watch?v=..."

# Chat with sources
notebooklm ask "What are the key themes?"
notebooklm ask "question" -s src_id1 -s src_id2   # specific sources only
notebooklm ask "question" --json                   # with source references
notebooklm ask "question" --save-as-note           # save answer as notebook note

# Web research (auto-imports sources)
notebooklm source add-research "AI trends 2026"              # fast mode
notebooklm source add-research "AI trends 2026" --mode deep  # deep mode
```

### Generate All Studio Artifact Types

```bash
# Audio Overview (podcast)
notebooklm generate audio "make it engaging" --wait
notebooklm download audio ./podcast.mp3

# Video Overview
notebooklm generate video --style whiteboard --wait
notebooklm download video ./overview.mp4

# Cinematic Video
notebooklm generate cinematic-video "documentary-style summary" --wait
notebooklm download cinematic-video ./documentary.mp4

# Slide Deck
notebooklm generate slide-deck
notebooklm download slide-deck ./slides.pdf    # or .pptx

# Quiz & Flashcards
notebooklm generate quiz --difficulty hard
notebooklm download quiz --format markdown ./quiz.md
notebooklm generate flashcards --quantity more
notebooklm download flashcards --format json ./cards.json

# Infographic
notebooklm generate infographic --orientation portrait
notebooklm download infographic ./infographic.png

# Mind Map
notebooklm generate mind-map
notebooklm download mind-map ./mindmap.json

# Data Table
notebooklm generate data-table "compare key concepts"
notebooklm download data-table ./data.csv

# Report
notebooklm generate report --template study-guide
```

### CLI Features the Web UI Doesn't Expose

- Batch downloads of all artifacts of a type
- Quiz/Flashcard export as JSON, Markdown, or HTML
- Mind map hierarchical JSON extraction
- Data table CSV export
- Slide deck as editable PPTX (web UI only offers PDF)
- Individual slide revision with natural-language prompts
- Report template customization with extra instructions
- Save chat answers/history as notebook notes
- Source fulltext access (retrieve indexed text of any source)
- Programmatic sharing and permissions management

### CLI Quick Reference

| Task | Command |
|------|---------|
| Authenticate | `notebooklm login` |
| Diagnose auth | `notebooklm auth check --test` |
| List notebooks | `notebooklm list` |
| Create notebook | `notebooklm create "Title"` |
| Set context | `notebooklm use <notebook_id>` |
| Show context | `notebooklm status` |
| Add URL source | `notebooklm source add "https://..."` |
| Add file | `notebooklm source add ./file.pdf` |
| Add YouTube | `notebooklm source add "https://youtube.com/..."` |
| List sources | `notebooklm source list` |
| Delete source | `notebooklm source delete <source_id>` |
| Wait for source | `notebooklm source wait <source_id>` |
| Web research | `notebooklm source add-research "query"` |
| Chat | `notebooklm ask "question"` |
| Chat with refs | `notebooklm ask "question" --json` |
| Save answer as note | `notebooklm ask "question" --save-as-note` |
| Show history | `notebooklm history` |
| Get source fulltext | `notebooklm source fulltext <source_id>` |
| Get source guide | `notebooklm source guide <source_id>` |
| List languages | `notebooklm language list` |
| Set language | `notebooklm language set <code>` |
| Export metadata | `notebooklm metadata --json` |
| Check sharing | `notebooklm share status` |

### Autonomy Rules (CLI)

**Run automatically (no confirmation):** `status`, `auth check`, `list`, `source list`, `artifact list`, `language list/get/set`, `use`, `create`, `ask` (without `--save-as-note`), `history`, `source add`

**Ask before running:** `delete`, `generate *` (long-running), `download *` (writes files), `ask --save-as-note`, `history --save`

### Parallel Agent Considerations

The CLI stores notebook context in `~/.notebooklm/context.json`. Multiple concurrent agents using `notebooklm use` can overwrite each other's context. Solutions:
1. Always pass explicit `--notebook <id>` or `-n <id>` instead of relying on `use`
2. Set unique `NOTEBOOKLM_HOME` per agent: `export NOTEBOOKLM_HOME=/tmp/agent-$ID`

---

## Approach 2: Browser Automation — Fallback

Use browser automation when: CLI auth is broken, you need visual debugging, or you're doing something the CLI doesn't support yet.

### Authentication (One-Time)

```bash
# Option A: Via CLI (preferred)
notebooklm login

# Option B: Via browser automation scripts
python scripts/run.py auth_manager.py setup    # Opens visible browser for Google login
python scripts/run.py auth_manager.py status   # Check auth state
python scripts/run.py auth_manager.py reauth   # Re-authenticate
python scripts/run.py auth_manager.py clear    # Clear saved auth
```

### Studio Features via Browser

To generate a NotebookLM Studio artifact (slide deck, audio, etc.) from a YouTube video via browser:

1. Open NotebookLM: `browser action=open profile=clawd targetUrl=https://notebooklm.google.com`
2. Click "Create new notebook" button
3. In the source dialog, click "Websites" button
4. Type the YouTube URL into the text field (use `kind=type` not `kind=fill`)
5. Click "Insert" — source will appear in left panel
6. In the Studio panel (right side), click the desired artifact type (Slide Deck, Audio Overview, Mind Map, etc.)
7. Generation starts immediately server-side

### Download Slides as PDF (Browser)

```bash
python scripts/run.py download_slides.py
python scripts/run.py download_slides.py --notebook-url "https://notebooklm.google.com/notebook/..."
python scripts/run.py download_slides.py --output ~/Desktop/my_slides.pdf
python scripts/run.py download_slides.py --show-browser
```

### Q&A via Browser Scripts

**Always use the `run.py` wrapper** — never call scripts directly:

```bash
# ✅ CORRECT
python scripts/run.py ask_question.py --question "Your question"
python scripts/run.py ask_question.py --question "..." --notebook-url "https://..."
python scripts/run.py ask_question.py --question "..." --notebook-id ID
python scripts/run.py ask_question.py --question "..." --show-browser

# ❌ WRONG — fails without venv
python scripts/ask_question.py --question "..."
```

### Notebook Library Management (Browser Scripts)

```bash
python scripts/run.py notebook_manager.py list
python scripts/run.py notebook_manager.py add \
  --url "URL" --name "Name" --description "Description" --topics "topic1,topic2"
python scripts/run.py notebook_manager.py search --query "keyword"
python scripts/run.py notebook_manager.py activate --id notebook-id
python scripts/run.py notebook_manager.py remove --id notebook-id
```

**Smart Add (recommended when details unknown):** Query the notebook first, then add with discovered metadata:
```bash
python scripts/run.py ask_question.py --question "What is the content of this notebook? What topics are covered?" --notebook-url "[URL]"
python scripts/run.py notebook_manager.py add --url "[URL]" --name "[discovered]" --description "[discovered]" --topics "[discovered]"
```

### Data Cleanup (Browser Scripts)
```bash
python scripts/run.py cleanup_manager.py                    # Preview
python scripts/run.py cleanup_manager.py --confirm          # Execute
python scripts/run.py cleanup_manager.py --preserve-library # Keep notebooks
```

---

## Follow-Up Mechanism

Every NotebookLM answer ends with: **"Is that ALL you need to know?"**

Required behavior:
1. Compare the answer to the user's original request
2. If gaps exist, immediately ask follow-up questions (via CLI `ask` or browser scripts)
3. Continue until information is complete
4. Synthesize all answers before responding to user

## Data Storage

- **CLI data:** `~/.notebooklm/` (auth, context, config)
- **Browser script data:** `~/.claude/skills/notebooklm/data/` (library.json, auth_info.json, browser_state/)

Both are gitignored. Never commit credentials.

## Configuration

Optional `.env` file in skill directory (browser automation only):
```env
HEADLESS=false
SHOW_BROWSER=false
STEALTH_ENABLED=true
TYPING_WPM_MIN=160
TYPING_WPM_MAX=240
DEFAULT_NOTEBOOK_ID=
```

For CLI configuration, see `notebooklm --help` or [docs/configuration.md](https://github.com/teng-lin/notebooklm-py/blob/main/docs/configuration.md).

## Decision Flow

```
User mentions NotebookLM / wants research / wants content generation
    ↓
Try CLI first: notebooklm status
    ↓
If not authenticated → notebooklm login (or python scripts/run.py auth_manager.py setup)
    ↓
Create/select notebook → notebooklm create / notebooklm use <id>
    ↓
Add sources → notebooklm source add "URL/file/YouTube"
    ↓
Query or generate → notebooklm ask "..." / notebooklm generate <type>
    ↓
Download artifacts → notebooklm download <type> ./output
    ↓
If CLI fails → fall back to browser automation scripts
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| CLI not found | `pip install "notebooklm-py[browser]"` |
| Auth fails (CLI) | `notebooklm auth check --test`, then `notebooklm login` |
| Auth fails (browser) | Browser must be visible: `--show-browser` flag |
| Rate limit (50/day) | Wait or switch Google account |
| Browser crashes | `python scripts/run.py cleanup_manager.py --preserve-library` |
| Notebook not found | `notebooklm list` or `python scripts/run.py notebook_manager.py list` |
| CLI context conflicts | Use explicit `-n <id>` instead of `notebooklm use` |
| ModuleNotFoundError | Use `run.py` wrapper for browser scripts |

## Limitations

- **CLI:** Uses undocumented Google APIs; may break without notice. Not affiliated with Google.
- **Browser automation:** Slower (browser overhead per operation), no session persistence between questions.
- **Both:** Rate limits on free Google accounts (~50 queries/day).

## Resources

- **CLI docs:** [github.com/teng-lin/notebooklm-py](https://github.com/teng-lin/notebooklm-py)
- **Skill scripts:** `scripts/` directory (ask_question.py, notebook_manager.py, etc.)
- **References:** `references/api_reference.md`, `references/troubleshooting.md`, `references/usage_patterns.md`
