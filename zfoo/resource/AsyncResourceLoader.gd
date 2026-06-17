class_name AsyncResourceLoader
extends IComponent

# SignalBridge
var signalTasks: Array[LoadResourceTask] = []

func _init() -> void:
	start()
	pass

# IComponent-Interface-Implement-Start
func start() -> void:
	super.start()
	pass

func update() -> void:
	if signalTasks.is_empty():
		return
	var finishedTasks: Array[LoadResourceTask] = []
	for task in signalTasks:
		var status := ResourceLoader.load_threaded_get_status(task.path)
		match status:
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
				Log.error("invalid resource:[{}] THREAD_LOAD_INVALID_RESOURCE", task.path)
				finishedTasks.append(task)
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
				Log.error("failed to load resource:[{}] THREAD_LOAD_FAILED", task.path)
				finishedTasks.append(task)
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
				var resource := ResourceLoader.load(task.path)
				task.resource = resource
				finishedTasks.append(task)
	if finishedTasks.is_empty():
		return
	for task in finishedTasks:
		# task.emit_signal("resource_signal", task.resource)
		task.resource_signal.emit(task.resource)
	finishedTasks.clear()
	pass
# IComponent-Interface-Implement-End


func async_load(path: String) -> Resource:
	if ResourceLoader.has_cached(path):
		return ResourceLoader.load(path)
	if !ResourceLoader.exists(path):
		Log.error("resource not exist in the path:[{}]", path)
		return null
	var error = ResourceLoader.load_threaded_request(path)
	if error:
		Log.error("failed to load resource:[{}]", path)
		return null
	var signalId = IdUtils.local_id()
	var task: LoadResourceTask = LoadResourceTask.new(signalId, path)
	signalTasks.append(task)
	var resource = await task.resource_signal
	var index = signalTasks.find(task)
	signalTasks.remove_at(index)
	return resource

class LoadResourceTask:
	signal resource_signal(resource: Resource)

	var signalId: int
	var path: String
	var resource: Resource

	func _init(_signalId: int, _path: String):
		self.signalId = _signalId
		self.path = _path
		pass
