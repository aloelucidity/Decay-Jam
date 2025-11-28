extends HBoxContainer


const AUDIO_SECTION: String = "Audio Settings"

@onready var label: Label = $Label
@onready var h_slider: HSlider = $HSlider

@export var label_text: String
@export var setting_name: StringName


func _ready() -> void:
	label.text = label_text
	h_slider.value = LocalSettings.load_setting(AUDIO_SECTION, setting_name, 1.0)


func drag_ended(value_changed: bool) -> void:
	if not value_changed: return
	LocalSettings.change_setting(AUDIO_SECTION, setting_name, h_slider.value)
