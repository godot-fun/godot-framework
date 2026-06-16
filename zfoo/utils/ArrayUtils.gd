class_name ArrayUtils
extends Object


static func is_empty(array: Array) -> bool:
	return array == null or array.size() == 0

static func is_not_empty(array: Array) -> bool:
	return !is_empty(array)
