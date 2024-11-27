extends Node2D
class_name GameManager

@onready var world: Node2D = $World ##The parent node where levels will be instantiated.
@onready var debug_level: Node2D = get_tree().get_first_node_in_group(Const.GROUP.LEVEL)

var level_to_load

func _load_level():
	var loading = level_to_load != null
	if not level_to_load:
		level_to_load = Const.LEVEL.START_LEVEL
	if level_to_load and not debug_level:
		var level = load(level_to_load)
		world.add_child(level.instantiate())
		if loading:
			DataManager.load_game()

func receive_data(_current_level):
	level_to_load = _current_level

func init_scene():
	_load_level()
