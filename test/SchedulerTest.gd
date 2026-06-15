

func Scheduler_test() -> void:
	SchedulerBus.schedule(Callable(self, "do_something"), 1000)
	await ThreadUtils.async_sleep(2000)
	assert(value == true)
	pass

var value: bool = false
func do_something() -> void:
	value = true
	pass


func StopWatch_test() -> void:
	var stopWatch: StopWatch = StopWatch.new()
	await gdf.gdf_node.get_tree().create_timer(1).timeout
	var costSeconds: float = stopWatch.cost_seconds()
	var costMinutes: float = stopWatch.cost_minutes()
	assert(stopWatch.cost() > 0)
	assert(absf(costSeconds - 1) < 0.2)
	assert(costMinutes < 0.1)
	pass
