#!/usr/bin/env bash
# record-with-actions.sh — Template: screen recording + peekaboo UI automation
#
# This script shows how to combine ffmpeg screen recording with peekaboo-driven
# UI actions to produce automated demo videos.
#
# Usage: edit the ACTIONS section below, then run:
#   chmod +x record-with-actions.sh
#   ./record-with-actions.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RECORD="$SCRIPT_DIR/record.sh"
PEEKABOO="${PEEKABOO_PATH:-/usr/local/bin/peekaboo}"
FFMPEG="${FFMPEG_PATH:-/usr/local/bin/ffmpeg}"

# ─── Configuration ────────────────────────────────────────────────────────────

OUTPUT="${1:-/tmp/demo-$(date +%Y%m%d-%H%M%S).mp4}"
FINAL_OUTPUT="${OUTPUT%.mp4}-1080p.mp4"

echo "🎬 Recording to: $OUTPUT"
echo "📦 Final (1080p): $FINAL_OUTPUT"

# ─── Start Recording ──────────────────────────────────────────────────────────

REC_PID=$("$RECORD" start \
  --output "$OUTPUT" \
  --fps 30 \
  --quality 18 \
  --cursor \
  --clicks)

echo "▶️  Recording started (PID: $REC_PID)"

# IMPORTANT: always wait 1-2s before driving UI so ffmpeg stabilizes
sleep 1.5

# ─── ACTIONS (edit this section) ─────────────────────────────────────────────
#
# Drive UI with peekaboo commands. Examples:
#
# Open an app:
#   $PEEKABOO app --open Safari
#   sleep 1
#
# Click an element by name:
#   $PEEKABOO click --app Safari --element "Address and Search Field"
#   sleep 0.3
#
# Type text:
#   $PEEKABOO type --text "https://example.com"
#   sleep 0.2
#   $PEEKABOO key --key return
#   sleep 2
#
# Take a screenshot checkpoint (for AI review later):
#   $PEEKABOO screenshot --path /tmp/checkpoint.png
#
# Scroll:
#   $PEEKABOO scroll --app Safari --direction down --amount 3
#   sleep 0.5
#
# Click coordinates:
#   $PEEKABOO click --x 720 --y 400
#
# Move mouse slowly (makes movement visible in recording):
#   $PEEKABOO move --x 720 --y 400 --duration 0.5
#
# ─── Example: Open Safari and navigate ───────────────────────────────────────

echo "🖥️  Driving UI..."

# Example actions — replace with your actual demo steps:
# $PEEKABOO app --open Safari
# sleep 1.5
# $PEEKABOO click --app Safari --element "Address and Search Field"
# sleep 0.3
# $PEEKABOO type --text "https://getbloom.app"
# sleep 0.2
# $PEEKABOO key --key return
# sleep 3
# $PEEKABOO scroll --app Safari --direction down --amount 5
# sleep 1

# For now, just pause to show the idle screen
sleep 5

echo "⏹️  Stopping recording..."

# ─── Stop Recording ───────────────────────────────────────────────────────────

"$RECORD" stop "$REC_PID"

# ─── Post-Processing ──────────────────────────────────────────────────────────

echo "🔧 Post-processing..."

# Scale from Retina 2880x1800 → 1920x1080 for sharing
"$FFMPEG" -y -i "$OUTPUT" \
  -vf "scale=1920:1080" \
  -c:v libx264 \
  -crf 20 \
  -pix_fmt yuv420p \
  -movflags +faststart \
  "$FINAL_OUTPUT" 2>/dev/null

RAW_SIZE=$(du -sh "$OUTPUT" | cut -f1)
FINAL_SIZE=$(du -sh "$FINAL_OUTPUT" | cut -f1)

echo ""
echo "✅ Done!"
echo "   Raw (Retina): $OUTPUT ($RAW_SIZE)"
echo "   Final (1080p): $FINAL_OUTPUT ($FINAL_SIZE)"

# ─── Optional: Take a peekaboo screenshot of final state ─────────────────────

# $PEEKABOO screenshot --path "${OUTPUT%.mp4}-final.png"
# echo "   Screenshot: ${OUTPUT%.mp4}-final.png"
