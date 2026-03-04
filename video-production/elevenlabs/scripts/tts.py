#!/usr/bin/env python3
"""
ElevenLabs TTS via Fal.ai
Usage: uv run tts.py --text "Your script here" --voice "Alice" --output output.mp3
"""
import argparse
import os
import sys
import urllib.request
from datetime import datetime
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description="ElevenLabs TTS via Fal.ai")
    parser.add_argument("--text", required=True, help="Text to convert to speech")
    parser.add_argument("--voice", default="Rachel", help="Voice name (default: Rachel)")
    parser.add_argument("--stability", type=float, default=0.5, help="Voice stability 0-1 (default: 0.5)")
    parser.add_argument("--language", default=None, help="ISO 639-1 language code")
    parser.add_argument("--output", default=None, help="Output MP3 path")
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
        output_path = Path.home() / "clawd" / "output" / f"tts-{ts}.mp3"

    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Build input
    inputs = {
        "text": args.text,
        "voice": args.voice,
        "stability": args.stability,
        "apply_text_normalization": "auto",
    }
    if args.language:
        inputs["language_code"] = args.language

    print(f"Generating audio: voice={args.voice}, chars={len(args.text)}", file=sys.stderr)

    handler = fal_client.submit("fal-ai/elevenlabs/tts/eleven-v3", arguments=inputs)
    result = handler.get()

    audio_url = result["audio"]["url"]
    print(f"Downloading from {audio_url}", file=sys.stderr)
    urllib.request.urlretrieve(audio_url, output_path)

    print(f"AUDIO: {output_path}")


if __name__ == "__main__":
    main()
