#!/usr/bin/env node
/**
 * Kling AI video generation — text-to-video, image-to-video, Omni, multi-shot
 * Node.js 18+, zero external deps
 */
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { submitTask, queryTask, pollAndDownload, downloadFile } from './shared/task.mjs';
import { parseArgs, getTokenOrExit, readMediaAsValue, resolveAllowedOutputDir } from './shared/args.mjs';

const API_T2V = '/v1/videos/text2video';
const API_I2V = '/v1/videos/image2video';
const API_OMNI = '/v1/videos/omni-video';

function printHelp() {
  console.log(`Kling AI video generation

Usage:
  node kling.mjs video --prompt <text> [options]               # Text-to-video
  node kling.mjs video --image <path|url> [--prompt ...]       # Image-to-video
  node kling.mjs video --prompt "..." [--image ...] [--element_ids ...]  # Omni
  node kling.mjs video --multi_shot --shot_type customize --multi_prompt <json>  # Multi-shot
  node kling.mjs video --task_id <id> [--download]              # Query/download

Submit (common):
  --prompt          Video description (Omni: <<<element_1>>> <<<image_1>>> <<<video_1>>>)
  --duration        Duration 3-15 s (default: 5)
  --model           kling-v3 / kling-v3-omni / kling-video-o1 (script chooses)
  --mode            pro / std (default: pro)
  --aspect_ratio    16:9 / 9:16 / 1:1 (default: 16:9)
  --sound           on / off (default: off). v3/omni support; with --video only off; o1 no sound
  --negative_prompt Negative prompt
  --output_dir      Output dir (default: ./output)
  --no-wait         Submit only, do not wait
  --wait            Wait for completion (default)

Image-to-video / Omni:
  --image           First-frame path or URL (comma-separated multiple → Omni)
  --image_tail      Last-frame image
  --element_ids     Subject IDs, comma-separated (Omni)
  --video           Reference video path or URL (Omni)
  --video_refer_type feature / base (default: feature)

Multi-shot (Omni):
  --multi_shot      Enable multi-shot
  --shot_type       Shot type: customize (required when multi_shot)
  --multi_prompt    Shots JSON, e.g. '[{"index":1,"prompt":"...","duration":"5"}]' (max 6)

Query/download:
  --task_id         Task ID
  --download        Download if task succeeded

Env:
  KLING_TOKEN       Bearer Token (recommended)
  KLING_API_KEY     accessKey|secretKey (alternative)
  KLING_MEDIA_ROOTS Comma-separated extra dirs for local media / --output_dir (default: cwd only)
  KLING_ALLOW_ABSOLUTE_PATHS=1  Allow any local path (e.g. WSL downloads outside project)`);
}

function chooseApiPath(args) {
  if (args.multi_shot || args.element_ids || args.video) return API_OMNI;
  if (args.image) {
    const images = args.image.split(',').map(s => s.trim()).filter(Boolean);
    if (images.length > 1) return API_OMNI;
    return API_I2V;
  }
  return API_T2V;
}

async function queryTaskAnyPath(taskId, token) {
  const paths = [API_OMNI, API_I2V, API_T2V];
  for (const apiPath of paths) {
    try {
      const data = await queryTask(apiPath, taskId, token);
      if (data && (data.task_status === 'succeed' || data.task_status === 'failed' || data.task_status === 'processing' || data.task_status === 'submitted')) {
        return { apiPath, data };
      }
    } catch (_) { /* try next */ }
  }
  throw new Error(`Task not found / 未找到任务: ${taskId}`);
}

export async function main() {
  const args = parseArgs(process.argv, ['multi_shot']);
  if (args.help) { printHelp(); return; }

  const token = await getTokenOrExit();
  const outputDir = resolveAllowedOutputDir(args.output_dir || './output');

  if (args.task_id && !args.prompt && !args.image && !args.multi_shot) {
    try {
      const { apiPath, data } = await queryTaskAnyPath(args.task_id, token);
      console.log(`Task ID / 任务 ID: ${args.task_id}`);
      console.log(`Status / 状态: ${data?.task_status || 'unknown'}`);
      if (data?.task_status_msg) console.log(`Message / 消息: ${data.task_status_msg}`);
      const videos = data?.task_result?.videos || [];
      if (videos.length > 0 && videos[0].url) {
        console.log(`Video URL / 视频链接: ${videos[0].url}`);
        if (args.download) {
          const { mkdir } = await import('node:fs/promises');
          const { join } = await import('node:path');
          await mkdir(outputDir, { recursive: true });
          await downloadFile(videos[0].url, join(outputDir, `${args.task_id}.mp4`));
        }
      }
    } catch (e) {
      console.error(`Error / 错误: ${e.message}`);
      process.exit(1);
    }
    return;
  }

  const hasImage = args.image && args.image.trim();
  if (!args.prompt && !hasImage && !args.multi_shot) {
    console.error('Error / 错误: --prompt, --image, or --multi_shot required');
    console.error('Use --help / 使用 --help 查看帮助');
    process.exit(1);
  }

  if (hasImage) {
    const firstInput = args.image.trim().split(',')[0].trim();
    const isUrl = firstInput.startsWith('http://') || firstInput.startsWith('https://');
    if (!isUrl && !existsSync(resolve(firstInput))) {
      console.error(`Error / 错误: image not found / 图片不存在: ${firstInput}`);
      process.exit(1);
    }
  }

  const apiPath = chooseApiPath(args);
  const queryHint = `node kling.mjs video --task_id`;

  try {
    if (apiPath === API_T2V) {
      const payload = {
        model_name: args.model || 'kling-v3',
        prompt: args.prompt,
        negative_prompt: args.negative_prompt || '',
        duration: String(args.duration || '5'),
        mode: args.mode || 'pro',
        aspect_ratio: args.aspect_ratio || '16:9',
        sound: args.sound || 'off',
        callback_url: '',
        external_task_id: '',
      };
      const result = await submitTask(API_T2V, payload, token);
      console.log(`\nTask ID / 任务 ID: ${result.taskId}`);
      console.log(`Query / 查询: ${queryHint} ${result.taskId} [--download]`);
      if (args.wait !== false) {
        console.log();
        const outPath = await pollAndDownload(API_T2V, result.taskId, outputDir, { token });
        console.log(`\n✓ Done / 完成: ${outPath}`);
      }
      return;
    }

    if (apiPath === API_I2V) {
      const payload = {
        model_name: args.model || 'kling-v3',
        image: await readMediaAsValue(args.image),
        image_tail: args.image_tail ? await readMediaAsValue(args.image_tail) : '',
        prompt: args.prompt || '',
        negative_prompt: args.negative_prompt || '',
        duration: String(args.duration || '5'),
        mode: args.mode || 'pro',
        sound: args.sound || 'off',
        callback_url: '',
        external_task_id: '',
      };
      const result = await submitTask(API_I2V, payload, token);
      console.log(`\nTask ID / 任务 ID: ${result.taskId}`);
      console.log(`Query / 查询: ${queryHint} ${result.taskId} [--download]`);
      if (args.wait !== false) {
        console.log();
        const outPath = await pollAndDownload(API_I2V, result.taskId, outputDir, { token });
        console.log(`\n✓ Done / 完成: ${outPath}`);
      }
      return;
    }

    const payload = {
      model_name: args.model || 'kling-v3-omni',
      duration: String(args.duration || '5'),
      mode: args.mode || 'pro',
      aspect_ratio: args.aspect_ratio || '16:9',
      sound: args.sound || 'off',
      callback_url: '',
    };

    if (args.multi_shot) {
      payload.multi_shot = true;
      payload.shot_type = args.shot_type || 'customize';
      if (args.multi_prompt) {
        try {
          payload.multi_prompt = JSON.parse(args.multi_prompt);
        } catch {
          console.error('Error / 错误: --multi_prompt must be valid JSON / 必须是合法 JSON');
          process.exit(1);
        }
      } else {
        console.error('Error / 错误: multi-shot requires --multi_prompt / 多镜头需要 --multi_prompt');
        process.exit(1);
      }
    } else {
      payload.multi_shot = false;
      payload.prompt = args.prompt || '';
    }

    const imageList = [];
    if (args.image) {
      const images = args.image.split(',');
      for (const img of images) {
        imageList.push({ image_url: await readMediaAsValue(img.trim()), type: 'first_frame' });
      }
    }
    if (args.image_tail) {
      imageList.push({ image_url: await readMediaAsValue(args.image_tail), type: 'end_frame' });
    }
    if (imageList.length > 0) payload.image_list = imageList;

    if (args.element_ids) {
      payload.element_list = args.element_ids.split(',').map(id => {
        const num = Number(id.trim());
        return { element_id: num };
      });
    }

    if (args.video) {
      const videoUrl = await readMediaAsValue(args.video);
      payload.video_list = [{ video_url: videoUrl, refer_type: args.video_refer_type || 'feature' }];
    }

    const result = await submitTask(API_OMNI, payload, token);
    console.log(`\nTask ID / 任务 ID: ${result.taskId}`);
    console.log(`Query / 查询: ${queryHint} ${result.taskId} [--download]`);
    if (args.wait !== false) {
      console.log();
      const outPath = await pollAndDownload(API_OMNI, result.taskId, outputDir, { token });
      console.log(`\n✓ Done / 完成: ${outPath}`);
    }
  } catch (e) {
    console.error(`Error / 错误: ${e.message}`);
    process.exit(1);
  }
}

const __filename = fileURLToPath(import.meta.url);
if (process.argv[1] && resolve(__filename) === resolve(process.argv[1])) {
  main().catch((e) => {
    console.error(`Error / 错误: ${e?.message || e}`);
    process.exit(1);
  });
}
