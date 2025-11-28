extends MarginContainer


@export var current_tab: Control


func change_tab(tab_name: String):
	current_tab.hide()
	var tab: Control = get_node(tab_name)
	
	var animation_player: AnimationPlayer = tab.get_node("AnimationPlayer")
	animation_player.play("transition")
	tab.show()
	current_tab = tab
