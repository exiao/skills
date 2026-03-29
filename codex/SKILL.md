---
name: codex
description: Get a second opinion from OpenAI Codex CLI — code review (pass/fail), adversarial challenge, or open consultation. Use when asked for "codex review", "second opinion", or "ask codex".
---
# codex — Multi-AI Second Opinion

> Adapted from [garrytan/gstack](https://github.com/garrytan/gstack/blob/main/codex/SKILL.md) (MIT).
> Stripped gstack preamble/telemetry/plan-file dependencies for standalone use.

OpenAI Codex CLI wrapper for getting an independent second opinion from a different AI.
Three modes: code review (pass/fail gate), adversarial challenge, and open consultation
with session continuity.

Use when asked to "codex review", "codex challenge", "ask codex", "second opinion",
or "consult codex".

---

## Step 0: Check codex binary

```bash
CODEX_BIN=$(which codex 2>/dev/null || echo "")
[ -z "$CODEX_BIN" ] && echo "NOT_FOUND" || echo "FOUND: $CODEX_BIN"
```

If `NOT_FOUND`: stop and tell the user:
"Codex CLI not found. Install it: `npm install -g @openai/codex` or see https://github.com/openai/codex"

---

## Step 1: Detect base branch

Determine which branch this PR targets:

1. Check if a PR already exists: `gh pr view --json baseRefName -q .baseRefName`
2. If no PR, detect default branch: `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`
3. Fall back to `main`.

Use this as "the base branch" in all subsequent steps.

---

## Step 2: Detect mode

Parse the user's input:

1. `/codex review` or `/codex review <instructions>` → **Review mode** (Step 3A)
2. `/codex challenge` or `/codex challenge <focus>` → **Challenge mode** (Step 3B)
3. `/codex` with no arguments → **Auto-detect:**
   - Check for a diff: `git diff origin/<base> --stat 2>/dev/null | tail -1 || git diff <base> --stat 2>/dev/null | tail -1`
   - If a diff exists, ask the user:
     - A) Review the diff (code review with pass/fail gate)
     - B) Challenge the diff (adversarial, try to break it)
     - C) Something else (provide a prompt)
   - If no diff, ask: "What would you like to ask Codex?"
4. `/codex <anything else>` → **Consult mode** (Step 3C), remaining text is the prompt

---

## Step 3A: Review Mode

Run Codex code review against the current branch diff.

1. Create temp file for stderr:
```bash
TMPERR=$(mktemp /tmp/codex-err-XXXXXX.txt)
```

2. Run the review (5-minute timeout):
```bash
codex review --base <base> -c 'model_reasoning_effort="xhigh"' --enable web_search_cached 2>"$TMPERR"
```

If the user provided custom instructions (e.g., `/codex review focus on security`):
```bash
codex review "focus on security" --base <base> -c 'model_reasoning_effort="xhigh"' --enable web_search_cached 2>"$TMPERR"
```

3. Parse cost from stderr:
```bash
grep "tokens used" "$TMPERR" 2>/dev/null || echo "tokens: unknown"
```

4. Determine gate verdict:
   - Output contains `[P1]` → gate is **FAIL**
   - No `[P1]` markers (only `[P2]` or none) → gate is **PASS**

5. Present the output:

```
CODEX SAYS (code review):
════════════════════════════════════════════════════════════
<full codex output, verbatim — do not truncate or summarize>
════════════════════════════════════════════════════════════
GATE: PASS                    Tokens: 14,331
```

or `GATE: FAIL (N critical findings)`

6. Clean up:
```bash
rm -f "$TMPERR"
```

---

## Step 3B: Challenge (Adversarial) Mode

Codex tries to break your code: edge cases, race conditions, security holes, failure modes.

1. Construct the adversarial prompt:

Default (no focus):
"Review the changes on this branch against the base branch. Run `git diff origin/<base>` to see the diff. Your job is to find ways this code will fail in production. Think like an attacker and a chaos engineer. Find edge cases, race conditions, security holes, resource leaks, failure modes, and silent data corruption paths. Be adversarial. Be thorough. No compliments — just the problems."

With focus (e.g., "security"):
"Review the changes on this branch against the base branch. Run `git diff origin/<base>` to see the diff. Focus specifically on SECURITY. Your job is to find every way an attacker could exploit this code. Think about injection vectors, auth bypasses, privilege escalation, data exposure, and timing attacks. Be adversarial."

2. Run codex exec with JSONL output (5-minute timeout):
```bash
codex exec "<prompt>" -s read-only -c 'model_reasoning_effort="xhigh"' --enable web_search_cached --json 2>/dev/null | python3 -c "
import sys, json
for line in sys.stdin:
    line = line.strip()
    if not line: continue
    try:
        obj = json.loads(line)
        t = obj.get('type','')
        if t == 'item.completed' and 'item' in obj:
            item = obj['item']
            itype = item.get('type','')
            text = item.get('text','')
            if itype == 'reasoning' and text:
                print(f'[codex thinking] {text}')
                print()
            elif itype == 'agent_message' and text:
                print(text)
            elif itype == 'command_execution':
                cmd = item.get('command','')
                if cmd: print(f'[codex ran] {cmd}')
        elif t == 'turn.completed':
            usage = obj.get('usage',{})
            tokens = usage.get('input_tokens',0) + usage.get('output_tokens',0)
            if tokens: print(f'\ntokens used: {tokens}')
    except: pass
"
```

3. Present full output:

```
CODEX SAYS (adversarial challenge):
════════════════════════════════════════════════════════════
<full output from above, verbatim>
════════════════════════════════════════════════════════════
Tokens: N
```

---

## Step 3C: Consult Mode

Ask Codex anything about the codebase. Supports session continuity for follow-ups.

1. Check for existing session:
```bash
cat .context/codex-session-id 2>/dev/null || echo "NO_SESSION"
```

If a session exists, ask the user:
- A) Continue the conversation (Codex remembers prior context)
- B) Start a new conversation

2. Run codex exec with JSONL output (5-minute timeout):

For a **new session:**
```bash
codex exec "<prompt>" -s read-only -c 'model_reasoning_effort="xhigh"' --enable web_search_cached --json 2>/dev/null | python3 -c "
import sys, json
for line in sys.stdin:
    line = line.strip()
    if not line: continue
    try:
        obj = json.loads(line)
        t = obj.get('type','')
        if t == 'thread.started':
            tid = obj.get('thread_id','')
            if tid: print(f'SESSION_ID:{tid}')
        elif t == 'item.completed' and 'item' in obj:
            item = obj['item']
            itype = item.get('type','')
            text = item.get('text','')
            if itype == 'reasoning' and text:
                print(f'[codex thinking] {text}')
                print()
            elif itype == 'agent_message' and text:
                print(text)
            elif itype == 'command_execution':
                cmd = item.get('command','')
                if cmd: print(f'[codex ran] {cmd}')
        elif t == 'turn.completed':
            usage = obj.get('usage',{})
            tokens = usage.get('input_tokens',0) + usage.get('output_tokens',0)
            if tokens: print(f'\ntokens used: {tokens}')
    except: pass
"
```

For a **resumed session:**
```bash
codex exec resume <session-id> "<prompt>" -s read-only -c 'model_reasoning_effort="xhigh"' --enable web_search_cached --json 2>/dev/null | python3 -c "
<same python streaming parser as above>
"
```

3. Save session ID for follow-ups:
```bash
mkdir -p .context
# Save the SESSION_ID from parser output to .context/codex-session-id
```

4. Present full output:

```
CODEX SAYS (consult):
════════════════════════════════════════════════════════════
<full output, verbatim — includes [codex thinking] traces>
════════════════════════════════════════════════════════════
Tokens: N
Session saved — run /codex again to continue this conversation.
```

5. After presenting, note any points where Codex's analysis differs from your own
   understanding. Flag disagreements: "Note: Claude disagrees on X because Y."

---

## Model & Reasoning

- **Model:** No model hardcoded. Codex uses its current default (frontier agentic model).
  If the user specifies a model (e.g., `-m gpt-5.1-codex-max`), pass `-m` through.
- **Reasoning:** All modes use `xhigh` for maximum reasoning power.
- **Web search:** All commands use `--enable web_search_cached` for doc/API lookups.

---

## Error Handling

- **Binary not found:** Detected in Step 0. Stop with install instructions.
- **Auth error:** "Codex authentication failed. Run `codex login` to authenticate via ChatGPT."
- **Timeout (5 min):** "Codex timed out. The diff may be too large or the API slow. Try again or use a smaller scope."
- **Empty response:** "Codex returned no response. Check stderr for errors."
- **Session resume failure:** Delete the session file and start fresh.

---

## Important Rules

- **Never modify files.** This skill is read-only. Codex runs in read-only sandbox mode.
- **Present output verbatim.** Do not truncate, summarize, or editorialize Codex's output. Show it in full inside the CODEX SAYS block.
- **Add synthesis after, not instead of.** Any Claude commentary comes after the full output.
- **5-minute timeout** on all codex calls.
- **No double-reviewing.** If `/review` was already run, Codex provides a second independent opinion. Don't re-run Claude's own review.
