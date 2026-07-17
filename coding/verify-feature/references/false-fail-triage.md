# False-FAIL triage: red tests that are your machine, not the code

When a local test sweep returns failures, classify them BEFORE reporting or
"fixing." Most local-only failures fall into three buckets. Run this recipe.

## 0. Group, don't read everything

Never read N tracebacks one by one. Bucket first:

```bash
# pull just the FAILED lines, group by file/class
grep '^FAILED' sweep.txt | awk -F'::' '{print $1}' | sort | uniq -c | sort -rn
```

Pull ONE representative traceback per bucket and classify the bucket as a whole.

## 1. Did my branch even touch the failing file?

```bash
git diff origin/<base>...HEAD -- path/to/test_or_source.py
```

Empty diff -> the failure is pre-existing or environmental, NOT introduced by your
change. Report it that way; do NOT edit source you didn't change to silence it.

## 2. Exported env var overriding config defaults

The single most common false-FAIL. The config file ships a default (e.g.
`allow_private_urls: false`) and a test asserts that behavior, but your shell has
an export that flips it.

```bash
env | grep -i <PROJECT_PREFIX>          # e.g. grep -i HERMES
# re-run stripping the suspect var(s):
env -u HERMES_ALLOW_PRIVATE_URLS python -m pytest tests/path -q
```

The config file is what CI's clean runner sees. An exported override is your box
only. If unsetting the var turns the bucket green, it's environmental.

## 3. macOS tmp paths vs Linux-written tests

Tests written against Linux `/tmp` break on macOS because:
- pytest `tmp_path` resolves under `/var/folders/...`, which sensitive-path guards
  (anything blocking `/var`, `/etc`, system dirs) correctly reject.
- `AF_UNIX` socket binds there exceed macOS's 104-char `sun_path` limit ->
  `OSError: AF_UNIX path too long`.

```bash
mkdir -p /tmp/ptmp
TMPDIR=/tmp/ptmp python -m pytest tests/path -q
```

If failure count drops sharply (10 -> 1 here), the bucket was the macOS path, not
the code.

## 4. OS-specific tests

Linux-only tests (pulse/ALSA sockets, `/proc`, epoll specifics) can't pass on macOS
at all. On the real CI matrix they're skipped/guarded per-platform, so they are not
failures of your change. Don't chase them locally.

## Reporting

If a bucket is environmental, the verdict for the CHANGE is still PASS. Report:

> N failures, all environmental: M from an exported `HERMES_ALLOW_PRIVATE_URLS=true`
> (config default is false), K from macOS `/var/folders` tmp paths, J OS-specific.
> None touch the files this branch changed. Green on CI's clean Linux runners.

Never weaken an assertion or patch unrelated source to make a machine-specific
failure disappear.
