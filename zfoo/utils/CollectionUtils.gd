class_name CollectionUtils
extends Object


static func is_empty(dictionary: Dictionary) -> bool:
	return dictionary == null or dictionary.size() == 0

static func is_not_empty(dictionary: Dictionary) -> bool:
	return !is_empty(dictionary)
