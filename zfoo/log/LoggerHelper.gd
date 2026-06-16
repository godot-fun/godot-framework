class_name LoggerHelper
extends Object

static var LOG_FILE_PATH: String = OS.get_user_data_dir() + "/logs/godot.log"

static func init() -> void:
	if OS.is_debug_build():
		OS.add_logger(ConsoleLogger.new())
		return
	OS.add_logger(FileLogger.new())
	print(StringUtils.format("{} - add loggger file:[{}]", TimeUtils.date(), LOG_FILE_PATH))
	pass


@warning_ignore("unused_parameter")
static func format_error_message(function: String, file: String, line: int, code: String, rationale: String, editor_notify: bool, error_type: int, script_backtraces: Array[ScriptBacktrace]) -> String:
	# Match Godot console-like format as much as possible.
	var first_line := ""
	if !StringUtils.is_blank(code):
		first_line = StringUtils.format("SCRIPT ERROR: {}", code)
	elif !StringUtils.is_blank(rationale):
		first_line = StringUtils.format("SCRIPT ERROR: {}", rationale)
	else:
		first_line = "SCRIPT ERROR: (no details)"

	var parts: Array[String] = []
	parts.append(first_line)
	parts.append(StringUtils.format("   at: {} ({}:{})", function, file, line))

	if script_backtraces != null and script_backtraces.size() > 0:
		parts.append("   GDScript backtrace (most recent call first):")
		var idx := 0
		for bt in script_backtraces:
			parts.append(StringUtils.format("\t[{}] {}", idx, str(bt)))
			idx += 1

	return "\n".join(parts)



static func tail_log() -> String:
	const TAIL_LINES := 128
	const CHUNK_SIZE := 4096

	if not FileAccess.file_exists(LOG_FILE_PATH):
		return StringUtils.format("Log file not found:[{}]", LOG_FILE_PATH)

	var file := FileAccess.open(LOG_FILE_PATH, FileAccess.READ)
	if file == null:
		return StringUtils.format("Failed to open log file:[{}]", LOG_FILE_PATH)

	var file_len := file.get_length()
	var pos := file_len
	var chunks: Array[String] = []
	var newlines := 0

	while pos > 0 and newlines <= TAIL_LINES:
		var start := maxi(0, pos - CHUNK_SIZE)
		var read_len := pos - start
		file.seek(start)
		var bytes := file.get_buffer(read_len)
		var chunk := bytes.get_string_from_utf8()
		chunks.append(chunk)
		newlines += chunk.count(FileUtils.NEWLINE_LF) + chunk.count(FileUtils.NEWLINE_CR)
		pos = start

	file.close()

	chunks.reverse()
	var collected := FileUtils.normalize_line_endings_to_lf("".join(chunks))
	var lines := collected.split(FileUtils.NEWLINE_LF, false)
	if lines.size() > TAIL_LINES:
		lines = lines.slice(lines.size() - TAIL_LINES, lines.size())

	var tail_text := FileUtils.NEWLINE_LF.join(lines)
	return tail_text
