#!/usr/bin/env python3
"""Build a transcripts page from test-output/sectionN/*.md self-play transcript files.
Collapsible per-lesson, grouped by section. Edit SECTIONS, META, and the :root tokens.

Layout expected:
  test-output/section1/01-*.md 02-*.md ...
  test-output/section2/05-*.md ...
"""
import re, html, pathlib

ROOT = pathlib.Path(__file__).parent
OUT = ROOT / "test-output"

# Page metadata — edit for your course.
TITLE = "Course — Full Lesson Transcripts (Synthetic)"
HEADLINE = "Full Lesson Transcripts"
KICKER = "Course · QA"
SUBHEAD = "Self-play walkthroughs of every lesson, end to end. Raw output."
AUDIENCE = "tool-literate professional"

# (display title, dir under test-output/, one-line section description)
SECTIONS = [
    ("Section 1", "section1", "Lessons 1-4."),
    ("Section 2", "section2", "Lessons 5-8."),
]


def md_inline(s):
    s = html.escape(s)
    s = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", s)
    s = re.sub(r"`(.+?)`", r"<code>\1</code>", s)
    s = re.sub(r"^&gt; (.*)$", r"<span class='bq'>\1</span>", s)
    return s


def render_md(text):
    out, in_code, in_ul = [], False, False
    for raw in text.splitlines():
        line = raw.rstrip("\n")
        if line.strip().startswith("```"):
            if in_code:
                out.append("</pre>"); in_code = False
            else:
                if in_ul: out.append("</ul>"); in_ul = False
                out.append("<pre>"); in_code = True
            continue
        if in_code:
            out.append(html.escape(line)); continue
        if not line.strip():
            if in_ul: out.append("</ul>"); in_ul = False
            continue
        m = re.match(r"^(#{1,6})\s+(.*)", line)
        if m:
            if in_ul: out.append("</ul>"); in_ul = False
            lvl = min(len(m.group(1)), 4)
            tag = lvl + 2 if lvl > 1 else 4
            out.append(f"<h{tag}>{md_inline(m.group(2))}</h{tag}>")
            continue
        if line.strip() in ("---", "***"):
            if in_ul: out.append("</ul>"); in_ul = False
            out.append("<hr>"); continue
        m = re.match(r"^\s*[-*]\s+(.*)", line)
        if m:
            if not in_ul: out.append("<ul>"); in_ul = True
            out.append(f"<li>{md_inline(m.group(1))}</li>"); continue
        if in_ul: out.append("</ul>"); in_ul = False
        sm = re.match(r"^\*\*(Claude|Instructor|INSTRUCTOR|Student[^:]*|STUDENT[^:]*)[:：]\*\*\s*(.*)", line)
        if sm:
            who = sm.group(1)
            cls = "ins" if re.search(r"claude|instr", who, re.I) else "stu"
            out.append(f"<p class='turn {cls}'><span class='who'>{html.escape(who)}</span> {md_inline(sm.group(2))}</p>")
            continue
        out.append(f"<p>{md_inline(line)}</p>")
    if in_code: out.append("</pre>")
    if in_ul: out.append("</ul>")
    return "\n".join(out)


cards, total = [], 0
for sec_title, sec_dir, sec_desc in SECTIONS:
    inner = []
    for f in sorted((OUT / sec_dir).glob("*.md")):
        total += 1
        text = f.read_text()
        mt = re.search(r"^#\s+(.*)", text, re.M)
        title = (mt.group(1).strip() if mt else f.stem)
        title = re.sub(r"^Self-Play Transcript\s*[—-]\s*", "", title)
        body = render_md(text)
        inner.append(f"<details class='lesson'><summary><span class='lnum'>{f.stem.split('-')[0]}</span> {html.escape(title)}</summary><div class='body'>{body}</div></details>")
    cards.append(f"<h2>{html.escape(sec_title)}</h2><p class='secdesc'>{html.escape(sec_desc)}</p>{''.join(inner)}")

# Edit the :root tokens and fonts to match your project's visual identity.
PAGE = f"""<!doctype html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{html.escape(TITLE)}</title>
<style>
:root{{--bg:#ffffff;--surface:#f7f7f5;--ink:#1a1a1a;--ink2:#444;--muted:#666;--faint:#999;
--line:#eee;--line2:#e2e2e2;--accent:#c2410c;
--serif:Georgia,'Times New Roman',serif;--sans:system-ui,-apple-system,'Segoe UI',sans-serif;
--mono:ui-monospace,SFMono-Regular,Menlo,monospace}}
*{{box-sizing:border-box}}
body{{margin:0;background:var(--bg);color:var(--ink);font:16px/1.6 var(--sans);-webkit-font-smoothing:antialiased}}
.wrap{{max-width:820px;margin:0 auto;padding:56px 24px 96px}}
.kick{{color:var(--accent);font-weight:500;letter-spacing:.1em;text-transform:uppercase;font-size:12px}}
h1{{font-family:var(--serif);font-weight:500;font-size:48px;line-height:1.1;margin:10px 0 8px}}
.sub{{color:var(--muted);font-size:18px;margin:0 0 24px}}
.warn{{background:var(--surface);border:1px solid var(--line2);border-left:3px solid var(--accent);border-radius:8px;
padding:16px 18px;margin:20px 0 10px;font-size:15px;color:var(--ink2)}}
.warn b{{color:var(--ink);font-weight:600}}
.chips{{display:flex;gap:8px;flex-wrap:wrap;margin:18px 0}}
.chip{{background:var(--surface);border:1px solid var(--line2);border-radius:999px;padding:5px 13px;font-size:13px;color:var(--muted)}}
.chip b{{color:var(--ink);font-weight:600}}
h2{{font-family:var(--serif);font-weight:500;font-size:30px;color:var(--ink);margin:48px 0 4px;padding-bottom:10px;border-bottom:1px solid var(--line2)}}
.secdesc{{color:var(--faint);font-size:15px;margin:0 0 16px}}
details.lesson{{background:var(--surface);border:1px solid var(--line2);border-radius:8px;margin:10px 0;overflow:hidden}}
details.lesson summary{{cursor:pointer;padding:16px 20px;font-family:var(--serif);font-size:21px;font-weight:500;list-style:none;display:flex;align-items:center;gap:12px;color:var(--ink)}}
details.lesson summary::-webkit-details-marker{{display:none}}
details.lesson summary::after{{content:"+";margin-left:auto;color:var(--faint);font-size:22px}}
details.lesson[open] summary::after{{content:"–"}}
details.lesson[open] summary{{border-bottom:1px solid var(--line)}}
.lnum{{display:inline-flex;min-width:28px;height:28px;align-items:center;justify-content:center;background:var(--bg);border:1px solid var(--line2);border-radius:7px;font-size:13px;color:var(--accent);font-weight:600}}
.body{{padding:10px 22px 20px}}
.body p{{margin:10px 0}}
.turn{{padding:10px 14px;border-radius:8px;margin:9px 0}}
.turn.ins{{background:#f0efec;border:1px solid var(--line2)}}
.turn.stu{{background:#fbf3ee;border:1px solid #f0ddd4}}
.who{{display:inline-block;font-size:11px;font-weight:600;letter-spacing:.05em;text-transform:uppercase;margin-right:6px}}
.turn.ins .who{{color:var(--ink2)}} .turn.stu .who{{color:var(--accent)}}
.bq{{display:block;border-left:3px solid var(--line2);padding:2px 14px;color:var(--muted);margin:4px 0;font-style:italic}}
pre{{background:#faf8f5;border:1px solid var(--line2);border-radius:8px;padding:13px 15px;overflow:auto;font:13.5px/1.55 var(--mono);color:#2a2a28;white-space:pre-wrap;word-break:break-word}}
code{{background:#f0ece8;border:1px solid var(--line2);border-radius:5px;padding:1px 6px;font-size:13px;font-family:var(--mono);overflow-wrap:anywhere}}
hr{{border:0;border-top:1px solid var(--line2);margin:14px 0}}
h4,h5,h6{{font-family:var(--serif);font-weight:500;margin:18px 0 6px;font-size:18px;color:var(--ink)}}
.body ul{{margin:8px 0;padding-left:20px}} .body li{{margin:5px 0}}
.foot{{color:var(--faint);font-size:13px;margin-top:48px;border-top:1px solid var(--line2);padding-top:18px}}
</style></head><body><div class="wrap">
<div class="kick">{html.escape(KICKER)}</div>
<h1>{html.escape(HEADLINE)}</h1>
<p class="sub">{html.escape(SUBHEAD)}</p>
<div class="warn"><b>Synthetic.</b> These are simulated sessions: an agent plays both the instructor (following each lesson's script) and a calibrated student persona. No real student produced these. They show how each lesson runs turn by turn and where it snags.</div>
<div class="chips"><span class="chip"><b>{total}</b> lessons</span><span class="chip"><b>{len(SECTIONS)}</b> sections</span><span class="chip">audience: <b>{html.escape(AUDIENCE)}</b></span></div>
{''.join(cards)}
<div class="foot">Generated by self-play QA. Each lesson ends with a "where it snagged" note.</div>
</div></body></html>"""

(ROOT / "index.html").write_text(PAGE)
print(f"wrote index.html — {total} lessons, {len(PAGE)} bytes")
