# Adding CI to a New Repo: Checklist

When adding a CI workflow (from `templates/ci-python-uv.yml`) to a repo that never had one:

## Steps

1. **Ensure ruff is in dependencies.** Check `pyproject.toml` for ruff in dev/test/eval extras. If missing, add `"ruff>=0.5"` to the appropriate optional-dependencies group.

2. **Run ruff locally first.** `uv run ruff check .` will likely find issues in repos that never had a linter. Run `--fix` for auto-fixable ones (unused imports, f-string without placeholders), then handle the rest manually:

   - **F841 (unused variable):** Prefix with underscore: `_var = ...`
   - **F401 in try/except:** Remove unused names from the import line
   - **E402 (import not at top):** If intentional (e.g. CLI files that interleave imports with command registration, or imports after sys.path manipulation), either add `# noqa: E402` per line or add a per-file-ignores config in pyproject.toml:
     ```toml
     [tool.ruff.lint.per-file-ignores]
     "src/app/cli.py" = ["E402"]
     ```
   - **E402 after sys.path setup:** Add `# noqa: E402` to the specific import lines

3. **Adapt the template.** Key things to change per repo:
   - `python-version`: match `requires-python` in pyproject.toml
   - Ruff target path: `.` for flat repos, `src/` for src-layout repos
   - `uv sync` flags: `--all-extras` to include dev/test deps
   - Extra env vars if tests need them (e.g. `DISABLE_CACHE: "1"`)

4. **Verify tests pass locally.** `uv run pytest -v --tb=short` before pushing.

5. **Commit lint fixes WITH the CI workflow** in the same PR so the first CI run is green. Don't add CI in one PR and fix lint in a follow-up.

## Common patterns seen in the wild

- **Typer CLI apps** (like research-cli): imports interleaved with `app.command()` registration are intentional E402s. Use per-file-ignores.
- **Scripts with sys.path manipulation** (like run_research.py): imports after `sys.path.insert()` are necessary E402s. Use inline `# noqa: E402`.
- **Hypothesis imports in try/except:** Only import the specific names you use (e.g. `given`) and remove `settings`, `assume` etc. if unused.
- **Eval/test files with unused variables:** Common in assertion-heavy test files. Prefix with `_` rather than deleting, as the assignment may document intent.
