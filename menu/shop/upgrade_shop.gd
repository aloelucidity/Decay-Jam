class_name UpgradeShop
extends VBoxContainer


@onready var label: Label = $HBoxContainer/Label
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var button: TextureButton = $HBoxContainer/Control/Button
@onready var button_label: Label = $HBoxContainer/Control/Button/Label

@export var upgrade_id: String
@export var max_upgrades: int
@export var prices: Array[int]


func _ready() -> void:
	label.text = name.capitalize() + ": "
	progress_bar.max_value = max_upgrades
	update_display()


func update_display() -> void:
	var upgrades: int = Globals[upgrade_id]
	progress_bar.value = upgrades
	if upgrades == max_upgrades:
		button.disabled = true
		button_label.text = "Max"
	else:
		button_label.text = "$%s" % prices[upgrades]


func purchase():
	var upgrades: int = Globals[upgrade_id]
	if Globals.money >= prices[upgrades] and upgrades < max_upgrades:
		Globals.money -= prices[upgrades]
		Globals[upgrade_id] += 1
		update_display()
