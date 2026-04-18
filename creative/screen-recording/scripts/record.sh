#!/usr/bin/env bash
# record.sh — macOS screen recorder via ffmpeg + AVFoundation
#
# Usage:
#   record.sh start [options]   → starts recording in background, prints PID
#   record.sh stop <PID>        → stops recording cleanly (SIGINT)
#
# Options (start mode):
#   --output PATH       Output .mp4 file path (required)
#   --fps N             Frame rate (default: 30)
#   --quality N         libx264 CRF value: 18=high, 23=balanced, 28=small (default: 23)
#   --duration N        Auto-stop after N seconds (default: unlimited)
#   --cursor            Capture cursor in recording
#   --clicks            Visualize mouse clicks
#   --region x,y,w,h   Capture sub-region in logical pixels (default: full screen)
#   --codec [x264|vt]   Encoder: x264=libx264 (smaller), vt=h264_videotoolbox (faster)
#   --device N          AVFoundation screen device index (default: 1)

set -euo pipefail

FFMPEG="${FFMPEG_PATH:-/usr/local/bin/ffmpeg}"
MODE="${1:-}"

usage() {
  sed -n '2,20p' "$0" | sed 's/^# //'
  exit 1
}

# ─── STOP ────────────────────────────────────────────────────────────────────
if [[ "$MODE" == "stop" ]]; then
  PID="${2:-}"
  if [[ -z "$PID" ]]; then
    echo "Usage: record.sh stop <PID>" >&2
    exit 1
  fi
  if kill -0 "$PID" 2>/dev/null; then
    # SIGINT lets ffmpeg flush and write the moov atom cleanly
    kill -SIGINT "$PID"
    # Wait up to 5s for clean exit
    for i in $(seq 1 10); do
      sleep 0.5
      kill -0 "$PID" 2>/dev/null || break
    done
    # Force kill if still running
    kill -0 "$PID" 2>/dev/null && kill -9 "$PID" && echo "Force-killed $PID" >&2 || true
    echo "Stopped recording (PID $PID)"
  else
    echo "PID $PID is not running" >&2
    exit 1
  fi
  exit 0
fi

# ─── START ───────────────────────────────────────────────────────────────────
if [[ "$MODE" != "start" ]]; then
  usage
fi
shift  # consume "start"

# Defaults
OUTPUT=""
FPS=30
QUALITY=23
DURATION=""
CURSOR=0
CLICKS=0
REGION=""
CODEC="x264"
DEVICE=1

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)   OUTPUT="$2";   shift 2 ;;
    --fps)      FPS="$2";      shift 2 ;;
    --quality)  QUALITY="$2";  shift 2 ;;
    --duration) DURATION="$2"; shift 2 ;;
    --cursor)   CURSOR=1;      shift ;;
    --clicks)   CLICKS=1;      shift ;;
    --region)   REGION="$2";   shift 2 ;;
    --codec)    CODEC="$2";    shift 2 ;;
    --device)   DEVICE="$2";   shift 2 ;;
    *)          echo "Unknown option: $1" >&2; usage ;;
  esac
done

if [[ -z "$OUTPUT" ]]; then
  echo "Error: --output is required" >&2
  usage
fi

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT")"

# ─── Build ffmpeg command ─────────────────────────────────────────────────────
FFMPEG_ARGS=()

# Input device options (must come before -i)
[[ "$CURSOR" -eq 1 ]] && FFMPEG_ARGS+=(-capture_cursor 1)
[[ "$CLICKS" -eq 1 ]] && FFMPEG_ARGS+=(-capture_mouse_clicks 1)
FFMPEG_ARGS+=(-framerate "$FPS")

# Input: AVFoundation screen device
# Note: input pixel format is uyvy422 — DO NOT set -pix_fmt on input
FFMPEG_ARGS+=(-f avfoundation -i "${DEVICE}:none")

# Duration limit (optional)
[[ -n "$DURATION" ]] && FFMPEG_ARGS+=(-t "$DURATION")

# Crop filter for region capture
if [[ -n "$REGION" ]]; then
  IFS=',' read -r RX RY RW RH <<< "$REGION"
  # Region is in logical pixels; multiply by 2 for Retina physical pixels
  PRX=$((RX * 2))
  PRY=$((RY * 2))
  PRW=$((RW * 2))
  PRH=$((RH * 2))
  FFMPEG_ARGS+=(-vf "crop=${PRW}:${PRH}:${PRX}:${PRY}")
fi

# Output codec
if [[ "$CODEC" == "vt" || "$CODEC" == "h264_videotoolbox" ]]; then
  FFMPEG_ARGS+=(-vcodec h264_videotoolbox -b:v 5000k)
else
  FFMPEG_ARGS+=(-vcodec libx264 -crf "$QUALITY")
fi

# Output pixel format (yuv420p for compatibility)
FFMPEG_ARGS+=(-pix_fmt yuv420p)

# Output file
FFMPEG_ARGS+=("$OUTPUT" -y)

# ─── Launch in background ─────────────────────────────────────────────────────
LOG_FILE="${OUTPUT%.mp4}.ffmpeg.log"

"$FFMPEG" "${FFMPEG_ARGS[@]}" \
  >"$LOG_FILE" 2>&1 &

FFMPEG_PID=$!

# Give ffmpeg a moment to fail fast if something's wrong
sleep 0.5
if ! kill -0 "$FFMPEG_PID" 2>/dev/null; then
  echo "Error: ffmpeg failed to start. Check log: $LOG_FILE" >&2
  cat "$LOG_FILE" >&2
  exit 1
fi

# Output the PID (caller captures this)
echo "$FFMPEG_PID"
