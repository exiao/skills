# Click-to-WhatsApp Ads

Use this reference when setting up Meta ads that send users into a WhatsApp Business conversation.

## Core Strategy

Do not optimize for generic "chat with us." Advertise one concrete job the user can complete in WhatsApp.

Strong wedges:

1. **Upload or screenshot review**
   - Promise: send an image or screenshot, get a useful review or next step.
   - Best fit for WhatsApp because image upload is natural and intent is high.
2. **Quick text check**
   - Promise: text one item, get a fast answer or assessment.
   - Lower friction, but can attract curiosity traffic.
3. **Daily or recurring update**
   - Promise: text a keyword, get a concise update and opt into future updates.
   - Better retention angle than first paid-acquisition wedge.

## Campaign Setup

- Objective: start with Engagement or Leads.
- Conversion location: Messaging apps / WhatsApp.
- Destination: WhatsApp only.
- Audience: broad first, then test interests if quality is poor.
- Placements: Advantage+ placements initially; inspect Reels, Stories, and Feed breakdown after 72 hours.
- Budget: start small for 4 to 7 days.
- Avoid fragmenting budgets across too many ad sets. Test creative first.

## Creative Test Matrix

Run 6 initial ads: 3 angles x 2 native formats.

Recommended formats:
- WhatsApp chat screenshot or phone recording
- Notes app checklist
- Reddit-style question
- Product test reveal
- Quick-cut text-over-video
- Lo-fi bold statement

Example screenshot-review ad:
- Primary text: "Send a screenshot and get a second opinion in WhatsApp."
- Headline: "Review It in WhatsApp"
- Prefill message: "Can you help me review this?"

## Creative Production Workflow

When asked to make ads, produce reviewable assets first. Do not launch or spend without explicit confirmation.

1. Create a batch folder.
   - Include PNG exports, editable source files, `manifest.md`, `ad-copy.csv`, and optional paused payload templates.
2. Make six rough/native 9:16 statics first.
   - 2 screenshot-review ads
   - 2 quick text-check ads
   - 2 recurring-update ads
3. Use deterministic local rendering when image generators are unnecessary.
   - SVG plus `rsvg-convert` is fast for Notes, Reddit, and WhatsApp mockups.
4. Fill out manifest fields.
   - file name, angle, format, first-frame text, primary text, headline, description, CTA, WhatsApp prefill, flow target, source tool, QA status, compliance notes.
5. Visual QA before handoff.
   - Text readable on mobile
   - WhatsApp action obvious
   - One promise per ad
   - No fake returns, profit claims, medical claims, or legal claims unless approved
   - Do not imply official WhatsApp or Meta partnership

## Pre-Launch Platform Check

Before activation:
- Confirm ad account is active.
- Confirm Page to WhatsApp connection in Ads Manager or WhatsApp Manager.
- Create ads paused.
- Preview on a real phone.
- Confirm tap opens the correct WhatsApp thread with the expected prefill or welcome flow.
- Send a test message and verify webhook referral metadata or fallback tracking.

## Message Match

The first WhatsApp response must match the ad promise exactly.

Example:
- Ad: "Send a screenshot and get a second opinion."
- First response: "Upload the screenshot here and I will review it for [specific output]."

## Funnel Events

Track:
1. `whatsapp_conversation_started`
2. `qualified_message`
3. `completed_core_action`
4. `recurring_opt_in`
5. `paid_conversion`, if applicable

## Compliance

- Do not imply WhatsApp endorsement.
- Do not use fake chat logs that look like real private messages unless clearly stylized.
- Do not promise regulated outcomes.
- Keep sensitive user data out of ad previews and screenshots.
