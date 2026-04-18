---
name: bulk-import-skills-from-git
description: Import skills from a GitHub repository (like exiao/skills or any skills bundle) into ~/.hermes/skills/, resolving naming conflicts and preserving directory structure. Use when a user shares a skills repo URL or wants to install a skills pack.
---

# Bulk Import Skills from Git Repository

## When to use
- User provides a GitHub URL to a skills repository
- User wants to install a skills pack or bundle
- You discover a new skills repo and want to add it to Hermes

## Trigger patterns
- "download all skills from <repo>"
- "import skills from <url>"
- "clone <repo> and add the skills"
- "add all skills from exiao/skills"

## Step-by-step workflow

### Step 1 — Clone the repo
1. Use `rm -rf /tmp/exiao-skills` first (or matching dir name) to clear any stale directory from previous attempts
   - Note: The rm may require approval — if blocked, ask the user to approve or try a different temp location
2. `git clone <repo-url> /tmp/exiao-skills`
   - Always use `workdir` and provide an absolute path to avoid "cd: permission denied" issues

### Step 2 — Discover all skills
```bash
find /tmp/exiao-skills -name "SKILL.md" | wc -l
find /tmp/exiao-skills -name "SKILL.md" -exec dirname {} \;
```
This gives you the count and all skill directory paths (preserves nested sub-skills).

### Step 3 — Compare against existing skills
Check `~/.hermes/skills/` for conflicts:
```bash
find ~/.hermes/skills -type d | sort
```

The skill name is the parent directory of SKILL.md. If a directory with that name already exists under `~/.hermes/skills/`, skip it.

### Step 4 — Copy non-conflicting skills
Use a delegate_task (subagent) with terminal toolset to do the heavy lifting. The goal should instruct the subagent to:
1. Find all SKILL.md files in the cloned repo
2. For each, identify the skill directory (parent of SKILL.md)
3. Check if the same directory name already exists under ~/.hermes/skills/
4. If NOT present, copy the entire directory preserving structure (including references/, scripts/, templates/, etc.)
5. If present, skip it
6. Report counts and listing

Example subagent goal:
```
Copy all skills from /tmp/<repo-dir>/ into ~/.hermes/skills/, preserving directory structure. For each SKILL.md:
1. Get the parent directory name (this is the skill name)
2. Check if it already exists in ~/.hermes/skills/ (search top-level and nested)
3. If NOT present: copy the full directory
4. If present: skip
Report: count copied, count skipped, list of both.
```

### Step 5 — Clean up
```bash
rm -rf /tmp/<repo-dir>
```

## Pitfalls
- `/tmp/<repo-dir>` may be a stale non-git directory from a previous failed clone — always `rm -rf` first
- The rm may trigger approval prompts for recursive delete in /tmp — if blocked, ask the user to approve
- Browser-based navigation (browser_navigate) may not work if Playwright browsers aren't installed — always fall back to `git clone` + terminal
- `~/.hermes/.env` is write-protected — you CANNOT append env vars from the agent side. Tell the user to add keys manually with `echo "KEY=VALUE" >> ~/.hermes/.env`
- Nested skills (e.g., app-store-connect/crash-triage) share the naming collision check on their basename, not their full path
- Always copy the FULL skill directory (not just SKILL.md) — sub-skills often have references/, scripts/, templates/ that are needed
- After `rm -rf /tmp/<repo-dir>`, the shell's CWD may become invalid (the deleted directory). Always pass `workdir` explicitly (e.g., `/Users/testuser`) to subsequent terminal commands, or `cd` to a safe location first
- Use `cp -rn` for safe non-destructive copy: the `-n` flag never overwrite existing files, giving an extra safety layer beyond the directory-name collision check

## Related knowledge
- External skills repos: exiao/skills, hermes-agent/skills (bundled)
- Skills live in `~/.hermes/skills/` with optional category subdirectories
- After copying, skills are discovered automatically — no restart needed