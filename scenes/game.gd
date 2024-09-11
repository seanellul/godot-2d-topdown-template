extends Node2D
class_name GameManager

@export var n_of_players := 1

@onready var world: Node2D = $World
@onready var debug_level: Node2D = get_tree().get_first_node_in_group(Const.GROUP.LEVEL)

static var gm: GameManager = self

var level_to_load
var current_level: Level

func _ready() -> void:
	gm = self

func _load_level():
	var loading = level_to_load != null
	if not level_to_load:
		level_to_load = Const.LEVEL.LEVEL_1
	if level_to_load and not debug_level:
		var level = load(level_to_load)
		world.add_child(level.instantiate())
		if loading:
			DataManager.load_game()
	current_level = world.get_child(0)

func receive_data(_current_level):
	level_to_load = _current_level

func init_scene():
	_load_level()
