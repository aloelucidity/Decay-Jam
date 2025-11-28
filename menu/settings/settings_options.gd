class_name SettingsOptions
extends OptionButton


@export var section: String
@export var key: String
## saved as their index in the array, not as the strings themselves
@export var options: Array[String]


func _ready() -> void:
	for option in options:
		add_item(option)
	
	var index: int = LocalSettings.load_setting(section, key, 0)
	select(index)
	
	connect("item_selected", item_selected)


func item_selected(index: int):
	LocalSettings.change_setting(section, key, index)
