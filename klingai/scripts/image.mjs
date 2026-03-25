#!/usr/bin/env node
/**
 * Kling AI image generation — text-to-image, image-to-image, 4K, series, subject
 * Node.js 18+, zero external deps
 */
import { submitTask, queryTask, pollTask, downloadFile } from './shared/task.mjs';
import { resolve, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs, getTokenOrExit, readMediaAsValue, resolveAllowedOutputDir } from './shared/args.mjs';

const API_GEN = '/v1/images/generations';
const API_OMNI = '/v1/images/omni-image';

function printHelp() {
  console.log(`Kling AI image generation

Usage:
  node kling.mjs image --prompt <text> [options]           # Text/image-to-image
  node kling.mjs image --prompt "..." [--resolution 4k]     # 4K / series / subject → Omni
  node kling.mjs image --task_id <id> [--download]         # Query/download

Submit (common):
  --prompt          Image description (required). Omni: <<<image_1>>> / <<<element_1>>>
  --resolution      1k / 2k / 4k (4k uses Omni)
  --aspect_ratio    Aspect ratio (default: 16:9 basic, auto for Omni)
  --n               Number of images 1-9
  --output_dir      Output dir (default: ./output)
  --no-wait         Submit only, do not wait
  --wait            Wait for completion (default)

Basic API:
  --negative_prompt Negative prompt
  --model           Model (default: kling-v3)

Omni (4K/series/subject):
  --model           kling-v3-omni / kling-image-o1
  --result_type     single / series (default: single)
  --series_amount   Series count 2-9 (when result_type=series)
  --image           Reference image path or URL, comma-separated for multiple
  --element_ids     Subject IDs, comma-separated

Query/download:
  --task_id         Task ID
  --download        Download if task succeeded

Env:
  KLING_TOKEN       Bearer Token (recommended)
  KLING_API_KEY     accessKey|secretKey (alternative)
  KLING_MEDIA_ROOTS Comma-separated extra dirs for --image / --output_dir (default: cwd only)
  KLING_ALLOW_ABSOLUTE_PATHS=1  Allow any local path (e.g. WSL downloads)`);
}

function useOmniApi(args) {
  if (args.element_ids) return true;
  if (args.result_type === 'series') return true;
  if ((args.resolution || '').toLowerCase() === '4k') return true;
  if ((args.aspect_ratio || '').toLowerCase() === 'auto') return true;
  if (args.image && args.image.includes(',')) return true;
  return false;
}

async function queryTaskAnyPath(taskId, token) {
  for (const apiPath of [API_OMNI, API_GEN]) {
    try {
      const data = await queryTask(apiPath, taskId, token);
      if (data && (data.task_status === 'succeed' || data.task_status === 'failed' || data.task_status === 'processing' || data.task_status === 'submitted')) {
        return { apiPath, data };
      }
    } catch (_) { /* try next */ }
  }
  throw new Error(`Task not found / 未找到任务: ${taskId}`);
}

function collectImageUrls(taskResult) {
  const urls = [];
  const append = (list) => {
    if (!Array.isArray(list)) return;
    for (const item of list) {
      if (item?.url) urls.push(item.url);
    }
  };
  append(taskResult?.images);
  append(taskResult?.series_images);
  if (urls.length === 0 && taskResult?.url) urls.push(taskResult.url);
  return urls;
}

async function pollAndDownloadImages(apiPath, taskId, outputDir, opts = {}) {
  const data = await pollTask(apiPath, taskId, opts);
  const urls = collectImageUrls(data?.task_result || {});
  if (urls.length === 0) {
    throw new Error('Task succeeded but missing image urls / 任务成功但未返回图片 URL');
  }
  const outPaths = [];
  for (let i = 0; i < urls.length; i++) {
    const outPath = join(outputDir, urls.length === 1 ? `${taskId}.png` : `${taskId}_${i}.png`);
    await downloadFile(urls[i], outPath);
    outPaths.push(outPath);
  }
  return outPaths;
}

export async function main() {
  const args = parseArgs(process.argv);
  if (args.help) { printHelp(); return; }

  const token = await getTokenOrExit();
  const outputDir = resolveAllowedOutputDir(args.output_dir || './output');
  const queryHint = `node kling.mjs image --task_id`;

  if (args.task_id && !args.prompt) {
    try {
      const { apiPath, data } = await queryTaskAnyPath(args.task_id, token);
      console.log(`Task ID / 任务 ID: ${args.task_id}`);
      console.log(`Status / 状态: ${data?.task_status || 'unknown'}`);
      const result = data?.task_result || {};
      const imageUrls = collectImageUrls(result);
      imageUrls.forEach((url, i) => {
        console.log(`Image / 图片[${i}]: ${url}`);
      });
      if (args.download && imageUrls.length > 0) {
        const { mkdir } = await import('node:fs/promises');
        await mkdir(outputDir, { recursive: true });
        for (let i = 0; i < imageUrls.length; i++) {
          const outPath = join(outputDir, imageUrls.length === 1 ? `${args.task_id}.png` : `${args.task_id}_${i}.png`);
          await downloadFile(imageUrls[i], outPath);
        }
      }
    } catch (e) {
      console.error(`Error / 错误: ${e.message}`);
      process.exit(1);
    }
    return;
  }

  if (!args.prompt) {
    console.error('Error / 错误: --prompt or --task_id required');
    console.error('Use --help / 使用 --help 查看帮助');
    process.exit(1);
  }

  const apiPath = useOmniApi(args) ? API_OMNI : API_GEN;

  try {
    if (apiPath === API_GEN) {
      const payload = {
        model_name: args.model || 'kling-v3',
        prompt: args.prompt,
        negative_prompt: args.negative_prompt || '',
        n: parseInt(args.n || '1', 10),
        aspect_ratio: args.aspect_ratio || '16:9',
        resolution: args.resolution || '1k',
        callback_url: '',
      };
      if (args.image) {
        payload.image = await readMediaAsValue(args.image.trim().split(',')[0].trim());
      }
      const result = await submitTask(API_GEN, payload, token);
      console.log(`\nTask ID / 任务 ID: ${result.taskId}`);
      console.log(`Query / 查询: ${queryHint} ${result.taskId} [--download]`);
      if (args.wait !== false) {
        console.log();
        const outPaths = await pollAndDownloadImages(API_GEN, result.taskId, outputDir, { token });
        console.log(`\n✓ Done / 完成: ${outPaths.length} image(s)`);
        outPaths.forEach((p) => console.log(`  - ${p}`));
      }
      return;
    }

    const payload = {
      model_name: args.model || 'kling-v3-omni',
      prompt: args.prompt,
      resolution: (args.resolution || '1k').toLowerCase(),
      aspect_ratio: (args.aspect_ratio || 'auto').toLowerCase(),
      result_type: args.result_type || 'single',
      callback_url: '',
    };
    if (payload.result_type === 'series') {
      payload.series_amount = parseInt(args.series_amount || '4', 10);
    } else {
      payload.n = parseInt(args.n || '1', 10);
    }
    if (args.image) {
      const images = args.image.split(',');
      payload.image_list = [];
      for (const img of images) {
        payload.image_list.push({ image: await readMediaAsValue(img.trim()) });
      }
    }
    if (args.element_ids) {
      payload.element_list = args.element_ids.split(',').map(id => ({ element_id: id.trim() }));
    }

    const result = await submitTask(API_OMNI, payload, token);
    console.log(`\nTask ID / 任务 ID: ${result.taskId}`);
    console.log(`Query / 查询: ${queryHint} ${result.taskId} [--download]`);
    if (args.wait !== false) {
      console.log();
      const outPaths = await pollAndDownloadImages(API_OMNI, result.taskId, outputDir, { token });
      console.log(`\n✓ Done / 完成: ${outPaths.length} image(s)`);
      outPaths.forEach((p) => console.log(`  - ${p}`));
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
