#!/usr/bin/env python3
"""No-fallback smoke probe for Hermes google-gemini-cli / Code Assist.

Run from a hermes-agent checkout:
    python ~/.hermes/skills/ai-tools/hermes-agent/scripts/gemini_cli_no_fallback_probe.py

Optional env:
    GEMINI_MODEL=gemini-3.1-pro-preview
    GEMINI_PROMPT='Use no tools. Reply exactly: GEMINI_DIRECT_OK'

This intentionally disables the fallback chain so a printed success cannot come
from Codex/Grok/etc. It redacts API-key-looking substrings in error output.
"""

from __future__ import annotations

import os
import re
import sys


def _redact(text: object) -> str:
    s = str(text)
    s = re.sub(r"ya29\.[A-Za-z0-9._-]+", "[REDACTED]", s)
    s = re.sub(r"(sk-[A-Za-z0-9_-]{12,})", "[REDACTED]", s)
    return s


def main() -> int:
    try:
        from run_agent import AIAgent
    except Exception as exc:  # pragma: no cover, diagnostic script
        print("IMPORT_ERROR", _redact(exc))
        print("Run this from a hermes-agent checkout with its venv active.")
        return 2

    model = os.environ.get("GEMINI_MODEL", "gemini-3.1-pro-preview")
    prompt = os.environ.get("GEMINI_PROMPT", "Use no tools. Reply exactly: GEMINI_DIRECT_OK")

    agent = AIAgent(
        provider="google-gemini-cli",
        model=model,
        quiet_mode=False,
        enabled_toolsets=[],
    )
    # Critical: otherwise Hermes may print the expected text from fallback.
    agent._fallback_chain = []

    try:
        result = agent.run_conversation(prompt)
    except Exception as exc:  # pragma: no cover, diagnostic script
        print("EXCEPTION", type(exc).__name__, _redact(exc))
        return 1

    final = result.get("final_response")
    error = result.get("error")
    print("MODEL", model)
    print("FINAL", repr(final))
    print("ERROR", _redact(error) if error else None)
    return 0 if final and not error else 1


if __name__ == "__main__":
    raise SystemExit(main())
