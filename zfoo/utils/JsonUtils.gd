class_name JsonUtils
extends Object

# Nested classes are not supported.
static func json_to_object(json: String, type: Variant) -> Variant:
	if StringUtils.is_blank(json):
		return
	var data = JSON.parse_string(json)
	if data == null:
		Log.error("Json pars error:[{}]", json)
		return
	if !ReflectionUtils.has_empty_constructor(type):
		return
	var obj = type.new()
	var property_map := ReflectionUtils.get_script_property_map(obj)
	for key in data.keys():
		var value = data[key]
		if property_map.has(key):
			value = convert_json_value(property_map[key], value)
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



static func convert_json_value(property: Dictionary, value: Variant) -> Variant:
	if value == null:
		return null
	var property_type: int = property.type
	var hint: int = property.hint
	var hint_string: String = property.get("hint_string", "")
	if hint == PROPERTY_HINT_ARRAY_TYPE or property_type == TYPE_ARRAY:
		return convert_json_array(hint_string, value)
	match property_type:
		TYPE_BOOL:
			return bool(value)
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return float(value)
		TYPE_STRING:
			return str(value)
		_:
			return value


static func convert_json_array(element_type_name: String, value: Variant) -> Variant:
	if typeof(value) != TYPE_ARRAY:
		return value
	if StringUtils.is_blank(element_type_name):
		return value
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
