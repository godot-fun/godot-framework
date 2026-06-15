@abstract
class_name ISceneTransition
extends RefCounted

func start() -> void:
	pass

func change_before() -> void:
	await ThreadUtils.async_sleep(0)
	pass

func change_after() -> void:
	await ThreadUtils.async_sleep(0)
	pass

func end() -> void:
	pass
