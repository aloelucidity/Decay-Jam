extends Control


@export_file_path var shop_path: String


func run_story_mode() -> void:
	Transitions.change_scene_to(shop_path)
