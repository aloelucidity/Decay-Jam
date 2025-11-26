class_name ScreenManager
extends Control


@export var default_screen: Screen
@onready var current_screen: Screen

signal screen_changed


func _ready():
	current_screen = default_screen
	for screen in get_children():
		screen.connect("screen_change", screen_change)
		screen.visible = (screen == current_screen)
		if screen.visible:
			# do open animation so its visible if the
			# reset vars normally make it invisible
			screen.animation_player.play_backwards("transition")
			screen.animation_player.seek(0.01, true)
			screen.emit_signal("screen_opened")


func screen_change(new_screen_name: String):
	if is_instance_valid(current_screen):
		current_screen.hide()
	
	var new_screen: Screen = get_node_or_null(new_screen_name)
	if not is_instance_valid(new_screen): 
		current_screen = null
		emit_signal("screen_changed")
		return
	
	current_screen = new_screen
	
	new_screen.animation_player.play_backwards("transition")
	new_screen.show()
	
	new_screen.emit_signal("screen_opened")
	emit_signal("screen_changed")
