class_name CoinLine
extends LevelObject


func _init(_level_generator: LevelGenerator) -> void:
	super(_level_generator)
	sample_width = 15


func build(sample: int) -> void:
	var index: int = 0
	
	while index < sample_width:
		var coin_obj: Area2D = preload("res://level/scenes/coin/coin.tscn").instantiate()
		coin_obj.position = get_sample_pos(sample + index)
		coin_obj.position.y -= 16
		add_child(coin_obj)
		
		index += 3
