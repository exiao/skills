---
name: context7
description: Use when writing code that uses a specific library or framework and you need accurate, current API docs — not year-old training data. Fetches version-specific documentation via Context7 MCP.
---

# Context7

Context7 pulls live, version-specific documentation straight from source repos and injects it into context. Eliminates hallucinated APIs and outdated code patterns.

## When to Use

- Coding tasks that reference a specific library or framework
- When you're unsure if an API is current
- When code generation might rely on stale training data (React hooks, Next.js config, Supabase client, etc.)
- Any time the user says "use context7" or "check the docs for X"

## How to Call

Context7 is a remote MCP server. Call it via mcporter (no auth required for basic use).

### Step 1: Resolve library ID

```
mcporter call https://mcp.context7.com/mcp.resolve-library-id libraryName=<name> query=<task>
```

Examples:
```
mcporter call https://mcp.context7.com/mcp.resolve-library-id libraryName=react query="useEffect hook"
mcporter call https://mcp.context7.com/mcp.resolve-library-id libraryName=nextjs query="middleware auth"
mcporter call https://mcp.context7.com/mcp.resolve-library-id libraryName=supabase query="realtime subscriptions"
```

Returns a `libraryId` like `/vercel/next.js` or `/supabase/supabase`.

### Step 2: Fetch docs

```
mcporter call https://mcp.context7.com/mcp.query-docs libraryId=<id> query=<task>
```

Example:
```
mcporter call https://mcp.context7.com/mcp.query-docs libraryId=/vercel/next.js query="middleware that checks JWT in cookies"
```

### Shortcut (known library)

If you already know the library ID, skip step 1:
```
mcporter call https://mcp.context7.com/mcp.query-docs libraryId=/facebook/react query="concurrent features"
```

## Tips

- Always pass `query` — it ranks results by relevance to your actual task
- For version-specific docs, include the version in the query: `"Next.js 14 App Router"`
- Common library IDs: `/vercel/next.js`, `/supabase/supabase`, `/django/django`, `/facebook/react`, `/tailwindlabs/tailwindcss`
- If resolve-library-id returns multiple matches, pick the one with the most tokens/snippets

## Tool Signature

**resolve-library-id**
- `libraryName` (required): Library name to search
- `query` (required): Task context for relevance ranking

**query-docs**
- `libraryId` (required): Context7 library ID (e.g., `/mongodb/docs`)
- `query` (required): Question or task to get docs for
- `tokens` (optional): Max tokens to return (default ~10000)
