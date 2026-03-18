#!/usr/bin/env python3
"""
Download all undownloaded NotebookLM slide decks as PDFs.

Runs preflight detection, then downloads any slide decks not yet saved.
Tracks downloaded slides in ~/.notebooklm_slides/manifest.json.

Usage:
    python scripts/run.py download_all_slides.py
    python scripts/run.py download_all_slides.py --output-dir ~/Documents/NotebookLM
    python scripts/run.py download_all_slides.py --show-browser
    python scripts/run.py download_all_slides.py --force   # re-download all
"""

import argparse
import json
import re
import sys
import time
from datetime import datetime
from pathlib import Path

from patchright.sync_api import sync_playwright, Download

sys.path.insert(0, str(Path(__file__).parent))
from config import DATA_DIR
from browser_utils import BrowserFactory, StealthUtils
from notebooklm_utils import open_studio_tab, find_slide_deck_artifacts
from preflight_slides import (
    load_manifest,
    save_manifest,
    scrape_notebooks_with_slides,
    get_untouched,
    SLIDES_DIR,
)

DEFAULT_OUTPUT_DIR = Path.home() / "Downloads" / "NotebookLM_Slides"


def safe_filename(title: str) -> str:
    """Convert a notebook title to a safe filename."""
    safe = re.sub(r'[^\w\s\-]', '', title).strip()
    safe = re.sub(r'\s+', '_', safe)
    return safe[:80] or "untitled"


def download_pdf_for_notebook(context, notebook: dict, output_dir: Path) -> Path | None:
    """
    Open a specific notebook, find the slide deck, download as PDF.
    Returns the saved path or None on failure.
    """
    stealth = StealthUtils()
    page = context.new_page()

    try:
        print(f"  🌐 Opening: {notebook['title']}")
        page.goto(notebook["notebook_url"], wait_until="domcontentloaded", timeout=20000)

        if "accounts.google.com" in page.url:
            print("  ❌ Session expired — re-auth needed")
            page.close()
            return None

        # Wait for page to fully render (Angular SPA needs more than domcontentloaded)
        try:
            page.wait_for_load_state("networkidle", timeout=15000)
        except Exception:
            pass
        time.sleep(3)

        slides_id = None
        slides_url = notebook.get("slides_url")

        # Step 1: open Studio tab (required — Sources tab is default)
        # Retry up to 3 times since Angular may still be rendering
        studio_opened = False
        for attempt in range(3):
            studio_opened = open_studio_tab(page)
            if studio_opened:
                break
            print(f"  ⏳ Studio tab not ready (attempt {attempt+1}/3), waiting...")
            time.sleep(3)
        if not studio_opened:
            print("  ⚠️  Studio tab not found — trying anyway")

        # Step 2: scan page for a direct Google Slides link (fastest)
        def scan_for_slides_link():
            try:
                links = page.query_selector_all(
                    "a[href*='docs.google.com/presentation'], a[href*='slides.google.com']"
                )
                for link in links:
                    href = link.get_attribute("href") or ""
                    m = re.search(r"/presentation/d/([a-zA-Z0-9_-]+)", href)
                    if m:
                        return m.group(1), href
            except Exception:
                pass
            return None, None

        # Try direct URL first (if preflight stored it)
        if slides_url and slides_url != "exists":
            m = re.search(r"/presentation/d/([a-zA-Z0-9_-]+)", slides_url)
            if m:
                slides_id = m.group(1)

        # Try scanning the page for links
        if not slides_id:
            slides_id, slides_url = scan_for_slides_link()

        # Step 3: click artifact to open inline viewer, then use More options → Download PDF
        if not slides_id:
            # Give Studio panel a moment to fully render artifact list
            time.sleep(2)
            print("  🔍 Finding Slide Deck artifact...")
            artifacts = find_slide_deck_artifacts(page)
            print(f"  🔎 Artifacts found: {len(artifacts)}")
            if not artifacts:
                print(f"  ❌ Could not find slides for: {notebook['title']}")
                page.close()
                return None

            # Click artifact to open inline viewer
            try:
                artifacts[0]["element"].click()
                time.sleep(2)
            except Exception as e:
                print(f"  ⚠️  Artifact click failed: {e}")
                page.close()
                return None

            # Use More options (more_horiz) → Download PDF Document
            print("  📥 Downloading via More options menu...")
            filename = safe_filename(notebook["title"]) + ".pdf"
            output_path = output_dir / filename
            output_dir.mkdir(parents=True, exist_ok=True)

            # Find more_horiz button in the inline viewer toolbar
            more_btn = None
            try:
                for icon in page.query_selector_all("mat-icon"):
                    if (icon.inner_text() or "").strip() == "more_horiz":
                        btn = icon.evaluate_handle("el => el.closest('button')")
                        if btn:
                            more_btn = btn.as_element()
                            break
            except Exception as e:
                print(f"  ⚠️  more_horiz search failed: {e}")

            if not more_btn:
                print(f"  ❌ Could not find More options button for: {notebook['title']}")
                page.close()
                return None

            more_btn.click()
            time.sleep(0.8)

            try:
                with page.expect_download(timeout=60000) as dl_info:
                    found_pdf = False
                    # Try "pdf" first (new-style menu: "Download PDF Document (.pdf)")
                    # then fall back to "download" (old-style menu: just "Download")
                    menu_items = page.query_selector_all("[role='menuitem'], [role='option']")
                    for item in menu_items:
                        text = (item.inner_text() or "").lower()
                        if "pdf" in text:
                            item.click()
                            found_pdf = True
                            break
                    if not found_pdf:
                        for item in menu_items:
                            text = (item.inner_text() or "").lower()
                            if "download" in text:
                                item.click()
                                found_pdf = True
                                break
                    if not found_pdf:
                        print("  ❌ No download menu item found")
                        page.close()
                        return None

                download = dl_info.value
                download.save_as(str(output_path))
                size_kb = output_path.stat().st_size / 1024
                print(f"  ✅ Saved: {output_path.name} ({size_kb:.1f} KB)")
                page.close()
                return output_path

            except Exception as e:
                print(f"  ❌ PDF download failed: {e}")
                page.close()
                return None

        # Fallback: download via Google Slides export URL (if slides_id was found earlier)
        export_url = f"https://docs.google.com/presentation/d/{slides_id}/export/pdf"
        print(f"  📥 Exporting PDF: {export_url[:60]}...")

        filename = safe_filename(notebook["title"]) + ".pdf"
        output_path = output_dir / filename

        slides_page = context.new_page()
        try:
            with slides_page.expect_download(timeout=60000) as dl_info:
                slides_page.goto(export_url)

            download: Download = dl_info.value
            output_dir.mkdir(parents=True, exist_ok=True)
            download.save_as(str(output_path))
            slides_page.close()

            size_kb = output_path.stat().st_size / 1024
            print(f"  ✅ Saved: {output_path.name} ({size_kb:.1f} KB)")
            page.close()
            return output_path

        except Exception as e:
            print(f"  ❌ Download failed: {e}")
            try:
                slides_page.close()
            except Exception:
                pass
            page.close()
            return None

    except Exception as e:
        print(f"  ❌ Error processing notebook: {e}")
        try:
            page.close()
        except Exception:
            pass
        return None


def main():
    parser = argparse.ArgumentParser(description="Download all undownloaded NotebookLM slides")
    parser.add_argument("--output-dir", default=str(DEFAULT_OUTPUT_DIR), help="Output directory for PDFs")
    parser.add_argument("--show-browser", action="store_true", help="Show browser window")
    parser.add_argument("--force", action="store_true", help="Re-download all slides (ignore manifest)")
    parser.add_argument("--limit", type=int, default=0, help="Max notebooks to download (0 = no limit)")
    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    headless = not args.show_browser

    print("🖥️  NotebookLM Bulk Slide Downloader")
    print(f"  Output dir: {output_dir}")
    print(f"  Force re-download: {args.force}")

    # Load manifest
    manifest = load_manifest()
    print(f"  Already downloaded: {len(manifest)} notebook(s)")

    # Preflight: find all notebooks with slides
    print("\n🔍 Running preflight scan...")
    all_notebooks = scrape_notebooks_with_slides(headless=headless)

    if not all_notebooks:
        print("✅ No notebooks with slides found. Nothing to download.")
        return 0

    # Filter to untouched (unless --force)
    if args.force:
        to_download = all_notebooks
        print(f"  Force mode: downloading all {len(to_download)} notebook(s)")
    else:
        to_download = get_untouched(all_notebooks, manifest)
        if not to_download:
            print(f"\n✅ All {len(all_notebooks)} notebooks already downloaded. Nothing to do.")
            return 0

    # Apply limit
    if args.limit and args.limit > 0:
        to_download = to_download[:args.limit]
        print(f"  Limit: downloading first {len(to_download)} notebook(s)")

    print(f"\n📥 Downloading slides for {len(to_download)} notebook(s):")
    for nb in to_download:
        print(f"  • {nb['title']}")

    # Download each
    downloaded = []
    failed = []

    playwright = None
    context = None

    try:
        playwright = sync_playwright().start()
        context = BrowserFactory.launch_persistent_context(playwright, headless=headless)

        for i, notebook in enumerate(to_download):
            print(f"\n[{i+1}/{len(to_download)}] {notebook['title']}")
            result = download_pdf_for_notebook(context, notebook, output_dir)

            if result:
                downloaded.append(notebook)
                # Update manifest
                manifest[notebook["notebook_id"]] = {
                    "title": notebook["title"],
                    "notebook_url": notebook["notebook_url"],
                    "slides_url": notebook.get("slides_url"),
                    "downloaded_at": datetime.utcnow().isoformat(),
                    "local_path": str(result),
                }
                save_manifest(manifest)
            else:
                failed.append(notebook)

            time.sleep(1)  # brief pause between notebooks

    except Exception as e:
        print(f"\n❌ Fatal error: {e}")
        import traceback
        traceback.print_exc()

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

    # Summary
    print(f"\n{'='*50}")
    print(f"✅ Downloaded: {len(downloaded)}")
    if failed:
        print(f"❌ Failed: {len(failed)}")
        for nb in failed:
            print(f"   • {nb['title']}")

    if downloaded:
        print(f"\nFiles saved to: {output_dir}")

    return 0 if not failed else 1


if __name__ == "__main__":
    sys.exit(main())
