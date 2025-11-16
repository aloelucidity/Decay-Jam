extends Label


@export var target_node: Node
@export var prefix: String
@export var stat_to_track: String
@export var factor: float = 1


func _process(_delta: float) -> void:
	var stat: Variant = target_node[stat_to_track]
	if typeof(stat) == TYPE_FLOAT:
		stat = snappedf(stat / factor, 0.01)
	text = prefix + str(stat)
