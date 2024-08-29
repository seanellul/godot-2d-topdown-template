extends Node2D
class_name GameManager

@onready var world: Node2D = $World

@onready var debug_level: Node2D = get_tree().get_first_node_in_group("level")

static var gm: GameManager = self

var level_to_load
var current_level

func _ready() -> void:
	gm = self
	SceneManager.load_complete.connect(_on_level_loaded)

func _load_level():
	level_to_load = level_to_load if level_to_load else Const.LEVEL.LEVEL_1
	if level_to_load and not debug_level:
		var level = load(level_to_load)
		world.add_child(level.instantiate())
	current_level = world.get_child(0)

func _on_level_loaded(level: Node2D):
	if level.is_in_group(Const.GROUP.LEVEL):
		current_level = level

func receive_data(current_level):
	level_to_load = current_level

func init_scene():
	_load_level()
