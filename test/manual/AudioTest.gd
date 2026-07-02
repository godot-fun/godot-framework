extends Node

@onready var playMusicButton: Button = $PlayMusic
@onready var playSoundButton: Button = $PlaySound

func _ready() -> void:
	playMusicButton.pressed.connect(pressedPlayMusicButton)
	playSoundButton.pressed.connect(pressedPlaySoundButton)
	
	Linear_test()
	pass


func Linear_test() -> void:
	var a: float = linear_to_db(1)
	assert(a == 0)
	var b: float = db_to_linear(0)
	assert(b == 1)
	pass

func pressedPlayMusicButton():
	Audio.play_musics(["test/asset/All_the_Way_North.mp3", "test/asset/White_Windmill.mp3"])
	pass

func pressedPlaySoundButton():
	Audio.play_sound("test/asset/cheer.mp3")
	pass
