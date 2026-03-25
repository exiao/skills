/**
 * Kling AI HTTP client (zero external deps)
 * Uses Node.js 18+ built-in fetch
 */
import { getBearerToken, makeKlingHeaders, getConfiguredApiBase } from './auth.mjs';

const API_BASE = 'https://api-beijing.klingai.com';
const CANDIDATE_BASES = [
  API_BASE,
  'https://api-singapore.klingai.com',
];

async function probeBase(base, token) {
  try {
    const res = await fetch(`${base}/v1/videos/text2video?pageNum=1&pageSize=1`, {
      method: 'GET',
      headers: makeKlingHeaders(token, null),
      signal: AbortSignal.timeout(8000),
    });
    if (!res.ok) return false;
    const json = await res.json().catch(() => null);
    return json != null && (json.code === 0 || json.code === 200);
  } catch {
    return false;
  }
}

let _resolvedBase = null;

async function resolveApiBase(token) {
  if (_resolvedBase) return _resolvedBase;
  const configuredApiBase = getConfiguredApiBase();
  if (configuredApiBase) {
    _resolvedBase = configuredApiBase;
    return _resolvedBase;
  }

  console.error('\n🔍 Probing API endpoints... / 正在检测 API 节点...');
  for (const base of CANDIDATE_BASES) {
    process.stderr.write(`   ${base} ... `);
    if (await probeBase(base, token)) {
      process.stderr.write('✓ OK\n\n');
      _resolvedBase = base;
      return _resolvedBase;
    }
    process.stderr.write('✗\n');
  }

  console.error('\n❌ Cannot connect to any Kling API endpoint / 无法连接任何可灵 API 节点');
  for (const base of CANDIDATE_BASES) console.error(`   • ${base}`);
  console.error('\nPossible causes / 可能原因:');
  console.error('  1. Token invalid or expired / Token 无效或已过期:');
  console.error('     China / 国内: https://app.klingai.com/cn/dev/console/application');
  console.error('     Global / 国际: https://app.klingai.com/global/dev/console/application');
  console.error('  2. Network issue / 网络问题');
  console.error('\nSet KLING_TOKEN or KLING_API_KEY, then retry / 设置后重试:\n');
  process.exit(1);
}

/**
 * 解析可灵 API 响应，code 为 0 或 200 为成功
 */
function parseResponse(json) {
  if (json.code !== 0 && json.code !== 200) {
    throw new Error(`API error / API 错误 (code=${json.code}): ${json.message || 'Unknown error'}`);
  }
  return json.data;
}

/**
 * POST 请求可灵 API
 * @param {string} path  API 路径，如 /v1/videos/image2video
 * @param {object} body  请求体
 * @param {string} [token]  可选 token，不传则自动获取
 * @returns {Promise<object>} data 字段
 */
export async function klingPost(path, body, token) {
  if (!token) token = getBearerToken();
  const base = await resolveApiBase(token);
  const res = await fetch(`${base}${path}`, {
    method: 'POST',
    headers: makeKlingHeaders(token),
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const text = await res.text().catch(() => '');
    throw new Error(`HTTP ${res.status}: ${text}`);
  }
  return parseResponse(await res.json());
}

/**
 * GET 请求可灵 API
 * @param {string} path  API 路径，如 /v1/videos/image2video/{task_id}
 * @param {string} [token]  可选 token，不传则自动获取
 * @returns {Promise<object>} data 字段
 */
export async function klingGet(path, token) {
  if (!token) token = getBearerToken();
  const base = await resolveApiBase(token);
  const res = await fetch(`${base}${path}`, {
    method: 'GET',
    headers: makeKlingHeaders(token, null),
  });
  if (!res.ok) {
    const text = await res.text().catch(() => '');
    throw new Error(`HTTP ${res.status}: ${text}`);
  }
  return parseResponse(await res.json());
}

export { getBearerToken, makeKlingHeaders, setSkillVersion, getSkillVersion } from './auth.mjs';
export { API_BASE, CANDIDATE_BASES, resolveApiBase };
