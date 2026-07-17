# Stale-evidence gate — recipe

Run this BEFORE asserting any finding you measured by reading on-disk artifacts
(fixtures, sample workspaces, cached exports, data dumps). It stops the
"confidently wrong, flips on fresh data" failure.

## Why it exists

A finding measured against stale data is a guess wearing a measurement's clothes.
The trap is worst when what you're measuring is itself regenerated each run
(an LLM-authored schema, label set, vocabulary, or output format): one snapshot
is a sample of one, and a property that looks stable in it may just be incidental
to that run.

## The gate (run all four, then state the basis)

```bash
# 1. DATE the artifact you're about to measure.
ls -lt <path/to/artifact>
# fixtures/ and evals/ files are PINNED — treat as months-behind prod, never
# generalize from them to "what the pipeline does now".

# 2. Find the ACTUALLY newest instance, by real mtime, not the path you assumed.
find . -name '<artifact-filename>' -not -path '*/node_modules/*' -newermt 'yesterday' 2>/dev/null \
  | xargs ls -lt 2>/dev/null | head
# also sort candidate run dirs by mtime:
ls -dt <runs-or-workspace-glob>/ | head

# 3. If runs execute REMOTELY (Modal/CI/cloud) and land in object storage / a DB,
#    the local copies are whatever someone pulled down — usually old. Confirm:
date                          # what is "today"?
# if nothing local is from today/yesterday, the honest line is:
#   "freshest on disk is <X> (stale); to measure a current run, pull from <store> first"

# 4. Compare 2-3 RECENT instances if the artifact is regenerated per run.
#    A property that DIFFERS across them cannot be the target of a deterministic check.
for d in <recent-run-1> <recent-run-2> <recent-run-3>; do
  echo "== $d =="; grep -iE '<the-property-you-rely-on>' "$d/<artifact>"
done
```

## State the basis in the finding

Every measured finding names its dated basis:

> "Measured across QRVO_2026-05-27 and AVGO_2026-06-01 (freshest with both files
>  on disk; real runs land in R2)."

A finding with no named, dated basis should be treated as provisional. If you
can't get current data, say the conclusion is provisional on stale input and name
exactly what you'd need to confirm it — do not promote it to a verdict.

## Heuristic: stable-target test

Before proposing ANY deterministic check (lint, assertion, schema validation)
against a generated artifact, prove the target is stable across runs. If the
headers / labels / field names / structure drift run-to-run, there is nothing
stable to check against, and the real fix is upstream (pin the schema / enum at
generation time, or move the value into a deterministic data source) — not a
check layered on top of moving output.

## Step 5: ANCHOR TO THE SPEC before concluding "no stable target"

Drift across samples does NOT prove "there's no rule." It can equally mean you're
looking at PRE-SPEC output, or samples from both sides of a format change. When the
artifact is produced by a process that has a source-of-truth definition — a prompt,
a schema, a skill/SKILL.md that dictates the format, a JSON schema, a lint rule —
read THAT before declaring the structure unstable.

Seen this session: appendix-H tiers looked LLM-invented and drifting across three
older runs → concluded "no stable schema, blocked." Wrong. The compiler skill
(`SKILL.md`) defined a canonical lint-gated table with a fixed five-tier vocabulary;
the "drift" was just runs that predated that pinning. Reading the spec flipped the
verdict from blocked to shippable, and the freshest fixture then matched the spec
28/30 with zero violations.

```bash
# find the spec that governs the artifact's format, not just more samples of it
grep -rln -iE '<artifact-name>|<the-format-keywords>' \
  skills/ specs/ prompts*.py *.md 2>/dev/null | grep -vE 'workspace|fixtures|outputs'
# then read the canonical format block and the controlled vocabulary it defines
```

Decision rule: a drifting sample + a pinned spec = your samples are old (or
pre-pinning); trust the spec and re-measure on the newest output. A drifting sample
+ NO spec anywhere = genuinely unstable; the fix is upstream (add the spec/enum),
not a check on moving output. Never conclude "unstable, can't check" from samples
alone — only after you've looked for and failed to find a governing spec.

