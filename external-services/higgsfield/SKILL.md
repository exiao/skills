---
name: higgsfield
preloaded: true
description: "Use the Higgsfield MCP for AI image and video generation — 30+ models (Seedance, Kling, Veo, Flux, Soul, Minimax Hailuo, Cinema Studio, Nano Banana, Seedream) accessible from any MCP-compatible agent. Supports text-to-video, image-to-video, text-to-image, multi-model comparison, character training (Soul Characters), ad engine, and brand builder workflows. Triggers on \"Higgsfield\", \"Higgsfield MCP\", \"generate video via Higgsfield\", \"Soul Character\", \"multi-model comparison\", \"ad engine\", \"brand builder\"."
metadata:
  version: 2.0.0
---

# Higgsfield MCP — AI Image & Video Generation

Higgsfield MCP connects AI agents to a full creative studio — image generation, video creation, character training, and asset management via MCP (Model Context Protocol).

**MCP Server URL:**
```
https://mcp.higgsfield.ai/mcp
```

**No API key required** — authentication happens through your Higgsfield account.

---

## Setup

### Via mcporter (preferred for Hermes Agent)

```bash
mcporter add higgsfield --url https://mcp.higgsfield.ai/mcp
mcporter tools higgsfield
```

### Via Claude Desktop / Claude Code

1. Settings → Connectors → Add custom connector
2. Name: "Higgsfield", URL: `https://mcp.higgsfield.ai/mcp`
3. Connect → sign in with Higgsfield account

### Via config file (any MCP client)

```json
{
  "mcpServers": {
    "higgsfield": {
      "url": "https://mcp.higgsfield.ai/mcp"
    }
  }
}
```

---

## Supported Agents

- Claude (web, Cowork, Claude Code)
- Hermes Agent / OpenClaw
- NemoClaw
- Any MCP-compatible client

---

## Capabilities

### Models Available (30+)

| Category | Models |
|----------|--------|
| **Image** | Soul, Nano Banana, Flux, Seedream, Cinema Studio |
| **Video** | Seedance, Kling, Minimax Hailuo, Veo |

- Up to **4K resolution**, any aspect ratio
- Videos up to **15 seconds**
- Generate from text prompts, reference images, or both
- Agent auto-selects best model, or you can specify one

### Video Presets

9 curated presets: UGC, unboxing, product review, hyper motion, TV spot, and more — automatically passed into generation.

### Workflow Tiers

| Tier | Description | Example |
|------|-------------|---------|
| **Asset Creation** | Single-asset generation in seconds | "Generate a cinematic wide shot of a neon-lit Tokyo alley at night" |
| **Full Production** | Train characters, generate scenes, produce videos, manage history | "Train a Soul Character from these photos, then generate a 10-image lookbook" |
| **Multi-Model Comparison** | Same prompt through multiple models simultaneously | "Generate this scene on 4 different models and show me the results" |

### Ad Engine
Finds top-spending niches, generates videos across formats (UGC, TV spot, Wild Card), writes outreach, delivers weekly reports.

### Brand Builder
Finds underserved products, sources factories, generates listing photos and hero video, mines reviews for counter-narrative ads, builds D2C sites.

### Content at Scale
Pulls listings/trends, generates polished videos per item, distributes via WhatsApp, YouTube, etc.

---

## Use Cases

| Category | Description |
|----------|-------------|
| **E-Commerce & Product** | Lifestyle product shots, background swaps, promo videos without a photo studio |
| **Social Media** | Scroll-stopping images and short-form video for Instagram, TikTok, YouTube |
| **Marketing Agencies** | Scale campaign visuals across formats/styles; generate dozens of variations |
| **Filmmaking** | Storyboards, concept art, previsualization, cinematic clips; Soul Characters for cast consistency |
| **Infographics** | Custom illustrations, icons, and imagery for data stories |

---

## Pricing

Uses Higgsfield credit system. Cost varies by model and resolution. Existing plan credits work seamlessly. Eric has a **Creator subscription**.

---

## Seedance Prompting

For Seedance-specific video generation, see `references/seedance-prompting-guide.md` — covers the 5 official prompt formats (Transformations, Orbs, POVs, Fights, Animation), VFX bracket syntax, content filter workarounds, and full prompt templates.

## Kling Prompting

For Kling-specific prompting and direct API usage, see the `kling` skill.
