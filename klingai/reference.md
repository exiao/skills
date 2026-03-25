# Kling AI — API reference

| Subcommand | Endpoints |
|------------|-----------|
| video | POST/GET /v1/videos/text2video, /v1/videos/image2video, /v1/videos/omni-video |
| image | POST/GET /v1/images/generations, /v1/images/omni-image |
| element | POST/GET /v1/general/advanced-custom-elements, /v1/general/advanced-presets-elements; POST /v1/general/delete-elements |

All APIs use Bearer token (`KLING_TOKEN` or JWT from `KLING_API_KEY`). Submit returns `task_id`; poll `{path}/{task_id}` until status succeed/failed, then use `output` or `task_result` for URLs.
