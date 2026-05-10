---
name: editframe
description: Build, preview, and render videos with Editframe, the HTML/CSS/React video composition tool. Use this whenever the user mentions Editframe, wants code-generated videos, asks to scaffold an Editframe project, build an HTML/CSS video composition, render MP4 locally, use ef-timegroup/ef-video/ef-audio/ef-text components, or automate video generation with Node.js and FFmpeg.
---

# Editframe

Editframe builds videos with code. Compositions are HTML pages using Editframe custom elements, CSS animations, browser-rendered media, and optional React. The CLI renders MP4 locally with headless Chrome and FFmpeg.

## Before building

1. Confirm Node.js is installed. Prefer Node 22+ for current docs, Node 18+ is the minimum from the getting-started page.
2. Confirm FFmpeg is installed and on `PATH`.
3. Ask what kind of project they want:
   - Single video: product demo, social video, explainer, personal project.
   - Reusable video template with variable data/assets.
   - Video editing tool with Editframe as the engine.
   - Video workflow automation that generates videos from triggers or inputs.
   - Something else.
4. Ask what assets they have: local paths, URLs, clips, images, audio, brand files, website pages.
5. Ask whether they prefer `html` or `react`. If no preference, choose `html` for simple single videos and `react` for data-driven/templates or complex components.

If the user provides website URLs as a source, download and cache relevant assets first: HTML, stylesheets, images, video, audio. Use local paths in the composition so renders are reproducible.

## Scaffold

Use one of these:

```bash
npm create @editframe@latest -- html --global
npm create @editframe@latest -- react --global
```

If those flags fail because the CLI changed, fall back to the interactive scaffold:

```bash
npm create @editframe@latest
```

Then choose `html` or `react`.

## Preview

Start the dev server as a tracked background process when available:

```bash
npm start
```

It prints a localhost URL, commonly `http://localhost:4321`. Use the preview to verify timing, layout, and media. Hot reload should work while editing.

## Core composition model

Use `<ef-timegroup>` as the timing primitive. Every composition needs a root timegroup that defines the canvas and timeline.

Common modes:

- `mode="sequence"`: children play one after another. Use for scenes.
- `mode="fixed"`: children overlap. Use `duration` and optional `offset`.
- `mode="contain"`: duration becomes the longest internal temporal child. Useful for video/audio clips.
- `mode="fit"`: duration stretches to match the parent. Useful for full-length backgrounds or music.

Use CSS time strings: `500ms`, `2s`, `2.5s`.

Root canvas defaults for 1080p:

```html
<ef-timegroup mode="sequence" fps="30" class="relative w-[1920px] h-[1080px] overflow-hidden bg-black">
  <!-- scenes -->
</ef-timegroup>
```

Preview controls can be wrapped with:

```html
<ef-preview>
  <ef-timegroup id="composition" mode="sequence" class="relative w-[1920px] h-[1080px]"></ef-timegroup>
  <ef-scrubber></ef-scrubber>
  <ef-time-display></ef-time-display>
  <ef-toggle-play></ef-toggle-play>
</ef-preview>
```

## Media and timing patterns

Add video:

```html
<ef-timegroup mode="contain">
  <ef-video src="assets/clip.mp4"></ef-video>
</ef-timegroup>
```

Trim clips:

```html
<ef-timegroup mode="sequence">
  <ef-video src="assets/clip1.mp4" sourceout="4s"></ef-video>
  <ef-video src="assets/clip2.mp4" sourcein="8s" sourceout="12s"></ef-video>
</ef-timegroup>
```

Overlay content by wrapping media and HTML in a fixed/contain timegroup:

```html
<ef-timegroup mode="contain" class="relative">
  <ef-video src="assets/demo.mp4" class="absolute inset-0 w-full h-full object-cover"></ef-video>
  <ef-timegroup mode="fixed" duration="3s" offset="1s" class="absolute bottom-16 left-16">
    <ef-text class="text-white text-6xl font-bold">New feature</ef-text>
  </ef-timegroup>
</ef-timegroup>
```

Sequence transitions use `overlap` and Editframe CSS variables:

```html
<ef-timegroup mode="sequence" id="scenes" overlap="1s">
  <ef-timegroup mode="fixed" duration="3s" class="scene bg-indigo-900"></ef-timegroup>
  <ef-timegroup mode="fixed" duration="3s" class="scene bg-rose-900"></ef-timegroup>
</ef-timegroup>

<style>
  #scenes > ef-timegroup {
    animation:
      fade-in var(--ef-transition-duration) ease-out both,
      fade-out var(--ef-transition-duration) ease-in var(--ef-transition-out-start) both;
  }
</style>
```

CSS animations are synchronized to the composition timeline. Use `var(--ef-duration)` when an animation should match an element's duration.

## Render

Render local composition:

```bash
npx editframe render -o output.mp4
```

Useful flags:

```bash
npx editframe render path/to/composition.html -o output.mp4
npx editframe render --url http://localhost:4321 -o output.mp4
npx editframe render -o output.mp4 --fps 60
npx editframe render -o output.mp4 --scale 2
npx editframe render -o output.mp4 --to-ms 5000
npx editframe render -o output.mp4 --from-ms 2000 --to-ms 7000
npx editframe render -o output.mp4 --data '{"title":"My Video"}'
npx editframe render -o output.mp4 --data-file data.json
```

Always verify the final MP4 exists and has a plausible duration/size. If possible, inspect the video or extract frames with FFmpeg before calling it done.

## API notes

Local rendering needs no account or API key. Cloud/API workflows use `EDITFRAME_API_KEY`. Never hardcode it.

File upload flow:

1. `POST https://editframe.com/api/v1/files` with `Authorization: Bearer $EDITFRAME_API_KEY`, content type, `X-Filename`, and raw bytes.
2. Poll `GET /api/v1/files/{id}` until `status` is `ready` or `failed`.
3. Sign the URL via the URL signing endpoint before using uploaded media as `src`.

Use the API only when the user asks for cloud rendering, hosted files, webhooks, or signed URLs. For normal local video creation, use the CLI.

## Common pitfalls

- FFmpeg missing from `PATH` causes render failures.
- Remote assets make renders flaky. Prefer local cached files.
- A root timegroup should define canvas size and FPS.
- `loop` helps preview playback but does not change the final render duration.
- Children in `fixed` mode overlap. Use `offset` if they should start later.
- Final FPS comes from the root timegroup.
- For complex reusable templates, pass data with `--data-file` instead of hardcoding copy/assets.

## References

Read `references/agent-prompt.md` when starting a new Editframe project with a user.
Read `references/docs-summary.md` for compact docs on composition, CLI render flags, and API files.

## Skill source

Use these sources to refresh or update this skill later:

- Main getting-started page: https://editframe.com/getting-started
- Docs getting started: https://editframe.com/docs/getting-started
- Time model docs: https://editframe.com/docs/composition/time-model
- Render CLI docs: https://editframe.com/docs/cli/render
- Files API docs: https://editframe.com/docs/api/files
- Embedded agent prompt source: https://editframe.com/assets/AgentPromptCTA-PmDFIsXz.js

Update procedure:

1. Re-fetch the URLs above.
2. Check the embedded JS for the exported agent prompt string.
3. Update `references/agent-prompt.md` with the verbatim prompt if it changed.
4. Update `references/docs-summary.md` and this SKILL.md with any changed commands, flags, components, or pitfalls.
5. Run `skill_view(name="editframe")` to verify the skill loads and linked files are discoverable.
