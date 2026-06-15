class_name ConsoleLogger
extends Logger

# Logger-Interface-Implement-Start
func _log_error(function: String, file: String, line: int, code: String, rationale: String, editor_notify: bool, error_type: int, script_backtraces: Array[ScriptBacktrace]) -> void:
	printerr(LoggerHelper.format_error_message(function, file, line, code, rationale, editor_notify, error_type, script_backtraces))
	pass
# Logger-Interface-Implement-End
