class_name FileUtils
extends Object

# Bytes
const ONE_BYTE: int = 1
const BYTES_PER_KB: int = 1024
const BYTES_PER_MB: int = BYTES_PER_KB * 1024
const BYTES_PER_GB: int = BYTES_PER_MB * 1024

# Bits
const BITS_PER_BYTE: int = 8
const BITS_PER_KB: int = BYTES_PER_KB * 8
const BITS_PER_MB: int = BYTES_PER_MB * 8
const BITS_PER_GB: int = BYTES_PER_GB * 8

# Line endings (text files)
const NEWLINE_LF: String = "\n"
const NEWLINE_CR: String = "\r"
const NEWLINE_CRLF: String = "\r\n"

static func normalize_line_endings_to_lf(s: String) -> String:
	return s.replace(NEWLINE_CRLF, NEWLINE_LF).replace(NEWLINE_CR, NEWLINE_LF)

# Append content to the file.
static func write_string_to_file(filePath: String, content: String) -> void:
	var file := FileAccess.open(filePath, FileAccess.WRITE)
	# bread and butter
	file.store_string(content)
	file = null
	pass
	

static func read_file_to_string(filePath: String) -> String:
	# make sure our file exists on users system
	if !FileAccess.file_exists(filePath):
		return StringUtils.EMPTY
	
	# allow reading only for file
	var file := FileAccess.open(filePath, FileAccess.READ)
	
	var content := file.get_as_text()
	file = null
	return content

static func read_file_to_byte_array(filePath: String) -> PackedByteArray:
	# make sure our file exists on users system
	if !FileAccess.file_exists(filePath):
		return PackedByteArray()
	
	# allow reading only for file
	var file := FileAccess.open(filePath, FileAccess.READ)
	
	var buffer := file.get_buffer(file.get_length())
	file = null
	return buffer

static func delete_file(filePath: String) -> void:
	if !FileAccess.file_exists(filePath):
		return
	DirAccess.remove_absolute(filePath)
	pass

# Returns absolute paths of all files in the given folder.
# Set recursive to true to include files in subfolders.
static func get_all_files_in_folder(folderPath: String, recursive: bool = false) -> Array[String]:
	var files: Array[String] = []
	var dir := DirAccess.open(folderPath)
	if dir == null:
		return files
	
	for file_name in dir.get_files():
		files.append(folderPath.path_join(file_name))
	
	if recursive:
		for dir_name in dir.get_directories():
			files.append_array(get_all_files_in_folder(folderPath.path_join(dir_name), true))
	
	return files


# Convert a string into a valid filename using underscores as separators.
# aa bb cc dd -> aa_bb_cc
static func sanitize_filename(name: String) -> String:
	var regex := RegEx.new()

	# Replace all non-alphanumeric characters with '_'
	regex.compile("[^a-zA-Z0-9_-]")

	var result := regex.sub(name, "_", true)

	regex.compile("_+")
	result = regex.sub(result, "_", true)

	result = result.strip_edges()
	result = result.trim_prefix("_")
	result = result.trim_suffix("_")

	if StringUtils.is_blank(result):
		result = "unnamed"

	return result