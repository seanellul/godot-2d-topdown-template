extends BaseState

@export var level_key: String  = "" ##Leave empty to transfer inside the same level
@export var destination_path: String = ""

func _ready() -> void:
	SceneManager.load_start.connect(func(_loading_screen): Globals.transfer_start.emit())
	SceneManager.load_complete.connect(func(_loaded_scene): Globals.transfer_complete.emit())

func enter():
	if level_key:
		_transfer_to_level()
	elif destination_path and params:
		_transfer_to_position()

func _transfer_to_level():
	GameManager.gm.current_level.destination_path = destination_path
	SceneManager.swap_scenes(
		Const.LEVEL[level_key],
		GameManager.gm.world,
		GameManager.gm.current_level,
		Const.TRANSITION.FADE_TO_BLACK
	)

func _transfer_to_position():
	Globals.transfer_start.emit()
	var entity: CharacterEntity = params.entity
	var destination = GameManager.gm.current_level.get_node_or_null(destination_path) if GameManager.gm else null
	if entity and destination:
		entity.position = destination.position
	await get_tree().create_timer(0.5).timeout
	Globals.transfer_complete.emit()
