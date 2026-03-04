#!/usr/bin/env python3
"""
InfiniteTalk talking avatar video generation via Fal.ai.
Usage: uv run generate_video.py --image face.png --audio voice.mp3 --prompt "..." --output out.mp4
"""
import argparse
import os
import sys
import urllib.request
from datetime import datetime
from pathlib import Path


def upload_file(fal_client, file_path: Path) -> str:
    """Upload a local file to fal.ai storage and return the URL."""
    print(f"Uploading {file_path.name} to fal.ai storage...", file=sys.stderr)
    with open(file_path, "rb") as f:
        mime = "image/png" if file_path.suffix.lower() == ".png" else \
               "image/jpeg" if file_path.suffix.lower() in (".jpg", ".jpeg") else \
               "audio/mpeg" if file_path.suffix.lower() == ".mp3" else \
               "audio/wav"
        url = fal_client.upload(f.read(), mime)
    print(f"  → {url}", file=sys.stderr)
    return url


def main():
    parser = argparse.ArgumentParser(description="InfiniteTalk video generation via Fal.ai")
    parser.add_argument("--image", required=True, help="Character image (local path or URL)")
    parser.add_argument("--audio", required=True, help="Audio file (local path or URL)")
    parser.add_argument("--prompt", required=True, help="Expression/behavior prompt for avatar")
    parser.add_argument("--output", default=None, help="Output MP4 path")
    parser.add_argument("--resolution", default="720p", choices=["480p", "720p"], help="Video resolution")
    parser.add_argument("--acceleration", default="regular", choices=["none", "regular", "high"])
    args = parser.parse_args()

    try:
        import fal_client
    except ImportError:
        print("ERROR: fal-client not installed. Run: pip install fal-client", file=sys.stderr)
        sys.exit(1)

    api_key = os.environ.get("FAL_KEY")
    if not api_key:
        print("ERROR: FAL_KEY environment variable not set", file=sys.stderr)
        sys.exit(1)

    # Build output path
    if args.output:
        output_path = Path(args.output).expanduser()
    else:
        ts = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
        output_path = Path.home() / "clawd" / "output" / f"infinitetalk-{ts}.mp4"

    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Resolve image URL
    image_arg = args.image
    if not image_arg.startswith("http"):
        image_url = upload_file(fal_client, Path(image_arg).expanduser())
    else:
        image_url = image_arg

    # Resolve audio URL
    audio_arg = args.audio
    if not audio_arg.startswith("http"):
        audio_url = upload_file(fal_client, Path(audio_arg).expanduser())
    else:
        audio_url = audio_arg

    inputs = {
        "image_url": image_url,
        "audio_url": audio_url,
        "prompt": args.prompt,
        "resolution": args.resolution,
        "acceleration": args.acceleration,
    }

    print(f"Generating video: resolution={args.resolution}, acceleration={args.acceleration}", file=sys.stderr)

    def on_queue_update(update):
        if hasattr(update, "logs"):
            for log in update.logs:
                print(f"  [{log.get('level', 'INFO')}] {log.get('message', '')}", file=sys.stderr)

    handler = fal_client.submit(
        "fal-ai/infinitalk",
        arguments=inputs,
    )
    result = handler.get()

    video_url = result["video"]["url"]
    print(f"Downloading from {video_url}", file=sys.stderr)
    urllib.request.urlretrieve(video_url, output_path)

    print(f"VIDEO: {output_path}")


if __name__ == "__main__":
    main()
