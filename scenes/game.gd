extends Node2D

@onready var world: Node2D = $World

@onready var debug_level: Node2D = get_tree().get_first_node_in_group("level")

var level_to_load

func _load_level():
	level_to_load = level_to_load if level_to_load else Const.LEVEL.LEVEL_1
	if level_to_load and not debug_level:
		var level = load(level_to_load)
		world.add_child(level.instantiate())

func receive_data(current_level):
	level_to_load = current_level

func init_scene():
	_load_level()
