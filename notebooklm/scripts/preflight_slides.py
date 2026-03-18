#!/usr/bin/env python3
"""
Preflight: detect which NotebookLM notebooks have undownloaded slide decks.

Scans all notebooks on the home page, checks Studio for completed Slide Deck
artifacts, and compares against the download manifest. Outputs JSON list of
notebooks that have slides we haven't saved yet.

Phase 1: Sequentially collect all notebook URLs from the home page (fast pass).
Phase 2: Async slide-check using asyncio + patchright async API (5 concurrent).
Results are cached in ~/.notebooklm_slides/slides_cache.json (7-day TTL).

Exit codes:
  0 = nothing to download
  1 = undownloaded slides found (ready for download_all_slides.py)

Usage:
    python scripts/run.py preflight_slides.py
    python scripts/run.py preflight_slides.py --json
    python scripts/run.py preflight_slides.py --show-browser
    python scripts/run.py preflight_slides.py --clear-cache
"""

import argparse
import asyncio
import json
import sys
import time
from datetime import datetime, timedelta
from pathlib import Path

from patchright.sync_api import sync_playwright
from patchright.async_api import async_playwright as async_patchright

sys.path.insert(0, str(Path(__file__).parent))
from config import BROWSER_PROFILE_DIR, STATE_FILE, BROWSER_ARGS, USER_AGENT
from browser_utils import BrowserFactory
from notebooklm_utils import (
    get_current_url,
    navigate_to_notebook_rows,
)

SLIDES_DIR = Path.home() / ".notebooklm_slides"
MANIFEST_PATH = SLIDES_DIR / "manifest.json"
CACHE_PATH = SLIDES_DIR / "slides_cache.json"
NOTEBOOKLM_HOME = "https://notebooklm.google.com"
CACHE_TTL_DAYS = 7
NUM_WORKERS = 5


# ── Manifest ──────────────────────────────────────────────────────────────────

def load_manifest() -> dict:
    if MANIFEST_PATH.exists():
        try:
            with open(MANIFEST_PATH) as f:
                return json.load(f)
        except Exception:
            pass
    return {}


def save_manifest(manifest: dict):
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(MANIFEST_PATH, "w") as f:
        json.dump(manifest, f, indent=2)


# ── Slides cache ──────────────────────────────────────────────────────────────

def load_slides_cache() -> dict:
    if CACHE_PATH.exists():
        try:
            with open(CACHE_PATH) as f:
                return json.load(f)
        except Exception:
            pass
    return {}


def save_slides_cache(cache: dict):
    SLIDES_DIR.mkdir(parents=True, exist_ok=True)
    with open(CACHE_PATH, "w") as f:
        json.dump(cache, f, indent=2)


def _cache_is_fresh(entry: dict) -> bool:
    """Return True if the entry was checked within CACHE_TTL_DAYS."""
    try:
        last = datetime.fromisoformat(entry["last_checked"])
        return datetime.utcnow() - last < timedelta(days=CACHE_TTL_DAYS)
    except Exception:
        return False


# ── Async helpers (Phase 2) ───────────────────────────────────────────────────

async def _async_open_studio_tab(page) -> bool:
    """Async version of open_studio_tab. Returns True if Studio tab was clicked."""
    # Dismiss any blocking dialog
    try:
        backdrop = await page.query_selector(".cdk-overlay-backdrop")
        if backdrop:
            await backdrop.click()
            await asyncio.sleep(0.8)
    except Exception:
        pass

    for attempt in range(5):
        try:
            tabs = await page.query_selector_all("[role='tab']")
            for tab in tabs:
                text = await tab.inner_text()
                if "studio" in (text or "").lower():
                    await tab.click(force=True)
                    await asyncio.sleep(3)
                    return True
        except Exception:
            pass
        if attempt < 4:
            await asyncio.sleep(2)
    return False


async def _async_find_slide_deck_artifacts(page) -> list:
    """Async version of find_slide_deck_artifacts. Returns list of {title, metadata}."""
    results = []
    try:
        items = await page.query_selector_all("artifact-library-item")
        for item in items:
            icon = await item.query_selector("mat-icon.artifact-icon")
            if not icon:
                continue
            icon_text = (await icon.inner_text() or "").strip()
            if icon_text != "tablet":
                continue
            title_el = await item.query_selector(".artifact-primary-content")
            raw = (await title_el.inner_text() or "").strip() if title_el else ""
            lines = [l.strip() for l in raw.split("\n") if l.strip() and l.strip() not in ("tablet", "")]
            title = lines[0] if lines else "Slide Deck"
            metadata = lines[1] if len(lines) > 1 else ""
            results.append({"title": title, "metadata": metadata})
    except Exception as e:
        print(f"  ⚠️  artifact search error: {e}", file=sys.stderr)
    return results


async def _check_notebooks_async(notebooks: list[dict], cache: dict, headless: bool = True) -> list[dict]:
    """
    Phase 2: Check each notebook for slides using async patchright, 5 concurrent.
    Writes cache after each notebook check.
    """
    total = len(notebooks)
    semaphore = asyncio.Semaphore(NUM_WORKERS)
    cache_lock = asyncio.Lock()
    counter = [0]

    async with async_patchright() as p:
        browser = await p.chromium.launch_persistent_context(
            user_data_dir=str(BROWSER_PROFILE_DIR),
            channel="chrome",
            headless=headless,
            no_viewport=True,
            ignore_default_args=["--enable-automation"],
            user_agent=USER_AGENT,
            args=BROWSER_ARGS,
        )

        # Replicate BrowserFactory._inject_cookies for the async context
        if STATE_FILE.exists():
            try:
                with open(STATE_FILE) as f:
                    state = json.load(f)
                if state.get("cookies"):
                    await browser.add_cookies(state["cookies"])
            except Exception as e:
                print(f"  ⚠️  Could not inject cookies: {e}", file=sys.stderr)

        async def check_one(nb: dict):
            title = nb["title"]
            notebook_url = nb["notebook_url"]
            notebook_id = nb["notebook_id"]

            counter[0] += 1
            idx = counter[0]

            # Check cache before acquiring semaphore (fast path)
            cached = cache.get(notebook_id)
            if cached and _cache_is_fresh(cached):
                status = f"✅ {len(cached['slides'])} slide(s)" if cached["has_slides"] else "—"
                print(f"  [{idx}/{total}] '{title[:50]}' [cached] {status}", file=sys.stderr)
                if cached["has_slides"]:
                    return {
                        "notebook_id": notebook_id,
                        "notebook_url": notebook_url,
                        "title": title,
                        "slides": cached["slides"],
                    }
                return None

            async with semaphore:
                print(f"  [{idx}/{total}] '{title[:50]}' [scanning]...", file=sys.stderr)
                page = await browser.new_page()
                try:
                    await page.goto(notebook_url, wait_until="domcontentloaded", timeout=20000)
                    await asyncio.sleep(2)

                    has_slides = False
                    slides: list[dict] = []
                    status_msg = "—"

                    if await _async_open_studio_tab(page):
                        artifacts = await _async_find_slide_deck_artifacts(page)
                        if artifacts:
                            has_slides = True
                            slides = [{"title": a["title"], "metadata": a["metadata"]} for a in artifacts]
                            status_msg = f"✅ {len(artifacts)} slide(s)"
                    else:
                        status_msg = "⚠️ no studio"

                    print(f"    → '{title[:50]}' {status_msg}", file=sys.stderr)

                    entry = {
                        "has_slides": has_slides,
                        "slides": slides,
                        "slides_url": None,
                        "title": title,
                        "notebook_url": notebook_url,
                        "last_checked": datetime.utcnow().isoformat(),
                    }
                    # Write cache after every notebook (protects progress on interrupt)
                    async with cache_lock:
                        cache[notebook_id] = entry
                        save_slides_cache(cache)

                    if has_slides:
                        return {
                            "notebook_id": notebook_id,
                            "notebook_url": notebook_url,
                            "title": title,
                            "slides": slides,
                        }
                    return None

                except Exception as e:
                    print(f"  ⚠️  Error scanning '{title[:50]}': {e}", file=sys.stderr)
                    return None
                finally:
                    await page.close()

        raw = await asyncio.gather(*[check_one(nb) for nb in notebooks])
        await browser.close()

    return [r for r in raw if r]


# ── Main scraper ──────────────────────────────────────────────────────────────

def scrape_notebooks_with_slides(headless: bool = True) -> list[dict]:
    """
    Scan all notebooks on the home page, check each Studio for completed slide decks.
    Returns list of dicts: {notebook_id, notebook_url, title, slides: [{title, metadata}]}

    Phase 1 (sync): collect notebook URLs from the home page.
    Phase 2 (async): check each notebook for slide artifacts.
    """
    cache = load_slides_cache()
    playwright = None
    context = None
    notebooks: list[dict] = []

    # ── Phase 1: collect all notebook URLs (sequential, sync) ─────────────────
    try:
        playwright = sync_playwright().start()
        context = BrowserFactory.launch_persistent_context(playwright, headless=headless)
        page = context.new_page()

        print("🌐 Opening NotebookLM...", file=sys.stderr)
        page.goto(NOTEBOOKLM_HOME, wait_until="domcontentloaded", timeout=30000)
        time.sleep(2)

        if "accounts.google.com" in get_current_url(page):
            print("❌ Not authenticated. Run: python scripts/run.py auth_manager.py setup", file=sys.stderr)
            return []

        print("📋 Collecting notebook URLs...", file=sys.stderr)
        rows = navigate_to_notebook_rows(page)
        total = len(rows)
        print(f"📚 Found {total} notebook(s)", file=sys.stderr)

        for i in range(total):
            # Navigate home if we drifted away
            current_url = get_current_url(page)
            if "notebook/" in current_url or current_url.rstrip("/") != NOTEBOOKLM_HOME.rstrip("/"):
                page.goto(NOTEBOOKLM_HOME, wait_until="domcontentloaded", timeout=20000)
                for _ in range(10):
                    time.sleep(0.5)
                    if page.query_selector("tr[role='row']"):
                        break

            fresh_rows = []
            for _ in range(5):
                fresh_rows = navigate_to_notebook_rows(page)
                if fresh_rows:
                    break
                time.sleep(1)

            if i >= len(fresh_rows):
                print(f"  ⚠️  Could not get row {i} (only {len(fresh_rows)} found), skipping", file=sys.stderr)
                continue

            nb = fresh_rows[i]
            title = nb["title"]

            try:
                nb["row"].click()
                for _ in range(25):
                    time.sleep(0.3)
                    if "notebook/" in get_current_url(page):
                        break
            except Exception as e:
                print(f"  ⚠️  Row {i} click failed: {e}", file=sys.stderr)
                continue

            notebook_url = get_current_url(page).split("?")[0].split("#")[0]
            notebook_id = notebook_url.split("/")[-1]
            notebooks.append({"title": title, "notebook_url": notebook_url, "notebook_id": notebook_id})

        page.close()

    except Exception as e:
        print(f"\n❌ Phase 1 error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
    finally:
        if context:
            try:
                context.close()
            except Exception:
                pass
        if playwright:
            try:
                playwright.stop()
            except Exception:
                pass

    if not notebooks:
        return []

    # ── Phase 2: async parallel slide scanning ─────────────────────────────────
    n_workers = min(NUM_WORKERS, len(notebooks))
    print(f"\n🔍 Scanning {len(notebooks)} notebooks for slides ({n_workers} workers)...", file=sys.stderr)

    return asyncio.run(_check_notebooks_async(notebooks, cache, headless=headless))


# ── Filtering ─────────────────────────────────────────────────────────────────

def get_untouched(notebooks: list[dict], manifest: dict) -> list[dict]:
    """Filter to notebooks that have slides not yet downloaded."""
    untouched = []
    for nb in notebooks:
        nb_id = nb["notebook_id"]
        if nb_id not in manifest:
            untouched.append(nb)
        else:
            saved_slide_titles = set(manifest[nb_id].get("slide_titles", []))
            current_titles = {s["title"] for s in nb.get("slides", [])}
            if current_titles - saved_slide_titles:
                nb["reason"] = "new_slides"
                untouched.append(nb)
    return untouched


# ── CLI ───────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Preflight: detect undownloaded NotebookLM slides")
    parser.add_argument("--json", action="store_true", dest="json_out", help="Output JSON")
    parser.add_argument("--show-browser", action="store_true")
    parser.add_argument("--clear-cache", action="store_true", help="Wipe slides_cache.json and exit")
    args = parser.parse_args()

    if args.clear_cache:
        if CACHE_PATH.exists():
            CACHE_PATH.unlink()
            print(f"🗑️  Cache cleared: {CACHE_PATH}", file=sys.stderr)
        else:
            print("ℹ️  No cache file found.", file=sys.stderr)
        return

    manifest = load_manifest()
    print(f"📋 Manifest: {len(manifest)} already downloaded", file=sys.stderr)

    cache = load_slides_cache()
    fresh = sum(1 for e in cache.values() if _cache_is_fresh(e))
    print(f"💾 Cache: {len(cache)} entries ({fresh} fresh, {len(cache) - fresh} stale)", file=sys.stderr)

    notebooks = scrape_notebooks_with_slides(headless=not args.show_browser)
    untouched = get_untouched(notebooks, manifest)

    if args.json_out:
        print(json.dumps(untouched))
    else:
        if not untouched:
            print("✅ All slides already downloaded.")
        else:
            print(f"\n📥 {len(untouched)} notebook(s) with undownloaded slides:")
            for nb in untouched:
                reason = nb.get("reason", "new")
                print(f"  • {nb['title']} [{reason}]")
                for s in nb.get("slides", []):
                    print(f"    - {s['title']}")

    sys.exit(0 if not untouched else 1)


if __name__ == "__main__":
    main()
