# Inert-feature probe

A feature can pass every test and still do nothing in production, because the
tests feed it synthetic inputs the author built while the real corpus/pipeline
never reaches it. Run these checks BEFORE reporting a feature as helping. Each is
a one-liner; the OUTPUT is the verdict, not the green test suite.

Context: this came from a 4-PR batch where tests passed on all four but 3 were
inert. The tell was the user asking "try it on a memo" and "verify the other 3
that they actually help" — i.e. exercise it on real data, not the fixture.

## 1. Run the new code on the REAL corpus and read the output

```bash
# Import the new function, run it over actual production files (NOT the test
# fixtures), and look at what it produces. Look for: everything collapsing to a
# default/fallback value, empty results, or no-ops.
cd <repo> && PYTHONPATH=... python3 - <<'PY'
from pkg.new_module import the_new_fn
import glob, os
for f in sorted(glob.glob(os.path.expanduser("~/projects/<real-corpus>/*.md")))[:6]:
    out = the_new_fn(open(f).read(), os.path.basename(f))
    print(os.path.basename(f), "->", summarize(out))   # e.g. Counter of edge types
PY
```

If every result is the fallback case (e.g. all edges typed `mentions`, all rows
`unknown`), the feature's value-add never fired. That is FAIL, not PASS.

## 2. Count the trigger population

```bash
# A validator/feature only acts on inputs matching some condition. Count how many
# REAL inputs match. Zero = inert by construction.
grep -rln '^## Timeline' companies/ | wc -l     # -> 0 of 58: validates nothing real
grep -rln 'THE_MARKER' --include=*.py . | grep -v 'the_checker_itself' | wc -l
```

## 3. Trace wiring in BOTH directions

```bash
# PRODUCER: does anything construct the input type outside the module's own tests?
grep -rln 'TheInputType(' --include=*.py . | grep -v 'test_\|the_module_itself'
#   (empty -> nothing feeds it -> orphan)

# CONSUMER: does CI / the pipeline / the eval runner actually call it?
grep -rln '<new_fn>\|<new_module>' .github/workflows/ <pipeline_entrypoint>.py \
     <eval_runner_conftest>.py pyproject.toml
#   (empty -> nothing runs it -> dead code shipped green)
```

## 4. Durability: does anything DEFEND the feature on the next run?

The subtlest inert case passes probes 1-3 *today* and still rots. A one-time
migration can make the real corpus fire now (e.g. 56/56 pages validate), but if a
production writer regenerates that artifact every run and doesn't emit the new
structure, the next pipeline cycle overwrites it flat and the corpus drifts back
to inert. Tests stay green the whole time; the migration had a half-life of one
run per item.

Find the writer that REGENERATES the artifact and check it preserves/emits the
feature:

```bash
# Who writes this file/table, and does it emit the new structure or clobber it?
grep -rn 'write_text\|\.write(\|to_csv\|\.save()\|INSERT INTO <table>' --include=*.py <pkg>/
# Then read that writer: does it read the prior artifact and PRESERVE the
# feature's section, or does it build from scratch and overwrite?
```

- BAD: a migration adds `## Timeline` to 58 pages, but the publisher rebuilds each
  page from scratch with `page.write_text(...)` and never emits the section. Next
  run = flat page, pushed back to the repo. The migration defended nothing.
- GOOD: the publisher itself emits the section every run AND reads the prior
  artifact to preserve append-only history. Then the migration is a backfill of a
  structure production now maintains.

Verdict: a feature that fires now but has no defending producer is **not done** —
it needs the producer change (often in a different repo/module than the
migration). Ship them together, or the migration is cosmetic.

## 5. Adversary test for gates and validators

A gate is only as good as what it catches when someone is actually doing the
wrong thing. Write the violation the way a real developer would write it (no
self-labelling marker, no opt-in comment) and confirm the gate fires.

- BAD invariant: "sentinel comment must only appear in allowlisted files" —
  catches only a violator who labels their own rogue write. Fires on nobody.
- GOOD invariant: scan for the actual dangerous CALL (e.g. a raw DB write /
  `Table.insert(` / `os.system(`) in any non-allowlisted module. Fires on the
  real mistake.

## Verdict mapping

| Probe result | Report |
|---|---|
| Real-corpus output is all fallback / empty | FAIL — feature does not help on real data |
| Trigger population is 0 | FAIL — inert by construction; needs a migration/wiring first |
| No producer and no consumer | FAIL — orphan scaffolding, not a feature |
| Gate doesn't fire on a realistically-written violation | FAIL — theater; rethink the invariant |
| Real output shows the intended effect on real inputs | PASS — cite the output |

When inert: say so plainly, then either wire it (add the producer/CI call/
migration) or recommend closing the PR. Never report an inert feature as
"verified, tests pass." A doc or schema inside the PR can still have standalone
value — separate that from the code path that does nothing.
