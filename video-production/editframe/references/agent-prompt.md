# Editframe agent prompt source

Source: https://editframe.com/getting-started, embedded in `/assets/AgentPromptCTA-PmDFIsXz.js`.

Use this as the starting workflow when a user asks to build an Editframe video.

```text
Let's build a video with Editframe.
Before you get started, let the user know you're going to take care of a few setup steps for them.
- [ ] Confirm node.js is installed
- [ ] Confirm ffmpeg is installed
- [ ] Install editframe agent skills
- [ ] Create a new editframe project
First, make sure Node.js and FFmpeg are installed.
If either is missing, install them before continuing.
Installation is platform dependent, if you need to, you can ask the user to
navigate to the appropriate download page:
- Node.js: https://nodejs.org/en/download/
- FFmpeg: https://ffmpeg.org/download.html
However, if you are able to install via the command line, absolutely prefer to do that.
Ask the user what kind of project they want to create.
- Single video (Product demo, social media video, personal project, etc.)
- Video template (A template that can be reused with different assets, like a birthday card video or a wedding announcement)
- Video editing tool (A custom video editor built with editframe as the engine)
- Video workflow automation (A script that automatically generates videos based on certain triggers or inputs)
- Something else (ask them to describe it)
This may required follow-up questions to clarify exactly what they want to build and what their goals are.
Ask them if they have any existing assets they want to use:
- Video clips, images, or audio files (provide file paths or URLs)
- Website URLs to use as a content source
  - If the user provides website URLs, download and cache all relevant assets from
    those pages before building: scrape the HTML, follow and download linked
    stylesheets, images, and any video or audio files found on the page. Store
    everything locally so the composition can reference local paths rather than
    live URLs. Summarize what was downloaded for the user before proceeding.
Read the editframe composition skill before making any suggestions/decisions.
Ask them if they have any nodejs/react libraries in mind that they want to use.
Ask them if they have a preference for react or vanilla html/css/js.
Create a project:
react: npm create @editframe@latest -- react --global
html: npm create @editframe@latest -- html --global
Then, start building based on what the user asked for. If you need to ask follow up questions to clarify, do that.
When you have something running, we need the preview server to start.
If you are able to start and manage background processes as a formal capability/tool, start with:
npm start
That will emit a localhost url that is used to preview. Open that url for the user or show it to them.
If you are not able to start and manage background processes, tell the user to run npm start and to look for the url to open.
Prioritize getting all anwsers and ideas from the user before you start fetching assets or building anything. You want to make sure you have a clear understanding of what they want before you start working on it. That also minimizes the amount of time they need to wait.
```
