#!/usr/bin/env python3
"""Checkpointing delegate-loop workflow harness (native Hermes equivalent of CC ultracode).

Plan lives in THIS script, not a conversation. Each "agent" = a tool-less POST to the
local billing proxy. State persists to checkpoint.json after every agent call, so a
kill mid-run resumes without re-doing completed work.

Usage: python3 workflow_harness.py [--reset]
"""
import json, os, sys, time, hashlib, urllib.request, urllib.error
from concurrent.futures import ThreadPoolExecutor

PROXY = "http://127.0.0.1:18801/v1/messages"
MODEL = "claude-haiku-4-5-20251001"
CKPT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "checkpoint.json")

CLAIMS = [
    "Nvidia's data-center revenue surpassed its gaming revenue for the first time in fiscal 2023.",
    "TSMC manufactures Nvidia's H100 GPU on its 3nm process node.",
    "Broadcom designs custom AI accelerators (XPUs) for Google.",
    "AMD's MI300 accelerator uses HBM3 memory.",
    "CoreWeave was originally an Ethereum cryptocurrency mining company.",
]

# ---- checkpoint: the durability mechanism ----
def load_ckpt():
    if os.path.exists(CKPT):
        return json.load(open(CKPT))
    return {"agents": {}}   # key -> result

def save_ckpt(c):
    tmp = CKPT + ".tmp"
    json.dump(c, open(tmp, "w"), indent=2)
    os.replace(tmp, CKPT)

CKPT_STATE = load_ckpt()

def agent(key, prompt, max_tokens=400):
    """One agent call. Cached by key: if this key is in the checkpoint, skip the API call.
    THIS is what makes the workflow fault-tolerant + resumable."""
    if key in CKPT_STATE["agents"]:
        print(f"  [cached] {key}", flush=True)
        return CKPT_STATE["agents"][key]
    print(f"  [run]    {key}", flush=True)
    body = json.dumps({"model": MODEL, "max_tokens": max_tokens,
                       "messages": [{"role": "user", "content": prompt}]}).encode()
    last = None
    for attempt in range(3):  # structured retry, deterministic
        try:
            req = urllib.request.Request(PROXY, data=body,
                headers={"content-type": "application/json", "anthropic-version": "2023-06-01"})
            r = json.load(urllib.request.urlopen(req, timeout=90))
            text = r.get("content", [{}])[0].get("text", "").strip()
            CKPT_STATE["agents"][key] = text
            save_ckpt(CKPT_STATE)   # checkpoint immediately, per call
            return text
        except Exception as e:
            last = e; time.sleep(1.5 * (attempt + 1))
    raise RuntimeError(f"agent {key} failed after retries: {last}")

def parallel(fns, workers=4):
    with ThreadPoolExecutor(max_workers=workers) as ex:
        return list(ex.map(lambda f: f(), fns))

# ---- the workflow (plan-in-code) ----
def phase1_research(i, claim):
    return agent(f"research:{i}", f"In 2-3 sentences, state the known facts relevant to "
                 f"evaluating this claim. Be specific with dates/numbers.\nClaim: {claim}")

def phase2_verify(i, claim, research, vote):
    # adversarial: try to REFUTE, default refuted if uncertain
    out = agent(f"verify:{i}:{vote}",
        f"You are an adversarial fact-checker. TRY TO REFUTE this claim. If you cannot "
        f"clearly confirm it from the facts, default to REFUTED.\n"
        f"Claim: {claim}\nFacts: {research}\n"
        f'Reply with exactly one line: "VERDICT: SUPPORTED" or "VERDICT: REFUTED", then a 10-word reason.',
        max_tokens=80)
    return "SUPPORTED" if "SUPPORTED" in out.upper().split("REASON")[0] else "REFUTED"

def main():
    if "--reset" in sys.argv and os.path.exists(CKPT):
        os.remove(CKPT); CKPT_STATE["agents"] = {}
        print("checkpoint reset")

    print("PHASE 1: research (parallel)")
    research = parallel([lambda i=i, c=c: (i, phase1_research(i, c)) for i, c in enumerate(CLAIMS)])
    research = dict(research)

    print("PHASE 2: adversarial verify (3-vote each)")
    verdicts = {}
    for i, claim in enumerate(CLAIMS):
        votes = [phase2_verify(i, claim, research[i], v) for v in range(3)]
        supported = votes.count("SUPPORTED")
        verdicts[i] = "SUPPORTED" if supported >= 2 else "REFUTED"  # majority of 3

    print("PHASE 3: synthesize")
    table = "\n".join(f"{i+1}. [{verdicts[i]}] {CLAIMS[i]}" for i in range(len(CLAIMS)))
    print("\n=== FINAL VERDICTS ===")
    print(table)
    json.dump({"verdicts": verdicts, "claims": CLAIMS}, open(
        os.path.join(os.path.dirname(CKPT), "result.json"), "w"), indent=2)
    print(f"\nagent calls in checkpoint: {len(CKPT_STATE['agents'])}")

if __name__ == "__main__":
    main()
