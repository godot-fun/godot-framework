extends Node

@onready var sceneToMainButton: Button = $SceneToMain
@onready var addNodeButton: Button = $AddNode

func _ready() -> void:
	sceneToMainButton.pressed.connect(pressedSceneToMainButton)
	addNodeButton.pressed.connect(pressedSceneAddNodeButton)
	pass


func pressedSceneToMainButton():
	await SceneHelper.async_change_scene_to_file("test/manual/TestA.tscn")
	#await SceneHelper.async_change_scene_to_file("zfoo/test/manual/TestA.tscn", RectTransitionSlide.new())
	pass

func pressedSceneAddNodeButton():
	SceneHelper.add_scene(gdf.gdf_node.get_tree().root, load("test/manual/TestA.tscn"))
	pass
