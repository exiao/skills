# Bloom search and collections flakiness in Stably

## Symptom

A Stably Playwright run fails or times out while testing Bloom portfolio/search flows that rely on stock search results. Common manifestations:

- Searching `AAPL` does not produce a clickable `Apple Inc` result in headless/Stably.
- Results show ETF-like symbols first, such as `AAPW`, `AAPY`, or `AAPD`.
- Tests wait on `getByText('Apple Inc')` or company-name selectors and time out.
- The Ideas/Collections page does not expose the expected global stock search input, so search-from-collections specs fail even though collection navigation works.

## Root cause pattern

These tests accidentally depend on Algolia/live search ordering and availability. That makes them brittle in CI/headless even when the product is healthy. Search should only be exercised by tests whose purpose is search. Portfolio CRUD and collection navigation tests should reach state through deterministic app paths.

## Better refactor pattern

1. Identify the actual behavior under test.
   - Portfolio create/edit/delete does not need stock search.
   - Collection page navigation does not need global search.
2. Replace search setup with deterministic internal navigation.
   - Use a stable collection URL such as `/collection/90` for Magnificent 7.
   - Use the page's `Copy collection to portfolio` button to create portfolio state.
   - Verify tickers inside the collection, using regex ticker selectors like `/AAPL/`, `/MSFT/`, `/GOOGL/`.
3. Click the ticker row/link directly from the collection when the test needs a stock detail page.
4. Keep selectors scoped and semantic: role+name or visible ticker text beats company names and `.nth()`.
5. Add cleanup for any state created by copy/bookmark/create flows.

## Example transformation

Brittle:

```ts
await page.getByPlaceholder(/search/i).fill('AAPL');
await page.getByText('Apple Inc').click();
```

Deterministic:

```ts
await page.goto(`${baseURL}/collection/90`);
await expect(page.getByText(/AAPL/)).toBeVisible();
await page.getByRole('button', { name: /copy collection to portfolio/i }).click();
```

Or for navigation:

```ts
await page.goto(`${baseURL}/collection/90`);
await page.getByRole('link', { name: /AAPL/ }).click();
await expect(page).toHaveURL(/\/stocks\/AAPL|\/stock\/AAPL/);
```

## Verification

After patching, run only the affected specs with the Stably reporter first, then inspect the generated run URL. A known successful targeted run for this pattern was `a8nzs43jgx8v91u9m3tcep2q`, covering:

- `tests/all-tests/assert-portfolio-features-around-add-edit-and-delete-work-fine.spec.ts`
- `tests/all-tests/verify-search-and-collections.spec.ts`

Use this as a pattern, not as a fixed dependency. Collection IDs and routes can change, so confirm the current app route before hardcoding a new one.
