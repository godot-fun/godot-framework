class_name gdf
extends Node

static var gdf_node: Node
static var gdf_layer: CanvasLayer


func _ready() -> void:
	if gdf_node == null:
		gdf_node = self
		init_layer()
		init_async_timer()
		Audio.init()
		LoggerHelper.init()
	pass

func _process(_delta: float) -> void:
	for component in IComponent.components:
		component.update()
	pass

####################################################################################################
# Layer
func init_layer() -> void:
	gdf_layer = CanvasLayer.new()
	gdf_layer.name = "gdf_layer"
	gdf_layer.layer = 10240
	gdf_node.add_child(gdf_layer)
	pass

####################################################################################################
# Scheduler & TimeUtils
func init_async_timer() -> void:
	var timer := Timer.new()
	timer.name = "async_timer"
	timer.autostart = true
	timer.wait_time = 1.0
	timer.timeout.connect(async_timer_one_second)
	timer.process_thread_group = Node.PROCESS_THREAD_GROUP_SUB_THREAD
	add_child(timer)
	timer.start()
	pass

func async_timer_one_second() -> void:
	TimeUtils.current_time_millis()
	Audio.async_update()
	pass

####################################################################################################
# Callable
static func callable_deferred(callable: Callable) -> void:
	gdf_node.call_deferred("call_deferred_callable", callable)
	pass

func call_deferred_callable(callable: Callable) -> void:
	callable.call()
	pass

####################################################################################################
static func quit(exit_code: int = 0) -> void:
	for i in range(10):
		await gdf_node.get_tree().process_frame
	gdf_node.get_tree().quit(exit_code)
	pass