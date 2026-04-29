---
name: memory-setup
description: Set up a persistent memory system for any AI coding agent (Claude Code, OpenCode, Assistant Runtime, OpenClaw, etc.). Covers workspace files, memory entry format, session-end extraction, daily garbage collection, multi-tier recall, and optional vector search. Use when someone wants their agent to remember things across sessions, set up memory, or configure persistent context.
---

# Memory Setup

Set up persistent memory for an AI coding agent so it remembers context, preferences, decisions, and lessons across sessions. This is agent-agnostic — works with Claude Code, OpenCode, Hermes Agent, OpenClaw, or any agent that can read/write files.

## Core Principle

AI agents have no memory between sessions unless you write things to disk. Memory = files. This skill sets up the file structure, entry format, lifecycle hooks, and maintenance routines that make memory work end-to-end.

---

## Architecture Overview

```
                    SESSION START
                    ─────────────
                    Load MEMORY.md + USER.md → system prompt (frozen snapshot)
                    Load SOUL.md / AGENTS.md / CLAUDE.md → operating instructions
                            │
                            ▼
                    DURING SESSION
                    ──────────────
                    Agent writes to MEMORY.md / USER.md via tool or direct edit
                    Full transcript saved to session store (SQLite, JSONL, etc.)
                            │
                            ▼
                    SESSION END
                    ───────────
                    Extract durable facts from transcript → MEMORY.md / USER.md
                    Write episode summary → episodes/YYYY-MM-DD.md
                            │
                            ▼
                    DAILY MAINTENANCE (memory-gc)
                    ────────────────────────────
                    Decay stale entries │ Drain pending overflow
                    Promote durable facts from episodes │ Prune old files
```

## Step 1: Create the Workspace

Pick a home directory for your agent's memory. Common conventions:

| Agent | Default Location |
|-------|-----------------|
| Claude Code | `~/.claude/` or project `.claude/` |
| OpenCode | `~/.opencode/` |
| Hermes Agent | `~/.hermes/` |
| OpenClaw | `~/.openclaw/workspace/` |
| Generic | `~/.agent/` |

```bash
WORKSPACE="$HOME/.agent"  # adjust for your agent
mkdir -p "$WORKSPACE/memories"
mkdir -p "$WORKSPACE/episodes"
mkdir -p "$WORKSPACE/plans"
mkdir -p "$WORKSPACE/plans/archive"
mkdir -p "$WORKSPACE/sessions"
```

## Step 2: Create Core Memory Files

### MEMORY.md — Long-term curated memory

The primary memory file. Loaded into system prompt at session start. Contains durable facts, preferences, project context, and lessons learned.

```markdown
# MEMORY.md

> Durable facts and context. Loaded every session.
> Entry format: [YYYY-MM-DD][category] content
> Categories: fact, pref, env, proj:<path>, rel:<name>, task, tmp, rule, meta

§
```

**Entry format:** `[YYYY-MM-DD][cat] content`

| Category | Purpose | Decay |
|----------|---------|-------|
| `fact` | Durable facts | 60 days |
| `pref` | User preferences | 60 days |
| `env` | Environment/infra | 30 days |
| `proj:<path>` | Project-specific context | 30 days |
| `rel:<name>` | Info about a person | Never |
| `task` | Active tasks/goals | 14 days |
| `tmp` | Ephemeral notes | 7 days |
| `rule` | Hard behavioral constraints | Never |
| `meta` | System configuration | Never |

**Rules:**
- Date = creation date only, never updated
- `§` separator between entries
- `[rule]` entries are hard constraints the agent must follow
- Keep under ~100 entries — use `memory-gc` to prune

### USER.md — User profile

Loaded every session alongside MEMORY.md. Contains stable info about the user.

```markdown
# USER.md

- **Name:** (your name)
- **Timezone:** (e.g. America/New_York)
- **Communication style:** (how you like to be talked to)
- **Key preferences:** (tools, languages, frameworks you prefer)
```

### SOUL.md — Agent persona (optional)

Sets tone, personality, and boundaries. Some agents load this automatically; others need it referenced in CLAUDE.md or AGENTS.md.

```markdown
# SOUL.md

## Vibe
Direct, concise, casual. No corporate speak.

## Boundaries
- Private things stay private
- Ask before acting externally (emails, posts, deploys)

## Continuity
These files are your memory. Read them. Update them.
```

### AGENTS.md / CLAUDE.md — Operating instructions

Tell the agent HOW to use memory. Add a memory section to your existing context file:

```markdown
## Memory

- **Capture is automatic.** Session-end hooks extract durable memories.
  For urgent items, write inline: `[YYYY-MM-DD][cat] content`
- **Entry format:** `[YYYY-MM-DD][cat] content`
  Categories: fact, pref, env, proj:<path>, rel:<name>, task, tmp, rule, meta
- **[rule] entries** are hard behavioral constraints for the session.
- **Past-session queries** → use recall skill (hot → episodes → sessions).
  Never fabricate history.
- **Never fabricate a creation date.** If unsure, use today's.
```

## Step 3: Session-End Memory Extraction

At the end of each session, extract durable facts from the conversation and write them to memory files. This can be done via:

### Option A: Agent hook/plugin (recommended)

If your agent supports session-end hooks, configure one that:
1. Pulls the last 30-40 turns from the session transcript
2. Sends them to a fast model (e.g. Haiku, GPT-4o-mini) with an extraction prompt
3. Writes extracted entries to MEMORY.md / USER.md
4. Writes an episode summary to `episodes/YYYY-MM-DD.md`

**Extraction prompt template:**

```
Review this conversation. Extract durable memories worth keeping.

Return JSON:
{
  "entries": [
    {"cat": "fact|pref|env|task|tmp|rule", "target": "MEMORY|USER", "content": "..."}
  ],
  "episode": {
    "summary": "One paragraph summary of the session",
    "tags": ["tag1", "tag2"]
  }
}

Rules:
- Only extract what's worth remembering across sessions
- Skip small talk, debugging noise, routine commands
- Prefer specific facts over vague summaries
- Use the correct category for each entry
- If nothing worth saving, return empty arrays
```

### Option B: Manual prompt at end of session

If hooks aren't available, end sessions with:

> "Before we end, write any important decisions, preferences, or facts from this session to MEMORY.md using the `[YYYY-MM-DD][cat] content` format."

### Option C: CLAUDE.md instruction

Add to your CLAUDE.md:

```markdown
## Session End
Before ending any session, review the conversation for durable facts, decisions,
or corrections. Write them to MEMORY.md in `[YYYY-MM-DD][cat] content` format.
Write a 1-paragraph episode summary to episodes/YYYY-MM-DD.md.
```

## Step 4: Episode Summaries

Episodes are daily session summaries that form the middle tier of recall. Each day gets one file with all sessions appended:

**File:** `episodes/YYYY-MM-DD.md`

```markdown
## Episode — 2:30 PM

**Summary:** Set up CI pipeline for the new API. Decided on GitHub Actions over CircleCI. Fixed a flaky test in the auth module.

**Tags:** devops, ci, testing, auth

---

## Episode — 7:15 PM

**Summary:** Reviewed PR #42, discussed pricing strategy for the Pro tier. User prefers value-based pricing over cost-plus.

**Tags:** code-review, pricing, product
```

## Step 5: Multi-Tier Recall

When the agent needs to remember something from the past, search in order:

| Tier | Source | Method | Speed |
|------|--------|--------|-------|
| 1. Hot memory | MEMORY.md + USER.md | Already in context | Instant |
| 2. Episodes | `episodes/*.md` | Grep by tag/date, then read | Fast |
| 3. Sessions | Raw transcripts | Full-text search (FTS5, ripgrep) | Slow |

**Stop when confidence plateaus.** Don't search deeper tiers if you already found the answer.

**Always use both:**
- **Semantic search** (vector/embedding) for fuzzy concept matching
- **Exact search** (grep/ripgrep) for specific strings, names, IDs

## Step 6: Daily Garbage Collection

Run `memory-gc` daily (via cron, scheduled task, or manual) to keep memory files clean:

1. **Decay:** Remove stale entries by category (tmp=7d, task=14d, env=30d, fact/pref=60d, rule/meta=never)
2. **Drain:** Process `.pending.md` overflow into MEMORY.md
3. **Promote:** Scan last 7 days of episodes, promote 0-3 durable facts not already in memory
4. **Prune:** Delete memory files >90 days old, session files >180 days

See the `memory-gc` skill for the full implementation.

## Step 7: Optional — Vector Search

For large memory stores, add semantic vector search:

```bash
# Example: index memory files with embeddings
# Provider options: OpenAI, Gemini, Voyage, Ollama (local)

# Gemini (free tier available)
# Get key at https://aistudio.google.com/app/apikey
export GEMINI_API_KEY="your-key"

# OpenAI
export OPENAI_API_KEY="your-key"
```

Configure your agent's memory search to index both `memories/` and `sessions/` directories. The exact config depends on your agent platform.

## Step 8: Overflow Handling

When MEMORY.md gets too large (>100 entries), new entries should go to `.pending.md` instead. The daily GC drains pending entries after decaying old ones to make room.

```
memories/
├── MEMORY.md          ← Hot memory (target: ~60-100 entries)
├── USER.md            ← User profile
├── .pending.md        ← Overflow queue (drained by memory-gc)
└── .gc.log            ← GC audit log
```

## Step 9: Backup

Treat your agent's memory as irreplaceable. Back it up:

```bash
cd "$WORKSPACE"
git init
echo -e ".DS_Store\n.env\n**/*.key\n**/*.pem\n**/secrets*" > .gitignore
git add memories/ episodes/ SOUL.md
git commit -m "Initial memory setup"

# Push to a PRIVATE repo
gh repo create agent-memory --private --source . --push
```

Consider a periodic backup (cron every 30 min or daily) that auto-commits and pushes.

## File Layout Summary

```
$WORKSPACE/
├── SOUL.md                 ← Agent persona (optional)
├── AGENTS.md / CLAUDE.md   ← Operating instructions
├── memories/
│   ├── MEMORY.md           ← Hot memory (loaded every session)
│   ├── USER.md             ← User profile (loaded every session)
│   ├── .pending.md         ← Overflow queue
│   └── .gc.log             ← GC audit log
├── episodes/
│   └── YYYY-MM-DD.md       ← Daily session summaries
├── sessions/
│   └── *.jsonl             ← Raw transcripts (optional)
├── plans/
│   ├── <task>.md            ← Active plans
│   └── archive/             ← Completed plans
└── skills/                  ← Skill definitions
```

## Verification

After setup, test the memory loop:

1. Tell your agent: "Remember that my favorite color is blue."
2. End the session (or trigger session-end extraction)
3. Start a new session
4. Ask: "What's my favorite color?"

The agent should find it in MEMORY.md or via recall.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Agent doesn't remember anything | Check MEMORY.md is being loaded into system prompt at session start |
| Memory grows unbounded | Set up memory-gc cron job, check decay rules |
| Session-end extraction misses things | Increase turn count in extraction (try 40-50), check model isn't skipping |
| Recall returns nothing | Use both grep (exact) AND semantic search (fuzzy) — one alone misses things |
| .pending.md keeps growing | GC isn't running or MEMORY.md is at capacity — decay more aggressively |
