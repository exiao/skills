---
name: substack-draft
description: Use when saving a finished article to Substack as a draft for manual review and publishing. Does NOT publish automatically — always saves as draft.
---

# Substack Draft

Save finished articles as Substack drafts. No API exists — this is browser-based.

**⚠️ This skill saves drafts only. Never click Publish. Eric publishes manually.**

## Pipeline Position

```
article-writer → image-generator → THIS SKILL (save draft) → Eric reviews → Eric publishes
```

The draft is already written, humanized, and approved before it gets here. This skill gets it into Substack's editor as a draft.

## Pre-Draft Checklist

Before saving the draft, verify:
1. [ ] Draft approved by Eric
2. [ ] Title + subtitle finalized (from headlines skill)
3. [ ] All images placed with alt text
4. [ ] SEO checklist passed (from article-writer)
5. [ ] Humanizer checklist passed (from article-writer)
6. [ ] Internal links to previous posts included
7. [ ] CTA at end (subscribe / share)
8. [ ] AI share buttons added if used in this post
9. [ ] AI crawler access validated (robots.txt and CDN rules)

## Publishing Process

### Step 1 — Open Substack Editor
```
browser action=open targetUrl="https://[publication].substack.com/publish/post" profile=chrome
browser action=snapshot
```
Verify the editor loaded. If login needed, navigate to login first.

### Step 2 — Enter Content
1. Click title field → type/paste title
2. Click subtitle field → type/paste subtitle
3. Click body → paste article content
4. For images: use Substack's image upload in the editor

### Step 3 — Configure Post Settings
- **Section**: Select appropriate section if publication has sections
- **Tags/Topics**: Add relevant topic tags
- **Preview text**: First ~140 chars of subtitle (auto-generated, but verify)
- **SEO title**: Override if needed (check title length < 60 chars)
- **SEO description**: Use subtitle or custom meta description

### Step 4 — Preview
```
browser action=snapshot
```
Review the preview. Check:
- Title/subtitle render correctly
- Images display properly
- Formatting looks right
- Links work

### Step 5 — Save as Draft
**Always save as draft. Never click Publish or Schedule.**

Click "Save" or "Save draft". Confirm the post appears in Substack's drafts list. Eric will publish manually when ready.

## Publication Details

- **Blog**: blog.promptpm.ai ("my crystal ball" by Eric Xiao)
- **Available URL**: getbloom.substack.com (not yet created)

## After Saving Draft

1. Confirm the draft appears in Substack's drafts list
2. Share the Substack draft URL with Eric for review
3. Log in `marketing/substack/drafts/[slug].md`:
   - Draft URL
   - Date saved
   - Target keywords (from seo-research)
4. Notify Eric the draft is ready to review and publish

## File Organization

```
marketing/substack/
├── research/          # Keyword research (from seo-research skill)
├── drafts/            # Written articles + images
│   └── [slug]/
│       ├── outline-variants.md
│       ├── draft.md
│       └── images/
└── published/         # Archive of published posts
    └── [slug].md      # Post-publish log (URL, date, keywords)
```

## References

- Fed by **article-writer** (finished draft)
- Fed by **image-generator** (article images)
- Feeds into **distribution** (promotion playbook)
- Feeds into **typefully** (social scheduling)
