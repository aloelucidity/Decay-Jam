extends Label


@onready var default_color: Color = get_theme_color("font_color")
@export var flash_speed: float = 2


func _process(_delta: float) -> void:
	var mix: float = 0.5 + sin(Time.get_unix_time_from_system() * flash_speed)/2
	add_theme_color_override("font_color", lerp(Color.WHITE, default_color, mix))
