#!/usr/bin/env node
// video-gen.mjs — Generate social media videos using OpenAI Sora API
import { readFileSync, writeFileSync, mkdirSync } from "fs";
import { join } from "path";

// ── Config ──────────────────────────────────────────────────────────
const CONFIG_PATH = join(process.env.USERPROFILE || "", ".openclaw", "openclaw.json");
const OUTPUT_DIR = join(process.env.USERPROFILE || "", ".openclaw", "workspace", "videos");

function loadApiKey() {
  try {
    const cfg = JSON.parse(readFileSync(CONFIG_PATH, "utf8"));
    return cfg.plugins?.entries?.["voice-call"]?.config?.streaming?.openaiApiKey;
  } catch {
    return null;
  }
}

const API_KEY = process.env.OPENAI_API_KEY || loadApiKey();
if (!API_KEY) {
  console.error("No OpenAI API key found. Set OPENAI_API_KEY or configure it in openclaw.json");
  process.exit(1);
}

// ── Arg parsing ─────────────────────────────────────────────────────
const args = process.argv.slice(2);
let prompt = "";
let platform = "tiktok"; // tiktok | youtube | youtube-short
let seconds = "8";
let model = "sora-2";

for (let i = 0; i < args.length; i++) {
  if (args[i] === "--platform" && args[i + 1]) { platform = args[++i]; }
  else if (args[i] === "--seconds" && args[i + 1]) { seconds = args[++i]; }
  else if (args[i] === "--model" && args[i + 1]) { model = args[++i]; }
  else if (args[i] === "--help" || args[i] === "-h") {
    console.log(`
Usage: node video-gen.mjs "your prompt here" [options]

Options:
  --platform tiktok|youtube|youtube-short  (default: tiktok)
  --seconds  4|8|12                        (default: 8)
  --model    sora-2|sora-2-pro             (default: sora-2)

Examples:
  node video-gen.mjs "A cat surfing on a rainbow wave" --platform tiktok
  node video-gen.mjs "Aerial shot of a city at sunset" --platform youtube --seconds 12
`);
    process.exit(0);
  } else {
    prompt += (prompt ? " " : "") + args[i];
  }
}

if (!prompt) {
  console.error("Please provide a prompt. Example: node video-gen.mjs \"A dog running on the beach\"");
  process.exit(1);
}

// Map platform to resolution
const SIZES = {
  tiktok: "720x1280",
  "youtube-short": "720x1280",
  youtube: "1280x720",
};
const size = SIZES[platform] || "720x1280";

// ── API helpers ─────────────────────────────────────────────────────
const BASE = "https://api.openai.com/v1";
const headers = {
  Authorization: `Bearer ${API_KEY}`,
  "Content-Type": "application/json",
};

async function createVideo() {
  const body = { prompt, model, seconds, size };
  console.log(`\nGenerating video...`);
  console.log(`  Prompt:   "${prompt}"`);
  console.log(`  Platform: ${platform} (${size})`);
  console.log(`  Duration: ${seconds}s`);
  console.log(`  Model:    ${model}\n`);

  const res = await fetch(`${BASE}/videos`, {
    method: "POST",
    headers,
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const err = await res.text();
    console.error(`Failed to create video (HTTP ${res.status}): ${err}`);
    process.exit(1);
  }
  return res.json();
}

async function pollVideo(id) {
  const spinner = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
  let tick = 0;

  while (true) {
    const res = await fetch(`${BASE}/videos/${id}`, { headers });
    if (!res.ok) {
      console.error(`Poll failed (HTTP ${res.status})`);
      process.exit(1);
    }
    const video = await res.json();

    process.stdout.write(`\r${spinner[tick++ % spinner.length]} Status: ${video.status} | Progress: ${video.progress ?? 0}%   `);

    if (video.status === "completed") {
      console.log("\nVideo generation complete!");
      return video;
    }
    if (video.status === "failed") {
      console.error(`\nVideo generation failed: ${video.error?.message || "unknown error"}`);
      process.exit(1);
    }

    // Wait 5 seconds between polls
    await new Promise((r) => setTimeout(r, 5000));
  }
}

async function downloadVideo(id, label) {
  mkdirSync(OUTPUT_DIR, { recursive: true });

  // Download video
  const res = await fetch(`${BASE}/videos/${id}/content?variant=video`, {
    headers: { ...headers, Accept: "application/binary" },
  });
  if (!res.ok) {
    console.error(`Download failed (HTTP ${res.status})`);
    process.exit(1);
  }

  const timestamp = new Date().toISOString().replace(/[:.]/g, "-").slice(0, 19);
  const filename = `${platform}_${timestamp}.mp4`;
  const filepath = join(OUTPUT_DIR, filename);

  const buffer = Buffer.from(await res.arrayBuffer());
  writeFileSync(filepath, buffer);
  console.log(`Saved: ${filepath}`);

  // Download thumbnail
  try {
    const thumbRes = await fetch(`${BASE}/videos/${id}/content?variant=thumbnail`, {
      headers: { ...headers, Accept: "application/binary" },
    });
    if (thumbRes.ok) {
      const thumbFile = join(OUTPUT_DIR, `${platform}_${timestamp}_thumb.jpg`);
      writeFileSync(thumbFile, Buffer.from(await thumbRes.arrayBuffer()));
      console.log(`Thumbnail: ${thumbFile}`);
    }
  } catch { /* thumbnail optional */ }

  return filepath;
}

// ── Main ────────────────────────────────────────────────────────────
async function main() {
  const job = await createVideo();
  console.log(`Job ID: ${job.id}`);

  const completed = await pollVideo(job.id);
  const file = await downloadVideo(job.id, prompt);

  console.log(`\nDone! Video saved to: ${file}`);
  console.log(`Duration: ${completed.seconds}s | Size: ${completed.size}`);
}

main().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});
