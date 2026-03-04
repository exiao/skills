#!/usr/bin/env node
/**
 * Post a 6-slide TikTok slideshow via PostBridge API.
 * 
 * Usage: node post-to-tiktok.js --config <config.json> --dir <slides-dir> --caption "caption text" --title "post title"
 * 
 * Uploads slide1.png through slide6.png using PostBridge two-step media upload,
 * then creates a TikTok slideshow post.
 * Posts as SELF_ONLY (draft) by default — user adds music then publishes.
 * 
 * PostBridge media upload flow:
 *   Step 1: POST /v1/media/create-upload-url { name, mime_type, size_bytes } → { media_id, upload_url }
 *   Step 2: PUT <upload_url> with raw file bytes
 */

const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);
function getArg(name) {
  const idx = args.indexOf(`--${name}`);
  return idx !== -1 ? args[idx + 1] : null;
}

const configPath = getArg('config');
const dir = getArg('dir');
const caption = getArg('caption');
const title = getArg('title') || '';

if (!configPath || !dir || !caption) {
  console.error('Usage: node post-to-tiktok.js --config <config.json> --dir <dir> --caption "text" [--title "text"]');
  process.exit(1);
}

const config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
const BASE_URL = 'https://api.post-bridge.com/v1';
const AUTH = `Bearer ${config.postbridge.apiKey}`;

async function uploadImage(filePath) {
  const filename = path.basename(filePath);
  const fileBytes = fs.readFileSync(filePath);
  const sizeBytes = fileBytes.length;

  // Step 1: Get upload URL
  const createRes = await fetch(`${BASE_URL}/media/create-upload-url`, {
    method: 'POST',
    headers: {
      'Authorization': AUTH,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      name: filename,
      mime_type: 'image/png',
      size_bytes: sizeBytes
    })
  });

  const { media_id, upload_url } = await createRes.json();
  if (!media_id || !upload_url) {
    throw new Error(`Failed to get upload URL for ${filename}`);
  }

  // Step 2: Upload file bytes to the pre-signed URL
  const uploadRes = await fetch(upload_url, {
    method: 'PUT',
    headers: { 'Content-Type': 'image/png' },
    body: fileBytes
  });

  if (!uploadRes.ok) {
    throw new Error(`Upload PUT failed for ${filename}: ${uploadRes.status} ${uploadRes.statusText}`);
  }

  return media_id;
}

(async () => {
  console.log('📤 Uploading slides...');
  const mediaIds = [];
  for (let i = 1; i <= 6; i++) {
    const filePath = path.join(dir, `slide${i}.png`);
    if (!fs.existsSync(filePath)) {
      console.error(`  ❌ Missing: ${filePath}`);
      process.exit(1);
    }
    console.log(`  Uploading slide ${i}...`);
    try {
      const mediaId = await uploadImage(filePath);
      mediaIds.push(mediaId);
      console.log(`  ✅ media_id: ${mediaId}`);
    } catch (err) {
      console.error(`  ❌ Upload error: ${err.message}`);
      process.exit(1);
    }
    // Rate limit buffer
    if (i < 6) await new Promise(r => setTimeout(r, 1500));
  }

  console.log('\n📱 Creating TikTok post...');
  const tiktokAccountId = config.postbridge.socialAccounts?.tiktok;
  if (!tiktokAccountId) {
    console.error('❌ config.postbridge.socialAccounts.tiktok is not set');
    process.exit(1);
  }

  const postBody = {
    caption,
    media: mediaIds,
    social_accounts: [tiktokAccountId]
  };

  // Schedule for immediate posting (omit scheduled_at for immediate)
  const postRes = await fetch(`${BASE_URL}/posts`, {
    method: 'POST',
    headers: {
      'Authorization': AUTH,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(postBody)
  });

  const result = await postRes.json();
  if (!postRes.ok) {
    console.error('❌ Post creation failed:', JSON.stringify(result));
    process.exit(1);
  }

  console.log('✅ Posted!', JSON.stringify(result));

  // Save metadata
  const metaPath = path.join(dir, 'meta.json');
  const meta = {
    postId: result.id || result.post_id,
    caption,
    title,
    postedAt: new Date().toISOString(),
    mediaIds,
    slideCount: mediaIds.length
  };
  fs.writeFileSync(metaPath, JSON.stringify(meta, null, 2));
  console.log(`📋 Metadata saved to ${metaPath}`);
})();
