#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "requests>=2.31.0",
# ]
# ///
"""
Generate or edit images using xAI's Grok Imagine (Aurora) API.

Usage:
    uv run generate_image.py --prompt "description" --filename "output.png"
    uv run generate_image.py --prompt "edit this" --filename "output.png" -i input.png
    uv run generate_image.py --prompt "combine" --filename "output.png" -i a.png -i b.png -i c.png
"""

import argparse
import base64
import os
import sys
from pathlib import Path

import requests

API_BASE = "https://api.x.ai/v1"
GENERATION_URL = f"{API_BASE}/images/generations"
EDIT_URL = f"{API_BASE}/images/edits"

MODEL_MAP = {
    "default": "grok-imagine-image",
    "quality": "grok-imagine-image-quality",
}

SUPPORTED_ASPECT_RATIOS = [
    "1:1", "16:9", "9:16", "4:3", "3:4",
    "3:2", "2:3", "2:1", "1:2", "auto",
]


def get_api_key(provided_key: str | None) -> str | None:
    """Get API key from argument, then env var."""
    if provided_key:
        return provided_key
    return os.environ.get("XAI_API_KEY")


def encode_image(image_path: str) -> str:
    """Read an image file and return a base64 data URI."""
    path = Path(image_path)
    if not path.exists():
        print(f"Error: Image file not found: {image_path}", file=sys.stderr)
        sys.exit(1)

    suffix = path.suffix.lower()
    mime_map = {
        ".png": "image/png",
        ".jpg": "image/jpeg",
        ".jpeg": "image/jpeg",
        ".webp": "image/webp",
        ".gif": "image/gif",
    }
    mime = mime_map.get(suffix, "image/png")

    with open(path, "rb") as f:
        data = base64.b64encode(f.read()).decode("utf-8")

    return f"data:{mime};base64,{data}"


def download_image(url: str, output_path: Path) -> bool:
    """Download an image from a URL to a local file."""
    try:
        resp = requests.get(url, timeout=120)
        resp.raise_for_status()
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "wb") as f:
            f.write(resp.content)
        return True
    except Exception as e:
        print(f"Error downloading image: {e}", file=sys.stderr)
        return False


def make_output_path(base_path: Path, index: int, total: int) -> Path:
    """Generate output path, appending -N suffix when generating multiple images."""
    if total <= 1:
        return base_path
    stem = base_path.stem
    suffix = base_path.suffix
    return base_path.parent / f"{stem}-{index}{suffix}"


def process_response_images(data: dict, output_base: Path) -> int:
    """Process API response images: download URLs or decode b64, print MEDIA: lines.

    Returns the count of successfully saved images.
    """
    images = data.get("data", [])
    if not images:
        print("Error: No images returned in response.", file=sys.stderr)
        sys.exit(1)

    saved = 0
    for i, img in enumerate(images):
        out_path = make_output_path(output_base, i + 1, len(images))
        url = img.get("url")
        b64 = img.get("b64_json")

        if url:
            if download_image(url, out_path):
                saved += 1
                full = out_path.resolve()
                print(f"\nImage saved: {full}")
                print(f"MEDIA:{full}")
        elif b64:
            try:
                image_data = base64.b64decode(b64)
                out_path.parent.mkdir(parents=True, exist_ok=True)
                with open(out_path, "wb") as f:
                    f.write(image_data)
                saved += 1
                full = out_path.resolve()
                print(f"\nImage saved: {full}")
                print(f"MEDIA:{full}")
            except Exception as e:
                print(f"Error saving base64 image: {e}", file=sys.stderr)
        else:
            print(f"Warning: Image {i + 1} has no url or b64_json.", file=sys.stderr)

    if saved == 0:
        print("Error: Failed to save any images.", file=sys.stderr)
        sys.exit(1)

    print(f"\nDone. {saved}/{len(images)} image(s) saved.")
    return saved


def generate_images(api_key: str, args: argparse.Namespace) -> None:
    """Generate images from a text prompt (no input images)."""
    model = MODEL_MAP[args.model]
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    }

    payload: dict = {
        "model": model,
        "prompt": args.prompt,
        "n": args.n,
    }
    if args.aspect_ratio:
        payload["aspect_ratio"] = args.aspect_ratio
    if args.resolution:
        payload["resolution"] = args.resolution

    print(f"Generating {args.n} image(s) with {model}...")
    if args.aspect_ratio:
        print(f"  Aspect ratio: {args.aspect_ratio}")
    print(f"  Resolution: {args.resolution}")

    try:
        resp = requests.post(GENERATION_URL, json=payload, headers=headers, timeout=300)
    except requests.exceptions.Timeout:
        print("Error: Request timed out after 300s.", file=sys.stderr)
        sys.exit(1)
    except requests.exceptions.ConnectionError as e:
        print(f"Error: Connection failed: {e}", file=sys.stderr)
        sys.exit(1)

    if resp.status_code != 200:
        print(f"Error: API returned {resp.status_code}", file=sys.stderr)
        try:
            error_body = resp.json()
            print(f"  {error_body}", file=sys.stderr)
        except Exception:
            print(f"  {resp.text}", file=sys.stderr)
        sys.exit(1)

    process_response_images(resp.json(), Path(args.filename))


def edit_images(api_key: str, args: argparse.Namespace) -> None:
    """Edit one or more input images with a prompt."""
    model = MODEL_MAP[args.model]
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    }

    input_paths = args.input_images
    num_inputs = len(input_paths)
    print(f"Editing {num_inputs} image(s) with {model}...")

    # Encode input images
    encoded = []
    for img_path in input_paths:
        print(f"  Loading: {img_path}")
        data_uri = encode_image(img_path)
        encoded.append({"type": "image_url", "url": data_uri})

    payload: dict = {
        "model": model,
        "prompt": args.prompt,
    }

    # Single image uses "image", multiple uses "images"
    if num_inputs == 1:
        payload["image"] = encoded[0]
    else:
        payload["images"] = encoded

    if args.aspect_ratio:
        payload["aspect_ratio"] = args.aspect_ratio
        print(f"  Aspect ratio: {args.aspect_ratio}")
    if args.resolution:
        payload["resolution"] = args.resolution
    print(f"  Resolution: {args.resolution}")

    try:
        resp = requests.post(EDIT_URL, json=payload, headers=headers, timeout=300)
    except requests.exceptions.Timeout:
        print("Error: Request timed out after 300s.", file=sys.stderr)
        sys.exit(1)
    except requests.exceptions.ConnectionError as e:
        print(f"Error: Connection failed: {e}", file=sys.stderr)
        sys.exit(1)

    if resp.status_code != 200:
        print(f"Error: API returned {resp.status_code}", file=sys.stderr)
        try:
            error_body = resp.json()
            print(f"  {error_body}", file=sys.stderr)
        except Exception:
            print(f"  {resp.text}", file=sys.stderr)
        sys.exit(1)

    process_response_images(resp.json(), Path(args.filename))


def main():
    parser = argparse.ArgumentParser(
        description="Generate or edit images using xAI Grok Imagine (Aurora)"
    )
    parser.add_argument(
        "--prompt", "-p",
        required=True,
        help="Image description or edit instructions",
    )
    parser.add_argument(
        "--filename", "-f",
        required=True,
        help="Output filename (e.g., 2026-05-07-sunset.png)",
    )
    parser.add_argument(
        "--input-image", "-i",
        action="append",
        dest="input_images",
        metavar="IMAGE",
        help="Input image path(s) for editing. Up to 3 images.",
    )
    parser.add_argument(
        "--resolution", "-r",
        choices=["1k", "2k"],
        default="1k",
        help="Output resolution (default: 1k)",
    )
    parser.add_argument(
        "--aspect-ratio", "-a",
        choices=SUPPORTED_ASPECT_RATIOS,
        default=None,
        help="Output aspect ratio (default: model decides)",
    )
    parser.add_argument(
        "--model", "-m",
        choices=["default", "quality"],
        default="default",
        help="Model: 'default' (grok-imagine-image, fast) or 'quality' (grok-imagine-image-quality, best)",
    )
    parser.add_argument(
        "-n",
        type=int,
        default=1,
        help="Number of images to generate (1-10, default: 1)",
    )
    parser.add_argument(
        "--api-key", "-k",
        help="xAI API key (overrides XAI_API_KEY env var)",
    )

    args = parser.parse_args()

    # Validate n
    if args.n < 1 or args.n > 10:
        print("Error: -n must be between 1 and 10.", file=sys.stderr)
        sys.exit(1)

    # Validate input images count
    if args.input_images and len(args.input_images) > 3:
        print(f"Error: Too many input images ({len(args.input_images)}). Maximum is 3.", file=sys.stderr)
        sys.exit(1)

    # Warn if -n > 1 with edits (edits don't support batch)
    if args.input_images and args.n > 1:
        print("Warning: -n is ignored for image edits, generating 1 image.", file=sys.stderr)
        args.n = 1

    # Get API key
    api_key = get_api_key(args.api_key)
    if not api_key:
        print("Error: No API key provided.", file=sys.stderr)
        print("  Set XAI_API_KEY env var or pass --api-key.", file=sys.stderr)
        sys.exit(1)

    if args.input_images:
        edit_images(api_key, args)
    else:
        generate_images(api_key, args)


if __name__ == "__main__":
    main()
