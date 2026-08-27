---
name: atlas-cloud
description: >-
  Call Atlas Cloud's unified API for image, video, audio, and 3D generation.
  Use when: "Atlas Cloud", "generate with Atlas", "Atlas image API", "Atlas
  video API", "ATLASCLOUD_API_KEY", or when an agent needs live model
  discovery, schema-driven request construction, asynchronous prediction
  polling, or an optional media-generation provider.
---

# Atlas Cloud

Use Atlas Cloud as an optional media-generation provider. Discover the current model and its schema before constructing a request; model IDs and accepted parameters change independently.

## Authentication

Require `ATLASCLOUD_API_KEY` and fail before making a generation request when it is absent:

```bash
test -n "${ATLASCLOUD_API_KEY:-}" || { echo "ATLASCLOUD_API_KEY is required" >&2; exit 1; }
```

Create a key in the Atlas Cloud dashboard. Never place the key in a request body, command output, tracked file, or generated artifact. Send it only as a Bearer token:

```text
Authorization: Bearer $ATLASCLOUD_API_KEY
```

## Discover a Model

Treat the live catalog as the source of truth. Fetch it immediately before choosing a model:

```bash
curl -fsS https://api.atlascloud.ai/api/v1/models > /tmp/atlas-models.json
jq -r '.data[] | select(.display_console == true) | [.type, .model, .schema] | @tsv' /tmp/atlas-models.json
```

Filter by capability when needed:

```bash
jq -r '.data[] | select(.display_console == true and .type == "Image") | [.model, .schema] | @tsv' /tmp/atlas-models.json
jq -r '.data[] | select(.display_console == true and .type == "Video") | [.model, .schema] | @tsv' /tmp/atlas-models.json
```

Select one exact model ID, capture its schema URL, and verify both came from the same catalog object:

```bash
MODEL='<model-id-from-catalog>'
SCHEMA_URL=$(jq -er --arg model "$MODEL" '.data[] | select(.model == $model and .display_console == true) | .schema' /tmp/atlas-models.json)
curl -fsS "$SCHEMA_URL" > /tmp/atlas-model-schema.json
jq '.components.schemas.Input | {required, properties}' /tmp/atlas-model-schema.json
```

Do not invent parameters or copy a payload from another model. Use only fields accepted by `components.schemas.Input` and satisfy every field in `required`.

## Choose the Generation Endpoint

Read the POST path from the schema instead of guessing it:

```bash
POST_PATH=$(jq -er '.paths | to_entries[] | select(.value.post != null) | .key' /tmp/atlas-model-schema.json)
printf '%s\n' "$POST_PATH"
```

Common paths are `/api/v1/model/generateImage`, `/api/v1/model/generateVideo`, and `/api/v1/model/generateAudio`, but always use the path returned by the selected model's live schema.

## Build the Request

Create a JSON file with `jq` so prompts and optional fields are escaped correctly. This example uses only the common `model` and `prompt` fields; add model-specific options only after checking the schema:

```bash
PROMPT='<generation prompt>'
jq -n --arg model "$MODEL" --arg prompt "$PROMPT" \
  '{model: $model, prompt: $prompt}' > /tmp/atlas-request.json
```

For image-to-video, image editing, audio, or 3D tasks, follow the selected schema's exact input name. A model may require `image`, `image_url`, `audio_url`, or another field; these names are not interchangeable.

## Submit Once

Generation consumes credits. Confirm the model, payload, and expected spend with the user when their request did not already authorize a paid generation.

Make exactly one POST. Do not automatically retry a generation POST after a timeout, connection error, or ambiguous response because the first request may already have been accepted:

```bash
curl -fsS -X POST "https://api.atlascloud.ai${POST_PATH}" \
  -H "Authorization: Bearer $ATLASCLOUD_API_KEY" \
  -H 'Content-Type: application/json' \
  --data-binary @/tmp/atlas-request.json \
  > /tmp/atlas-submit.json
```

Capture the prediction ID from the response envelope:

```bash
PREDICTION_ID=$(jq -er '.data.id // .id' /tmp/atlas-submit.json)
printf '%s\n' "$PREDICTION_ID"
```

If no prediction ID is present, stop and report the HTTP/API error. Do not submit again automatically.

## Poll the Prediction

Polling is read-only and may use bounded backoff. Stop on `completed`, `failed`, or `timeout`:

```bash
for delay in 2 3 5 8 13 21 30 30 30 30; do
  curl -fsS \
    -H "Authorization: Bearer $ATLASCLOUD_API_KEY" \
    "https://api.atlascloud.ai/api/v1/model/prediction/${PREDICTION_ID}" \
    > /tmp/atlas-prediction.json

  STATUS=$(jq -er '.data.status // .status' /tmp/atlas-prediction.json)
  case "$STATUS" in
    completed) break ;;
    failed|timeout)
      jq '{status:(.data.status // .status), error:(.data.error // .error), error_code:(.data.error_code // .error_code)}' /tmp/atlas-prediction.json
      exit 1
      ;;
  esac
  sleep "$delay"
done
```

After the loop, require a completed state instead of treating local polling exhaustion as a generation failure:

```bash
STATUS=$(jq -er '.data.status // .status' /tmp/atlas-prediction.json)
test "$STATUS" = completed || { echo "Prediction is still $STATUS; resume GET polling later" >&2; exit 2; }
jq -r '(.data.outputs // .outputs)[]' /tmp/atlas-prediction.json
```

Return the generated URLs and state which model was used. Do not claim a local download succeeded unless the artifact was actually fetched and validated.

## Failure Rules

- `401`: verify that `ATLASCLOUD_API_KEY` is current and loaded in this process; never print it.
- `400` or `422`: re-fetch the model schema and compare every submitted field, type, and enum value.
- `403` or rate-limit response: stop generation writes and report the response; do not switch keys or providers silently.
- Network failure after POST: treat acceptance as unknown. Preserve the response and request context; do not repeat the POST automatically.
- Polling timeout: preserve `PREDICTION_ID` and resume only the GET request later.
- Failed prediction: report the returned error and do not fabricate an output URL.

## Data Boundary

Atlas Cloud receives the prompt and every media URL or uploaded asset included in the request. Confirm before sending private, licensed, identity-sensitive, or customer data. Use public HTTPS URLs or the upload flow documented by the selected model when remote media is required.

## References

- API documentation: https://docs.atlascloud.ai
- Live model catalog: https://api.atlascloud.ai/api/v1/models
