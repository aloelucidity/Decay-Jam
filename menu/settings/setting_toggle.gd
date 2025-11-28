extends CheckButton


@export var section: String
@export var key: String


func _ready() -> void:
	set_pressed_no_signal(
		LocalSettings.load_setting(section, key, false)
	)


func _toggled(toggled_on: bool) -> void:
	LocalSettings.change_setting(section, key, toggled_on)
