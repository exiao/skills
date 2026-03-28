#!/usr/bin/env bash
set -euo pipefail

# video-editor: ffmpeg wrapper for common video/audio editing operations
# Usage: edit.sh <subcommand> [options]

VERSION="1.0.0"

# ─── Helpers ──────────────────────────────────────────────────────────────────

die() { echo "error: $*" >&2; exit 1; }

require_arg() {
  [[ -n "${2:-}" ]] || die "$1 is required"
}

check_ffmpeg() {
  command -v ffmpeg >/dev/null 2>&1 || die "ffmpeg not found. Install it from https://ffmpeg.org/download.html or via your package manager (e.g. brew install ffmpeg / apt install ffmpeg)"
  command -v ffprobe >/dev/null 2>&1 || die "ffprobe not found. Install it from https://ffmpeg.org/download.html or via your package manager (e.g. brew install ffmpeg / apt install ffmpeg)"
}

get_duration() {
  ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$1" 2>/dev/null | head -1
}

get_resolution() {
  ffprobe -v quiet -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$1" 2>/dev/null | head -1
}

get_codec() {
  ffprobe -v quiet -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "$1" 2>/dev/null | head -1
}

has_audio() {
  local count
  count=$(ffprobe -v quiet -select_streams a -show_entries stream=index -of csv=p=0 "$1" 2>/dev/null | wc -l)
  [[ "$count" -gt 0 ]]
}

# Split comma-separated string into array
split_csv() {
  IFS=',' read -ra RESULT <<< "$1"
  echo "${RESULT[@]}"
}

# ─── Subcommands ──────────────────────────────────────────────────────────────

cmd_trim() {
  local input="" output="" ss="" to="" precise=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      -ss|--ss) ss="$2"; shift 2 ;;
      -to|--to) to="$2"; shift 2 ;;
      --precise) precise=true; shift ;;
      *) die "trim: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "-o" "$output"
  require_arg "-ss" "$ss"

  local to_args=()
  [[ -n "$to" ]] && to_args=(-to "$to")

  if $precise; then
    ffmpeg -y -ss "$ss" "${to_args[@]}" -i "$input" -c:v libx264 -c:a aac "$output"
  else
    ffmpeg -y -ss "$ss" "${to_args[@]}" -i "$input" -c copy "$output"
  fi
  echo "Trimmed: $output"
}

cmd_concat() {
  local input="" output=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      *) die "concat: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "-o" "$output"

  IFS=',' read -ra files <<< "$input"
  [[ ${#files[@]} -ge 2 ]] || die "concat: need at least 2 files"

  # Check if all files share the same codec
  local first_codec
  first_codec=$(get_codec "${files[0]}")
  local same_codec=true
  for f in "${files[@]}"; do
    [[ -f "$f" ]] || die "concat: file not found: $f"
    local c
    c=$(get_codec "$f")
    [[ "$c" == "$first_codec" ]] || same_codec=false
  done

  if $same_codec; then
    # Fast concat via demuxer
    local listfile
    listfile=$(mktemp /tmp/concat_XXXXXX.txt)
    for f in "${files[@]}"; do
      echo "file '$(cd "$(dirname "$f")" && pwd)/$(basename "$f")'" >> "$listfile"
    done
    ffmpeg -y -f concat -safe 0 -i "$listfile" -c copy "$output"
    rm -f "$listfile"
  else
    # Re-encode concat via filter_complex
    local inputs=() filter=""
    for i in "${!files[@]}"; do
      inputs+=(-i "${files[$i]}")
      filter+="[$i:v:0][$i:a:0]"
    done
    filter+="concat=n=${#files[@]}:v=1:a=1[outv][outa]"
    ffmpeg -y "${inputs[@]}" -filter_complex "$filter" -map "[outv]" -map "[outa]" "$output"
  fi
  echo "Concatenated ${#files[@]} files: $output"
}

cmd_overlay() {
  local input="" overlay_file="" output="" position="top-right" scale=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      --overlay) overlay_file="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --position) position="$2"; shift 2 ;;
      --scale) scale="$2"; shift 2 ;;
      *) die "overlay: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "--overlay" "$overlay_file"
  require_arg "-o" "$output"

  local scale_filter=""
  if [[ -n "$scale" ]]; then
    scale_filter="[1:v]scale=iw*${scale}:-1[ovrl];"
    local ovrl_ref="[ovrl]"
  else
    local ovrl_ref="[1:v]"
  fi

  local pos_expr
  case "$position" in
    top-left)     pos_expr="10:10" ;;
    top-right)    pos_expr="W-w-10:10" ;;
    bottom-left)  pos_expr="10:H-h-10" ;;
    bottom-right) pos_expr="W-w-10:H-h-10" ;;
    center)       pos_expr="(W-w)/2:(H-h)/2" ;;
    *)            pos_expr="$position" ;;  # custom x:y
  esac

  ffmpeg -y -i "$input" -i "$overlay_file" \
    -filter_complex "${scale_filter}[0:v]${ovrl_ref}overlay=${pos_expr}[out]" \
    -map "[out]" -map "0:a?" -c:a copy "$output"
  echo "Overlay applied: $output"
}

cmd_crossfade() {
  local input="" output="" duration=1 transition="fade"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --duration) duration="$2"; shift 2 ;;
      --transition) transition="$2"; shift 2 ;;
      *) die "crossfade: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "-o" "$output"

  IFS=',' read -ra files <<< "$input"
  [[ ${#files[@]} -ge 2 ]] || die "crossfade: need at least 2 files"

  if [[ ${#files[@]} -eq 2 ]]; then
    local dur0
    dur0=$(get_duration "${files[0]}")
    local offset
    offset=$(echo "$dur0 - $duration" | bc)
    ffmpeg -y -i "${files[0]}" -i "${files[1]}" \
      -filter_complex "[0:v][1:v]xfade=transition=${transition}:duration=${duration}:offset=${offset}[outv];[0:a][1:a]acrossfade=d=${duration}[outa]" \
      -map "[outv]" -map "[outa]" "$output"
  else
    # Chain crossfades for 3+ clips
    local cmd_inputs=()
    local vfilter="" afilter=""
    local running_offset=0

    for i in "${!files[@]}"; do
      cmd_inputs+=(-i "${files[$i]}")
    done

    # Build chained xfade filters
    local prev_v="[0:v]" prev_a="[0:a]"
    local dur0
    dur0=$(get_duration "${files[0]}")
    running_offset=$(echo "$dur0 - $duration" | bc)

    for ((i=1; i<${#files[@]}; i++)); do
      local out_v="[v${i}]" out_a="[a${i}]"
      if [[ $i -eq $((${#files[@]}-1)) ]]; then
        out_v="[outv]"
        out_a="[outa]"
      fi
      vfilter+="${prev_v}[$i:v]xfade=transition=${transition}:duration=${duration}:offset=${running_offset}${out_v};"
      afilter+="${prev_a}[$i:a]acrossfade=d=${duration}${out_a};"
      prev_v="$out_v"
      prev_a="$out_a"
      if [[ $i -lt $((${#files[@]}-1)) ]]; then
        local dur_i
        dur_i=$(get_duration "${files[$i]}")
        running_offset=$(echo "$running_offset + $dur_i - $duration" | bc)
      fi
    done

    # Remove trailing semicolons
    vfilter="${vfilter%;}"
    afilter="${afilter%;}"

    ffmpeg -y "${cmd_inputs[@]}" \
      -filter_complex "${vfilter};${afilter}" \
      -map "[outv]" -map "[outa]" "$output"
  fi
  echo "Crossfade applied: $output"
}

cmd_speed() {
  local input="" output="" factor=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --factor) factor="$2"; shift 2 ;;
      *) die "speed: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "-o" "$output"
  require_arg "--factor" "$factor"

  local pts_factor
  pts_factor=$(echo "1.0 / $factor" | bc -l)

  # atempo only accepts 0.5-2.0, chain for extreme values
  local atempo_chain=""
  local remaining="$factor"
  while (( $(echo "$remaining > 2.0" | bc -l) )); do
    atempo_chain+="atempo=2.0,"
    remaining=$(echo "$remaining / 2.0" | bc -l)
  done
  while (( $(echo "$remaining < 0.5" | bc -l) )); do
    atempo_chain+="atempo=0.5,"
    remaining=$(echo "$remaining / 0.5" | bc -l)
  done
  atempo_chain+="atempo=${remaining}"

  if has_audio "$input"; then
    ffmpeg -y -i "$input" \
      -filter_complex "[0:v]setpts=${pts_factor}*PTS[v];[0:a]${atempo_chain}[a]" \
      -map "[v]" -map "[a]" "$output"
  else
    ffmpeg -y -i "$input" \
      -filter:v "setpts=${pts_factor}*PTS" "$output"
  fi
  echo "Speed ${factor}x applied: $output"
}

cmd_crop() {
  local input="" output="" ratio="" gravity="center"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --ratio) ratio="$2"; shift 2 ;;
      --gravity) gravity="$2"; shift 2 ;;
      *) die "crop: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "-o" "$output"
  require_arg "--ratio" "$ratio"

  IFS=':' read -r rw rh <<< "$ratio"

  local y_expr
  case "$gravity" in
    top)    y_expr="0" ;;
    bottom) y_expr="ih-oh" ;;
    center|*) y_expr="(ih-oh)/2" ;;
  esac

  # Calculate crop: fit within current dimensions
  local crop_filter="crop=if(gt(iw/ih\,${rw}/${rh})\,ih*${rw}/${rh}\,iw):if(gt(iw/ih\,${rw}/${rh})\,ih\,iw*${rh}/${rw}):(iw-ow)/2:${y_expr}"
  ffmpeg -y -i "$input" -filter:v "$crop_filter" -c:a copy "$output"
  echo "Cropped to ${ratio}: $output"
}

cmd_scale() {
  local input="" output="" width="" height="-2"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --width) width="$2"; shift 2 ;;
      --height) height="$2"; shift 2 ;;
      *) die "scale: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "-o" "$output"
  require_arg "--width" "$width"

  ffmpeg -y -i "$input" -vf "scale=${width}:${height}" -c:a copy "$output"
  echo "Scaled to ${width}x${height}: $output"
}

cmd_fade() {
  local input="" output="" fade_in=0 fade_out=0 video_only=false audio_only=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --fade-in) fade_in="$2"; shift 2 ;;
      --fade-out) fade_out="$2"; shift 2 ;;
      --video-only) video_only=true; shift ;;
      --audio-only) audio_only=true; shift ;;
      *) die "fade: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "-o" "$output"

  local duration
  duration=$(get_duration "$input")

  local vfilters=() afilters=()

  if ! $audio_only; then
    [[ "$fade_in" != "0" ]] && vfilters+=("fade=t=in:st=0:d=${fade_in}")
    if [[ "$fade_out" != "0" ]]; then
      local fo_start
      fo_start=$(echo "$duration - $fade_out" | bc)
      vfilters+=("fade=t=out:st=${fo_start}:d=${fade_out}")
    fi
  fi

  if ! $video_only && has_audio "$input"; then
    [[ "$fade_in" != "0" ]] && afilters+=("afade=t=in:st=0:d=${fade_in}")
    if [[ "$fade_out" != "0" ]]; then
      local afo_start
      afo_start=$(echo "$duration - $fade_out" | bc)
      afilters+=("afade=t=out:st=${afo_start}:d=${fade_out}")
    fi
  fi

  local vf_arg="" af_arg=""
  [[ ${#vfilters[@]} -gt 0 ]] && vf_arg="-vf $(IFS=,; echo "${vfilters[*]}")"
  [[ ${#afilters[@]} -gt 0 ]] && af_arg="-af $(IFS=,; echo "${afilters[*]}")"

  # shellcheck disable=SC2086
  ffmpeg -y -i "$input" $vf_arg $af_arg "$output"
  echo "Fade applied: $output"
}

cmd_text() {
  local input="" output="" text="" position="bottom-center" fontsize=48 fontcolor="white"
  local from="" to="" font="" bg_color=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --text) text="$2"; shift 2 ;;
      --position) position="$2"; shift 2 ;;
      --fontsize) fontsize="$2"; shift 2 ;;
      --fontcolor) fontcolor="$2"; shift 2 ;;
      --from) from="$2"; shift 2 ;;
      --to) to="$2"; shift 2 ;;
      --font) font="$2"; shift 2 ;;
      --bg-color) bg_color="$2"; shift 2 ;;
      *) die "text: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "-o" "$output"
  require_arg "--text" "$text"

  local x_expr y_expr
  case "$position" in
    top-left)      x_expr="20"; y_expr="20" ;;
    top-center)    x_expr="(w-tw)/2"; y_expr="20" ;;
    top-right)     x_expr="w-tw-20"; y_expr="20" ;;
    center)        x_expr="(w-tw)/2"; y_expr="(h-th)/2" ;;
    bottom-left)   x_expr="20"; y_expr="h-th-40" ;;
    bottom-center) x_expr="(w-tw)/2"; y_expr="h-th-40" ;;
    bottom-right)  x_expr="w-tw-20"; y_expr="h-th-40" ;;
    *)             x_expr="(w-tw)/2"; y_expr="h-th-40" ;;
  esac

  local safe_text="${text//\'/\\\'}"
  local dt_filter="drawtext=text='${safe_text}':fontsize=${fontsize}:fontcolor=${fontcolor}:x=${x_expr}:y=${y_expr}"
  [[ -n "$font" ]] && dt_filter+=":fontfile=${font}"
  [[ -n "$bg_color" ]] && dt_filter+=":box=1:boxcolor=${bg_color}:boxborderw=8"
  if [[ -n "$from" ]]; then
    local end_time="${to:-$(get_duration "$input")}"
    dt_filter+=":enable='between(t,${from},${end_time})'"
  fi

  ffmpeg -y -i "$input" -vf "$dt_filter" -c:a copy "$output"
  echo "Text overlay applied: $output"
}

cmd_rotate() {
  local input="" output="" angle=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --angle) angle="$2"; shift 2 ;;
      *) die "rotate: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "-o" "$output"
  require_arg "--angle" "$angle"

  local transpose_val
  case "$angle" in
    90)  transpose_val="1" ;;
    180) transpose_val="1,transpose=1" ;;
    270) transpose_val="2" ;;
    *)   die "rotate: angle must be 90, 180, or 270" ;;
  esac

  ffmpeg -y -i "$input" -vf "transpose=${transpose_val}" -c:a copy "$output"
  echo "Rotated ${angle}°: $output"
}

cmd_loop() {
  local input="" output="" duration=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --duration) duration="$2"; shift 2 ;;
      *) die "loop: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "-o" "$output"
  require_arg "--duration" "$duration"

  local src_dur
  src_dur=$(get_duration "$input")
  local loops
  loops=$(echo "($duration / $src_dur) + 1" | bc)

  ffmpeg -y -stream_loop "$loops" -i "$input" -t "$duration" -c copy "$output"
  echo "Looped to ${duration}s: $output"
}

cmd_frames() {
  local input="" output="" fps=1
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --fps) fps="$2"; shift 2 ;;
      *) die "frames: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "-o" "$output"

  # Create output directory if pattern includes path
  local outdir
  outdir=$(dirname "$output")
  mkdir -p "$outdir"

  ffmpeg -y -i "$input" -vf "fps=${fps}" "$output"
  echo "Frames extracted to: $output"
}

cmd_gif() {
  local input="" output="" fps=15 width=480 from="" to="" optimize=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --fps) fps="$2"; shift 2 ;;
      --width) width="$2"; shift 2 ;;
      --from) from="$2"; shift 2 ;;
      --to) to="$2"; shift 2 ;;
      --optimize) optimize=true; shift ;;
      *) die "gif: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "-o" "$output"

  local time_args=()
  [[ -n "$from" ]] && time_args+=(-ss "$from")
  [[ -n "$to" ]] && time_args+=(-to "$to")

  if $optimize; then
    # Two-pass for better quality
    local palette
    palette=$(mktemp /tmp/palette_XXXXXX.png)
    ffmpeg -y "${time_args[@]}" -i "$input" \
      -vf "fps=${fps},scale=${width}:-1:flags=lanczos,palettegen=stats_mode=diff" "$palette"
    ffmpeg -y "${time_args[@]}" -i "$input" -i "$palette" \
      -lavfi "fps=${fps},scale=${width}:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" "$output"
    rm -f "$palette"
  else
    ffmpeg -y "${time_args[@]}" -i "$input" \
      -vf "fps=${fps},scale=${width}:-1:flags=lanczos" "$output"
  fi
  echo "GIF created: $output"
}

cmd_add_audio() {
  local input="" audio="" output="" volume="0.3"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      --audio) audio="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --volume) volume="$2"; shift 2 ;;
      *) die "add-audio: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "--audio" "$audio"
  require_arg "-o" "$output"

  local vid_dur
  vid_dur=$(get_duration "$input")

  if has_audio "$input"; then
    ffmpeg -y -i "$input" -i "$audio" \
      -filter_complex "[1:a]volume=${volume}[a1];[0:a][a1]amix=inputs=2:duration=first[aout]" \
      -map "0:v" -map "[aout]" -t "$vid_dur" -c:v copy "$output"
  else
    ffmpeg -y -i "$input" -i "$audio" \
      -filter_complex "[1:a]volume=${volume}[aout]" \
      -map "0:v" -map "[aout]" -t "$vid_dur" -c:v copy -shortest "$output"
  fi
  echo "Audio added: $output"
}

cmd_replace_audio() {
  local input="" audio="" output=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      --audio) audio="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      *) die "replace-audio: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "--audio" "$audio"
  require_arg "-o" "$output"

  local vid_dur
  vid_dur=$(get_duration "$input")

  ffmpeg -y -i "$input" -i "$audio" \
    -map 0:v -map 1:a -t "$vid_dur" -c:v copy "$output"
  echo "Audio replaced: $output"
}

cmd_ducking() {
  local input="" music="" output="" threshold=0.02 ratio=8 attack=200 release=1000
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      --music) music="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --threshold) threshold="$2"; shift 2 ;;
      --ratio) ratio="$2"; shift 2 ;;
      --attack) attack="$2"; shift 2 ;;
      --release) release="$2"; shift 2 ;;
      *) die "ducking: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "--music" "$music"
  require_arg "-o" "$output"

  ffmpeg -y -i "$input" -i "$music" \
    -filter_complex "[0:a]asplit=2[voice][sc];[1:a][sc]sidechaincompress=threshold=${threshold}:ratio=${ratio}:attack=${attack}:release=${release}[ducked];[voice][ducked]amix=inputs=2:duration=longest[out]" \
    -map "[out]" "$output"
  echo "Audio ducking applied: $output"
}

cmd_normalize() {
  local input="" output="" target_lufs="-16"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --target-lufs) target_lufs="$2"; shift 2 ;;
      *) die "normalize: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "-o" "$output"

  # Two-pass loudnorm for accurate normalization
  local stats
  stats=$(ffmpeg -i "$input" -af "loudnorm=I=${target_lufs}:TP=-1.5:LRA=11:print_format=json" -f null /dev/null 2>&1 | grep -A 20 '"input_')

  local measured_i measured_tp measured_lra measured_thresh
  measured_i=$(echo "$stats" | grep "input_i" | grep -o '[-0-9.]*')
  measured_tp=$(echo "$stats" | grep "input_tp" | grep -o '[-0-9.]*')
  measured_lra=$(echo "$stats" | grep "input_lra" | grep -o '[-0-9.]*')
  measured_thresh=$(echo "$stats" | grep "input_thresh" | grep -o '[-0-9.]*')

  ffmpeg -y -i "$input" \
    -af "loudnorm=I=${target_lufs}:TP=-1.5:LRA=11:measured_I=${measured_i}:measured_TP=${measured_tp}:measured_LRA=${measured_lra}:measured_thresh=${measured_thresh}:linear=true" \
    "$output"
  echo "Normalized to ${target_lufs} LUFS: $output"
}

cmd_mix() {
  local input="" output="" volumes="" duration="longest"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --volumes) volumes="$2"; shift 2 ;;
      --duration) duration="$2"; shift 2 ;;
      *) die "mix: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "-o" "$output"

  IFS=',' read -ra files <<< "$input"
  IFS=',' read -ra vols <<< "${volumes:-}"

  local inputs=() filter=""
  for i in "${!files[@]}"; do
    inputs+=(-i "${files[$i]}")
    local vol="${vols[$i]:-1.0}"
    filter+="[${i}:a]volume=${vol}[a${i}];"
  done

  for i in "${!files[@]}"; do
    filter+="[a${i}]"
  done
  filter+="amix=inputs=${#files[@]}:duration=${duration}[out]"

  ffmpeg -y "${inputs[@]}" -filter_complex "$filter" -map "[out]" "$output"
  echo "Mixed ${#files[@]} tracks: $output"
}

cmd_fade_audio() {
  local input="" output="" fade_in=0 fade_out=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i) input="$2"; shift 2 ;;
      -o) output="$2"; shift 2 ;;
      --fade-in) fade_in="$2"; shift 2 ;;
      --fade-out) fade_out="$2"; shift 2 ;;
      *) die "fade-audio: unknown option $1" ;;
    esac
  done
  require_arg "-i" "$input"
  require_arg "-o" "$output"

  local duration
  duration=$(get_duration "$input")
  local filters=()

  [[ "$fade_in" != "0" ]] && filters+=("afade=t=in:st=0:d=${fade_in}")
  if [[ "$fade_out" != "0" ]]; then
    local fo_start
    fo_start=$(echo "$duration - $fade_out" | bc)
    filters+=("afade=t=out:st=${fo_start}:d=${fade_out}")
  fi

  [[ ${#filters[@]} -eq 0 ]] && die "fade-audio: specify --fade-in and/or --fade-out"

  ffmpeg -y -i "$input" -af "$(IFS=,; echo "${filters[*]}")" "$output"
  echo "Audio fade applied: $output"
}

cmd_help() {
  cat <<'EOF'
video-editor v1.0.0 — ffmpeg wrapper for common video/audio editing

Usage: edit.sh <command> [options]

Video Commands:
  trim          Extract a segment from a video
  concat        Join multiple clips into one
  overlay       Picture-in-picture, watermark, or logo overlay
  crossfade     Smooth transition between clips
  speed         Speed up or slow down video
  crop          Crop to aspect ratio (e.g., 9:16)
  scale         Resize video resolution
  fade          Video and/or audio fade in/out
  text          Text overlay using drawtext
  rotate        Rotate 90°, 180°, or 270°
  loop          Loop a clip to fill a duration
  frames        Extract frames as image sequence
  gif           Convert video to optimized GIF

Audio Commands:
  add-audio     Mix audio track onto video
  replace-audio Replace video's audio track
  ducking       Lower music when voice plays
  normalize     EBU R128 loudness normalization
  mix           Layer multiple audio tracks
  fade-audio    Audio-only fade in/out

Common Options:
  -i <file>     Input file (comma-separated for multi-file commands)
  -o <file>     Output file
  --help        Show this help

Run 'edit.sh <command> --help' for command-specific options.
EOF
}

# ─── Main Dispatch ────────────────────────────────────────────────────────────

check_ffmpeg

case "${1:-help}" in
  trim)          shift; cmd_trim "$@" ;;
  concat)        shift; cmd_concat "$@" ;;
  overlay)       shift; cmd_overlay "$@" ;;
  crossfade)     shift; cmd_crossfade "$@" ;;
  speed)         shift; cmd_speed "$@" ;;
  crop)          shift; cmd_crop "$@" ;;
  scale)         shift; cmd_scale "$@" ;;
  fade)          shift; cmd_fade "$@" ;;
  text)          shift; cmd_text "$@" ;;
  rotate)        shift; cmd_rotate "$@" ;;
  loop)          shift; cmd_loop "$@" ;;
  frames)        shift; cmd_frames "$@" ;;
  gif)           shift; cmd_gif "$@" ;;
  add-audio)     shift; cmd_add_audio "$@" ;;
  replace-audio) shift; cmd_replace_audio "$@" ;;
  ducking)       shift; cmd_ducking "$@" ;;
  normalize)     shift; cmd_normalize "$@" ;;
  mix)           shift; cmd_mix "$@" ;;
  fade-audio)    shift; cmd_fade_audio "$@" ;;
  help|--help|-h) cmd_help ;;
  version|--version|-v) echo "video-editor v${VERSION}" ;;
  *)             die "Unknown command: $1. Run 'edit.sh help' for usage." ;;
esac
