class_name ConcurrentArrayList
extends RefCounted

var list: Array[Variant] = []
var mutex: Mutex = Mutex.new()

func add(element):
	mutex.lock()
	list.push_back(element)
	mutex.unlock()
	pass

# Retrieves and removes the head of this queue, or returns null if this queue is empty.
func pop_front() -> Variant:
	if list.is_empty():
		return null
	mutex.lock()
	var element = list.pop_front()
	mutex.unlock()
	return element

func pop_back() -> Variant:
	if list.is_empty():
		return null
	mutex.lock()
	var element = list.pop_back()
	mutex.unlock()
	return element

# Retrieves, but does not remove, the head of this queue, or returns null if this queue is empty.
func peek() -> Variant:
	return list.front()

func clear():
	mutex.lock()
	list.clear()
	mutex.unlock()
	pass

func is_empty() -> bool:
	return list.is_empty()

func size() -> int:
	return list.size()
