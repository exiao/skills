/**
 * Kling AI CLI helpers (zero external deps)
 * Argument parsing, auth, media file reading
 */
import { readFile } from 'node:fs/promises';
import { resolve, relative, sep } from 'node:path';
import { platform } from 'node:process';
import { getBearerToken, promptAndSaveCredentials, setSkillVersion } from './auth.mjs';

/** 是否允许读取/写入 cwd 与 KLING_MEDIA_ROOTS 以外的本地路径（默认关闭） */
function allowAbsolutePaths() {
  const v = (process.env.KLING_ALLOW_ABSOLUTE_PATHS || '').trim().toLowerCase();
  return v === '1' || v === 'true' || v === 'yes';
}

/** 额外允许的根目录（逗号分隔），用于下载目录、WSL 跨盘路径等 */
function extraMediaRoots() {
  const raw = (process.env.KLING_MEDIA_ROOTS || '').trim();
  if (!raw) return [];
  return raw.split(',').map((s) => s.trim()).filter(Boolean).map((p) => resolve(p));
}

function allAllowedRoots() {
  const roots = [resolve(process.cwd()), ...extraMediaRoots()];
  return roots;
}

/** Windows：仅在同盘内做 relative 校验 */
function sameDriveRoot(a, b) {
  if (platform !== 'win32') return true;
  const ra = resolve(a);
  const rb = resolve(b);
  const da = ra.match(/^([A-Za-z]:)/);
  const db = rb.match(/^([A-Za-z]:)/);
  if (!da || !db) return true;
  return da[1].toLowerCase() === db[1].toLowerCase();
}

/**
 * 判断绝对路径是否落在任一允许根下（用于本地文件读、输出目录写）
 * @param {string} absPath 已 resolve 的绝对路径
 */
export function isAllowedLocalPath(absPath) {
  if (allowAbsolutePaths()) return true;
  const normalized = resolve(absPath);
  for (const root of allAllowedRoots()) {
    if (!sameDriveRoot(root, normalized)) continue;
    const rel = relative(root, normalized);
    if (rel === '') return true;
    if (!rel.startsWith('..') && !rel.includes(`${sep}..`)) return true;
  }
  return false;
}

/**
 * 校验并返回用于读文件的绝对路径（URL 不适用）
 * @param {string} userPath 用户传入的本地路径
 * @returns {string}
 */
export function resolveAllowedReadPath(userPath) {
  const normalized = resolve(userPath.trim());
  if (!isAllowedLocalPath(normalized)) {
    const roots = allAllowedRoots().join(', ');
    throw new Error(
      `Local path outside allowed roots / 本地路径不在允许范围内: ${normalized}\n`
      + `Allowed / 允许: cwd + KLING_MEDIA_ROOTS, or set KLING_ALLOW_ABSOLUTE_PATHS=1\n`
      + `Roots / 当前根: ${roots}\n`
      + `Example / 示例: export KLING_MEDIA_ROOTS="/mnt/c/Users/you/Downloads,/tmp/claw-downloads"`,
    );
  }
  return normalized;
}

/**
 * 校验输出目录（相对路径相对于 cwd 解析）
 * @param {string} userPath 如 ./output 或绝对路径
 * @returns {string} 绝对路径
 */
export function resolveAllowedOutputDir(userPath) {
  const normalized = resolve(userPath.trim());
  if (!isAllowedLocalPath(normalized)) {
    const roots = allAllowedRoots().join(', ');
    throw new Error(
      `Output dir outside allowed roots / 输出目录不在允许范围内: ${normalized}\n`
      + `Allowed / 允许: under cwd, KLING_MEDIA_ROOTS, or KLING_ALLOW_ABSOLUTE_PATHS=1\n`
      + `Roots / 当前根: ${roots}`,
    );
  }
  return normalized;
}

/** 消费 --skill-version */
function consumeSkillVersionArgv(argv) {
  for (let i = 2; i < argv.length - 1; i++) {
    if (argv[i] === '--skill-version') {
      setSkillVersion(argv[i + 1]);
      argv.splice(i, 2);
      return;
    }
  }
}

/**
 * 解析命令行参数
 * @param {string[]} argv  process.argv（会原地消费 --skill-version）
 * @param {string[]} [booleanFlags]  额外的布尔标志名（不需要跟值的 --flag）
 * @returns {object} 参数键值对
 */
export function parseArgs(argv, booleanFlags = []) {
  consumeSkillVersionArgv(argv);
  const boolSet = new Set(['no-wait', 'download', 'wait', 'help', ...booleanFlags]);
  const args = {};
  for (let i = 2; i < argv.length; i++) {
    const key = argv[i];
    if (!key.startsWith('--')) continue;
    const name = key.slice(2);
    if (name === 'no-wait') { args.wait = false; continue; }
    if (boolSet.has(name)) { args[name] = true; continue; }
    const val = argv[i + 1];
    if (val !== undefined && !val.startsWith('--')) {
      args[name] = val; i++;
    } else {
      args[name] = true;
    }
  }
  return args;
}

/**
 * 获取 Bearer Token：环境变量/kling.env → 交互式输入 → 失败退出
 * @returns {Promise<string>} token
 */
export async function getTokenOrExit() {
  try {
    return getBearerToken();
  } catch {
    try {
      return await promptAndSaveCredentials();
    } catch (e) {
      console.error(`Auth error / 鉴权错误: ${e.message}`);
      console.error('Set / 设置: export KLING_TOKEN="your-token"');
      console.error('Or / 或: export KLING_API_KEY="accessKey|secretKey"');
      console.error('Get keys / 获取密钥: https://app.klingai.com/cn/dev/console/application');
      process.exit(1);
    }
  }
}

/**
 * 读取媒体文件：URL 直接返回，本地文件读为 base64（路径受 KLING_MEDIA_ROOTS / KLING_ALLOW_ABSOLUTE_PATHS 约束）
 * @param {string} pathOrUrl  文件路径或 URL
 * @returns {Promise<string>} URL 或 base64 字符串
 */
export async function readMediaAsValue(pathOrUrl) {
  if (!pathOrUrl) return undefined;
  const s = pathOrUrl.trim();
  if (s.startsWith('http://') || s.startsWith('https://')) return s;
  const abs = resolveAllowedReadPath(s);
  const buf = await readFile(abs);
  return buf.toString('base64');
}
