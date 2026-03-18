"""
Shared utilities for NotebookLM slide scripts.
"""
import time
import re
from pathlib import Path
from typing import Optional


def get_current_url(page) -> str:
    """Get the real current URL (window.location.href is more reliable than page.url)."""
    return page.evaluate("() => window.location.href")


def dismiss_dialogs(page):
    """Dismiss any open dialog/modal overlays that block clicks."""
    # Try clicking the CDK overlay backdrop (dismisses most Angular Material dialogs)
    try:
        backdrop = page.query_selector(".cdk-overlay-backdrop")
        if backdrop:
            backdrop.click()
            time.sleep(0.8)
            return
    except Exception:
        pass
    # Try Escape key
    try:
        page.keyboard.press("Escape")
        time.sleep(0.8)
    except Exception:
        pass
    # Try clicking dialog close buttons
    try:
        for sel in ["button[aria-label*='close' i]", "button[aria-label*='cancel' i]",
                    "button[aria-label*='dismiss' i]", ".close-button",
                    "button.mat-dialog-close", "mat-icon:text-is('close')"]:
            btn = page.query_selector(sel)
            if btn:
                btn.click()
                time.sleep(0.5)
                break
    except Exception:
        pass


def open_studio_tab(page) -> bool:
    """Click the Studio tab. Returns True if found and clicked. Retries up to 10s."""
    # Dismiss any dialogs that might be blocking clicks
    dismiss_dialogs(page)

    for attempt in range(5):
        try:
            tabs = page.query_selector_all("[role='tab']")
            for tab in tabs:
                if "studio" in (tab.inner_text() or "").lower():
                    # Use force=True to bypass pointer-events overlays (e.g. dialog backdrops)
                    tab.click(force=True)
                    time.sleep(3)
                    return True
        except Exception:
            pass
        if attempt < 4:
            time.sleep(2)  # wait for Angular to render tabs
    return False


def find_slide_deck_artifacts(page) -> list:
    """
    Return all completed Slide Deck artifact elements from the Studio panel.

    NotebookLM DOM structure for completed artifacts:
      <artifact-library-item>
        <div class="artifact-item-button">
          <div class="artifact-primary-content">
            <mat-icon class="artifact-icon ...">tablet</mat-icon>
            [title text]
            [metadata: "1 source · Xm ago"]
          </div>
          <button class="more-options">more_vert</button>
        </div>
      </artifact-library-item>

    The "Slide Deck" generator button uses <basic-create-artifact-button> — NOT artifact-library-item.
    """
    results = []
    try:
        items = page.query_selector_all("artifact-library-item")
        for item in items:
            icon = item.query_selector("mat-icon.artifact-icon")
            if icon and (icon.inner_text() or "").strip() == "tablet":
                title_el = item.query_selector(".artifact-primary-content")
                raw = (title_el.inner_text() or "").strip() if title_el else ""
                lines = [l.strip() for l in raw.split("\n") if l.strip() and l.strip() not in ("tablet", "")]
                title = lines[0] if lines else "Slide Deck"
                metadata = lines[1] if len(lines) > 1 else ""
                clickable = item.query_selector(".artifact-item-button, .artifact-button-content") or item
                results.append({"title": title, "metadata": metadata, "element": clickable, "item": item})
    except Exception as e:
        print(f"  ⚠️  artifact search error: {e}")
    return results


def click_artifact_and_wait(page, artifact: dict) -> bool:
    """Click an artifact to open its inline viewer. Returns True if viewer opened."""
    try:
        artifact["element"].click()
        # Wait for the viewer to open (more_horiz button appears)
        for _ in range(20):
            time.sleep(0.3)
            icons = page.query_selector_all("mat-icon")
            for icon in icons:
                if (icon.inner_text() or "").strip() == "more_horiz":
                    return True
    except Exception as e:
        print(f"  ⚠️  Click artifact failed: {e}")
    return False


def download_artifact_as_pdf(page, output_path: Path) -> bool:
    """
    Assumes the artifact inline viewer is open.
    Clicks More options (more_horiz) → Download PDF Document → saves file.
    """
    # Find more_horiz button (the viewer toolbar More options)
    more_btn = None
    try:
        for icon in page.query_selector_all("mat-icon"):
            if (icon.inner_text() or "").strip() == "more_horiz":
                btn = icon.evaluate_handle("el => el.closest('button')")
                if btn:
                    more_btn = btn.as_element()
                    break
    except Exception as e:
        print(f"  ⚠️  more_horiz search: {e}")

    if not more_btn:
        print("  ❌ Could not find 'More options' button in viewer")
        return False

    more_btn.click()
    time.sleep(0.8)

    try:
        from patchright.sync_api import Download
        context = page.context
        with page.expect_download(timeout=60000) as dl_info:
            found = False
            # Try "pdf" first (new-style menu: "Download PDF Document (.pdf)")
            # then fall back to "download" (old-style menu: just "Download")
            menu_items = page.query_selector_all("[role='menuitem'], [role='option']")
            for item in menu_items:
                text = (item.inner_text() or "").lower()
                if "pdf" in text:
                    item.click()
                    found = True
                    break
            if not found:
                for item in menu_items:
                    text = (item.inner_text() or "").lower()
                    if "download" in text:
                        item.click()
                        found = True
                        break
            if not found:
                print("  ❌ No download menu item found")
                return False

        download: Download = dl_info.value
        output_path.parent.mkdir(parents=True, exist_ok=True)
        download.save_as(str(output_path))
        size_kb = output_path.stat().st_size / 1024
        print(f"  ✅ {output_path.name} ({size_kb:.1f} KB)")
        return True

    except Exception as e:
        print(f"  ❌ Download failed: {e}")
        return False


def safe_filename(title: str) -> str:
    safe = re.sub(r"[^\w\s\-]", "", title).strip()
    safe = re.sub(r"\s+", "_", safe)
    return safe[:80] or "untitled"


def navigate_to_notebook_rows(page) -> list:
    """
    On the NotebookLM home page, return all clickable notebook rows.
    Each row represents one notebook.
    """
    # Wait for the notebook list table to appear (up to 5s)
    for _ in range(10):
        if page.query_selector("tr[role='row']"):
            break
        time.sleep(0.5)

    try:
        # Try filtering to 'My notebooks' only
        for radio in page.query_selector_all("[role='radio']"):
            if "my notebooks" in (radio.inner_text() or "").lower():
                radio.click()
                # Wait for the list to re-render after filter click (up to 5s)
                for _ in range(10):
                    time.sleep(0.5)
                    if page.query_selector("tr[role='row']"):
                        break
                break
    except Exception:
        pass

    rows = []
    try:
        all_rows = page.query_selector_all("tr[role='row']")
        for row in all_rows:
            tds = row.query_selector_all("td")
            if tds and len(tds) >= 2:
                title = (tds[0].inner_text() or "").strip().replace("\n", " ")
                if title:
                    rows.append({"row": row, "title": title})
    except Exception:
        pass
    return rows
