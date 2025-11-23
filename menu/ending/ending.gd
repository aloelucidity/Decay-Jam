extends AutoResizer


@export_file_path var intermission_path: String
@export_file_path var title_path: String
@onready var mouse_blocker: Control = %MouseBlocker


func to_intermission():
	Globals.day += 1
	Transitions.change_scene_to(intermission_path)
	mouse_blocker.show()


func to_title():
	Globals.reset()
	Transitions.change_scene_to(title_path)
	mouse_blocker.show()
