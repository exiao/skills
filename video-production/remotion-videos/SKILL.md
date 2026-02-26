---
name: remotion-videos
description: Use when create animated marketing videos with Remotion (renders to MP4).
---

# Remotion Videos

Create animated videos using Remotion (React). Based on the official remotion-dev best practices plus Bloom-specific compositions.

## Quick Router

Read the relevant rule file based on the task:

### Core Animation
| Task | Rule File |
|------|-----------|
| Interpolation, easing, springs | `references/rules/timing.md` |
| Animations fundamentals | `references/rules/animations.md` |
| Text animations (typewriter, word-by-word, etc.) | `references/rules/text-animations.md` |
| Scene transitions (slide, fade, wipe, flip) | `references/rules/transitions.md` |
| Sequencing (delay, trim, limit duration) | `references/rules/sequencing.md` |
| Trimming (cut beginning/end) | `references/rules/trimming.md` |

### Media
| Task | Rule File |
|------|-----------|
| Images (Img component) | `references/rules/images.md` |
| Videos (embed, trim, volume, speed, loop) | `references/rules/videos.md` |
| Audio (import, trim, volume, speed, pitch) | `references/rules/audio.md` |
| Audio visualization (spectrum, waveforms) | `references/rules/audio-visualization.md` |
| GIFs synced to timeline | `references/rules/gifs.md` |
| Fonts (Google Fonts, local) | `references/rules/fonts.md` |
| Assets (importing images/videos/audio) | `references/rules/assets.md` |

### Captions & Voiceover
| Task | Rule File |
|------|-----------|
| Generate captions (transcribe audio) | `references/rules/transcribe-captions.md` |
| Import SRT captions | `references/rules/import-srt-captions.md` |
| Display captions (animated subtitles) | `references/rules/display-captions.md` |
| Subtitles overview | `references/rules/subtitles.md` |
| AI voiceover (ElevenLabs TTS) | `references/rules/voiceover.md` |

### Advanced
| Task | Rule File |
|------|-----------|
| 3D content (Three.js / React Three Fiber) | `references/rules/3d.md` |
| Charts (bar, pie, line, stock) | `references/rules/charts.md` |
| Maps (Mapbox) | `references/rules/maps.md` |
| Lottie animations | `references/rules/lottie.md` |
| Light leak overlays | `references/rules/light-leaks.md` |
| Transparent video rendering | `references/rules/transparent-videos.md` |

### Setup & Config
| Task | Rule File |
|------|-----------|
| Compositions, stills, folders, default props | `references/rules/compositions.md` |
| Dynamic metadata (calculateMetadata) | `references/rules/calculate-metadata.md` |
| Parametrize with Zod schema | `references/rules/parameters.md` |
| TailwindCSS in Remotion | `references/rules/tailwind.md` |
| Measuring text (fit, overflow) | `references/rules/measuring-text.md` |
| Measuring DOM nodes | `references/rules/measuring-dom-nodes.md` |

### FFmpeg & Media Utils
| Task | Rule File |
|------|-----------|
| FFmpeg operations (trim, silence detection) | `references/rules/ffmpeg.md` |
| Extract frames from video | `references/rules/extract-frames.md` |
| Get video duration | `references/rules/get-video-duration.md` |
| Get video dimensions | `references/rules/get-video-dimensions.md` |
| Get audio duration | `references/rules/get-audio-duration.md` |
| Check if video can be decoded | `references/rules/can-decode.md` |

---

## remotion-bits Component Kit

Pre-built animation components. Install: `npm install remotion-bits`

Key components: `AnimatedText` (word/character/line reveals), `ParticleSystem` (confetti, snow, fireflies), `GradientTransition`, `Scene3D` (3D camera moves), `Typewriter`, `CodeBlock` (syntax-highlighted typing).

See `references/remotion-bits.md` for full catalog and usage examples.

---

## Bloom Project

Project location: `~/clawd/remotion-videos/`

```
remotion-videos/
├── src/
│   ├── Root.tsx          # All compositions registered here
│   ├── ProductDemo.tsx   # Main product demo component
│   ├── schema.ts         # Zod schemas for props
│   ├── scenes/           # Individual scene components
│   │   ├── TerminalTyping.tsx
│   │   ├── FileScanning.tsx
│   │   ├── ScoreReveal.tsx
│   │   ├── ResultsSummary.tsx
│   │   └── TextOverlay.tsx
│   └── Composition.tsx
├── public/               # Static assets
├── out/                  # Rendered output
├── remotion.config.ts
└── package.json
```

### Existing Compositions

| ID | Size | Use Case |
|----|------|----------|
| `ProductDemo` | 1080x1080 | Twitter/Instagram square |
| `ProductDemoVertical` | 1080x1920 | TikTok/Reels/Shorts vertical |
| `BloomDemo` | 1080x1080 | Bloom-branded square |
| `BloomDemoVertical` | 1080x1920 | Bloom-branded vertical |

All compositions: 15 seconds @ 30fps (450 frames).

### Props Schema (ProductDemoProps)

```typescript
{
  command: string;           // Terminal command shown typing
  files: Array<{             // File list for scanning animation
    name: string;
    errors: number;
    warnings: number;
  }>;
  score: number;             // Score to reveal (0-maxScore)
  maxScore: number;          // Maximum score value
  statusLabel: string;       // e.g. "Critical", "Moderate Risk"
  statusColor: string;       // Hex color for status
  resultLines: string[];     // Summary findings
  title: string;             // Video title text
  logoText: string;          // Brand/product name
}
```

---

## Rendering

```bash
cd ~/clawd/remotion-videos

# Preview in browser (Remotion Studio)
npm run dev

# Render to MP4
npx remotion render ProductDemo out/product-demo.mp4

# Render vertical for TikTok
npx remotion render ProductDemoVertical out/product-demo-vertical.mp4

# Custom props
npx remotion render ProductDemo out/custom.mp4 --props='{"command":"my command","score":85}'

# Render as GIF
npx remotion render ProductDemo out/demo.gif --image-format=png --codec=gif

# Specific frame range
npx remotion render ProductDemo out/clip.mp4 --frames=0-150
```

### Creating New Compositions

1. Create scene components in `src/scenes/`
2. Create main composition in `src/`
3. Define Zod schema in `src/schema.ts`
4. Register in `src/Root.tsx` with dimensions:
   - Square: 1080x1080 (Twitter, Instagram)
   - Vertical: 1080x1920 (TikTok, Reels, Shorts)
   - Horizontal: 1920x1080 (YouTube)

---

## Tips

- Keep videos 15-30 seconds for social media
- Use high contrast colors for mobile viewing
- Add captions/text overlays (most viewers watch muted)
- Test both square and vertical before publishing
- Render at 30fps for social media (60fps for high-motion)
- Use remotion-bits components before building animations from scratch
