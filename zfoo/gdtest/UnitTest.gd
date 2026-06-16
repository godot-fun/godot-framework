extends Node

# Include files in subfolders
@export var include_subfolders: bool = false

@export var enable_test_logging: bool = false

var error_occurred: bool = false

func _ready() -> void:
	var path: String = get_tree().current_scene.scene_file_path
	var parent_dir := path.get_base_dir()
	var files: Array[String] = FileUtils.get_all_files_in_folder(parent_dir, include_subfolders)
	gdf.events.log_error.connect(func() -> void: error_occurred = true)
	for file in files:
		if !file.ends_with(".gd"):
			continue
		var res: Resource = ResourceLoader.load(file)
		if res is Script:
			await unit_test(res)
	gdf.quit()
	pass


func unit_test(script: Script) -> void:
	var stop_watch: StopWatch = StopWatch.new()
	var static_test_methods: Array[String] = []
	var test_methods: Array[String] = []
	for method in script.get_script_method_list():
		var method_name: String = method.name
		var method_name_lower: String= method_name.to_lower()
		if !(method_name_lower.ends_with("test") || method_name_lower.begins_with("test")):
			continue
		if !method.args.is_empty():
			Log.error("❌ FAIL | [{}] | method:[{}] args is not empty", script.resource_path, method_name)
			gdf.quit(1)
			return
		var is_static: int = method.flags & METHOD_FLAG_STATIC
		if is_static:
			static_test_methods.push_back(method_name)
		else:
			test_methods.push_back(method_name)
	
	for method in static_test_methods:
		await script.call(method)
		await check_unit(script, method)
	
	if ArrayUtils.is_not_empty(test_methods):
		if !script.can_instantiate():
			Log.error("❌ FAIL | [{}] | can not instantiate this script", script.resource_path)
			gdf.quit(1)
			return
		var obj: Object= script.new()
		for method in test_methods:
			await obj.call(method)
			await check_unit(script, method)
	var test_unit := static_test_methods.size() + test_methods.size()
	Log.info("✅ PASS | [{}] | Run test unit:[{}] | {} seconds", script.resource_path, test_unit, stop_watch.cost_seconds())
	pass


func check_unit(script: Script, method: String) -> void:
	if error_occurred:
		Log.error("❌ FAIL | [{}] | {}", script.resource_path, method)
		await gdf.quit(1)
		return
	if enable_test_logging:
		Log.info("🟢 PASS | [{}] | {}", script.resource_path, method)
	pass