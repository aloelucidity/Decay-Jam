extends HBoxContainer


const BODY_SCENE: PackedScene = preload("res://menu/shop/body_button.tscn")
const BODIES_LIST: Array = preload("res://car/bodies/bodies_list.tres").bodies_list
@onready var notes_label: RichTextLabel = %NotesLabel


func _ready() -> void:
	for body_stats: BodyStats in BODIES_LIST:
		var body_button: BodyButton = BODY_SCENE.instantiate()
		body_button.body_stats = body_stats
		add_child(body_button)
		body_button.connect(
			"mouse_entered", 
			notes_label.set_text.bind(body_stats.shop_description)
		)
