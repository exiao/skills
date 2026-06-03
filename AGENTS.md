# Skills Repo Conventions

> This file is read by Codex GitHub code review (it loads `AGENTS.md` by name). The `CODEX-ONLY` block below carries review instructions for Codex. Keep this block within the first ~32 KiB of the file (Codex stops reading past `project_doc_max_bytes`, 32 KiB default). Do not replace this file with a symlink — Codex does not follow symlinks for AGENTS.md.

<!-- CODEX-ONLY:START -->
## Code Review Instructions (Codex)

Review this PR for a PUBLIC repo of agent skills (Claude Code, Hermes Agent, Codex, OpenClaw). Each skill is a `SKILL.md` with YAML frontmatter plus optional references/scripts/assets. Because the repo is public, credential/PII leaks and broken references are the highest-value finds.

Operate with a skeptical, evidence-driven mindset. Verify every claim against the actual code in the diff and its surrounding call paths. Distinguish confirmed bugs from assumptions. You may be wrong; accuracy is the shared objective. Optimize for precision: the author acts on every finding, so a false alarm costs more than a missed nit.

**Find these, in priority order:**

1. **Leaks & correctness** (weight highest):
   - Hardcoded credentials, API keys, tokens, product IDs, or auth strings (must use `$ENV_VAR_NAME`).
   - Personal data: emails, phone numbers, account balances, internal URLs, personal directory paths.
   - Broken internal references: a `SKILL.md` pointing to a reference/script/asset file that doesn't exist.
   - Inaccurate CLI commands (e.g. `bloom quote`/`bloom peers`/`bloom ratings` don't exist — `bloom info` covers them). Verify referenced commands are real.
   - Frontmatter invalid or missing `name`/`description`; description that's marketing copy instead of a routing instruction with trigger phrases.
   - Product names wrongly bulk-renamed ("Hermes Agent", "OpenClaw", "Claude Code", "Codex" are real — keep as-is).
2. **Scope & coherence:** does the PR do one logical thing? README.md updated when skills are added/removed/renamed?
3. **Security:** any path that would execute untrusted content or embed a real secret in a script.

**Evidence gates — satisfy each before flagging, or say you can't and lower confidence:**

1. **Trace the call path.** For "reads the wrong thing / never runs / breaks at runtime," cite the line that writes the value, registers the route, or defines the behavior. If it's not in the diff or nearby code, mark confidence LOW and label "Needs author confirmation" instead of asserting a bug.
2. **Runtime-context check.** Scripts here run inside agent harnesses with the user's own environment. A `$ENV_VAR` placeholder is correct, not a bug — only flag literal secrets. Skill content describing dangerous-sounding operations is documentation, not execution.
3. **No fabrication.** Never invent endpoints, schemas, secrets, versions, or test results. If a claim can't be proven from the provided context, say so explicitly.
4. **No repeats.** If a prior review thread resolved or declined this exact issue, do not re-raise it.

**Severity (assign honestly, do not inflate):**

- **P0** = actively exploitable security hole or guaranteed production data loss/corruption. Merge-blocking. Rare. Unsure it's exploitable → not P0.
- **P1** = breaks production at runtime: crash, wrong data served, endpoint unreachable, or a real correctness/regression bug that ships broken behavior.
- **P2** = correctness issue that degrades behavior without breaking prod.
- **P3** = style, robustness, test gaps, and all documentation.
- Documentation, comments, and "update the README/docs" are **P3, never higher**. Bundle all doc suggestions into ONE comment.

**Do NOT flag:** style/naming, pre-existing issues not introduced by this PR, issues on unmodified lines, "this could be slightly better," premature optimization, or error handling for scenarios needing multiple unlikely conditions. Do NOT flag a skill description for "missing detail" if it already states what it does + when to use it + trigger phrases.

**Each finding must include:** (a) the concrete failure scenario ("when X hits Y, Z breaks"), (b) the evidence line/SHA, (c) a one-line fix. A vague concern → omit it.

**End every review with one line:** `N P0, M P1, K P2, J P3 — top issue: <one sentence>`. Zero P0/P1/P2 → "No blocking issues."
<!-- CODEX-ONLY:END -->

A public repo of skills for Claude Code, [Hermes Agent](https://github.com/NousResearch/hermes-agent), and other skill-aware agents (Codex, OpenClaw). Every directory at root is a **category** containing related skills (except `.github/`).

## Repo Structure

```
category-name/
├── DESCRIPTION.md            # Category description
└── skill-name/
    ├── SKILL.md              # Entry point (required)
    ├── references/           # Detailed docs, checklists, examples
    ├── scripts/              # Deterministic code (Python, JS, bash)
    └── assets/               # Templates, images, static resources
```

## Categories

| Category | What's inside |
|----------|--------------|
| **app-store** | App Store Connect API, ASO keyword optimization, screenshots, iOS simulators |
| **coding** | PR babysitting, Sentry issue fixes, code simplification, deploy verification, QA dogfooding |
| **design** | UI/UX design, design systems (Impeccable), frontend design, slides, Excalidraw diagrams, brand identity, Remotion, stickers |
| **external-services** | CLI integrations for third-party APIs (Appfigures, Apple Search Ads, DataForSEO, Firecrawl, Google Ads, Grok, Higgsfield, Meta Ads, Porkbun, Prometheus, Render, Stably, Typefully, etc.) |
| **investing** | Stock research, portfolio analysis, market intelligence (coming soon) |
| **memory** | Memory management — garbage collection, setup, and recall from past sessions |
| **skills-meta** | Creating, auditing, improving skills; MCP port management; prompt optimization |
| **thinking** | Brainstorming, office hours frameworks (YC, Sahil), synthetic user studies, planning, perspective shifts |
| **video** | Character creation, video editing, production (Kling, Sora, Remotion, ElevenLabs), YouTube content, thumbnails |
| **writing** | Writing, copywriting, content strategy, editing, content evaluation, hooks, outlines, positioning, content pipeline, research (last30days) |

## Skill Conventions

- `SKILL.md` must have YAML frontmatter with `name` and `description`.
- `description` is a routing instruction for the model, not a human summary. Include trigger phrases.
- Keep `SKILL.md` under 500 lines. Move details to `references/`.
- No README.md, CHANGELOG.md, or human-facing docs inside skill directories.

## Frontmatter Format

```yaml
---
name: my-skill
description: What this skill does and when to invoke it. Include trigger phrases.
---
```

Only `name` and `description` are required. No metadata block needed.

## Writing Good Descriptions

The `description` field is the primary routing signal. When a user says "help me with X," the agent picks a skill based on description match. Bad descriptions cause misroutes or skills that never get invoked.

**Do:**
- Start with what the skill does, then when to use it
- Include literal trigger phrases ("Use when: babysit this PR, watch PR, monitor PR")
- Mention the specific tools/CLIs involved ("via the Serper API", "using bloom-cli")
- Be specific about scope boundaries ("For visual execution, use frontend-design instead")

**Don't:**
- Write marketing copy ("A powerful toolkit for...")
- Be vague ("Helps with development tasks")
- Duplicate another skill's trigger phrases

## Cross-Referencing Other Skills or CLIs

When a skill references third-party tools or CLIs, verify the commands actually exist. Common mistakes:

- `bloom quote` → doesn't exist, use `bloom info` (includes price, ratings, peers)
- `bloom peers` → doesn't exist, use `bloom info`
- `bloom ratings` → doesn't exist, use `bloom info`

For bloom CLI command discovery, run `bloom --help` or `bloom <command> --help`. Common commands include: `bloom info`, `bloom price`, `bloom financials`, `bloom screen`, `bloom earnings`, `bloom technicals`, `bloom news`, `bloom sentiment`.

When referencing another skill, use its exact `name` from frontmatter (not folder name or a guess).

## Rules

1. **No hardcoded credentials.** Use `$ENV_VAR_NAME` for tokens, API keys, auth strings, product IDs. This repo is public.
2. **No personal data.** No emails, phone numbers, account balances, or internal URLs.
3. **Update README.md** when adding, removing, or renaming skills.
4. **Don't rename product names.** "Hermes Agent", "OpenClaw", "Claude Code", "Codex" etc. are real product names. Use them as-is in skill content. Don't bulk-rename references to match a metadata convention.
5. **Prefer portable paths.** Use workspace-relative paths or well-known config paths (`~/.hermes/`, `~/.openclaw/`, `~/clawd/`). Avoid paths to personal directories (e.g. `~/Documents/personal/...`).

## PR Guidelines

- One logical change per PR. Don't stack unrelated changes.
- Branch from `main`. Don't stack branches on other feature branches.
- If CI (claude-review) flags issues, fix them before requesting merge.
- Check all three comment sources for review feedback: inline comments, issue comments, and review verdicts.

## CI

`claude-code-review.yml` runs on every PR. It checks:

- Frontmatter validity (name + description present, description is a routing instruction)
- Hardcoded secrets or personal data
- Broken internal references (referenced files that don't exist)
- Accuracy of CLI commands and tool references
- Scope and coherence (does the PR do one thing?)

CI failures from bad credentials (401) are infra issues — retry the run, don't change code.

The reviewer posts as `github-actions[bot]`. It may request changes. Fix real issues; dismiss stale reviews after fixing.
