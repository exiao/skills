#!/usr/bin/env python3
"""
Auto-captions: Generate karaoke-style word-by-word highlighted captions and burn into video.

Usage:
    python caption.py input.mp4 -o output.mp4
    python caption.py input.mp4 -o output.mp4 --preset tiktok
    python caption.py input.mp4 --ass-only -o captions.ass
"""

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional


# ---------------------------------------------------------------------------
# Style presets
# ---------------------------------------------------------------------------

PRESETS = {
    "tiktok": {
        "font": "Montserrat",
        "font_size": 68,
        "highlight_color": "&H0000FFFF",   # yellow (active word)
        "base_color": "&H80FFFFFF",        # semi-transparent white (inactive)
        "outline_color": "&H00000000",     # black outline
        "outline_width": 4,
        "shadow_depth": 2,
        "words_per_block": 3,
        "position": "bottom",
        "bold": True,
    },
    "minimal": {
        "font": "Helvetica",
        "font_size": 54,
        "highlight_color": "&H00FFFFFF",
        "base_color": "&H60FFFFFF",
        "outline_color": "&H00333333",
        "outline_width": 1.5,
        "shadow_depth": 1,
        "words_per_block": 4,
        "position": "center",
        "bold": False,
    },
    "bold": {
        "font": "Impact",
        "font_size": 80,
        "highlight_color": "&H0000FFFF",   # yellow
        "base_color": "&H00FFFFFF",        # white
        "outline_color": "&H00000000",
        "outline_width": 5,
        "shadow_depth": 3,
        "words_per_block": 3,
        "position": "bottom",
        "bold": True,
    },
}


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class Word:
    text: str
    start: float  # seconds
    end: float    # seconds


@dataclass
class CaptionBlock:
    words: list  # list of Word
    start: float
    end: float


@dataclass
class StyleConfig:
    font: str = "Montserrat"
    font_size: int = 68
    highlight_color: str = "&H00FFFFFF"
    base_color: str = "&H80FFFFFF"
    outline_color: str = "&H00000000"
    outline_width: float = 4
    shadow_depth: float = 2
    words_per_block: int = 3
    position: str = "bottom"
    margin_bottom: int = 150
    margin_top: int = 100
    bold: bool = True
    pop_in: bool = True
    video_width: int = 1080
    video_height: int = 1920


# ---------------------------------------------------------------------------
# Video probe
# ---------------------------------------------------------------------------

def probe_video(video_path: str) -> tuple[int, int, float]:
    """Return (width, height, duration) of a video file."""
    cmd = [
        "ffprobe", "-v", "quiet", "-print_format", "json",
        "-show_streams", "-show_format", video_path
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    info = json.loads(result.stdout)

    width, height = 1080, 1920
    duration = 0.0

    for stream in info.get("streams", []):
        if stream.get("codec_type") == "video":
            width = int(stream.get("width", 1080))
            height = int(stream.get("height", 1920))
            break

    fmt = info.get("format", {})
    duration = float(fmt.get("duration", 0))

    return width, height, duration


# ---------------------------------------------------------------------------
# Transcription (stable-ts)
# ---------------------------------------------------------------------------

def transcribe(video_path: str, model_name: str = "base", language: Optional[str] = None) -> list[Word]:
    """Transcribe video using stable-ts and return word-level timestamps."""
    try:
        import stable_whisper
    except ImportError:
        print("Error: stable-ts not installed. Run: pip install stable-ts", file=sys.stderr)
        sys.exit(1)

    print(f"Loading Whisper model '{model_name}'...")
    model = stable_whisper.load_model(model_name)

    print("Transcribing (this may take a while)...")
    kwargs = {}
    if language:
        kwargs["language"] = language

    result = model.transcribe(video_path, **kwargs)

    words = []
    for segment in result.segments:
        for word_timing in segment.words:
            text = word_timing.word.strip()
            if text:
                words.append(Word(
                    text=text,
                    start=word_timing.start,
                    end=word_timing.end,
                ))

    print(f"Transcribed {len(words)} words.")
    return words


# ---------------------------------------------------------------------------
# Caption blocking
# ---------------------------------------------------------------------------

def group_words_into_blocks(words: list[Word], words_per_block: int) -> list[CaptionBlock]:
    """Group words into display blocks of N words each."""
    blocks = []
    for i in range(0, len(words), words_per_block):
        chunk = words[i:i + words_per_block]
        block = CaptionBlock(
            words=chunk,
            start=chunk[0].start,
            end=chunk[-1].end,
        )
        blocks.append(block)
    return blocks


# ---------------------------------------------------------------------------
# ASS generation
# ---------------------------------------------------------------------------

def seconds_to_ass_time(s: float) -> str:
    """Convert seconds to ASS timestamp format H:MM:SS.cc"""
    h = int(s // 3600)
    m = int((s % 3600) // 60)
    sec = int(s % 60)
    cs = int((s % 1) * 100)
    return f"{h}:{m:02d}:{sec:02d}.{cs:02d}"


def generate_ass(blocks: list[CaptionBlock], style: StyleConfig) -> str:
    """Generate an ASS subtitle file with karaoke-style word highlighting."""

    # Calculate vertical alignment and margins
    if style.position == "top":
        alignment = 8  # top-center
        margin_v = style.margin_top
    elif style.position == "center":
        alignment = 5  # mid-center
        margin_v = 0
    else:  # bottom
        alignment = 2  # bottom-center
        margin_v = style.margin_bottom

    bold_flag = -1 if style.bold else 0

    # ASS header
    ass = f"""[Script Info]
Title: Auto Captions
ScriptType: v4.00+
PlayResX: {style.video_width}
PlayResY: {style.video_height}
WrapStyle: 0
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Highlight,{style.font},{style.font_size},{style.highlight_color},&H000000FF,{style.outline_color},&H00000000,{bold_flag},0,0,0,100,100,0,0,1,{style.outline_width},{style.shadow_depth},{alignment},40,40,{margin_v},1
Style: Base,{style.font},{style.font_size},{style.base_color},&H000000FF,{style.outline_color},&H00000000,{bold_flag},0,0,0,100,100,0,0,1,{style.outline_width},{style.shadow_depth},{alignment},40,40,{margin_v},1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""

    for block in blocks:
        start_time = seconds_to_ass_time(block.start)
        # Add a small buffer after the last word ends
        end_time = seconds_to_ass_time(block.end + 0.3)

        # Build the karaoke line with per-word highlighting
        # We use override tags to color each word differently as it becomes active
        text_parts = []

        for i, word in enumerate(block.words):
            # Duration of this word in centiseconds
            if i < len(block.words) - 1:
                word_dur = block.words[i + 1].start - word.start
            else:
                word_dur = word.end - word.start
            dur_cs = max(1, int(word_dur * 100))

            # Pop-in animation: scale from 80% to 100% over 5cs
            if style.pop_in:
                pop_in_tag = (
                    f"\\t({int((word.start - block.start) * 100)},{int((word.start - block.start) * 100) + 5},"
                    f"\\fscx100\\fscy100)"
                )
                # Start word slightly smaller
                pre_tag = f"\\fscx85\\fscy85{pop_in_tag}"
            else:
                pre_tag = ""

            # Karaoke fade tag: \kf highlights the word over its duration
            # The color override makes inactive words use base_color, active use highlight_color
            text_parts.append(
                f"{{\\kf{dur_cs}{pre_tag}}}{word.text} "
            )

        line_text = "".join(text_parts).rstrip()

        ass += f"Dialogue: 0,{start_time},{end_time},Highlight,,0,0,0,,{line_text}\n"

    return ass


# ---------------------------------------------------------------------------
# Burn-in
# ---------------------------------------------------------------------------

def burn_captions(video_path: str, ass_path: str, output_path: str, crf: int = 18):
    """Burn ASS subtitles into video using ffmpeg."""
    # Escape special characters in path for ffmpeg filter
    escaped_ass = ass_path.replace("\\", "\\\\").replace(":", "\\:").replace("'", "\\'")

    cmd = [
        "ffmpeg", "-y",
        "-i", video_path,
        "-vf", f"ass={escaped_ass}",
        "-c:v", "libx264",
        "-crf", str(crf),
        "-preset", "medium",
        "-c:a", "copy",
        output_path,
    ]

    print(f"Burning captions into video...")
    print(f"  ffmpeg command: {' '.join(cmd)}")
    subprocess.run(cmd, check=True)
    print(f"Output saved to: {output_path}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Generate karaoke-style captions and burn into video."
    )
    parser.add_argument("input", help="Input video file")
    parser.add_argument("-o", "--output", required=True, help="Output file path (.mp4 or .ass)")
    parser.add_argument("--preset", default="tiktok", choices=PRESETS.keys(),
                        help="Style preset (default: tiktok)")
    parser.add_argument("--font", help="Font family name")
    parser.add_argument("--font-size", type=int, help="Font size in pixels")
    parser.add_argument("--highlight-color", help="ASS color for active word (&HAABBGGRR)")
    parser.add_argument("--base-color", help="ASS color for inactive words")
    parser.add_argument("--outline-color", help="Outline color")
    parser.add_argument("--outline-width", type=float, help="Outline thickness")
    parser.add_argument("--shadow-depth", type=float, help="Shadow distance")
    parser.add_argument("--words-per-block", type=int, help="Words per caption block")
    parser.add_argument("--position", choices=["top", "center", "bottom"],
                        help="Caption position")
    parser.add_argument("--margin-bottom", type=int, help="Bottom margin in pixels")
    parser.add_argument("--margin-top", type=int, help="Top margin in pixels")
    parser.add_argument("--resolution", help="Override video resolution (WxH, e.g. 1080x1920)")
    parser.add_argument("--model", default="base",
                        help="Whisper model size: tiny, base, small, medium, large")
    parser.add_argument("--ass-only", action="store_true",
                        help="Only generate .ass file, skip burn-in")
    parser.add_argument("--crf", type=int, default=18,
                        help="Video quality (lower=better, default 18)")
    parser.add_argument("--pop-in", action=argparse.BooleanOptionalAction, default=True,
                        help="Enable/disable pop-in animation")
    parser.add_argument("--language", help="Language code for transcription (e.g., en, es)")

    args = parser.parse_args()

    if not os.path.isfile(args.input):
        print(f"Error: Input file not found: {args.input}", file=sys.stderr)
        sys.exit(1)

    # Probe video dimensions
    print(f"Probing video: {args.input}")
    width, height, duration = probe_video(args.input)
    print(f"  Resolution: {width}x{height}, Duration: {duration:.1f}s")

    if args.resolution:
        w, h = args.resolution.lower().split("x")
        width, height = int(w), int(h)

    # Build style config from preset + overrides
    preset = PRESETS[args.preset]
    style = StyleConfig(
        font=args.font or preset["font"],
        font_size=args.font_size or preset["font_size"],
        highlight_color=args.highlight_color or preset["highlight_color"],
        base_color=args.base_color or preset.get("base_color", "&H80FFFFFF"),
        outline_color=args.outline_color or preset["outline_color"],
        outline_width=args.outline_width if args.outline_width is not None else preset["outline_width"],
        shadow_depth=args.shadow_depth if args.shadow_depth is not None else preset["shadow_depth"],
        words_per_block=args.words_per_block or preset["words_per_block"],
        position=args.position or preset.get("position", "bottom"),
        margin_bottom=args.margin_bottom if args.margin_bottom is not None else 150,
        margin_top=args.margin_top if args.margin_top is not None else 100,
        bold=preset.get("bold", True),
        pop_in=args.pop_in,
        video_width=width,
        video_height=height,
    )

    # Auto-adjust margins for vertical video
    is_vertical = height > width
    if is_vertical:
        print("  Detected vertical video. Adjusting margins for platform UI.")
        if args.margin_bottom is None:
            style.margin_bottom = 150
        if args.margin_top is None:
            style.margin_top = 100

    # Step 1: Transcribe
    words = transcribe(args.input, model_name=args.model, language=args.language)

    if not words:
        print("Error: No words transcribed. Check that the video has audible speech.", file=sys.stderr)
        sys.exit(1)

    # Step 2: Group into blocks
    blocks = group_words_into_blocks(words, style.words_per_block)
    print(f"Created {len(blocks)} caption blocks ({style.words_per_block} words each).")

    # Step 3: Generate ASS
    ass_content = generate_ass(blocks, style)

    if args.ass_only:
        output_ass = args.output
        if not output_ass.lower().endswith(".ass"):
            print(f"warning: --ass-only output path '{output_ass}' does not end in .ass — the file will contain ASS subtitle data regardless", file=sys.stderr)
        with open(output_ass, "w", encoding="utf-8") as f:
            f.write(ass_content)
        print(f"ASS subtitle file saved to: {output_ass}")
        return

    # Write ASS to temp file for burn-in
    with tempfile.NamedTemporaryFile(mode="w", suffix=".ass", delete=False, encoding="utf-8") as f:
        f.write(ass_content)
        temp_ass = f.name

    try:
        # Step 4: Burn in
        burn_captions(args.input, temp_ass, args.output, crf=args.crf)

        # Also save the ASS file alongside output for reference
        ass_sidecar = Path(args.output).with_suffix(".ass")
        with open(ass_sidecar, "w", encoding="utf-8") as f:
            f.write(ass_content)
        print(f"ASS file also saved to: {ass_sidecar}")
    finally:
        os.unlink(temp_ass)


if __name__ == "__main__":
    main()
