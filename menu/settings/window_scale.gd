extends SettingsOptions


func _ready() -> void:
	var base_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var base_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
	
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	@warning_ignore("integer_division")
	var max_scale: int = min(
		floori(screen_size.x / base_width), 
		floori(screen_size.y / base_height)
	)
	
	for window_scale in range(max_scale):
		options.append(str(window_scale + 1) + "x scale")
	
	super()
