class_name RectTransitionFade
extends ISceneTransition

var transitionRect: ColorRect  = ColorRect.new()
var duration: float = 1.0

# ISceneTransition-Interface-Implement-Start
func start() -> void:
	var root: Window = gdf.gdf_node.get_tree().root
	transitionRect.name = "TransitionRect"
	transitionRect.color = Color.BLACK
	transitionRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transitionRect.size = root.get_viewport().get_visible_rect().size
	transitionRect.color.a = 0.0
	gdf.gdf_layer.add_child(transitionRect)
	pass

func change_before() -> void:
	var tween := transitionRect.create_tween()
	tween.tween_property(transitionRect, "color:a", 1.0, duration)
	await tween.finished
	pass

func change_after() -> void:
	var tween := transitionRect.create_tween()
	tween.tween_property(transitionRect, "color:a", 0.0, duration)
	await tween.finished
	pass

func end() -> void:
	transitionRect.queue_free()
	pass
# ISceneTransition-Interface-Implement-End
