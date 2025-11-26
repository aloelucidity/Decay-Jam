extends Control


@onready var mouse_blocker: Control = %MouseBlocker
@export var level_path: String


func start_run() -> void:
	mouse_blocker.show()
	Transitions.change_scene_to(level_path)
