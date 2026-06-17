class_name HttpResponse
extends RefCounted


var success: bool = false
## HTTP status code (200, 404, 500, ...)
var code: int = 0
var headers: Dictionary = {}
var body: PackedByteArray = PackedByteArray()


func get_body_string() -> String:
	return body.get_string_from_utf8()


func get_body_json() -> Variant:
	var text := get_body_string()
	if StringUtils.is_blank(text):
		return null
	var json := JSON.new()
	if json.parse(text) != OK:
		Log.error("HttpResponse parse JSON failed: {}", json.get_error_message())
		return null
	return json.data


func _to_string() -> String:
	return StringUtils.format("HttpResponse[code:{}, bodySize:{}]", code, body.size())
