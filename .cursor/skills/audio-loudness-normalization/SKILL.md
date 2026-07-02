---
name: audio-loudness-normalization
description: Batch-normalizes audio files to consistent LUFS loudness using FFmpeg. Use when the user wants loudness normalization, volume matching, unified audio levels, batch SFX/UI/BGM processing, or mentions LUFS, true peak, loudnorm, or inconsistent game audio.
---

# Audio Loudness Normalization

Batch-process files or folders so all audio lands at a consistent perceived loudness (LUFS), with true-peak limiting to prevent clipping.

## Prerequisites

1. **FFmpeg** must be installed and on `PATH`.
   - Windows: `winget install Gyan.FFmpeg` or download from https://ffmpeg.org/download.html
   - macOS: `brew install ffmpeg`
   - Linux: `sudo apt install ffmpeg`
2. Verify: `ffmpeg -version`

## Quick Start

**Default (recommended):** target **-14 LUFS**, true peak **-1.5 dBTP**, output to `<input>/normalized/`:

```powershell
# Windows — file or folder
powershell -ExecutionPolicy Bypass -File scripts/normalize.ps1 -Input "path/to/audio_or_folder"
```

```bash
# macOS / Linux — file or folder
bash scripts/normalize.sh path/to/audio_or_folder
```

Scripts live in this skill directory: `~/.cursor/skills/audio-loudness-normalization/scripts/`.

## When to Apply This Skill

- User has many WAV/MP3/OGG/FLAC files with inconsistent levels
- Game SFX, UI clicks, explosions, or BGM need unified loudness before import
- User asks to normalize a folder, batch audio, or match loudness across assets

## Workflow

```
Task Progress:
- [ ] Confirm FFmpeg is available
- [ ] Identify input (single file or folder)
- [ ] Choose LUFS target (see category table below)
- [ ] Run normalize script with dry-run if user wants a preview
- [ ] Verify output in normalized/ folder
- [ ] Spot-check 3–5 files by ear
```

### Step 1 — Pick a LUFS target

| Category | LUFS (I) | True Peak (TP) |
|----------|----------|----------------|
| UI / clicks | -18 to -14 | -1.5 dBTP |
| Gameplay SFX (weapons, skills) | -16 to -12 | -1.5 dBTP |
| Explosions / impacts | -12 to -8 | -1.5 dBTP |
| Ambience / footsteps | -22 to -18 | -3.0 dBTP |
| BGM | -16 to -14 | -1.5 dBTP |
| Voice / dialogue | -16 to -14 | -1.5 dBTP |

**Default for mixed folders:** `-14` LUFS. **Same category only** should share one target; do not use one value for UI and explosions together.

Full rationale and engine bus defaults: [reference.md](reference.md).

### Step 2 — Organize input (recommended)

Split assets by category before batching:

```
Audio/
  UI/
  SFX/
  Explosions/
  BGM/
```

Run the script once per folder with the matching `-TargetLUFS`.

### Step 3 — Run batch normalization

**Windows (PowerShell):**

```powershell
# Single folder, custom target
powershell -ExecutionPolicy Bypass -File scripts/normalize.ps1 `
  -Input "Audio/SFX" -TargetLUFS -14 -TruePeak -1.5

# Single file
powershell -ExecutionPolicy Bypass -File scripts/normalize.ps1 -Input "click.wav"

# Recursive subfolders
powershell -ExecutionPolicy Bypass -File scripts/normalize.ps1 `
  -Input "Audio" -Recurse -TargetLUFS -18

# Custom output directory
powershell -ExecutionPolicy Bypass -File scripts/normalize.ps1 `
  -Input "Audio/UI" -OutputDir "Audio/UI_normalized"

# Preview without writing files
powershell -ExecutionPolicy Bypass -File scripts/normalize.ps1 `
  -Input "Audio/SFX" -DryRun
```

**macOS / Linux (bash):**

```bash
bash scripts/normalize.sh Audio/SFX -t -14 -tp -1.5
bash scripts/normalize.sh click.wav
bash scripts/normalize.sh Audio -r -t -18
bash scripts/normalize.sh Audio/UI -o Audio/UI_normalized
bash scripts/normalize.sh Audio/SFX --dry-run
```

### Step 4 — Validate

- Confirm each output file exists and is not 0 bytes
- Replay UI, gun, explosion, and BGM samples together — levels should feel even within each category
- If one asset still stands out, fix the **source** or re-run with a category-specific folder; avoid per-file volume hacks in game code

## Script Behavior

| Behavior | Detail |
|----------|--------|
| Input | Single audio file or directory |
| Supported formats | `.wav`, `.mp3`, `.ogg`, `.flac`, `.aac`, `.m4a`, `.wma` |
| Method | FFmpeg **two-pass** `loudnorm` (measure → apply) |
| Output | Preserves relative paths under `normalized/` (or `-OutputDir`) |
| Originals | Never modified — outputs are copies |
| Skip | Leaves existing output unchanged unless `-Overwrite` |

## Agent Instructions

1. **Prefer the bundled scripts** over ad-hoc one-liners — two-pass loudnorm is more accurate than single-pass.
2. If FFmpeg is missing, install it first; do not fall back to peak normalization unless the user explicitly accepts lower quality.
3. Ask which **category** the assets belong to if the user did not say; pick the matching LUFS from the table.
4. For **mixed-category folders**, recommend splitting folders first, then batching per category.
5. Do **not** set per-asset volume in game code to fix batch loudness — re-normalize sources instead.
6. After normalization, mention engine-side defaults (BGM bus ~-4 dB, player BGM slider ~85%) only if the user integrates into a game engine.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `ffmpeg` not found | Install FFmpeg and restart the terminal |
| Output still uneven | Folder mixes categories — split and use per-category LUFS |
| Clipping / distortion | Lower `-TruePeak` to `-3` or reduce `-TargetLUFS` by 2 |
| Looping BGM clicks | Normalize loop assets separately; check zero-crossing at loop points |
| Very short UI blips | LUFS may be unstable; accept or normalize UI as a group |

## Additional Resources

- Category targets, bus defaults, player slider defaults: [reference.md](reference.md)
