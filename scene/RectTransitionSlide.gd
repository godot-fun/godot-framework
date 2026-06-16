class_name RectTransitionSlide
extends RectTransitionFade


# ISceneTransition-Interface-Implement-Start
func start() -> void:
	super.start()
	transitionRect.color.a = 1.0
	transitionRect.position.x = -transitionRect.size.x
	pass

func change_before() -> void:
	var tween := transitionRect.create_tween()
	tween.tween_property(transitionRect, "position:x", 0, duration)
	await tween.finished
	pass

func change_after() -> void:
	var tween := transitionRect.create_tween()
	tween.tween_property(transitionRect, "position:x", transitionRect.size.x, duration)
	await tween.finished
	pass

func end() -> void:
	transitionRect.queue_free()
	pass
# ISceneTransition-Interface-Implement-End
