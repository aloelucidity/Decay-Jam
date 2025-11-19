class_name AutoResizer
extends Control


func _ready() -> void:
	get_window().connect("size_changed", window_resized)
	window_resized()


func window_resized() -> void:
	var base_size: float = (
		ProjectSettings.get_setting("display/window/size/viewport_width")
		+ ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	var window: Window = get_window()
	if is_instance_valid(window):
		var new_zoom: float = float(window.size.x + window.size.y) / base_size
		scale = Vector2(new_zoom, new_zoom)
		set_deferred("size", Vector2(window.size) / scale)
		position = Vector2.ZERO
