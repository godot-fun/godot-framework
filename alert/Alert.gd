class_name Alert
extends Label

const default_font_size: int = 32
const default_speed: float = 50
const default_wait_time: int = 2700

func _process(delta):
	position.y = position.y + default_speed * delta
	pass


static func create_alert_label(i18n_text: String, color: Color) -> Label:
	var alertLabel: Label = Label.new()
	alertLabel.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	alertLabel.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
	alertLabel.text = i18n_text
	alertLabel.add_theme_font_size_override("font_size", default_font_size)
	
	var root: Window = gdf.gdf_node.get_tree().root
	alertLabel.size.x = root.size.x
	
	var styleBox: StyleBoxFlat = StyleBoxFlat.new()
	styleBox.bg_color = color
	alertLabel.add_theme_stylebox_override("normal", styleBox)
	alertLabel.z_index = 1024
	
	alertLabel.set_script(Alert)
	return alertLabel

####################################################################################################
# Alert
static func alert(txt: String, color: Color) -> void:
	var alertLabel = create_alert_label(txt, color)
	gdf.gdf_layer.add_child(alertLabel)
	await ThreadUtils.async_sleep(default_wait_time)
	alertLabel.queue_free()
	pass
