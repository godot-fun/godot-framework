class_name Audio
extends Object

enum AudioBusType {
	Music,
	SoundEffect,
	Voice,
	Ambience,
}

const ENDING_THRESHOLD: float = 4.0

static var audio_map: Dictionary[AudioBusType, AudioStreamPlayer] = {}
static var bus_index_by_type: Dictionary[AudioBusType, int] = {}

static func init() -> void:
	for bus_name in AudioBusType.keys():
		AudioServer.add_bus()
		var bus_index := AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(bus_index, bus_name)

		var bus_value: AudioBusType = AudioBusType[bus_name]
		bus_index_by_type[bus_value] = bus_index
		var audio_stream_player := AudioStreamPlayer.new()
		audio_stream_player.name = bus_name
		audio_stream_player.bus = bus_name
		gdf.gdf_node.add_child(audio_stream_player)
		audio_map[bus_value] = audio_stream_player
	pass

####################################################################################################
# music update
static var musics: Array[String] = []
static var music_change_timestamp: int = 0

static func async_update() -> void:
	var audio: AudioStreamPlayer = audio_map[AudioBusType.Music]
	if !audio.playing:
		return
	if musics.is_empty():
		return
	var total_length: float = audio.stream.get_length()
	var position: float = audio.get_playback_position()
	if total_length <= 0.0 || position <= 0.0 || (total_length - position) > ENDING_THRESHOLD:
		return
	if TimeUtils.now() - music_change_timestamp < TimeUtils.MILLIS_PER_SECOND_10:
		return
	gdf.callable_deferred(Callable(Audio, "play_music_random").bind(3.0))
	music_change_timestamp = TimeUtils.now()
	pass
####################################################################################################

static func set_audio_bus_volume_linear(type: AudioBusType, volume_linear: float) -> void:
	var bus_idx: int = bus_index_by_type[type]
	AudioServer.set_bus_volume_linear(bus_idx, clampf(volume_linear, 0.0, 1.0))
	pass

static func stop_all() -> void:
	for audio in audio_map.values():
		audio.stop()
	pass


####################################################################################################
# music
static func play_music(path: String) -> void:
	musics = [path]
	play_music_random()
	pass

static func play_musics(paths: Array[String]) -> void:
	musics = paths
	play_music_random()
	pass

static func play_music_random(duration: float = 1.0) -> void:
	if musics.is_empty():
		return
	var audio: AudioStreamPlayer = audio_map[AudioBusType.Music]
	var path: String = RandomUtils.random_ele(musics)
	var resource = await ResourceHelper.async_load(path)
	if resource == null:
		return
	if audio.playing:
		var tween := audio.create_tween()
		tween.tween_property(audio, "volume_linear", 0, duration)
		await tween.finished
	else:
		audio.volume_linear = 0
	audio.stream = resource
	audio.play()
	audio.create_tween().tween_property(audio, "volume_linear", 1, duration)
	pass


static func play_stream(bus: AudioBusType, path: String) -> void:
	if StringUtils.is_blank(path):
		return
	var player: AudioStreamPlayer = audio_map[bus]
	var resource: Variant = await ResourceHelper.async_load(path)
	if resource == null:
		return
	player.stream = resource
	player.play()
	pass

####################################################################################################
# sound
static func play_sound(path: String) -> void:
	await play_stream(AudioBusType.SoundEffect, path)
	pass

####################################################################################################
# voice
static func play_voice(path: String) -> void:
	await play_stream(AudioBusType.Voice, path)
	pass


static func is_playing_voice() -> bool:
	var audio := audio_map[AudioBusType.Voice]
	return audio.playing