extends Label


@onready var base_text: String = text
@export var display_var: String


func _ready() -> void:
	update_display(display_var, Globals[display_var])
	Globals.connect("stat_changed", update_display)


func update_display(stat: String, new_value) -> void:
	if stat != display_var: return
	text = base_text % str(new_value)
