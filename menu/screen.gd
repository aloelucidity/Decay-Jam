class_name Screen
extends Control


@onready var animation_player = $AnimationPlayer

signal start_transition
@warning_ignore("unused_signal")
signal screen_opened ## this is used in the screen manager class
signal screen_change(new_screen_name: String)

var is_transitioning: bool


func transition(new_screen_name: String):
	if is_transitioning: return
	is_transitioning = true
	
	emit_signal("start_transition")
	animation_player.play("transition")
	
	await animation_player.animation_finished

	emit_signal("screen_change", new_screen_name)
	is_transitioning = false


func get_transition_length() -> float:
	return animation_player.get_animation("transition").length
