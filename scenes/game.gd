extends Node2D
class_name GameManager

@onready var world: Node2D = $World

@onready var debug_level: Node2D = get_tree().get_first_node_in_group(Const.GROUP.LEVEL)

static var gm: GameManager = self

var level_to_load
var current_level: Level

func _ready() -> void:
	gm = self
	SceneManager.load_complete.connect(_on_level_loaded)

func _load_level():
	if not level_to_load:
		level_to_load = Const.LEVEL.LEVEL_1
	if level_to_load and not debug_level:
		var level = load(level_to_load)
		world.add_child(level.instantiate())
	current_level = world.get_child(0)

func _on_level_loaded(level: Node2D):
	if level is Level:
		current_level = level

func receive_data(_current_level):
	level_to_load = _current_level

func init_scene():
	_load_level()
