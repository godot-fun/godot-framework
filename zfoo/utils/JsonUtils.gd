class_name JsonUtils
extends Object

static func json_to_object(json: String, type: Variant) -> Variant:
	if StringUtils.is_blank(json):
		return
	var data = JSON.parse_string(json)
	if data == null:
		Log.error("Json pars error:[{}]", json)
		return
	if typeof(data) != TYPE_DICTIONARY:
		Log.error("Json root type error:[{}]", json)
		return
	return dict_to_object(data, type)


static func dict_to_object(data: Dictionary, type: Variant) -> Variant:
	if !ReflectionUtils.has_empty_constructor(type):
		return
	var obj = type.new()
	var property_map := ReflectionUtils.get_script_property_map(obj)
	for key in data.keys():
		var value = data[key]
		if property_map.has(key):
			value = convert_json_value(property_map[key], value, obj)
		obj.set(key, value)
	return obj


static func object_to_json(obj: Variant) -> String:
	var type := typeof(obj)
	match type:
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return str(obj)
		TYPE_INT:
			return str(obj)
		TYPE_FLOAT:
			return str(obj)
		TYPE_STRING:
			return "\"" + obj as String + "\""
		TYPE_ARRAY:
			var array: PackedStringArray = PackedStringArray()
			for element in obj:
				array.push_back(object_to_json(element))
			return "[" + ",".join(array) + "]"
		TYPE_DICTIONARY:
			var array: PackedStringArray = PackedStringArray()
			for key in obj:
				var value = obj.get(key)
				array.push_back("\"" + object_to_json(key) + "\": " + object_to_json(value))
			return "{" + ", ".join(array) + "}"
		TYPE_OBJECT:
			var array: PackedStringArray = PackedStringArray()
			for property in ReflectionUtils.get_script_property_map(obj).values():
				var property_name := property.name as String
				var value = obj.get(property_name)
				array.push_back("\"" + property_name + "\": " + object_to_json(value))
			return "{" + ", ".join(array) + "}"
		_:
			Log.error("unknow type:[{}]", type)
	return ""



static func convert_json_value(property: Dictionary, value: Variant, obj: Object) -> Variant:
	if value == null:
		return null
	var property_type: int = property.type
	var hint: int = property.hint
	var hint_string: String = property.get("hint_string", "")
	var property_name := property.name as String
	if hint == PROPERTY_HINT_ARRAY_TYPE or property_type == TYPE_ARRAY:
		return convert_json_array(hint_string, value, obj, property_name)
	match property_type:
		TYPE_BOOL:
			return bool(value)
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return float(value)
		TYPE_STRING:
			return str(value)
		TYPE_OBJECT:
			if typeof(value) == TYPE_DICTIONARY:
				var element_script := get_object_property_script(obj, property_name, hint_string)
				if element_script != null:
					return dict_to_object(value, element_script)
			return value
		_:
			return value


static func get_object_property_script(obj: Object, property_name: String, hint_string: String) -> Script:
	var property_value = obj.get(property_name)
	if property_value is Array:
		var typed_script = (property_value as Array).get_typed_script()
		if typed_script is Script:
			return typed_script
#	Log.error("cannot parse json property:[{}] type:[{}]", property_name, hint_string)
	return null


static func convert_json_array(element_type_name: String, value: Variant, obj: Object, property_name: String) -> Variant:
	if typeof(value) != TYPE_ARRAY:
		return value
	var element_script := get_object_property_script(obj, property_name, element_type_name)
	if element_script != null:
		return convert_json_object_array(value, element_script)
	match element_type_name:
		"String":
			var result: Array[String] = []
			for item in value:
				result.append(str(item))
			return result
		"int":
			var result: Array[int] = []
			for item in value:
				result.append(int(item))
			return result
		"float":
			var result: Array[float] = []
			for item in value:
				result.append(float(item))
			return result
		"bool":
			var result: Array[bool] = []
			for item in value:
				result.append(bool(item))
			return result
		_:
			return value


static func convert_json_object_array(value: Variant, element_script: Script) -> Array:
	var result: Array = []
	for item in value:
		if typeof(item) == TYPE_DICTIONARY:
			var element = dict_to_object(item, element_script)
			if element != null:
				result.append(element)
		else:
			result.append(item)
	var base_type := element_script.get_instance_base_type()
	return Array(result, TYPE_OBJECT, base_type, element_script)
