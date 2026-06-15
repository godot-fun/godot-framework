class_name Setting
extends Object

const SETTING_FILE_PATH: String = "user://setting.config";
const SECTION: String = "zfoo"
static var configFile: ConfigFile = load_config_file()

static func load_config_file() -> ConfigFile:
	var cf := ConfigFile.new()
	cf.load(SETTING_FILE_PATH)
	return cf

static func save():
	configFile.save(SETTING_FILE_PATH)
	pass

static func clear():
	configFile.clear()
	pass

static func set_bool(key: String, value: bool):
	configFile.set_value(SECTION, key, str(value))
	pass

static func get_bool(key: String, defalut: bool = false) -> bool:
	var value: String = configFile.get_value(SECTION, key, StringUtils.EMPTY)
	return defalut if StringUtils.is_blank(value) else value.to_lower() == "true"

static func set_int(key: String, value: int):
	configFile.set_value(SECTION, key, str(value))
	pass

static func get_int(key: String, defalut: int = 0) -> int:
	var value: String = configFile.get_value(SECTION, key, StringUtils.EMPTY)
	return defalut if StringUtils.is_blank(value) else int(value)

static func set_float(key: String, value: float):
	configFile.set_value(SECTION, key, str(value))
	pass

static func get_float(key: String, defalut: float = 0) -> float:
	var value: String = configFile.get_value(SECTION, key, StringUtils.EMPTY)
	return defalut if StringUtils.is_blank(value) else float(value)

static func set_string(key: String, value: String):
	configFile.set_value(SECTION, key, value)
	pass

static func get_string(key: String, defalut: String = StringUtils.EMPTY) -> String:
	var value: String = configFile.get_value(SECTION, key, defalut)
	return value
