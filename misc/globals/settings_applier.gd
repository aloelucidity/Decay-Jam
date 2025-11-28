extends Node


const FPS_INCREMENT: int = 30


func _ready() -> void:
	LocalSettings.connect("setting_changed", setting_changed)
	for section: String in LocalSettings.config.get_sections():
		for key in LocalSettings.get_section_keys(section):
			setting_changed(key, LocalSettings.load_setting(section, key, 0))


func setting_changed(key: String, new_value: Variant) -> void:
	match key:
		"window_scale":
			var window: Window = get_window()
			var window_scale: int = new_value
			if window_scale == 0:
				window.mode = Window.MODE_FULLSCREEN
			else:
				var screen_size: Vector2i = DisplayServer.screen_get_size()
				var base_size := Vector2i(
					ProjectSettings.get_setting("display/window/size/viewport_width"),
					ProjectSettings.get_setting("display/window/size/viewport_height")
				)
				window.mode = Window.MODE_WINDOWED
				window.size = base_size * window_scale
				window.position = screen_size / 2 - window.size / 2
			setting_changed("vsync", LocalSettings.load_setting("Display Settings", "vsync", true))
		
		"fps_limit":
			Engine.max_fps = int(new_value) * FPS_INCREMENT
		
		"vsync":
			var vsync_mode: int = DisplayServer.VSYNC_ENABLED if bool(new_value) else DisplayServer.VSYNC_DISABLED
			DisplayServer.window_set_vsync_mode(vsync_mode)
		
		"master_volume":
			var bus_id: int = AudioServer.get_bus_index("Master")
			AudioServer.set_bus_volume_linear(bus_id, new_value as float)

		"music_volume":
			var bus_id: int = AudioServer.get_bus_index("Music")
			AudioServer.set_bus_volume_linear(bus_id, new_value as float)

		"sfx_volume":
			var bus_id: int = AudioServer.get_bus_index("Sounds")
			AudioServer.set_bus_volume_linear(bus_id, new_value as float)
