extends Node2D


@export var intermission_path: String


func end_run() -> void:
	get_tree().change_scene_to_file(intermission_path)
