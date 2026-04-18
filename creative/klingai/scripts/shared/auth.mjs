/**
 * Kling AI — 鉴权层（无网络）
 *
 * 职责：
 *   1. 登录：环境变量、kling.env、交互输入、JWT、可选持久化
 *   2. 请求头：User-Agent、Authorization
 *
 * 网络与 API Base 探测统一在 client.mjs。
 */
import { createHmac } from 'node:crypto';
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createInterface } from 'node:readline';

const __dir = dirname(fileURLToPath(import.meta.url));

const KLING_ENV_FILENAME = 'kling.env';
const LEGACY_DOTENV = '.env';

// —— 本地配置：kling.env / .env ——
function parseEnvContent(content) {
  for (const line of content.split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const eqIdx = trimmed.indexOf('=');
    if (eqIdx <= 0) continue;
    const key = trimmed.slice(0, eqIdx).trim();
    let val = trimmed.slice(eqIdx + 1).trim();
    if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
      val = val.slice(1, -1);
    }
    if (!(key in process.env)) {
      process.env[key] = val;
    }
  }
}

function getEnvSearchPaths() {
  const seen = new Set();
  const paths = [];
  const add = (p) => {
    const abs = resolve(p);
    if (!seen.has(abs)) { seen.add(abs); paths.push(abs); }
  };
  const explicit = (process.env.KLING_ENV_FILE || '').trim();
  if (explicit) {
    add(explicit);
    return paths;
  }
  add(join(process.cwd(), KLING_ENV_FILENAME));
  add(join(process.cwd(), LEGACY_DOTENV));
  const home = process.env.HOME || process.env.USERPROFILE;
  if (home) {
    const dir = join(home, '.config', 'kling');
    add(join(dir, KLING_ENV_FILENAME));
    add(join(dir, LEGACY_DOTENV));
  }
  return paths;
}

(function loadEnvFiles() {
  for (const p of getEnvSearchPaths()) {
    try { parseEnvContent(readFileSync(p, 'utf-8')); } catch {}
  }
})();

// —— Skill 版本 / 请求头 ——
const DEFAULT_SKILL_VERSION = '1.0.0';
let skillVersion = DEFAULT_SKILL_VERSION;
export function setSkillVersion(version) {
  skillVersion = String(version || DEFAULT_SKILL_VERSION);
}
export function getSkillVersion() {
  return skillVersion;
}

export function makeKlingHeaders(token, contentType = 'application/json') {
  const h = { 'User-Agent': `Kling-Provider-Skill/${getSkillVersion()}` };
  if (token) h['Authorization'] = `Bearer ${token}`;
  if (contentType) h['Content-Type'] = contentType;
  return h;
}

function base64url(buf) {
  return Buffer.from(buf).toString('base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');
}

function makeJwt(accessKey, secretKey) {
  const header = base64url(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const now = Math.floor(Date.now() / 1000);
  const payload = base64url(JSON.stringify({
    iss: accessKey,
    exp: now + 1800,
    nbf: now - 5,
  }));
  const signature = base64url(
    createHmac('sha256', secretKey).update(`${header}.${payload}`).digest() // HMAC-SHA256 for JWT signing (RFC 7518), not password hashing. CodeQL alert #7 dismissed as false positive.
  );
  return `${header}.${payload}.${signature}`;
}

export function getBearerToken() {
  let token = (process.env.KLING_TOKEN || '').trim();
  if (token) {
    if (token.toLowerCase().startsWith('bearer ')) {
      token = token.slice(7).trim();
    }
    return token;
  }
  const apiKey = (process.env.KLING_API_KEY || '').trim();
  if (!apiKey) {
    throw new Error('Set KLING_TOKEN (recommended) or KLING_API_KEY (format: accessKey|secretKey) / 请设置 KLING_TOKEN 或 KLING_API_KEY');
  }
  const parts = apiKey.split('|');
  if (parts.length !== 2) {
    throw new Error('KLING_API_KEY format: accessKey|secretKey / KLING_API_KEY 格式错误');
  }
  return makeJwt(parts[0].trim(), parts[1].trim());
}

export function getConfiguredApiBase() {
  const base = (process.env.KLING_API_BASE || '').trim();
  return base || null;
}

function getCredentialSavePath() {
  const home = process.env.HOME || process.env.USERPROFILE;
  if (home) return join(home, '.config', 'kling', KLING_ENV_FILENAME);
  return resolve(__dir, '..', '..', '..', KLING_ENV_FILENAME);
}

function saveMergedCredential(envKey, envVal) {
  const savePath = getCredentialSavePath();
  mkdirSync(dirname(savePath), { recursive: true });
  let lines = [];
  try { lines = readFileSync(savePath, 'utf-8').split('\n'); } catch {}
  const prefix = `${envKey}=`;
  const idx = lines.findIndex((l) => l.startsWith(prefix));
  if (idx >= 0) {
    lines[idx] = `${envKey}=${envVal}`;
  } else {
    if (lines.length && lines[lines.length - 1] === '') lines.pop();
    lines.push(`${envKey}=${envVal}`);
  }
  writeFileSync(savePath, lines.join('\n').trimEnd() + '\n');
  return savePath;
}

export async function promptAndSaveCredentials() {
  if (!process.stdin.isTTY) {
    throw new Error('Set KLING_TOKEN (recommended) or KLING_API_KEY (format: accessKey|secretKey) / 请设置 KLING_TOKEN 或 KLING_API_KEY');
  }

  const rl = createInterface({ input: process.stdin, output: process.stderr });
  const ask = (q) => new Promise((r) => rl.question(q, (a) => r(a.trim())));

  try {
    console.error('\n── Kling AI Credentials / 可灵 AI 密钥配置 ─────────────');
    console.error('No credentials found / 未检测到密钥，请输入:');
    console.error('  • Bearer Token');
    console.error('  • API Key (accessKey|secretKey)');
    console.error('Get keys / 获取密钥: https://app.klingai.com/cn/dev/console/application');
    console.error('──────────────────────────────────────────────────────\n');

    const input = await ask('Enter credentials / 请输入密钥: ');
    if (!input) throw new Error('No credentials provided / 未提供密钥');

    let envKey, envVal, token;
    if (input.includes('|')) {
      const parts = input.split('|');
      if (parts.length !== 2 || !parts[0].trim() || !parts[1].trim()) {
        throw new Error('API Key format: accessKey|secretKey / API Key 格式错误');
      }
      envKey = 'KLING_API_KEY';
      envVal = input;
      token = makeJwt(parts[0].trim(), parts[1].trim());
    } else {
      token = input.toLowerCase().startsWith('bearer ') ? input.slice(7).trim() : input;
      envKey = 'KLING_TOKEN';
      envVal = token;
    }

    process.env[envKey] = envVal;

    try {
      const savePath = saveMergedCredential(envKey, envVal);
      console.error(`\n✓ Saved / 已保存: ${savePath}`);
      console.error('  Auto-loaded next time / 下次自动读取\n');
    } catch (err) {
      console.error(`\n⚠ Save failed / 保存失败 (${err.message})\n`);
    }

    return token;
  } finally {
    rl.close();
  }
}

