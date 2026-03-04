#!/usr/bin/env node
/**
 * TikTok Analytics Checker
 * 
 * Syncs PostBridge analytics and pulls per-post stats.
 * 
 * How it works:
 * 1. Triggers a PostBridge analytics sync (POST /v1/analytics/sync)
 * 2. Fetches all post-results in the date range (GET /v1/post-results)
 * 3. Skips results published less than 2 hours ago (TikTok indexing delay)
 * 4. Extracts TikTok video ID from platform_url in each post result
 * 5. Pulls per-post analytics via GET /v1/analytics/{id}
 * 
 * IMPORTANT: TikTok's API takes 1-2 hours to index new videos. Don't run this
 * on posts published less than 2 hours ago — analytics won't be available yet.
 * The daily cron runs in the morning, checking posts from the last 3 days, which
 * avoids this timing issue entirely.
 * 
 * Usage: node check-analytics.js --config <config.json> [--days 3] [--app snugly]
 * 
 * --app: Filter to a specific platform/app name
 * --days: How many days back to check (default: 3)
 */

const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);
function getArg(name) {
  const idx = args.indexOf(`--${name}`);
  return idx !== -1 ? args[idx + 1] : null;
}

const configPath = getArg('config');
const days = parseInt(getArg('days') || '3');
const appFilter = getArg('app');

if (!configPath) {
  console.error('Usage: node check-analytics.js --config <config.json> [--days 3] [--app name]');
  process.exit(1);
}

const config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
const BASE_URL = 'https://api.post-bridge.com/v1';
const AUTH = `Bearer ${config.postbridge.apiKey}`;

async function api(method, endpoint, body = null) {
  const opts = {
    method,
    headers: { 'Authorization': AUTH, 'Content-Type': 'application/json' }
  };
  if (body) opts.body = JSON.stringify(body);
  const res = await fetch(`${BASE_URL}${endpoint}`, opts);
  return res.json();
}

async function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

/**
 * Extract the TikTok video ID from a platform_url.
 * e.g. https://www.tiktok.com/@user/video/7605531854921354518 → "7605531854921354518"
 */
function extractTikTokVideoId(platformUrl) {
  if (!platformUrl) return null;
  const match = platformUrl.match(/\/video\/(\d+)/);
  return match ? match[1] : null;
}

(async () => {
  const now = new Date();
  const startDate = new Date(now - days * 86400000);
  // Don't check posts from the last 2 hours (TikTok indexing delay)
  const cutoffDate = new Date(now - 2 * 3600000);

  console.log(`📊 Checking analytics (last ${days} days, cutoff: posts before ${cutoffDate.toISOString().slice(11, 16)} UTC)\n`);

  // 1. Trigger analytics sync
  console.log('🔄 Triggering PostBridge analytics sync...');
  await api('POST', '/analytics/sync');
  await sleep(2000); // brief pause for sync to process
  console.log('  ✅ Sync requested\n');

  // 2. Get all post-results in range
  const postResultsData = await api('GET', '/post-results');
  let posts = (postResultsData.data || []).filter(p => {
    if (!p.published_at) return false;
    const publishedAt = new Date(p.published_at);
    return publishedAt >= startDate && publishedAt <= now;
  });

  // Filter by app/platform if specified
  if (appFilter) {
    posts = posts.filter(p =>
      (p.platform || '').toLowerCase().includes(appFilter.toLowerCase()) ||
      (p.account_name || '').toLowerCase().includes(appFilter.toLowerCase())
    );
  }

  // Filter to TikTok posts only
  posts = posts.filter(p => (p.platform || '').toLowerCase() === 'tiktok' || (p.platform_url || '').includes('tiktok.com'));

  // Sort by publish date (oldest first)
  posts.sort((a, b) => new Date(a.published_at) - new Date(b.published_at));

  console.log(`Found ${posts.length} TikTok post-results in range\n`);

  // 3. Separate by indexing readiness
  const ready = posts.filter(p => new Date(p.published_at) < cutoffDate);
  const tooNew = posts.filter(p => new Date(p.published_at) >= cutoffDate);

  console.log(`  Ready for analytics: ${ready.length}`);
  if (tooNew.length > 0) {
    console.log(`  Too new (< 2h, skipping): ${tooNew.length}`);
    tooNew.forEach(p => console.log(`    ⏳ "${(p.caption || '').substring(0, 50)}..." — wait for TikTok to index`));
  }
  console.log('');

  // 4. Pull analytics for ready posts
  console.log('📈 Per-Post Analytics:\n');

  const results = [];
  for (const post of ready) {
    const videoId = extractTikTokVideoId(post.platform_url);
    const analytics = await api('GET', `/analytics/${post.id}`);
    const metrics = {
      views: analytics.views || 0,
      likes: analytics.likes || 0,
      comments: analytics.comments || 0,
      shares: analytics.shares || 0
    };

    const result = {
      id: post.id,
      date: post.published_at?.slice(0, 10),
      hook: (post.caption || '').substring(0, 60),
      platform: post.platform || 'tiktok',
      views: metrics.views,
      likes: metrics.likes,
      comments: metrics.comments,
      shares: metrics.shares,
      platformUrl: post.platform_url || '',
      tiktokVideoId: videoId,
      status: post.status
    };
    results.push(result);

    const viewStr = result.views > 1000 ? `${(result.views / 1000).toFixed(1)}K` : result.views;
    console.log(`  ${result.date} | ${viewStr} views | ${result.likes} likes | ${result.comments} comments | ${result.shares} shares`);
    console.log(`    "${result.hook}..."`);
    console.log(`    TikTok video ID: ${result.tiktokVideoId || '(not yet available)'}`);
    if (result.platformUrl) console.log(`    URL: ${result.platformUrl}`);
    console.log('');

    await sleep(500);
  }

  // 5. Save results
  const baseDir = path.dirname(configPath);
  const analyticsPath = path.join(baseDir, 'analytics-snapshot.json');
  const snapshot = {
    date: now.toISOString(),
    posts: results
  };
  fs.writeFileSync(analyticsPath, JSON.stringify(snapshot, null, 2));
  console.log(`💾 Saved analytics snapshot to ${analyticsPath}`);

  // 6. Summary
  console.log('\n📊 Summary:');
  const totalViews = results.reduce((s, r) => s + r.views, 0);
  const totalLikes = results.reduce((s, r) => s + r.likes, 0);
  console.log(`  Total views: ${totalViews.toLocaleString()}`);
  console.log(`  Total likes: ${totalLikes.toLocaleString()}`);
  console.log(`  Posts tracked: ${results.length}`);

  if (results.length > 0) {
    const best = results.reduce((a, b) => a.views > b.views ? a : b);
    const worst = results.reduce((a, b) => a.views < b.views ? a : b);
    console.log(`  Best: ${best.views.toLocaleString()} views — "${best.hook}..."`);
    console.log(`  Worst: ${worst.views.toLocaleString()} views — "${worst.hook}..."`);
  }
})();
