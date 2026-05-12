#!/usr/bin/env python3
"""Generate clean Google App Campaign chart/callout image variants.

This is a deterministic fallback for Bloom-style creative when AI image models
produce generic finance slop. It creates vector-like PNGs with Pillow:
white background, green price line, orange event marker, and a tooltip that
connects market news to a price move.

Usage:
  uv run --with pillow python scripts/chart_callout_asset.py \
    --out-dir /tmp/bloom-assets \
    --brand Bloom \
    --headline "Earnings beat expectations" \
    --subline "Bloom explains the move before you react." \
    --event-label "Earnings update" \
    --filename bloom-earnings-1200x628.png \
    --size 1200x628
"""
from __future__ import annotations

import argparse
import math
import random
from pathlib import Path
from typing import Tuple

from PIL import Image, ImageDraw, ImageFilter, ImageFont

NAVY = (15, 23, 42)
GREEN = (20, 184, 120)
ORANGE = (244, 120, 45)
GREY = (226, 232, 240)
MID = (100, 116, 139)
TEAL = (40, 181, 189)


def parse_size(value: str) -> Tuple[int, int]:
    w, h = value.lower().split("x", 1)
    return int(w), int(h)


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        ("/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf"),
        ("/System/Library/Fonts/Supplemental/Helvetica Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Helvetica.ttf"),
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size)
        except Exception:
            pass
    return ImageFont.load_default()


def rounded_shadow(img: Image.Image, box, radius: int = 22) -> None:
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    x0, y0, x1, y1 = [int(v) for v in box]
    od.rounded_rectangle([x0 + 5, y0 + 7, x1 + 5, y1 + 7], radius=radius, fill=(0, 0, 0, 32))
    img.alpha_composite(overlay.filter(ImageFilter.GaussianBlur(9)))


def draw_asset(args: argparse.Namespace) -> Path:
    w, h = parse_size(args.size)
    random.seed(args.seed + w + h)
    img = Image.new("RGBA", (w, h), "white")
    d = ImageDraw.Draw(img)

    # Subtle grid. Keep it quiet so it does not become a fake dashboard.
    for i in range(5):
        y = int(h * (0.22 + i * 0.13))
        d.line([(70, y), (w - 70, y)], fill=(245, 247, 250), width=2)
    for i in range(6):
        x = int(w * (0.08 + i * 0.15))
        d.line([(x, 90), (x, h - 70)], fill=(248, 250, 252), width=1)

    d.ellipse([50, 44, 72, 66], fill=TEAL)
    d.text((84, 40), args.brand, fill=NAVY, font=load_font(28, True))
    d.text((84, 72), args.tagline, fill=MID, font=load_font(16))

    left, right = 90, w - 78
    bottom = int(h * 0.78)
    points = []
    for i in range(11):
        t = i / 10
        x = left + t * (right - left)
        if t < 0.45:
            y = bottom - 20 - math.sin(t * 10 + args.seed) * 18 - random.randint(-8, 10)
        elif t < 0.64:
            y = bottom - 38 - random.randint(-6, 18)
        else:
            y = bottom - 38 - (t - 0.64) * h * 0.72 - random.randint(-6, 8)
        points.append((x, y))

    for width, color in [(14, (187, 247, 208, 145)), (8, GREEN)]:
        d.line(points, fill=color, width=width, joint="curve")

    marker_x, marker_y = points[5]
    d.ellipse([marker_x - 20, marker_y - 20, marker_x + 20, marker_y + 20], fill="white", outline=ORANGE, width=9)
    d.ellipse([marker_x - 6, marker_y - 6, marker_x + 6, marker_y + 6], fill=ORANGE)

    if w > h:
        box = (int(w * 0.18), int(h * 0.16), int(w * 0.56), int(h * 0.36))
    else:
        box = (int(w * 0.12), int(h * 0.15), int(w * 0.88), int(h * 0.34))
    bx0, by0, bx1, by1 = box
    d.line([(marker_x, marker_y - 24), (marker_x, by1 + 4), (bx0 + 34, by1 + 4)], fill=(203, 213, 225), width=3)

    rounded_shadow(img, box, radius=24)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle(box, radius=24, fill="white", outline=GREY, width=2)
    d.ellipse([bx0 + 24, by0 + 25, bx0 + 44, by0 + 45], fill=ORANGE)
    d.text((bx0 + 58, by0 + 20), args.event_label, fill=MID, font=load_font(18, True))
    d.text((bx0 + 26, by0 + 58), args.headline, fill=NAVY, font=load_font(31 if w > h else 29, True))
    d.text((bx0 + 26, by0 + 99), args.subline, fill=(51, 65, 85), font=load_font(22 if w > h else 20))

    footer = args.footer
    text_width = d.textbbox((0, 0), footer, font=load_font(21))[2]
    d.text(((w - text_width) // 2, h - 48), footer, fill=(71, 85, 105), font=load_font(21))

    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / args.filename
    img.convert("RGB").save(out, quality=96)
    return out


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out-dir", required=True)
    parser.add_argument("--filename", required=True)
    parser.add_argument("--size", default="1200x628", help="e.g. 1200x628 or 1200x1200")
    parser.add_argument("--brand", default="Bloom")
    parser.add_argument("--tagline", default="market context")
    parser.add_argument("--event-label", required=True)
    parser.add_argument("--headline", required=True)
    parser.add_argument("--subline", required=True)
    parser.add_argument("--footer", default="Connect market-moving news to the price move.")
    parser.add_argument("--seed", type=int, default=0)
    args = parser.parse_args()
    print(draw_asset(args))


if __name__ == "__main__":
    main()
