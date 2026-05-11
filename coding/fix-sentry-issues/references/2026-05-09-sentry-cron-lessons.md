# 2026-05-09 Sentry cron lessons

Context: scheduled Bloom Sentry fixer scanned the 10 most frequent issues seen in the last 12h, audited recently resolved issues, wrote the plan, and opened PRs #1655 and #1656.

## Sentry MCP/API quirks

- The documented MCP command `mcporter call sentry.list_issues ...` failed with `Tool list_issues not found`.
- Fallback that worked:
  ```bash
  sentry api '/api/0/organizations/$SENTRY_ORG/issues/?query=lastSeen:-12h&sort=freq&limit=10' --method GET \
    | jq '[.[] | {id,shortId,project:.project.slug,title,culprit,permalink,status,count,userCount,firstSeen,lastSeen,level,logger,type,issueType,metadata}]'
  ```
- `mcporter list sentry` showed the tool is currently named `search_issues`, but the raw `sentry api` endpoint gave the most deterministic sort/filter behavior for the cron workflow.

## Resolved-issue audit lesson

- `statusDetails.inCommit` can point to unrelated commits. Example: INVEST-54D was resolved by a frontend paywall spacing commit and INVEST-5EC by an earnings-calendar commit. Treat unrelated resolving commits as `NOISE_SUPPRESSION / unrelated resolution`, then decide whether the issue is current and real enough to reopen.
- Do not reopen solely because the resolving commit is unrelated. External 404 fetches may still be legitimate tool-miss noise, and stale resolved issues outside the current hot set can be noted without creating a PR.

## Fix patterns discovered

### OpenAI Agents trace IDs

Sentry issue INVEST-5V0 showed `openai.agents` logging `Invalid 'data[0].trace_id': 'd43538c'. Expected an ID that begins with 'trace_'.`

Root cause in Bloom: `bloom_backend/views/chat_agent_simple.py` generated trace IDs with `str(uuid.uuid4())[:7]` and passed them to `RunConfig(trace_id=...)` and the durable workflow.

Fix pattern:
```python
def generate_agents_trace_id() -> str:
    return f"trace_{uuid.uuid4().hex}"
```
Use it for every OpenAI Agents tracing path.

### Capacitor Badge plugin on Android

Sentry issue BLOOM-FRONTEND-WEB-MF showed `"Badge" plugin is not implemented on android` from `pushNotificationService.ts`.

Root cause: code called `Badge.clear()` on all native platforms. Some Android installs do not have the plugin implemented or supported.

Fix pattern:
```ts
if (!Capacitor.isPluginAvailable('Badge')) return;
const result = await Badge.isSupported();
if (!result.isSupported) return;
await Badge.clear();
```
Treat unavailable/unsupported badge as a no-op and log warning, not error.

## Testing pitfalls

- `uv run python -m pytest -n0 ...` still hit `async def functions are not natively supported` for existing `@pytest.mark.asyncio` tests in this worktree. Use sync tests for focused verification when possible, plus `compileall` for syntax checks, and document the async plugin issue in the PR body.
- Frontend lint via `bun run lint -- <file>` is not reliable because the package script ignores positional file narrowing and runs `prettier --check src`. Use direct binaries after `bun install` for a changed-file check:
  ```bash
  cd frontend
  ./node_modules/.bin/prettier --check src/services/pushNotificationService.ts
  ./node_modules/.bin/eslint --ext=ts,tsx src/services/pushNotificationService.ts
  ```
