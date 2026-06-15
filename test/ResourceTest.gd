
func ResourceHelper_test() -> void:
	var resource = await ResourceHelper.async_load("res://icon.svg")
	assert(resource != null)
	pass
