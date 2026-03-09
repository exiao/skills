---
name: stably-sdk-rules
description: Best practices for writing Stably AI-powered Playwright tests. Use when writing, reviewing, or debugging tests in bloom-tests that use @stablyai/playwright-test — covers when to use aiAssert vs raw Playwright, agent.act, extract, getLocatorsByAI, and email flows.
---

# Stably SDK Rules

Source: https://skills.sh/stablyai/agent-skills/stably-sdk-rules

## Quick Rules

- Prefer raw Playwright for deterministic actions/assertions (faster + cheaper).
- Prioritize reliability over cost when Playwright becomes brittle.
- Use `agent.act()` for canvas, coordinate-based drag/click, or unstable multi-step flows.
- Use `expect(...).aiAssert()` for dynamic visual assertions; keep prompts specific.
- Use `page.extract()` / `locator.extract()` when you need visual-to-data extraction.
- Use `page.getLocatorsByAI()` when semantic selectors are hard with standard locators.
- Use Inbox for OTP/magic-link/verification email flows.
- All prompts must be self-contained; never rely on implicit previous context.
- Keep `agent.act()` tasks small; do loops/calculations/conditionals in code.
- Use `fullPage: true` only if content outside viewport matters.
- Always add `.describe("...")` to locators for trace readability.
- For email isolation, use unique `Inbox.build({ suffix })` per test and clean up.

## Setup

```bash
npm install -D @playwright/test @stablyai/playwright-test @stablyai/email
export STABLY_API_KEY=YOUR_KEY
export STABLY_PROJECT_ID=YOUR_PROJECT_ID
```

```ts
import { test, expect } from "@stablyai/playwright-test";
import { Inbox } from "@stablyai/email";
```

## Assertion Choice

- Use **Playwright assertions first** (faster, deterministic)
- Use **aiAssert** for dynamic/visual-heavy checks only
- Scope aiAssert to a locator when possible (faster + cheaper than full page)

## Interaction Choice

- Use **Playwright** for deterministic steps
- Use **agent.act** for brittle or semantic tasks (especially canvas/coordinates)

## Prompt Quality

- Include explicit target, intent, and constraints
- Pass cross-step data through variables, not vague references
- Never rely on previous step context in a prompt

## Usage Patterns

### aiAssert

```ts
await expect(page).aiAssert("Shows revenue trend chart and spotlight card", { timeout: 60000 });
await expect(page.locator(".header").describe("Header")).aiAssert("Has nav, avatar, and bell icon");
// fullPage: true only when assertion needs off-screen content
```

### extract

```ts
const orderId = await page.extract("Extract the order ID from the first row");

// With schema:
import { z } from "zod";
const Schema = z.object({ revenue: z.string(), users: z.number() });
const metrics = await page.extract("Get revenue and active users", { schema: Schema });
```

### getLocatorsByAI (requires Playwright >= 1.54.1)

```ts
const { locator, count } = await page.getLocatorsByAI("the login button");
expect(count).toBe(1);
await locator.describe("Login button located by AI").click();
```

### agent.act

```ts
await agent.act("Find the first pending order and mark it as shipped", { page });
// Good: compute values in code, then pass concrete values into the prompt
```

### Inbox (Email Isolation)

```ts
const inbox = await Inbox.build({ suffix: `test-${Date.now()}` });
await page.getByLabel("Email").describe("Email input").fill(inbox.address);

const email = await inbox.waitForEmail({ subject: "verification", timeoutMs: 60_000 });
const { data: otp } = await inbox.extractFromEmail({
  id: email.id,
  prompt: "Extract the 6-digit OTP code",
});
await inbox.deleteAllEmails();
```

### Auth Flows (Google)

```ts
import { authWithGoogle } from "@stablyai/playwright-test/auth";

await authWithGoogle({
  context,
  email: process.env.GOOGLE_AUTH_EMAIL!,
  password: process.env.GOOGLE_AUTH_PASSWORD!,
  otpSecret: process.env.GOOGLE_AUTH_OTP_SECRET!,
});
```

Required env vars: `GOOGLE_AUTH_EMAIL`, `GOOGLE_AUTH_PASSWORD`, `GOOGLE_AUTH_OTP_SECRET`. Use a dedicated test account only.

## Troubleshooting

- **aiAssert is slow/flaky:** scope to a locator, tighten prompt, avoid unnecessary `fullPage: true`
- **agent.act fails:** split into smaller tasks, pass explicit constraints, raise `maxCycles` only when needed
- **Email timeout:** verify subject/from filter and use unique inbox suffixes

## Bloom-Specific Config

Bloom tests live at `~/bloom-tests` (or `/tmp/bloom-tests-fix` for fixes). Key settings:
```ts
timeout: 300000,        // 5 min per test (AI chat flows are slow)
expect: { timeout: 60000 },  // 60s per assertion (aiAssert needs time)
```

Run with: `STABLY_API_KEY=... STABLY_PROJECT_ID=... BASE_URL=https://bloom.onrender.com stably test`

## Links

- Docs: https://docs.stably.ai
- npm: https://www.npmjs.com/package/@stablyai/playwright-test
- Email package: https://www.npmjs.com/package/@stablyai/email
