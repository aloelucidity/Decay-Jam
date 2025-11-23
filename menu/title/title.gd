extends AutoResizer


@export_file_path var intermission_path: String
@onready var mouse_blocker: Control = %MouseBlocker


func start_game() -> void:
	Transitions.change_scene_to(intermission_path)
	mouse_blocker.show()
