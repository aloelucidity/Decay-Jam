class_name CoinArc
extends LevelObject


func _init(_level_generator: LevelGenerator) -> void:
	super(_level_generator)
	sample_width = 15


func build(sample: int) -> void:
	var index: int = 0
	
	var width: int = sample_width - 3
	while index < sample_width:
		var half_width := float(width) / 2
		var pos: float = pingpong(index, half_width) / half_width
		var arc: float = ease(pos, 0.5)
		
		var coin_obj: Area2D = preload("res://level/scenes/coin/coin.tscn").instantiate()
		coin_obj.position = get_sample_pos(sample + index)
		coin_obj.position.y -= 48
		coin_obj.position.y -= arc * 20
		add_child(coin_obj)
		
		index += 3
