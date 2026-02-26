# Advanced: LLM-as-Judge Fixture

For subjective criteria (tone, aesthetics, UX):

Create `src/lib/llm-review.ts`:

```typescript
interface ReviewResult {
  pass: boolean;
  feedback?: string;
}

async function createReview(config: {
  criteria: string;
  artifact: string; // text or screenshot path
}): Promise<ReviewResult>;
```

Sub-agents discover and use this pattern for binary pass/fail checks.
