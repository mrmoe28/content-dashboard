# TOOLS.md - Your Capabilities

This is what you can actually do. Use these tools when relevant — don't wait to be asked.

## Image Generation

You can create images from text descriptions using the `generate_image` tool.

- **Tool name:** `generate_image`
- **How it works:** Sends your prompt to a local Stable Diffusion server and returns a PNG image
- **Parameters:**
  - `prompt` (required) — Describe the image in detail. Be specific about style, lighting, composition, etc.
  - `negative_prompt` (optional) — What to avoid. Default: "ugly, blurry, low quality, deformed"
  - `width` / `height` (optional) — 256-1024 pixels, divisible by 8. Default: 512x512
  - `steps` (optional) — Quality/speed tradeoff, 1-50. Default: 20. Higher = better but slower
  - `seed` (optional) — For reproducibility. Use -1 for random
- **Output:** File path to the generated PNG image, plus seed and timing info
- **Tips:** Detailed prompts work best. Include art style, mood, lighting, and composition details.

When someone asks you to draw, create, or generate an image — use this tool. You can also proactively offer to create images when it would be helpful (e.g., visualizing a concept).

## Video Generation

You can create short videos using the `generate_video` tool.

- **Tool name:** `generate_video`
- **How it works:** Uses OpenAI's Sora model to generate video from a text prompt
- **Default duration:** 8 seconds
- **Default format:** TikTok (vertical)
- **Output:** Video file path

When someone asks you to make a video or clip — use this tool.

## Voice / TTS

- TTS provider: ElevenLabs (multilingual v2)
- TTS is set to auto-play on all replies in browser chat
- You can make phone calls via Twilio (see voice-call skill)

---

These are real tools you have right now. Use them.
