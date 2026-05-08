# De-Platforming: Modal → Standard Host (Render, Railway, Fly.io)

Concrete checklist for removing Modal serverless wrapper from a FastAPI app and deploying to a standard PaaS.

## What to Remove from backend.py

```python
# DELETE these imports
import modal
from modal import App, Image, asgi_app

# DELETE the image builder
image = Image.debian_slim().pip_install_from_requirements("./requirements.txt") ...

# DELETE the volume
volume = modal.Volume.from_name("...", create_if_missing=True)

# DELETE the app wrapper
app = App(image=image)

# DELETE the decorated function
@app.function(
    image=image,
    volumes={"/data": volume},
    allow_concurrent_inputs=50,
    keep_warm=1,
    secrets=[modal.Secret.from_name("...")],
)
@asgi_app()
def fastapi_app():
    return web_app
```

## What to Add

```python
# Add at bottom of backend.py
if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 7000))
    uvicorn.run("backend:web_app", host="0.0.0.0", port=port)
```

## Database Path

Modal uses volumes mounted at `/data/`. Replace with env var:

```python
# Before (Modal)
if "MODAL_TASK_ID" in os.environ:
    DB_PATH = "/data/decision_records.db"
else:
    DB_PATH = os.path.join(data_dir, "decision_records.db")

# After (standard)
data_dir = os.environ.get("DATA_DIR", os.path.join(os.path.dirname(__file__), "data"))
os.makedirs(data_dir, exist_ok=True)
DB_PATH = os.path.join(data_dir, "decision_records.db")
```

On Render, use a Disk (`mountPath: /opt/render/project/data`, set `DATA_DIR` env var to match).

## Modal Secrets → Environment Variables

Modal secrets are injected via `modal.Secret.from_name(...)`. On a standard host, these become plain env vars set in the dashboard/CLI. Add `python-dotenv` for local dev:

```python
from dotenv import load_dotenv
load_dotenv()
```

## Requirements Cleanup

Remove from requirements.txt:
- `modal`
- Any Modal-specific extras

## Observability (Optional Removal)

Modal apps often include Phoenix/Arize tracing and Sentry that were set up for the Modal environment. If not needed on the target:

Remove from requirements.txt:
- `arize-phoenix`, `arize-phoenix-otel`
- `openinference-instrumentation-*`
- `sentry-sdk`
- `braintrust`

Remove from code:
- `initiate_tracing()` calls and the instrumentor import
- `with using_project("...")` context managers (unwrap the endpoint body)
- `initiate_sentry()` and its DSN

## LLM Provider Simplification

Modal apps often use multiple LLM providers with fallback chains (Groq → Cerebras, etc.). When de-platforming, consider consolidating to one provider:

- **Gemini via OpenAI-compatible client** works for chat, structured output (via instructor), and most use cases
- **Gemini search grounding** (native google-genai SDK) replaces Perplexity/Sonar for web search. NOT available via OpenAI compatibility mode; requires the `google-genai` package and native API.

```python
# Gemini via OpenAI compat (chat + structured output)
from openai import OpenAI
client = OpenAI(
    base_url="https://generativelanguage.googleapis.com/v1beta/openai/",
    api_key=os.environ.get("GEMINI_API_KEY"),
)

# Gemini search grounding (native SDK, for web search)
from google import genai
from google.genai import types

client = genai.Client(api_key=os.environ.get("GEMINI_API_KEY"))
tool = types.Tool(google_search=types.GoogleSearch())
config = types.GenerateContentConfig(tools=[tool])
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents=contents,  # list of types.Content objects
    config=config,
)
# Citations in response.candidates[0].grounding_metadata.grounding_chunks
```

Remove from requirements.txt when consolidating:
- `groq`
- `cerebras-cloud-sdk` (or `instructor[cerebras_cloud_sdk]` → just `instructor`)

## render.yaml Example

```yaml
services:
  - type: web
    name: my-api
    runtime: python
    buildCommand: pip install -r requirements.txt
    startCommand: uvicorn backend:web_app --host 0.0.0.0 --port $PORT
    envVars:
      - key: GEMINI_API_KEY
        sync: false
      - key: DATA_DIR
        value: /opt/render/project/data
    disk:
      name: app-data
      mountPath: /opt/render/project/data
      sizeGB: 1
```

## CORS

Update allowed origins to include the new deployment URL. Render preview URLs follow the pattern `https://<service-slug>-pr-<N>.onrender.com`:

```python
preview_origin_regex = r"^https://.*myapp.*\.onrender\.com$"
```
