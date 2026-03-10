---
name: content-pipeline
description: "Orchestrator for the 3-article content pipeline — runs research phase, spawns parallel article sub-agents, creates Typefully drafts. Use when running the full content pipeline (usually via cron at 3am)."
---

# Content Pipeline Orchestrator

Produces 3 article drafts per run: research once, then spawn 3 parallel sub-agents (one per article). Sub-agents handle their own skill reads. This orchestrator only handles the research phase and final reporting.

**Do NOT publish anything.** Everything stays as drafts.

---

## Phase 0 — Deduplication Check (MANDATORY FIRST)

1. Read `~/clawd/memory/content-published.md` — topics already covered are off-limits
2. Run `bird tweets --user exiao3 -n 30 --plain` — note angles Eric published in the last 30 days
3. Check recent Substack: `web_fetch https://mycrystalball.substack.com` — find recent post titles
4. Build an EXCLUSION LIST. Do not pick any topic overlapping with it.
5. After picking topics, append them to `~/clawd/memory/content-published.md`

---

## Phase 1 — Research (run once, takes ~15 min)

Read `~/marketing/WRITING-STYLE.md` first.

### 1a. Gather source material

- **Bird** (`/bird`): Pull @exiao3's last 30 posts. Note which topics/angles got most engagement.
- **Appfigures** (`/appfigures`): Current Bloom downloads, MRR, recent 1–3 star reviews. These are data points to use in articles.

### 1b. Find 3 topics

Use `/web-search` + `/trend-research` to find 3 topics, one per theme:

| Theme | Focus |
|-------|-------|
| AI tools | Claude Code, coding agents, building with AI |
| AI investing | AI-native hedge funds, Bloom, AI stock analysis |
| Product design | Shipping fast, indie dev, UX decisions |

**Pick topics where Eric has unique credibility** — Bloom builder, Claude Code daily user, solo founder. Avoid angles anyone could write. Use X engagement data from Step 1a to validate.

### 1c. Competitive gap check

For each topic: quick web search for what's already been written. Find the contrarian angle or data point competitors missed.

### 1d. Save research

Write all findings to `~/marketing/substack/drafts/[YYYY-MM-DD]-research.md`:
- X engagement patterns (which topics resonated)
- Appfigures metrics to reference
- 3 chosen topics with positioning angle for each
- Key SEO keywords per topic

---

## Phase 2 — Parallel Article Agents

Spawn 3 sub-agents in parallel using `sessions_spawn`, one per topic. Each sub-agent receives:

```
Topic: [topic]
Positioning angle: [angle from research]
Appfigures data to use: [specific numbers from Phase 1]
X engagement insight: [what angle resonated with Eric's audience]
Output directory: ~/marketing/substack/drafts/[slug]/

Your job:
1. Read ~/marketing/WRITING-STYLE.md
2. Run /headlines — generate 5 options, pick strongest → headlines.md
3. Run /outline-generator → outline.md
4. Run /article-writer → draft.md (must pass "only Eric could write this" test: use Bloom-specific numbers, named frameworks, personal tool experience)
5. Run /editor-in-chief — max 5 iterations → editing-log.md + draft-final.md
6. Run /image-generator — hero image → hero.png
7. Write LinkedIn post directly → linkedin-post.md
   - Re-read ~/marketing/WRITING-STYLE.md kill phrases list before writing
   - Write a native LinkedIn post from draft-final.md. Do NOT reframe into "here's what most people get wrong" or "X isn't Y, it's Z" patterns. Lead with the most specific, surprising fact or data point from the article. Let the story carry the reader — no interpretive sentences telling them what to feel.
   - Run /evaluate-content on the post (Voice + Leanness scores only). If either scores below 4/5, rewrite and re-check. Max 2 revision passes.
   - Save final version to linkedin-post.md (post body only — no metadata headers)
8. Write X thread → x-thread.md
   - Run /tweet-ideas using draft-final.md as source. Pick the 5 strongest standalone tweets and sequence them as a thread.
   - No promotional framing, no article links in thread body (link goes in reply)
9. Format for Substack → substack-ready.md

Do NOT publish. Do NOT send messages unless blocked.
```

### File structure per article
```
~/marketing/substack/drafts/[slug]/
  headlines.md        # 5 options + winner
  outline.md
  draft.md
  editing-log.md
  draft-final.md
  substack-ready.md
  hero.png
  x-thread.md
  linkedin-post.md
```

---

## Phase 3 — Substack Drafts

After all 3 sub-agents complete, for each article save a Substack draft using the `substack-draft` skill with `profile=clawd`.

**NEVER click Publish. Draft only.**

Steps per article:
1. Read `~/marketing/substack/drafts/[slug]/substack-ready.md` for title, subtitle, and body
2. Open Substack editor: `browser action=open targetUrl="https://mycrystalball.substack.com/publish/post" profile=clawd`
3. Paste title, subtitle, body
4. Upload `hero.png` as the cover image
5. Save as draft (never publish)
6. Capture the draft URL and include it in the Phase 4 report

---

## Phase 4 — Typefully Drafts

After Substack drafts are saved, create Typefully drafts for each article:

**IMPORTANT: Save as UNSCHEDULED drafts only. Do NOT schedule or publish anything.**

```bash
# X thread draft — unscheduled draft only
cd ~/clawd/skills/typefully && node scripts/typefully.js drafts:create 286685 \
  --platform x --text "$(cat ~/marketing/substack/drafts/[slug]/x-thread.md)"

# LinkedIn draft — unscheduled draft only
node scripts/typefully.js drafts:create 286685 \
  --platform linkedin --text "$(cat ~/marketing/substack/drafts/[slug]/linkedin-post.md)"
```

---

## Phase 5 — Report

Send summary to signal +15202753080:
- 3 topics chosen (one line each with positioning angle)
- Substack draft URLs (one per article — ready to review and publish)
- Typefully draft links (LinkedIn + X thread, unscheduled)
- Appfigures metrics used as data points
