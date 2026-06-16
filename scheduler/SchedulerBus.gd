class_name SchedulerBus
extends Object

static func schedule(callable: Callable, delay_ms: int) -> void:
	gdf.gdf_node.create_tween().tween_callback(callable).set_delay(delay_ms / float(TimeUtils.MILLIS_PER_SECOND))
#	gdf.gdf_node.get_tree().create_timer(delay_ms / float(TimeUtils.MILLIS_PER_SECOND)).timeout.connect(callable)
	pass


static func schedule_at_fixed_rate(callable: Callable, period_ms: int, name: String = StringUtils.EMPTY, multiple_thread: bool = false) -> void:
	var timer := Timer.new()
	timer.name = name if StringUtils.is_not_empty(name) else StringUtils.format("schedule_{}", IdUtils.local_id())
	timer.autostart = true
	timer.one_shot = false
	if multiple_thread:
		timer.process_thread_group = Node.PROCESS_THREAD_GROUP_SUB_THREAD
	timer.wait_time = period_ms / float(TimeUtils.MILLIS_PER_SECOND)
	timer.timeout.connect(callable)
	gdf.gdf_node.add_child(timer)
	timer.start()
	pass