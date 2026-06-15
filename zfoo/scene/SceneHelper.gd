class_name SceneHelper
extends Object


static func queue_free(node: Node) -> void:
	if (node == null):
		return
	node.queue_free()
	pass

static func add_scene(node: Node, scene: PackedScene) -> Node:
	var sceneNode := scene.instantiate()
	node.add_child(sceneNode)
	return sceneNode

static func async_change_scene_to_file(scenePath: String, transition: ISceneTransition = RectTransitionFade.new()) -> void:
	var scene: PackedScene = await ResourceHelper.async_load(scenePath)
	if scene == null:
		return
	await async_change_scene_to_packed(scene, transition)
	pass

static func async_change_scene_to_packed(scene: PackedScene, transition: ISceneTransition = RectTransitionFade.new()) -> void:
	transition.start()
	await transition.change_before()
	var sceneTree: SceneTree = gdf.gdf_node.get_tree()
	var error := sceneTree.change_scene_to_packed(scene)
	if error:
		printerr(StringUtils.format("load scene:[{}] error:[{}] in [{}]", scene, error, sceneTree))
	await transition.change_after()
	transition.end()
	pass
