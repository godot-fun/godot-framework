---
description: Project directory layout — resources by type, game code in game/
alwaysApply: true
---

# Project Directory Structure

Separate **framework**, **resources (by type)**, and **game code**. Do not mix them.

```
project-root/
├── zfoo/          # Framework only — sync/upgrade; no game business logic
├── image/         # Image assets
├── audio/         # Audio assets
├── font/          # Fonts (optional)
├── config/        # CSV/JSON tables (optional)
├── shader/        # Custom shaders (optional)
├── game/          # Scenes, scripts, systems, data models
├── test/          # Unit tests (UnitTest.gd scenes)
└── project.godot
```

## Resource directories (no `.gd` logic)

**`image/`** — textures and sprites:

```
image/
├── ui/            # Buttons, panels, icons
├── characters/    # Character sprites and portraits
├── backgrounds/   # Scene backgrounds
├── tiles/         # Tilemap tiles
└── effects/       # VFX and particle textures
```

**`audio/`** — use with zfoo `Audio` API:

```
audio/
├── bgm/           # Looping background music
├── sfx/           # Short one-shot sound effects
└── voice/         # Voice-over and narration
```

**Other resource roots** (add when needed): `font/`, `config/`, `shader/`.

## Game code — `game/`

```
game/
├── autoload/      # Game Autoloads (after GodotFramework)
├── core/          # Constants, ResPath, shared base classes
├── data/          # Resource classes and .tres instances
├── scenes/        # Runnable and instanced scenes
│   ├── boot/
│   ├── main/
│   ├── gameplay/
│   └── ui/
├── systems/       # Pure logic (inventory, save, quest, …)
└── network/       # Packets and codec (zfoo Router)
```
