class_name ReadyQueue
extends RefCounted

var queue: Array[Variant] = []
var ready: bool = false

func add(ele: Variant) -> void:
	queue.append(ele)
	pass

func pop_front() -> Variant:
	if !ready:
		return null
	return queue.pop_front()
