#!/usr/bin/env bash
set -euo pipefail

# Seedance 2.0 Video Generation via PiAPI
# Requires: PIAPI_API_KEY env var, jq

PIAPI_BASE="https://api.piapi.ai"
DEFAULT_MODEL="seedance-2-fast-preview"
DEFAULT_DURATION=5
DEFAULT_ASPECT="16:9"
DEFAULT_MAX_ATTEMPTS=720  # 1 hour at 5s intervals

usage() {
  cat <<EOF
Usage:
  seedance.sh generate "prompt" [options]
  seedance.sh extend <task_id> [options]
  seedance.sh status <task_id>
  seedance.sh wait <task_id> [--output file.mp4] [--max-attempts N]

Options:
  --model        seedance-2-preview | seedance-2-fast-preview (default: fast)
  --duration     5 | 10 | 15 seconds (default: 5)
  --aspect       16:9 | 9:16 | 4:3 | 3:4 (default: 16:9)
  --image        Reference image URL (repeatable, max 9)
  --video        Video URL for edit mode (1 max)
  --output       Output file path for download
  --max-attempts Max poll attempts for wait command (default: 720 = 1 hour)
EOF
  exit 1
}

die() { echo "Error: $*" >&2; exit 1; }

check_key() {
  if [[ -z "${PIAPI_API_KEY:-}" ]]; then
    echo "Error: PIAPI_API_KEY not set" >&2
    exit 1
  fi
}

# Extract video URL from API response, checking all known field locations
extract_video_url() {
  local response="$1"
  echo "$response" | jq -r '
    .data.task_result.task_output.video_url //
    .data.output.video //
    .data.output.video_url //
    .data.task_result.task_output.video //
    empty'
}

create_task() {
  local prompt="$1"; shift
  local model="$DEFAULT_MODEL"
  local duration="$DEFAULT_DURATION"
  local aspect="$DEFAULT_ASPECT"
  local images=()
  local video=""
  local parent_task_id=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --model) model="$2"; shift 2 ;;
      --duration)
        case "$2" in
          5|10|15) duration="$2" ;;
          *) echo "Error: --duration must be 5, 10, or 15" >&2; exit 1 ;;
        esac
        shift 2 ;;
      --aspect) aspect="$2"; shift 2 ;;
      --image) images+=("$2"); shift 2 ;;
      --video) video="$2"; shift 2 ;;
      --parent) parent_task_id="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  # Build input JSON
  local input
  input=$(jq -n \
    --arg prompt "$prompt" \
    --argjson duration "$duration" \
    --arg aspect "$aspect" \
    '{prompt: $prompt, duration: $duration, aspect_ratio: $aspect}')

  # Add image_urls if provided
  if [[ ${#images[@]} -gt 0 ]]; then
    local img_json
    img_json=$(printf '%s\n' "${images[@]}" | jq -R . | jq -s .)
    input=$(echo "$input" | jq --argjson imgs "$img_json" '. + {image_urls: $imgs}')
  fi

  # Add video_urls if provided (edit mode)
  if [[ -n "$video" ]]; then
    input=$(echo "$input" | jq --arg v "$video" '. + {video_urls: [$v]}')
  fi

  # Add parent_task_id if provided (extend mode)
  if [[ -n "$parent_task_id" ]]; then
    input=$(echo "$input" | jq --arg p "$parent_task_id" '. + {parent_task_id: $p}')
  fi

  # Build request body
  # NOTE: PiAPI uses "model" as the product name (always "seedance") and
  # "task_type" as the specific model variant the user chose (e.g. "seedance-2-fast-preview").
  # This is the correct PiAPI API contract — do not swap these fields.
  local body
  body=$(jq -n \
    --arg model "seedance" \
    --arg task_type "$model" \
    --argjson input "$input" \
    '{model: $model, task_type: $task_type, input: $input}')

  local response
  response=$(curl -s -X POST "${PIAPI_BASE}/api/v1/task" \
    -H "X-API-Key: ${PIAPI_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$body")

  local task_id
  task_id=$(echo "$response" | jq -r '.data.task_id // empty')

  if [[ -z "$task_id" ]]; then
    echo "Error creating task:" >&2
    echo "$response" | jq . 2>/dev/null || echo "$response" >&2
    exit 1
  fi

  echo "Task created: $task_id"
  echo "Model: $model"
  echo "Duration: ${duration}s"
  echo "Aspect: $aspect"
  [[ ${#images[@]} -gt 0 ]] && echo "Images: ${#images[@]} reference(s)"
  [[ -n "$video" ]] && echo "Mode: video edit"
  echo ""
  echo "Check status: seedance.sh status $task_id"
  echo "Wait for result: seedance.sh wait $task_id --output output.mp4"
}

get_status() {
  local task_id="$1"

  local response
  response=$(curl -s "${PIAPI_BASE}/api/v1/task/${task_id}" \
    -H "X-API-Key: ${PIAPI_API_KEY}")

  local status
  status=$(echo "$response" | jq -r '.data.status // "unknown"')

  echo "Task: $task_id"
  echo "Status: $status"

  if [[ "$status" == "success" || "$status" == "completed" ]]; then
    local video_url
    video_url=$(extract_video_url "$response")
    if [[ -n "$video_url" ]]; then
      echo "Video URL: $video_url"
    fi
    # Show credits used
    local credits
    credits=$(echo "$response" | jq -r '.data.task_result.used_credits // empty')
    [[ -n "$credits" ]] && echo "Credits used: $credits"
  elif [[ "$status" == "failed" ]]; then
    local errors
    errors=$(echo "$response" | jq -r '.data.task_result.error_messages[]? // empty')
    [[ -n "$errors" ]] && echo "Errors: $errors"
  fi

  # Return raw JSON for programmatic use
  echo ""
  echo "Raw response:"
  echo "$response" | jq .
}

wait_for_task() {
  local task_id="$1"; shift
  local output=""
  local max_attempts="$DEFAULT_MAX_ATTEMPTS"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --output) output="$2"; shift 2 ;;
      --max-attempts) max_attempts="$2"; shift 2 ;;
      *) die "wait: unknown option $1" ;;
    esac
  done

  echo "Waiting for task $task_id (max $max_attempts attempts, ~$((max_attempts * 5 / 60)) min)..."
  local attempt=0

  while [[ $attempt -lt $max_attempts ]]; do
    local response
    response=$(curl -s "${PIAPI_BASE}/api/v1/task/${task_id}" \
      -H "X-API-Key: ${PIAPI_API_KEY}")

    local status
    status=$(echo "$response" | jq -r '.data.status // "unknown"')

    case "$status" in
      success|completed)
        echo "Complete!"
        local video_url
        video_url=$(extract_video_url "$response")

        if [[ -n "$video_url" ]]; then
          echo "Video URL: $video_url"
          if [[ -n "$output" ]]; then
            echo "Downloading to $output..."
            curl -sL "$video_url" -o "$output"
            echo "Saved: $output"
          fi
        fi

        local credits
        credits=$(echo "$response" | jq -r '.data.task_result.used_credits // empty')
        [[ -n "$credits" ]] && echo "Credits used: $credits"
        return 0
        ;;
      failed)
        echo "Task failed!"
        echo "$response" | jq '.data.task_result.error_messages // empty'
        return 1
        ;;
      pending|starting|processing*)
        echo "  [$status] attempt $((attempt+1))/$max_attempts..."
        sleep 5
        ;;
      *)
        echo "  [unknown: $status] attempt $((attempt+1))/$max_attempts..."
        sleep 5
        ;;
    esac

    attempt=$((attempt + 1))
  done

  echo "Timed out after $max_attempts attempts ($((max_attempts * 5 / 60)) min)"
  return 1
}

# Main
check_key

case "${1:-}" in
  generate)
    shift
    [[ $# -lt 1 ]] && usage
    prompt="$1"; shift
    create_task "$prompt" "$@"
    ;;
  extend)
    shift
    [[ $# -lt 1 ]] && usage
    parent_id="$1"; shift
    extend_prompt="continue the video"
    # Optional second positional arg overrides the default continuation prompt
    if [[ $# -gt 0 && "${1:0:2}" != "--" ]]; then
      extend_prompt="$1"; shift
    fi
    create_task "$extend_prompt" --parent "$parent_id" "$@"
    ;;
  status)
    shift
    [[ $# -lt 1 ]] && usage
    get_status "$1"
    ;;
  wait)
    shift
    [[ $# -lt 1 ]] && usage
    task_id="$1"; shift
    wait_for_task "$task_id" "$@"
    ;;
  *)
    usage
    ;;
esac
