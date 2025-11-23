extends Label


@onready var base_text: String = text


func _ready() -> void:
	text = base_text % [str(Globals.day), Globals.equipped_body.shop_name, Globals.equipped_wheel.shop_name]
	if Globals.day == 1:
		text = text.replace("days", "day!! For real??")
