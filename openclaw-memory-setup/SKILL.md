---
name: openclaw-memory-setup
description: Set up a complete memory system for an OpenClaw instance. Covers workspace files, vector search with embeddings, compaction with automatic memory flush, heartbeat-driven memory maintenance, and daily/long-term memory patterns. Use when someone wants their OpenClaw agent to remember things across sessions.
---

# OpenClaw Memory Setup

## Overview

OpenClaw memory is plain Markdown in the agent workspace. The model only "remembers" what gets written to disk. This skill sets up the full memory stack: workspace files, vector semantic search, automatic compaction flush, and agent instructions that make it all work together.

## Prerequisites

- A running OpenClaw instance (`openclaw gateway` or daemon)
- An API key for embeddings (Gemini, OpenAI, Voyage, Mistral, or a local model)
- Access to the OpenClaw config at `~/.openclaw/openclaw.json`

## Reference Documentation

- Memory concepts: https://docs.openclaw.ai/concepts/memory
- Memory config reference: https://docs.openclaw.ai/reference/memory-config
- Agent workspace layout: https://docs.openclaw.ai/concepts/agent-workspace
- Compaction: https://docs.openclaw.ai/concepts/compaction
- Heartbeat: https://docs.openclaw.ai/gateway/heartbeat

## Step 1: Set Up the Workspace Directory

The workspace is the agent's home. Default location: `~/.openclaw/workspace`. Override with `agents.defaults.workspace` in config.

Create the directory structure:

```bash
WORKSPACE="${OPENCLAW_WORKSPACE:-$HOME/.openclaw/workspace}"
mkdir -p "$WORKSPACE/memory"
mkdir -p "$WORKSPACE/plans"
mkdir -p "$WORKSPACE/plans/archive"
```

## Step 2: Create Core Workspace Files

### AGENTS.md (operating instructions)

This is the most important file. It tells the agent HOW to use memory. Create `$WORKSPACE/AGENTS.md`:

```markdown
# AGENTS.md

## Every Session

1. Read `SOUL.md`, `USER.md`, `memory/YYYY-MM-DD.md` (today + yesterday)
2. Also read `MEMORY.md` (never load in shared/group contexts for privacy)

## Memory

- **Daily notes:** `memory/YYYY-MM-DD.md` — raw logs of what happened
- **Long-term:** `MEMORY.md` — curated memories, main session only
- Write it down. "Mental notes" don't survive restarts. **Text > Brain.**
- When corrected, log in MEMORY.md under "Lessons Learned" with specifics.
- Periodically review daily files and update MEMORY.md with what's worth keeping.
- **Memory recall:** Use both `memory_search` (semantic) AND `grep`/`rg` (exact match) when looking things up. Vector search misses exact strings; grep misses fuzzy concepts. Do both.

## How to Approach Tasks

1. Plan mode for non-trivial tasks (3+ steps). Write plans in `plans/<task-name>.md`.
2. Use sub-agents for parallel work. One task per sub-agent.
3. Update plan files as you complete steps.
4. Verify work before marking complete.
5. After corrections: update `MEMORY.md` under "Lessons Learned".
```

### MEMORY.md (long-term curated memory)

Create `$WORKSPACE/MEMORY.md`:

```markdown
# MEMORY.md - Long-term Memory

> Store durable facts here: preferences, decisions, people, lessons learned.
> Daily logs go in memory/YYYY-MM-DD.md instead.

## People

(Add people the agent interacts with: name, contact info, context)

## Preferences

(User preferences, communication style, tools, workflows)

## Lessons Learned

(Mistakes made, corrections received, patterns to avoid)

## Active Context

(Current projects, important state, things the agent needs to know)
```

### SOUL.md (persona and tone)

Create `$WORKSPACE/SOUL.md`:

```markdown
# SOUL.md

## Vibe

Direct, concise, casual. No corporate speak. Say what you mean.

## Boundaries

- Private things stay private.
- Ask before acting externally (sending messages, posting, deploying).

## Continuity

These files are your memory. Read them. Update them.
```

### USER.md (about the human)

Create `$WORKSPACE/USER.md`:

```markdown
# USER.md

- **Name:** (your name)
- **Timezone:** (e.g. America/New_York)
- **Communication:** (how you like to be talked to)
```

### HEARTBEAT.md (periodic check instructions)

Create `$WORKSPACE/HEARTBEAT.md`:

```markdown
# HEARTBEAT.md

## Sub-Agent Follow-Up
- Run `sessions_list(kinds: ["sub-agent"], activeMinutes: 120)` to find recent sub-agents
- If any completed without sending results, handle it now
- If any timed out, report the failure
```

## Step 3: Configure Vector Memory Search

Memory search lets the agent semantically find relevant notes even when wording differs. Add to `~/.openclaw/openclaw.json`:

### Option A: Gemini Embeddings (free tier available)

```json5
{
  agents: {
    defaults: {
      memorySearch: {
        enabled: true,
        sources: ["memory", "sessions"],
        provider: "gemini",
        model: "gemini-embedding-001",
        remote: {
          apiKey: "YOUR_GEMINI_API_KEY"
        },
        store: {
          vector: {
            enabled: true
          }
        }
      }
    }
  }
}
```

Set the Gemini API key. Get one at https://aistudio.google.com/app/apikey. Also set it as an env var so cron jobs can use it:

```json5
{
  env: {
    GEMINI_API_KEY: "YOUR_GEMINI_API_KEY"
  }
}
```

### Option B: OpenAI Embeddings

```json5
{
  agents: {
    defaults: {
      memorySearch: {
        enabled: true,
        sources: ["memory", "sessions"],
        provider: "openai",
        model: "text-embedding-3-small",
        remote: {
          apiKey: "YOUR_OPENAI_API_KEY"
        },
        store: {
          vector: {
            enabled: true
          }
        }
      }
    }
  }
}
```

### Option C: Ollama (local, no API key)

```json5
{
  agents: {
    defaults: {
      memorySearch: {
        enabled: true,
        sources: ["memory"],
        provider: "ollama",
        model: "nomic-embed-text"
      }
    }
  }
}
```

### Session Memory (experimental, recommended)

Index past session transcripts so the agent can recall previous conversations:

```json5
{
  agents: {
    defaults: {
      memorySearch: {
        experimental: {
          sessionMemory: true
        }
      }
    }
  }
}
```

## Step 4: Configure Compaction with Memory Flush

When a session gets long, OpenClaw compacts (summarizes) older messages. Before compaction, it triggers a silent turn that reminds the agent to write durable notes to disk.

```json5
{
  agents: {
    defaults: {
      compaction: {
        mode: "safeguard",
        memoryFlush: {
          enabled: true,
          softThresholdTokens: 40000,
          prompt: "Distill this session to memory/YYYY-MM-DD.md. Focus on decisions, state changes, lessons, blockers. If nothing worth saving: NO_FLUSH",
          systemPrompt: "Extract only what is worth remembering. No fluff."
        }
      }
    }
  }
}
```

This ensures important context survives compaction automatically. The agent writes notes to the daily file, then compaction summarizes the conversation.

## Step 5: Configure Heartbeat for Memory Maintenance

Heartbeats run periodic agent turns. Use them for memory hygiene and proactive check-ins.

```json5
{
  agents: {
    defaults: {
      heartbeat: {
        every: "1h",
        model: "anthropic/claude-sonnet-4-6",  // use a cheaper model for heartbeats
        target: "signal",  // or "telegram", "whatsapp", "last", "none"
        to: "+1XXXXXXXXXX",  // your phone number or chat ID
        prompt: "Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK."
      }
    }
  }
}
```

## Step 6: Enable Internal Hooks

Internal hooks handle workspace file loading (boot-md) and session memory indexing:

```json5
{
  hooks: {
    internal: {
      enabled: true,
      entries: {
        "boot-md": { enabled: true },
        "session-memory": { enabled: true }
      }
    }
  }
}
```

## Step 7: Set Up Nightly Memory Maintenance (Optional)

Create a cron job that periodically reviews and organizes memory files. This keeps daily logs from accumulating without curation.

Use the OpenClaw cron tool or CLI:

```json5
// Via openclaw cron add or the cron tool
{
  name: "memory-maintenance",
  schedule: { kind: "cron", expr: "0 2 * * *", tz: "America/New_York" },
  sessionTarget: "isolated",
  payload: {
    kind: "agentTurn",
    message: "Review memory files from the past week. Move important decisions, preferences, and lessons from daily files (memory/YYYY-MM-DD.md) into MEMORY.md under the appropriate section. Remove duplicates. Keep daily files as-is (they are the raw log). If MEMORY.md has stale entries, update or remove them."
  }
}
```

## Step 8: Back Up Your Workspace (Recommended)

Treat the workspace as private memory. Put it in a private git repo:

```bash
cd "$WORKSPACE"
git init
git add AGENTS.md SOUL.md TOOLS.md IDENTITY.md USER.md HEARTBEAT.md MEMORY.md memory/
git commit -m "Initial workspace setup"

# Add a private remote
gh repo create openclaw-workspace --private --source . --remote origin --push
```

Add a `.gitignore`:

```
.DS_Store
.env
**/*.key
**/*.pem
**/secrets*
```

## Complete Config Example

Here is a full working `~/.openclaw/openclaw.json` snippet covering all memory-related settings:

```json5
{
  agents: {
    defaults: {
      workspace: "~/.openclaw/workspace",
      
      // Memory search (vector + session recall)
      memorySearch: {
        enabled: true,
        sources: ["memory", "sessions"],
        experimental: { sessionMemory: true },
        provider: "gemini",
        model: "gemini-embedding-001",
        remote: {
          apiKey: "YOUR_GEMINI_API_KEY",
          batch: { enabled: false }
        },
        store: {
          vector: { enabled: true }
        }
      },
      
      // Compaction with pre-compaction memory flush
      compaction: {
        mode: "safeguard",
        memoryFlush: {
          enabled: true,
          softThresholdTokens: 40000,
          prompt: "Distill this session to memory/YYYY-MM-DD.md. Focus on decisions, state changes, lessons, blockers. If nothing worth saving: NO_FLUSH",
          systemPrompt: "Extract only what is worth remembering. No fluff."
        }
      },
      
      // Heartbeat for periodic checks
      heartbeat: {
        every: "1h",
        model: "anthropic/claude-sonnet-4-6",
        target: "last",
        prompt: "Read HEARTBEAT.md if it exists. Follow it strictly. If nothing needs attention, reply HEARTBEAT_OK."
      }
    }
  },
  
  // Internal hooks for workspace file loading
  hooks: {
    internal: {
      enabled: true,
      entries: {
        "boot-md": { enabled: true },
        "session-memory": { enabled: true }
      }
    }
  },
  
  // Gemini API key for embeddings (also available to cron jobs)
  env: {
    GEMINI_API_KEY: "YOUR_GEMINI_API_KEY"
  }
}
```

## How Memory Works End-to-End

1. **Session start**: OpenClaw loads AGENTS.md, SOUL.md, USER.md, IDENTITY.md from workspace. Agent reads today + yesterday daily files and MEMORY.md.
2. **During conversation**: Agent writes notes to `memory/YYYY-MM-DD.md` as things happen. Important durable facts go to `MEMORY.md`.
3. **Memory recall**: When asked about something from the past, agent uses `memory_search` (semantic vector search) and `grep` (exact match) to find relevant notes.
4. **Pre-compaction flush**: When the context window fills up, OpenClaw triggers a silent turn. The agent writes any unsaved context to the daily file before compaction summarizes the conversation.
5. **Heartbeat**: Hourly, the agent checks HEARTBEAT.md for tasks, reviews sub-agent status, and can proactively reach out.
6. **Nightly maintenance**: A cron job curates daily files into MEMORY.md, keeping long-term memory clean.

## Verification

After setup, restart the gateway and test:

```bash
openclaw gateway restart
```

Then message the agent: "Remember that my favorite color is blue." Wait a minute, then start a new session and ask: "What's my favorite color?" The agent should find it via memory search.

Check memory search is working:

```bash
openclaw memory search "favorite color"
```

## Troubleshooting

- **Memory search returns nothing**: Check that `memorySearch.enabled: true` and the embedding API key is valid. Run `openclaw doctor` for diagnostics.
- **Agent doesn't read workspace files**: Ensure `hooks.internal.entries.boot-md.enabled: true`.
- **Compaction flush not firing**: Check `compaction.memoryFlush.enabled: true` and that the session is long enough to trigger it.
- **Heartbeat not running**: Verify `heartbeat.every` is set and `target` points to a valid channel. Check `openclaw status` for heartbeat timing.
- **Cron jobs can't use embeddings**: Set `GEMINI_API_KEY` (or your provider's key) in `env.vars` in the config so isolated sessions inherit it.
