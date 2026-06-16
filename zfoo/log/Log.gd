class_name Log
extends Object


static func info(template: String, ...args: Array) -> void:
	if StringUtils.is_blank(template):
		return
	var message := template.format(args, StringUtils.EMPTY_JSON)
	if Thread.is_main_thread():
		print(StringUtils.format("{} - {}", TimeUtils.date(), message))
		return
	print(StringUtils.format("{} [thread {}] - {}", TimeUtils.date(), OS.get_thread_caller_id(), message))
	pass

static func error(template: String, ...args: Array) -> void:
	if StringUtils.is_blank(template):
		return
	var message := template.format(args, StringUtils.EMPTY_JSON)
	if Thread.is_main_thread():
		printerr(StringUtils.format("{} [ERROR] - {}", TimeUtils.date(), message))
		return
	printerr(StringUtils.format("{} [thread {}] [ERROR] - {}", TimeUtils.date(), OS.get_thread_caller_id(), message))
	pass