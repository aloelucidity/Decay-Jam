extends ColorRect


func _ready() -> void:
	get_window().connect("size_changed", window_resized)
	window_resized()


func window_resized() -> void:
	var window: Window = get_window()
	if is_instance_valid(window):
		size = window.size
		position = Vector2.ZERO
