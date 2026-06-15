@abstract
class_name IComponent
extends Object

static var components: Array[IComponent]

func start() -> void:
	if components.has(self):
		return
	components.append(self)
	Log.info("start component [{}] instance:[{}]", self.get_script().get_global_name(), self.get_instance_id())
	pass

func update() -> void:
	pass
