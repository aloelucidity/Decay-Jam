class_name Screen
extends Control


@onready var animation_player = $AnimationPlayer

signal start_transition
signal screen_opened
signal screen_change(new_screen_name: String)


func transition(new_screen_name: String):
	emit_signal("start_transition")
	animation_player.play("transition")
	
	await animation_player.animation_finished

	emit_signal("screen_change", new_screen_name)


func get_transition_length() -> float:
	return animation_player.get_animation("transition").length
