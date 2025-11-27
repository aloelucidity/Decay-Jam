extends HBoxContainer


func change_control_mode(is_controller: bool) -> void:
	for child: KeybindUI in find_children("*", "KeybindUI"):
		child.change_controller_mode(is_controller)
