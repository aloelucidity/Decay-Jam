extends HBoxContainer


const WHEEL_SCENE: PackedScene = preload("res://menu/shop/wheel_button.tscn")
const WHEELS_LIST: Array = preload("res://car/wheels/wheels_list.tres").wheels_list
@onready var notes_label: RichTextLabel = %NotesLabel


func _ready() -> void:
	for wheel_stats: WheelStats in WHEELS_LIST:
		var wheel_button: WheelButton = WHEEL_SCENE.instantiate()
		wheel_button.wheel_stats = wheel_stats
		add_child(wheel_button)
		wheel_button.connect(
			"mouse_entered", 
			notes_label.set_text.bind(wheel_stats.shop_description)
		)
