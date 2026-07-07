# How a dynamic workflow actually runs (v2.1.202)

Sourced by disassembling the installed `claude` binary (`strings` on the Mach-O) plus reading session transcript JSONL. No JSON build artifact exists; a workflow is a JS/TS **script string**.

## Where the script lives

- **Ad-hoc `ultracode` run:** the script is NOT a standalone file. It's embedded in the session transcript as a `Workflow` tool_use with a `script` field:
  `~/.claude/projects/<path-slug>/<session-uuid>.jsonl`.
  Extract it: iterate the JSONL, find `message.content[]` entries where `type=="tool_use"` and `name=="Workflow"`, read `input.script`.
- **Saved workflow** (`s` in the `/workflows` viewer, or "save as command"): becomes a slash command under `.claude/commands/<name>.md`.
- **Bundled** (`/deep-research`): compiled into the binary.

## How it executes

The script string runs in a **sandboxed Node VM context** (`vm.runInContext`) created with `codeGeneration: {strings:false, wasm:false}`, so no `eval`, no `new Function`, no wasm. There's a per-run timeout. Claude Code injects orchestration globals into the sandbox; the script calls them:

- `agent(prompt: string, opts?): Promise<any>`, spawn one subagent.
  - No `schema` → resolves to the subagent's final text (string).
  - With `opts.schema` (a JSON Schema) → subagent is forced to call a StructuredOutput tool; resolves to the validated object (no parsing).
  - Resolves `null` if the user skips the agent mid-run or it dies on a terminal API error after retries → `.filter(Boolean)`.
  - `opts`: `label`, `phase`, `model`, `effort` ('low'|'medium'|'high'|'xhigh'|'max'), `isolation: 'worktree'` (fresh git worktree, ~200-500ms + disk, only for parallel file-mutating agents), `agentType` (e.g. 'general-purpose', 'code-reviewer'; composes with schema). Omit `model`/`effort` to inherit the session's.
- `parallel(fns[])`, run stages concurrently.
- `pipeline(...)`, chained stages.
- `phase(title: string): void`, start a progress group; later `agent()` calls group under it. Inside `parallel`/`pipeline`, pass `opts.phase` per-agent instead to avoid racing the global phase state.
- `budget: {total: number|null, spent(): number, remaining(): number}`, token target from a "+500k"-style user directive, HARD ceiling, shared across the whole turn (main loop + all workflows). `spent() >= total` makes further `agent()` calls throw. Use for dynamic loops (`while (budget.total && budget.remaining() > 50_000)`) or fleet sizing (`budget.total ? Math.floor(budget.total/100_000) : 5`).
- `log(x)`, `console.{log,info,debug,error,warn}`, prefixed logging into the run.

## Limits

- **One level of nesting.** Calling `workflow()` inside a child workflow throws: "nesting is limited to one level. Inline the inner script or call its agents directly." A top-level script CAN call `workflow('<name>')` to invoke another *named/bundled* workflow, unless `CLAUDE_WORKFLOW_NAME_ONLY` restricts it.
- **Resumable.** Each run gets a `wf_<id>` runId. Relaunch with `Workflow({scriptPath, resumeFromRunId: "wf_..."})` and completed `agent()` calls return **cached** instead of re-spawning. Background workflows orphaned by a process exit are handed to the next session wake via an `adopt.json` "exit handoff".
- **Security:** the permission classifier evaluates the `script` field as a delegation payload, same as an Agent tool `prompt`. It reads the script body AND any embedded `agent(...)` prompts, blocking only if the delegated action itself is on the block list.

## Reference shape: the bundled deep-research workflow

```
Scope → pipeline( Search → URL-dedup → Fetch+Extract ) → 3-vote Verify → Synthesize
```

Distinctive moves from its source:
- `parallel(DIMENSIONS.map(d => () => agent(d.prompt, {schema: FINDINGS_SCHEMA})))`, fan out across angles.
- Adversarial verify: `agent('Try to refute: ${claim}. Default to refuted=true if uncertain.', {schema: VERDICT})` run as a 3-vote, then filter claims that don't survive. This cross-check is the quality pattern plain `TaskDelegate` fan-out does NOT give you.
- Invoked with args: `Workflow({name: 'deep-research', args: '<question>'})`; the script reads the global `args`.

## How to inspect a run yourself

```bash
# find the transcript for a project dir
ls ~/.claude/projects/  # dir names are the cwd path with / → -
# pull every Workflow script out of a session
python3 - <<'EOF'
import json
f="$HOME/.claude/projects/<slug>/<uuid>.jsonl"
for line in open(f):
    o=json.loads(line); msg=o.get("message",{})
    for c in (msg.get("content") or []) if isinstance(msg,dict) else []:
        if isinstance(c,dict) and c.get("type")=="tool_use" and c.get("name")=="Workflow":
            print(c["input"].get("script",""))
EOF
```
