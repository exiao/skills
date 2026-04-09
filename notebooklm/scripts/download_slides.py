#!/usr/bin/env python3
"""
Download the most recent Slide Deck from a NotebookLM notebook as PDF.

Flow:
  1. Open notebook (first one on home page, or --notebook-url)
  2. Click Studio tab
  3. Find the first completed Slide Deck artifact
  4. Click it → opens inline viewer
  5. Click "More options" → "Download PDF Document (.pdf)"
  6. Save to output path

Usage:
    python scripts/run.py download_slides.py [--notebook-url URL] [--output PATH]
    python scripts/run.py download_slides.py --show-browser
"""

import argparse
import sys
import time
from pathlib import Path
from urllib.parse import urlparse

from patchright.sync_api import sync_playwright

sys.path.insert(0, str(Path(__file__).parent))
from browser_utils import BrowserFactory, StealthUtils
from notebooklm_utils import navigate_to_notebook_rows, dismiss_dialogs, find_slide_deck_artifacts

NOTEBOOKLM_HOME = "https://notebooklm.google.com"
DEFAULT_OUTPUT = Path.home() / "Downloads" / "notebooklm_slides.pdf"


def get_first_notebook_url(page) -> str | None:
    """Click the first notebook row and return the resulting URL."""
    try:
        rows = navigate_to_notebook_rows(page)
        if not rows:
            return None
        nb = rows[0]
        print(f"  Opening: '{nb['title'][:60]}'")
        nb["row"].click()
        for _ in range(25):
            time.sleep(0.3)
            href = page.evaluate("() => window.location.href")
            if "notebook/" in href:
                # Strip query params (?addSource=true etc.) to avoid dialog popups
                clean = href.split("?")[0].split("#")[0]
                page.goto(clean, wait_until="domcontentloaded", timeout=20000)
                time.sleep(1)
                return clean
        return page.evaluate("() => window.location.href").split("?")[0]
    except Exception as e:
        print(f"  ⚠️  Could not open notebook: {e}")
    return None


def open_studio_tab(page) -> bool:
    """Click the Studio tab on a notebook page."""
    # Dismiss any dialog overlays blocking the click
    dismiss_dialogs(page)
    try:
        tabs = page.query_selector_all("[role='tab']")
        for tab in tabs:
            if "studio" in (tab.inner_text() or "").lower():
                tab.click(force=True)  # force bypasses pointer-events overlays
                time.sleep(1.5)
                return True
    except Exception as e:
        print(f"  ⚠️  Could not open Studio tab: {e}")
    return False


def find_slide_deck_artifact(page) -> object | None:
    """
    Find the first completed Slide Deck artifact in the Studio panel.

    NotebookLM DOM: completed artifacts use <artifact-library-item> elements.
    The slide deck artifact has a mat-icon with text 'tablet' inside
    an .artifact-primary-content div (NOT inside basic-create-artifact-button).
    """
    try:
        # Find all artifact-library-item elements
        items = page.query_selector_all("artifact-library-item")
        for item in items:
            icon = item.query_selector("mat-icon.artifact-icon")
            if icon and (icon.inner_text() or "").strip() == "tablet":
                # This is a completed slide deck artifact
                title_el = item.query_selector(".artifact-primary-content")
                raw = (title_el.inner_text() or "").strip() if title_el else ""
                # Strip leading icon text ("tablet\n") to get just the title
                lines = [l.strip() for l in raw.split("\n") if l.strip() and l.strip() != "tablet"]
                title = lines[0] if lines else "Slide Deck"
                print(f"  Found slide deck: '{title[:60]}'")
                # Return the clickable artifact-item-button div
                btn_div = item.query_selector(".artifact-item-button, .artifact-button-content")
                return btn_div or item
    except Exception as e:
        print(f"  ⚠️  Slide deck search failed: {e}")
    return None


def download_via_more_options(page, context, output_path: Path) -> bool:
    """
    With a slide deck open in the inline viewer, click More options → Download PDF.
    The viewer toolbar has a mat-icon 'more_horiz' button for the options menu.
    """
    # Find the More options button (more_horiz) in the artifact viewer toolbar
    more_btn = None
    try:
        for icon in page.query_selector_all("mat-icon"):
            if (icon.inner_text() or "").strip() == "more_horiz":
                # Get the parent button
                btn = icon.evaluate_handle("el => el.closest('button')")
                if btn:
                    more_btn = btn.as_element()
                    break
    except Exception as e:
        print(f"  ⚠️  more_horiz search failed: {e}")

    if not more_btn:
        print("  ❌ Could not find 'More options' (more_horiz) button in viewer")
        return False

    more_btn.click()
    time.sleep(0.8)

    # Click "Download PDF Document (.pdf)" from the dropdown menu
    try:
        with page.expect_download(timeout=60000) as dl_info:
            found = False
            for item in page.query_selector_all("[role='menuitem'], [role='option']"):
                text = (item.inner_text() or "").lower()
                if "pdf" in text:
                    item.click()
                    found = True
                    break
            if not found:
                print("  ❌ 'Download PDF' menu item not found")
                return False

        download = dl_info.value
        output_path.parent.mkdir(parents=True, exist_ok=True)
        download.save_as(str(output_path))
        size_kb = output_path.stat().st_size / 1024
        print(f"  ✅ Saved: {output_path} ({size_kb:.1f} KB)")
        return True

    except Exception as e:
        print(f"  ❌ Download failed: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(description="Download NotebookLM slides as PDF")
    parser.add_argument("--notebook-url", help="URL of notebook (default: opens first notebook)")
    parser.add_argument("--output", help=f"Output path (default: {DEFAULT_OUTPUT})")
    parser.add_argument("--show-browser", action="store_true")
    args = parser.parse_args()

    output_path = Path(args.output) if args.output else DEFAULT_OUTPUT
    headless = not args.show_browser

    print("🖥️  NotebookLM Slide Downloader")
    print(f"  Output: {output_path}")

    playwright = None
    context = None

    try:
        playwright = sync_playwright().start()
        context = BrowserFactory.launch_persistent_context(playwright, headless=headless)
        page = context.new_page()

        # Navigate to target
        target = args.notebook_url or NOTEBOOKLM_HOME
        print(f"\n🌐 Opening: {target}")
        page.goto(target, wait_until="domcontentloaded", timeout=30000)
        try:
            page.wait_for_load_state("networkidle", timeout=10000)
        except Exception:
            pass
        time.sleep(2)

        # Check auth
        if urlparse(page.evaluate("() => window.location.href")).hostname == "accounts.google.com":
            print("❌ Not authenticated. Run: python scripts/run.py auth_manager.py setup")
            return 1

        # If not on a notebook page, open first notebook
        current_url = page.evaluate("() => window.location.href")
        if "notebook/" not in current_url:
            if args.notebook_url:
                # Navigate directly
                page.goto(args.notebook_url, wait_until="domcontentloaded", timeout=20000)
                time.sleep(2)
            else:
                print("📚 Finding most recent notebook...")
                nb_url = get_first_notebook_url(page)
                if not nb_url or "notebook/" not in nb_url:
                    print("❌ Could not open a notebook. Try --notebook-url")
                    return 1
                time.sleep(1)

        current_url = page.evaluate("() => window.location.href")
        print(f"📓 Notebook: {current_url}")

        # Open Studio tab
        print("🎨 Opening Studio tab...")
        if not open_studio_tab(page):
            print("❌ Could not open Studio tab")
            return 1

        # Find slide deck artifact
        print("🔍 Looking for Slide Deck artifact...")
        slide_btn = find_slide_deck_artifact(page)
        if not slide_btn:
            print("❌ No completed Slide Deck found in Studio.")
            print("   Generate one first: open the notebook → Studio → Slide Deck")
            return 1

        # Click to open inline viewer
        artifact_title = (slide_btn.inner_text() or "").strip().split("\n")[0]
        print(f"📊 Opening: '{artifact_title[:60]}'")
        slide_btn.click()
        time.sleep(2)

        # Download PDF via More options menu
        print("📥 Downloading PDF...")
        success = download_via_more_options(page, context, output_path)

        if success:
            print(f"\n✅ Done: {output_path}")
        else:
            print("\n❌ Download failed. Try --show-browser for visual debugging.")

        return 0 if success else 1

    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return 1

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


if __name__ == "__main__":
    sys.exit(main())
