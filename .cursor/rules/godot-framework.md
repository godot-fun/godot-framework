---
description: godot framework
alwaysApply: true
---

# godot-framework

A lightweight game framework for godot engine

## Quick start

1. Copy the `zfoo/` folder into your Godot project.
2. Register the framework scene as an **Autoload** (Project → Project Settings → Autoload):

   | Name            | Path                          |
      |-----------------|-------------------------------|
   | `GodotFramework` | `res://zfoo/GodotFramework.tscn` |

3. Ensure `GodotFramework` loads **before** any scene that uses framework APIs. On startup, `gdf` initializes logging,
   audio buses, and a top-level UI layer (`gdf_layer`).

The Autoload node runs `GodotFramework.gd`, whose global class name is `gdf`.

```gdscript
# Defer a callable to the main thread (useful from network / worker callbacks)
gdf.callable_deferred(func() -> void: refresh_ui())

# Graceful exit (waits a few frames before quit)
await gdf.quit()
```

---

# Usage

## Alert — Floating toast messages

```gdscript
Alert.alert("Saved successfully", Colors.success)
Alert.alert("Network error", Colors.error)
```

---

## Audio — play music, SFX, voice

```gdscript
# Single track or playlist (auto cross-fade near end of track)
Audio.play_music("res://audio/bgm.mp3")
Audio.play_musics(["res://audio/a.mp3", "res://audio/b.mp3"])

# One-shot SFX / voice
await Audio.play_sound("res://audio/cheer.mp3")
await Audio.play_voice("res://audio/narration.mp3")

# Volume & control
Audio.set_audio_bus_volume_linear(Audio.AudioBusType.Music, 0.5)
Audio.stop_all()
var playing := Audio.is_playing_voice()
```

---

## Animation

```gdscript
# plays a one-shot sprite sheet animation and removes itself when finished. Multi-row sheet: 4 columns × 4 rows, scale 0.5, 13 fps
EffectAnimation2D.spawn(Vector2(500, 200), self, "res://effects/attack.png", Vector2i(4, 4), 0.5, 13)
```

---

## Unit tests

- Attach `zfoo/gdtest/UnitTest.gd` to a scene; `.gd` files in the same folder are scanned on startup.
- Any method whose name **starts or ends with `test`** (case-insensitive, no arguments) is run as a unit test.

---

## HotUpdate

- Godot PCK Hot Update for single pck
- Workflow: Launch App → Check Version → Download PCK → Verify MD5 → Load PCK → Enter Game

---

## Http

```gdscript
# GET request
var response := await HttpHelper.async_get("https://api.example.com/data")
if response.success:
    Log.info(response.get_body_string())
```

---

## Log

- file logger at `{user_data}/logs/godot.log`

```gdscript
Log.info("player login uid:[{}]", user_id)
Log.error("load failed path:[{}] err:[{}]", path, err)
```

---

## Network

- support `TcpClient`, `TcpClientThread`, `WebsocketClient`, `WebsocketClientThread`

```gdscript
# Create a network seesion
# `ICodec` for encode/decode
var session: Session = TcpClient.new(Codec.new(), "127.0.0.1:80")

# Register receiver (typically at login / session init)
Router.register_receiver(LoginResponse, func(packet: LoginResponse) -> void: on_login_response(packet))

# Send message is Fire-and-forget
Router.send(session, SomeRequest.new())

# Request–response (waits for matching reply or timeout)
var reply: LoginResponse = await Router.async_ask(session, LoginRequest.new())
```

---

## ResourceHelper — async loading

- Avoid blocking the main thread when loading large assets.

```gdscript
var texture: Texture2D = await ResourceHelper.async_load("res://assets/icon.svg")
var scene: PackedScene = await ResourceHelper.async_load("res://scene/Level.tscn")
```

---

## SceneHelper — scenes & nodes

```gdscript
# Switch scene with fade transition (default: RectTransitionFade)
await SceneHelper.async_change_scene_to_file("res://scene/Main.tscn")

# Custom slide transition
await SceneHelper.async_change_scene_to_file("res://scene/Main.tscn", RectTransitionSlide.new())

# Instantiate a scene as child of a node
var node := SceneHelper.add_scene_to_node(load("res://scene/Popup.tscn"), self)

# Safe queue_free
SceneHelper.queue_free(old_node)
```

---

## SchedulerBus — delayed & periodic tasks

```gdscript
var sw := StopWatch.new() # sw.cost_seconds()

# Run once after 1000 ms
SchedulerBus.schedule(func() -> void: do_something(), 1000)

# Run every 2000 ms (optional timer name, optional sub-thread)
SchedulerBus.schedule_at_fixed_rate(func() -> void: poll_status(), 2000)
```

---

## Setting — persistent user config

```gdscript
Setting.set_bool("sound_enabled", true)
Setting.set_string("nickname", "player1")
Setting.save()

var enabled := Setting.get_bool("sound_enabled", false)
var name := Setting.get_string("nickname", "")
```

---

## Utils — common helpers

- Also available: `ArrayUtils`, `CollectionUtils`, `NumberUtils`, `NetUtils`, `HttpUtils`, `IdUtils`, `RateLimitUtils`.

```gdscript
# StringUtils
var msg := StringUtils.format("score:[{}] name:[{}]", score, name)
if StringUtils.is_blank(text):
    return

# TimeUtils
var ts := TimeUtils.now()              # cached ms timestamp (updated each second)
var now_str := TimeUtils.date()        # "yyyy-mm-dd hh:mm:ss"

# JsonUtils — plain objects with public fields
var obj = JsonUtils.json_to_object('{"name":"test","age":10}', Student)
var json := JsonUtils.object_to_json(obj)

# FileUtils
FileUtils.write_string_to_file("user://log.txt", content)
var text := FileUtils.read_file_to_string("user://log.txt")
FileUtils.delete_file("user://log.txt")

# RandomUtils
var n := RandomUtils.random_int_limit(100)
var item = RandomUtils.random_ele(items)

# ThreadUtils — non-blocking wait on main thread
await ThreadUtils.async_sleep(500)
```


# Rules

- Only change godot framework `zfoo/` when you have a clear reason.