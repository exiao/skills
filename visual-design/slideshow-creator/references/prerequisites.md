# Prerequisites

This skill does NOT bundle any dependencies. Your AI agent will need to research and install the following based on your setup. Tell your agent what you're working with and it will figure out the rest.

### Required
- **Node.js** (v18+) — all scripts run on Node. Your agent should verify this is installed and install it if not.
- **node-canvas** (`npm install canvas`) — used for adding text overlays to slide images. This is a native module that may need build tools (Python, make, C++ compiler) on some systems. Your agent should research the install requirements for your OS.
- **Posting tool** — you need a way to post slideshows to TikTok. Options include ReelFarm (reel.farm), direct TikTok Creator API, or manual posting. The skill generates the slides and overlays; how you post them is flexible.

### Image Generation (pick one)
You choose what generates your images. Your agent should research the API docs for whichever you pick:
- **Gemini (DEFAULT)** — `gemini-3.1-flash-image-preview` (Nano Banana 2, released 2026-02-26). Needs a Gemini API key. Google's state-of-the-art model — Pro quality at Flash speed. **This is the recommended default.**
- **OpenAI** — `gpt-image-1.5`. Needs an OpenAI API key. Alternative if you prefer OpenAI.
- **Stability AI** — Stable Diffusion XL and newer. Needs a Stability AI API key. Good for stylized/artistic images.
- **Replicate** — run any open-source model (Flux, SDXL, etc.). Needs a Replicate API token. Most flexible.
- **Local** — bring your own images. No API needed. Place images in the output directory and the script skips generation.

### Conversion Tracking (optional but recommended for mobile apps)
- **RevenueCat** — this is what completes the intelligence loop. TikTok analytics tell you which posts get views. RevenueCat tells you which posts drive **paying users**. Combined, the agent can distinguish between a viral post that makes no money and a modest post that actually converts — and optimize accordingly. Install the RevenueCat skill from ClaWHub (`clawhub install revenuecat`) for full API access to subscribers, MRR, trials, churn, and revenue. There's also a **RevenueCat MCP** for programmatic control over products and offerings from your agent/IDE.

### Cross-Posting (optional, recommended)
Cross-post the same slideshows to Instagram Reels, YouTube Shorts, Threads, and other platforms. Same content, different algorithms, more reach. Your agent should research which platforms fit your audience.
