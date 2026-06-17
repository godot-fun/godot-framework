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
	var obj = type.new()
	for key in data.keys():
		obj.set(key, data[key])
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
			var properties = obj.get_property_list()
			var array: PackedStringArray = PackedStringArray()
			for property in properties:
				var propertyType = property.type
				var propertyName = property.name
				if propertyType == TYPE_NIL:
					continue
				if propertyName == "script":
					continue
				var value = obj.get(propertyName)
				array.push_back("\"" + propertyName + "\": " + object_to_json(value))
			return "{" + ", ".join(array) + "}"
		_:
			Log.error("unknow type:[{}]", type)
	return ""
