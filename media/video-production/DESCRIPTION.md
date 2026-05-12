# Video Production

All video creation skills: AI video generation (Sora, Kling, Seedance), voiceover (ElevenLabs), talking avatars (InfiniteTalk), coded animations (Remotion), screen recordings, thumbnails, scriptwriting, and YouTube content extraction.

## Sub-skill Map

| Skill | What it does |
|-------|-------------|
| **elevenlabs** | ElevenLabs TTS via Fal.ai → MP3 voiceover |
| **infinitetalk** | Lip-sync character animation → MP4 (needs image + audio) |
| **sora** | OpenAI Sora API — AI video from text/image prompts |
| **kling** | Kling 3.0 AI video prompt engineering |
| **remotion-videos** | React/code animated marketing videos → MP4/GIF |
| **browser-animation-video** | Motion graphics via Framer Motion + GSAP (web) |
| **demo-video** | Records real browser interactions via Playwright |
| **gemini-svg** | AI-generated interactive SVG animations |
| **thumbnail** | Video cover frames / thumbnails |
| **video-script** | Scene-by-scene scripts with production metadata |
| **youtube-scriptwriting** | Long-form YouTube scripts (research → hook → structure → body → edit) |
| **youtube-content** | Fetch YouTube transcripts, reformat into summaries/threads/posts |

## Shared Assets

- `VISUAL-HOOKS.md` — Visual hook framework for first 1-3 seconds
- `hook-frames/` — Reference screenshots of effective hook compositions

## Routing Guidance

- "generate voiceover" / "text to speech" → **elevenlabs**
- "talking avatar" / "lip sync" → **infinitetalk**
- "generate a video of…" / "Sora" → **sora**
- "Kling prompt" → **kling**
- "Remotion" / "animated marketing video in code" → **remotion-videos**
- "motion graphics" / "Framer Motion" / "GSAP" → **browser-animation-video**
- "record a demo" / "walkthrough video" → **demo-video**
- "SVG animation" → **gemini-svg**
- "thumbnail" / "cover frame" → **thumbnail**
- "write a video script" / "TikTok script" / "Reels script" → **video-script**
- "YouTube script" / "long-form script" / "write a script for YouTube" → **youtube-scriptwriting**
- YouTube URL / "summarize this video" / "transcript" → **youtube-content**

## AI UGC Ad Pipeline (multi-skill chain)

For "make me a UGC ad" / "before after ad" / "transformation ad":
1. Generate "before" face → nano-banana-pro
2. Enhance to "after" → fal.ai face-enhancement
3. Animate both → kling (motion control)
4. Assemble → video-editor
5. Add captions → auto-captions

Target: 12s, 9:16 vertical MP4 for TikTok Ads Manager.
