# Video Editing Recipes

Common multi-step workflows that chain edit.sh subcommands together. Each recipe shows the concept, then the concrete commands.

---

## Talking Head with B-Roll

A speaker on camera with cutaway clips, background music ducked under the voice, and a title card.

**Ingredients:** main talking head footage, 2-3 B-roll clips, voice audio (or extracted from main), background music track.

```bash
# Set EDIT to the absolute path, e.g. {baseDir}/scripts/edit.sh
EDIT="{baseDir}/scripts/edit.sh"

# 1. Trim the talking head to the usable segment
$EDIT trim -i talking_head.mp4 -ss 00:00:05 -to 00:03:20 -o head_trimmed.mp4

# 2. Trim B-roll clips
$EDIT trim -i broll_1.mp4 -ss 00:00:00 -to 00:00:08 -o broll_1_trimmed.mp4
$EDIT trim -i broll_2.mp4 -ss 00:00:02 -to 00:00:10 -o broll_2_trimmed.mp4

# 3. Extract voice from the main clip (or use separate voice recording)
# If voice is already separate, skip this
ffmpeg -y -i head_trimmed.mp4 -vn -c:a copy voice.aac

# 4. Duck the background music under the voice
$EDIT ducking -i voice.aac --music bg_music.mp3 -o ducked_audio.mp3

# 5. Normalize the mixed audio
$EDIT normalize -i ducked_audio.mp3 --target-lufs -16 -o final_audio.mp3

# 6. Build the video timeline
# Option A: Simple concat with crossfades
$EDIT crossfade -i "head_trimmed.mp4,broll_1_trimmed.mp4,head_trimmed_part2.mp4,broll_2_trimmed.mp4" --duration 0.5 -o timeline.mp4

# Option B: Use the talking head as base and overlay B-roll at specific times
# (requires manual ffmpeg for timed overlays — see "Advanced: Timed B-Roll Insert" below)

# 7. Replace audio with the ducked mix
$EDIT replace-audio -i timeline.mp4 --audio final_audio.mp3 -o with_audio.mp4

# 8. Add title card
$EDIT text -i with_audio.mp4 --text "How to Edit Video with FFmpeg" \
  --position top-center --fontsize 56 --fontcolor white --bg-color "black@0.6" \
  --from 0 --to 4 -o final.mp4

# 9. Fade in/out
$EDIT fade -i final.mp4 --fade-in 1 --fade-out 2 -o final_faded.mp4
```

### Advanced: Timed B-Roll Insert

To overlay B-roll at a specific timestamp on the talking head (instead of concatenating):

```bash
# Overlay broll_1 from 00:30 to 00:38 on the talking head
ffmpeg -y -i head_trimmed.mp4 -i broll_1_trimmed.mp4 \
  -filter_complex "[1:v]setpts=PTS-STARTPTS[broll];[0:v][broll]overlay=enable='between(t,30,38)'[out]" \
  -map "[out]" -map "0:a" -c:a copy output.mp4
```

---

## TikTok / Reels Slideshow

Turn a set of images into a vertical video with music, transitions, and optional text overlays.

**Ingredients:** 4-8 images (any size), a music track, optional caption text per slide.

```bash
# Set EDIT to the absolute path, e.g. {baseDir}/scripts/edit.sh
EDIT="{baseDir}/scripts/edit.sh"

# 1. Convert each image to a 3-second video clip at 9:16 (1080x1920)
for i in img1.jpg img2.jpg img3.jpg img4.jpg img5.jpg; do
  base="${i%.*}"
  # Scale and pad to 1080x1920, center the image
  ffmpeg -y -loop 1 -i "$i" -t 3 \
    -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black" \
    -c:v libx264 -pix_fmt yuv420p "${base}_clip.mp4"
done

# 2. Add crossfade transitions between clips
$EDIT crossfade -i "img1_clip.mp4,img2_clip.mp4,img3_clip.mp4,img4_clip.mp4,img5_clip.mp4" \
  --duration 0.5 --transition dissolve -o slideshow.mp4

# 3. Add text overlays (optional, one per slide)
# For per-slide text, apply drawtext with time ranges:
ffmpeg -y -i slideshow.mp4 \
  -vf "drawtext=text='The Beginning':fontsize=42:fontcolor=white:x=(w-tw)/2:y=h-th-100:enable='between(t,0,2.5)',\
drawtext=text='The Journey':fontsize=42:fontcolor=white:x=(w-tw)/2:y=h-th-100:enable='between(t,2.5,5)',\
drawtext=text='The Destination':fontsize=42:fontcolor=white:x=(w-tw)/2:y=h-th-100:enable='between(t,5,7.5)'" \
  -c:a copy slideshow_text.mp4

# 4. Add music at lower volume
$EDIT add-audio -i slideshow_text.mp4 --audio music.mp3 --volume 0.4 -o slideshow_music.mp4

# 5. Fade audio at the end
$EDIT fade -i slideshow_music.mp4 --fade-out 2 --audio-only -o final_tiktok.mp4
```

### Ken Burns Effect (Slow Zoom on Images)

Add subtle zoom/pan to make still images feel cinematic:

```bash
# Slow zoom in over 4 seconds (1080x1920 output)
ffmpeg -y -loop 1 -i image.jpg -t 4 \
  -vf "scale=1200:2133,zoompan=z='min(zoom+0.001,1.1)':d=120:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920" \
  -c:v libx264 -pix_fmt yuv420p zoomed.mp4
```

---

## Product Demo Video

Screen recording with zoom-ins on key areas, speed ramping for boring parts, background music, and a clean intro/outro.

**Ingredients:** screen recording, logo image, background music, optional voice narration.

```bash
# Set EDIT to the absolute path, e.g. {baseDir}/scripts/edit.sh
EDIT="{baseDir}/scripts/edit.sh"

# 1. Trim the screen recording to remove setup/cleanup
$EDIT trim -i screen_recording.mp4 -ss 00:00:12 -to 00:04:30 -o demo_trimmed.mp4

# 2. Speed up the boring navigation parts
# First, extract the boring segment
$EDIT trim -i demo_trimmed.mp4 -ss 00:00:00 -to 00:00:30 -o part1_intro.mp4
$EDIT trim -i demo_trimmed.mp4 -ss 00:00:30 -to 00:01:15 -o part2_boring.mp4
$EDIT trim -i demo_trimmed.mp4 -ss 00:01:15 -to 00:04:18 -o part3_demo.mp4

# Speed up the boring part 3x
$EDIT speed -i part2_boring.mp4 --factor 3.0 -o part2_fast.mp4

# 3. Rejoin the parts with transitions
$EDIT crossfade -i "part1_intro.mp4,part2_fast.mp4,part3_demo.mp4" \
  --duration 0.3 --transition fade -o demo_assembled.mp4

# 4. Add logo watermark
$EDIT overlay -i demo_assembled.mp4 --overlay logo.png \
  --position bottom-right --scale 0.08 -o demo_watermark.mp4

# 5. Add background music (ducked under narration if present)
# With narration:
$EDIT ducking -i narration.mp3 --music bg_music.mp3 -o demo_audio.mp3
$EDIT replace-audio -i demo_watermark.mp4 --audio demo_audio.mp3 -o demo_final.mp4

# Without narration (just music):
# $EDIT add-audio -i demo_watermark.mp4 --audio bg_music.mp3 --volume 0.2 -o demo_final.mp4

# 6. Add fade in/out
$EDIT fade -i demo_final.mp4 --fade-in 1.5 --fade-out 2 -o demo_complete.mp4
```

### Zoom Into a Region

To zoom into a specific area of a screen recording (simulating a mouse zoom):

```bash
# Zoom to 2x on a region centered at (960, 540) over 2 seconds, starting at t=15
ffmpeg -y -i demo.mp4 \
  -vf "zoompan=z='if(between(in_time,15,17),min(zoom+0.025,2),max(zoom-0.025,1))':d=1:x='960-iw/2/zoom':y='540-ih/2/zoom':s=1920x1080:fps=30" \
  -c:a copy zoomed_demo.mp4
```

---

## Quick One-Liners

These are standalone commands for common tasks that don't need a full recipe.

### Convert Horizontal to Vertical (with Blur Background)

```bash
# 16:9 input → 9:16 output with blurred background fill
ffmpeg -y -i horizontal.mp4 \
  -vf "split[original][bg];[bg]scale=1080:1920,boxblur=20[blurred];[original]scale=1080:-1[scaled];[blurred][scaled]overlay=(W-w)/2:(H-h)/2" \
  -c:a copy vertical_blur.mp4
```

### Add Subtitles from SRT

```bash
# Burn subtitles into video
ffmpeg -y -i video.mp4 -vf "subtitles=subs.srt:force_style='FontSize=24,PrimaryColour=&H00FFFFFF'" -c:a copy subtitled.mp4
```

### Create Video from Single Image + Audio

```bash
# Useful for podcast clips, music visualizers, etc.
ffmpeg -y -loop 1 -i cover.jpg -i audio.mp3 \
  -c:v libx264 -tune stillimage -c:a aac -shortest -pix_fmt yuv420p output.mp4
```

### Extract Audio from Video

```bash
ffmpeg -y -i video.mp4 -vn -c:a copy audio.aac
# Or convert to mp3:
ffmpeg -y -i video.mp4 -vn -c:a libmp3lame -q:a 2 audio.mp3
```

### Side-by-Side Comparison

```bash
# Two videos side by side (both must be same height)
ffmpeg -y -i left.mp4 -i right.mp4 \
  -filter_complex "[0:v]scale=960:540[l];[1:v]scale=960:540[r];[l][r]hstack[out]" \
  -map "[out]" -map "0:a?" comparison.mp4
```

### Stabilize Shaky Footage

```bash
# Two-pass stabilization
ffmpeg -i shaky.mp4 -vf vidstabdetect -f null -
ffmpeg -y -i shaky.mp4 -vf vidstabtransform=smoothing=10:input=transforms.trf stabilized.mp4
```
