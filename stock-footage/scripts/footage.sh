#!/usr/bin/env bash
set -euo pipefail

# Stock Footage CLI — search and download free video clips from Pexels / Pixabay
# Usage: footage.sh <command> [args] [flags]

PEXELS_BASE="https://api.pexels.com/videos"
PIXABAY_BASE="https://pixabay.com/api/videos"

# --- helpers ---

die() { echo "ERROR: $*" >&2; exit 1; }

check_api_key() {
  if [[ -n "${PEXELS_API_KEY:-}" ]]; then
    API=pexels
  elif [[ -n "${PIXABAY_API_KEY:-}" ]]; then
    API=pixabay
    echo "INFO: PEXELS_API_KEY not set, falling back to Pixabay" >&2
  else
    die "No API key found. Set PEXELS_API_KEY (free at https://www.pexels.com/api/) or PIXABAY_API_KEY (https://pixabay.com/api/docs/)"
  fi
}

pexels_curl() {
  local url="$1"
  local response
  response=$(curl -sS -w "\n%{http_code}" -H "Authorization: $PEXELS_API_KEY" "$url")
  local http_code
  http_code=$(echo "$response" | tail -1)
  local body
  body=$(echo "$response" | sed '$d')

  if [[ "$http_code" == "429" ]]; then
    echo "Rate limited. Waiting 30s and retrying..." >&2
    sleep 30
    response=$(curl -sS -w "\n%{http_code}" -H "Authorization: $PEXELS_API_KEY" "$url")
    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')
  fi

  [[ "$http_code" =~ ^2 ]] || die "Pexels API returned HTTP $http_code: $body"
  echo "$body"
}

pixabay_curl() {
  local url="$1"
  local response
  response=$(curl -sS -w "\n%{http_code}" "$url")
  local http_code
  http_code=$(echo "$response" | tail -1)
  local body
  body=$(echo "$response" | sed '$d')
  [[ "$http_code" =~ ^2 ]] || die "Pixabay API returned HTTP $http_code: $body"
  echo "$body"
}

# --- search ---

cmd_search() {
  local query="" orientation="" per_page=5 page=1 json_out=false min_dur="" max_dur=""

  # first positional arg is the query
  if [[ $# -gt 0 && ! "$1" =~ ^-- ]]; then
    query="$1"; shift
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --orientation) orientation="$2"; shift 2 ;;
      --per-page)    per_page="$2"; shift 2 ;;
      --page)        page="$2"; shift 2 ;;
      --min-duration) min_dur="$2"; shift 2 ;;
      --max-duration) max_dur="$2"; shift 2 ;;
      --json)        json_out=true; shift ;;
      *) die "Unknown flag: $1" ;;
    esac
  done

  [[ -n "$query" ]] || die "Usage: footage.sh search <query> [--orientation portrait|landscape|square] [--per-page N] [--json]"

  check_api_key

  local result
  if [[ "$API" == "pexels" ]]; then
    local url="${PEXELS_BASE}/search?query=$(jq -rn --arg q "$query" '$q|@uri')&per_page=${per_page}&page=${page}"
    [[ -n "$orientation" ]] && url="${url}&orientation=${orientation}"
    [[ -n "$min_dur" ]] && url="${url}&min_duration=${min_dur}"
    [[ -n "$max_dur" ]] && url="${url}&max_duration=${max_dur}"
    result=$(pexels_curl "$url")
  else
    # Pixabay requires the API key as a URL query param (their API design — unlike Pexels which uses a header).
    # Trade-off: the key is visible in logs/process lists; mitigate by keeping it in env vars, not scripts.
    local url="${PIXABAY_BASE}/?key=${PIXABAY_API_KEY}&q=$(jq -rn --arg q "$query" '$q|@uri')&per_page=${per_page}&page=${page}"
    result=$(pixabay_curl "$url")
  fi

  if [[ "$json_out" == true ]]; then
    echo "$result" | jq .
    return
  fi

  # format table
  if [[ "$API" == "pexels" ]]; then
    local count
    count=$(echo "$result" | jq '.videos | length')
    if [[ "$count" -eq 0 ]]; then
      echo "No results found for '$query'"
      return
    fi
    printf "%-12s %-10s %-16s %s\n" "ID" "Duration" "Resolution" "Preview URL"
    printf "%-12s %-10s %-16s %s\n" "---" "---" "---" "---"
    echo "$result" | jq -r '.videos[] | {
      id: .id,
      duration: .duration,
      width: (.video_files | map(select(.quality == "hd")) | first // (.video_files | first) | .width),
      height: (.video_files | map(select(.quality == "hd")) | first // (.video_files | first) | .height),
      preview: .url
    } | "\(.id)\t\(.duration)s\t\(.width)x\(.height)\t\(.preview)"' | while IFS=$'\t' read -r id dur res preview; do
      printf "%-12s %-10s %-16s %s\n" "$id" "$dur" "$res" "$preview"
    done
    echo ""
    echo "Total results: $(echo "$result" | jq '.total_results')"
  else
    local count
    count=$(echo "$result" | jq '.hits | length')
    if [[ "$count" -eq 0 ]]; then
      echo "No results found for '$query'"
      return
    fi
    printf "%-12s %-10s %-16s %s\n" "ID" "Duration" "Resolution" "Preview URL"
    printf "%-12s %-10s %-16s %s\n" "---" "---" "---" "---"
    echo "$result" | jq -r '.hits[] | "\(.id)\t\(.duration)s\t\(.videos.medium.width)x\(.videos.medium.height)\t\(.pageURL)"' | while IFS=$'\t' read -r id dur res preview; do
      printf "%-12s %-10s %-16s %s\n" "$id" "$dur" "$res" "$preview"
    done
    echo ""
    echo "Total results: $(echo "$result" | jq '.totalHits')"
  fi
}

# --- download ---

cmd_download() {
  local video_id="" quality="hd" output_dir="."

  if [[ $# -gt 0 && ! "$1" =~ ^-- ]]; then
    video_id="$1"; shift
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --quality) quality="$2"; shift 2 ;;
      --output)  output_dir="$2"; shift 2 ;;
      *) die "Unknown flag: $1" ;;
    esac
  done

  [[ -n "$video_id" ]] || die "Usage: footage.sh download <video-id> [--quality hd|sd|uhd] [--output dir]"

  check_api_key

  mkdir -p "$output_dir"

  if [[ "$API" == "pexels" ]]; then
    local result
    result=$(pexels_curl "${PEXELS_BASE}/videos/${video_id}")

    # pick the requested quality, fall back to whatever is available
    local download_url
    download_url=$(echo "$result" | jq -r --arg q "$quality" '
      .video_files
      | (map(select(.quality == $q and (.file_type == "video/mp4"))) | first)
        // (map(select(.file_type == "video/mp4")) | sort_by(-.width) | first)
      | .link
    ')

    [[ "$download_url" != "null" && -n "$download_url" ]] || die "No downloadable video file found for ID $video_id"

    local filename="pexels-${video_id}-${quality}.mp4"
    echo "Downloading to ${output_dir}/${filename}..." >&2
    curl -sS -L -o "${output_dir}/${filename}" "$download_url"
    echo "Saved: ${output_dir}/${filename}"
  else
    # Pixabay: download medium quality video
    local result
    result=$(pixabay_curl "${PIXABAY_BASE}/?key=${PIXABAY_API_KEY}&id=${video_id}")
    local download_url
    download_url=$(echo "$result" | jq -r '.hits[0].videos.medium.url // .hits[0].videos.small.url')
    [[ "$download_url" != "null" && -n "$download_url" ]] || die "No downloadable video found for Pixabay ID $video_id"

    local filename="pixabay-${video_id}.mp4"
    echo "Downloading to ${output_dir}/${filename}..." >&2
    curl -sS -L -o "${output_dir}/${filename}" "$download_url"
    echo "Saved: ${output_dir}/${filename}"
  fi
}

# --- preview ---

cmd_preview() {
  local video_id=""

  if [[ $# -gt 0 && ! "$1" =~ ^-- ]]; then
    video_id="$1"; shift
  fi

  [[ -n "$video_id" ]] || die "Usage: footage.sh preview <video-id>"

  check_api_key

  if [[ "$API" == "pexels" ]]; then
    local result
    result=$(pexels_curl "${PEXELS_BASE}/videos/${video_id}")

    echo "$result" | jq -r '"
Video:       \(.url)
Duration:    \(.duration)s
Dimensions:  \(.width)x\(.height)
Photographer: \(.user.name)
Preview:     \(.video_pictures[0].picture // "N/A")
"'

    # open in browser on macOS
    local url
    url=$(echo "$result" | jq -r '.url')
    if command -v open &>/dev/null && [[ -n "$url" ]]; then
      open "$url" 2>/dev/null || true
    fi
  else
    local result
    result=$(pixabay_curl "${PIXABAY_BASE}/?key=${PIXABAY_API_KEY}&id=${video_id}")
    echo "$result" | jq -r '.hits[0] | "
Video:       \(.pageURL)
Duration:    \(.duration)s
Tags:        \(.tags)
User:        \(.user)
"'
    local url
    url=$(echo "$result" | jq -r '.hits[0].pageURL')
    if command -v open &>/dev/null && [[ -n "$url" ]]; then
      open "$url" 2>/dev/null || true
    fi
  fi
}

# --- grab (search + download top result) ---

cmd_grab() {
  local query="" orientation="" per_page=1 quality="hd" output_dir="." min_dur="" max_dur=""

  if [[ $# -gt 0 && ! "$1" =~ ^-- ]]; then
    query="$1"; shift
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --orientation) orientation="$2"; shift 2 ;;
      --quality)     quality="$2"; shift 2 ;;
      --output)      output_dir="$2"; shift 2 ;;
      --min-duration) min_dur="$2"; shift 2 ;;
      --max-duration) max_dur="$2"; shift 2 ;;
      --per-page)    shift 2 ;; # ignored, always 1
      *) die "Unknown flag: $1" ;;
    esac
  done

  [[ -n "$query" ]] || die "Usage: footage.sh grab <query> [--orientation portrait|landscape] [--quality hd|sd] [--output dir]"

  check_api_key

  if [[ "$API" == "pexels" ]]; then
    local url="${PEXELS_BASE}/search?query=$(jq -rn --arg q "$query" '$q|@uri')&per_page=1"
    [[ -n "$orientation" ]] && url="${url}&orientation=${orientation}"
    [[ -n "$min_dur" ]] && url="${url}&min_duration=${min_dur}"
    [[ -n "$max_dur" ]] && url="${url}&max_duration=${max_dur}"
    local result
    result=$(pexels_curl "$url")

    local video_id
    video_id=$(echo "$result" | jq -r '.videos[0].id // empty')
    [[ -n "$video_id" ]] || die "No results found for '$query'"

    echo "Top result: ID $video_id" >&2
    echo "$result" | jq -r '.videos[0] | "  Duration: \(.duration)s  |  \(.url)"' >&2

    cmd_download "$video_id" --quality "$quality" --output "$output_dir"
  else
    local url="${PIXABAY_BASE}/?key=${PIXABAY_API_KEY}&q=$(jq -rn --arg q "$query" '$q|@uri')&per_page=3"
    local result
    result=$(pixabay_curl "$url")

    local video_id
    video_id=$(echo "$result" | jq -r '.hits[0].id // empty')
    [[ -n "$video_id" ]] || die "No results found for '$query'"

    echo "Top result: ID $video_id" >&2
    cmd_download "$video_id" --quality "$quality" --output "$output_dir"
  fi
}

# --- main ---

CMD="${1:-}"
shift || true

case "$CMD" in
  search)   cmd_search "$@" ;;
  download) cmd_download "$@" ;;
  preview)  cmd_preview "$@" ;;
  grab)     cmd_grab "$@" ;;
  *)
    echo "Usage: footage.sh <command> [args]"
    echo ""
    echo "Commands:"
    echo "  search <query>      Search for stock footage"
    echo "  download <id>       Download a video by ID"
    echo "  preview <id>        Show video details and open preview"
    echo "  grab <query>        Search and download the top result"
    echo ""
    echo "Environment:"
    echo "  PEXELS_API_KEY      Pexels API key (primary, free at pexels.com/api)"
    echo "  PIXABAY_API_KEY     Pixabay API key (fallback, free at pixabay.com/api/docs)"
    exit 1
    ;;
esac
