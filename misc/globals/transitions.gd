extends CanvasLayer


@onready var animation_player: AnimationPlayer = %AnimationPlayer
var transitioning: bool


func change_scene_to(path: String) -> void:
	if transitioning: return
	transitioning = true
	
	animation_player.play("transition_in")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(path)
	get_tree().paused = false
	animation_player.play("transition_out")
	
	transitioning = false
