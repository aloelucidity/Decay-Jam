class_name UpgradeShop
extends HBoxContainer


@onready var label: Label = $Label
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var button: Button = $Button

@export var upgrade_id: String
@export var max_upgrades: int
@export var price: int
@export var price_multiplier: float = 1.05


func _ready() -> void:
	label.text = name.capitalize() + ": "
	progress_bar.max_value = max_upgrades
	update_display()


func update_display() -> void:
	var final_price: int = get_final_price()
	button.text = "+ ($%s)" % final_price
	
	var upgrades: int = Globals[upgrade_id]
	progress_bar.value = upgrades
	if upgrades == max_upgrades:
		button.hide()


func get_final_price() -> int:
	var upgrades: int = Globals[upgrade_id]
	return floor(price * pow(price_multiplier, upgrades))


func purchase():
	var final_price: int = get_final_price()
	if Globals.money >= final_price and Globals[upgrade_id] < max_upgrades:
		Globals.money -= final_price
		Globals[upgrade_id] += 1
		update_display()
