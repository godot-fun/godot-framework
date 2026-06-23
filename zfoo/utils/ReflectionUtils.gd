class_name ReflectionUtils


static func has_empty_constructor(type: Variant) -> bool:
	if !type.has_method("new"):
		Log.error("type:[{}] can not be instantiated", get_type_name(type))
		return false
	for method in get_init_methods(type):
		if !method.args.is_empty():
			Log.error("type:[{}] has no default _init() constructor", get_type_name(type))
			return false
	if !type.has_method("can_instantiate") || !type.can_instantiate():
		return false
	return true


static func get_init_methods(type: Variant) -> Array[Dictionary]:
	var init_methods: Array[Dictionary] = []
	if !type.has_method("get_script_method_list"):
		return init_methods
	for method in type.get_script_method_list():
		if method.name == "_init":
			init_methods.append(method)
	return init_methods


static func get_script_property_map(obj: Object) -> Dictionary[String, Variant]:
	var property_map: Dictionary[String, Variant] = {}
	for property in obj.get_property_list():
		if (property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
			continue
		property_map[property.name] = property
	return property_map


static func get_type_name(type: Variant) -> String:
	if type is Script:
		var script := type as Script
		var global_name := script.get_global_name()
		if !StringUtils.is_blank(global_name):
			return global_name
		if !StringUtils.is_blank(script.resource_path):
			return script.resource_path
	return str(type)
