# Editframe docs summary

Sources:
- https://editframe.com/getting-started
- https://editframe.com/docs/getting-started
- https://editframe.com/docs/composition/time-model
- https://editframe.com/docs/cli/render
- https://editframe.com/docs/api/files

## Setup

Requires Node.js and FFmpeg. Docs disagree slightly: the marketing getting-started page says Node 18+, while docs say Node 22+. Prefer 22+ when installing fresh.

Scaffold:

```bash
npm create @editframe@latest
```

Templates:
- `html`: plain HTML/CSS web components.
- `react`: TypeScript + React.

Preview:

```bash
npm start
```

Render:

```bash
npx editframe render -o output.mp4
```

## Composition essentials

Editframe compositions are browser-rendered HTML using custom elements. The same HTML/CSS a browser renders gets captured frame by frame into video.

Core custom elements:
- `<ef-preview>`: wraps composition and preview controls.
- `<ef-timegroup>`: timing primitive and canvas/timeline container.
- `<ef-scrubber>`: timeline scrubber UI.
- `<ef-time-display>`: timestamp display.
- `<ef-toggle-play>`: play/pause control.
- `<ef-video>`: temporal video element.
- `<ef-audio>`: temporal audio element.
- `<ef-image>`: temporal image element.
- `<ef-text>`: temporal text element.

Root 1080p canvas convention:

```html
<ef-timegroup mode="sequence" fps="30" class="relative w-[1920px] h-[1080px] overflow-hidden">
</ef-timegroup>
```

## Time model

All time values use CSS time strings, such as `5s`, `500ms`, `2.5s`.

`mode="sequence"`
- Children play consecutively.
- Total duration is the sum of child durations.
- Add `overlap="1s"` for transitions.
- Transition CSS variables: `--ef-transition-duration`, `--ef-transition-out-start`.

`mode="fixed"`
- Children overlap by default.
- Set `duration` on each element/group.
- Use `offset` to delay a child.

`mode="contain"`
- Group duration is calculated from the longest internal temporal element.
- Good for media clips where duration should match the asset.

`mode="fit"`
- Group duration stretches to match the parent.
- Good for background music, background video, or full-scene loops.

Looping:
- `loop` on a root timegroup loops browser preview only.
- It does not affect final render duration.

FPS:
- Root timegroup controls output FPS.
- Children can use FPS for stylistic effects, but render FPS follows root.

CSS synchronization:
- CSS animations sync to the timeline.
- `var(--ef-duration)` is provided by Editframe.

## Render CLI

Default command renders `index.html` to `output.mp4`:

```bash
npx editframe render
```

Common commands:

```bash
npx editframe render -o output.mp4
npx editframe render path/to/composition.html -o output.mp4
npx editframe render --url https://mysite.com/composition -o output.mp4
npx editframe render --data '{"title":"My Video"}' -o output.mp4
npx editframe render --data-file data.json -o output.mp4
```

Flags:
- `-o, --output <path>`: output path, default `output.mp4`.
- `--fps <number>`: frames per second, default `30`.
- `--scale <number>`: HiDPI scale factor, default `1`.
- `--url <url>`: render from URL instead of local file.
- `--from-ms <number>`: start timestamp in ms.
- `--to-ms <number>`: end timestamp in ms.
- `--data <json>`: custom render data JSON string.
- `--data-file <path>`: custom render data file.
- `--include-audio`: include audio, default true.

Render process:
1. Launches headless Chrome and loads composition HTML.
2. Steps through time at the selected FPS.
3. Captures each frame.
4. Pipes frames to FFmpeg to encode MP4.

## API files

Local CLI rendering requires no account or API key. API workflows require `EDITFRAME_API_KEY`.

Upload:

```js
const fileBytes = await fs.readFile("clip.mp4");

const res = await fetch("https://editframe.com/api/v1/files", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${process.env.EDITFRAME_API_KEY}`,
    "Content-Type": "video/mp4",
    "X-Filename": "clip.mp4",
  },
  body: fileBytes,
});

const file = await res.json();
```

Poll:

```js
async function waitForFile(id) {
  while (true) {
    const res = await fetch(`https://editframe.com/api/v1/files/${id}`, {
      headers: { Authorization: `Bearer ${process.env.EDITFRAME_API_KEY}` },
    });
    const file = await res.json();

    if (file.status === "ready") return file;
    if (file.status === "failed") throw new Error(`File processing failed: ${id}`);

    await new Promise((r) => setTimeout(r, 1000));
  }
}
```

Statuses:
- `processing`: received, being transcoded or indexed.
- `ready`: available for use.
- `failed`: processing failed.

Use signed URLs for uploaded files before placing them in `src`.
