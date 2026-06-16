class_name ThreadUtils
extends Object

# will block current thread
static func sleep(millis: int) -> void:
	OS.delay_msec(millis)
	pass

static func async_sleep(millis: int) -> void:
	await gdf.gdf_node.get_tree().create_timer(millis / float(TimeUtils.MILLIS_PER_SECOND)).timeout
	pass
