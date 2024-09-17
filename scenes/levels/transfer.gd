@tool
extends Interactable
class_name Transfer

@export_category("Transfer settings")
@export var level_key: String  = "" ##Leave empty to transfer inside the same level.
@export var destination_path: String = ""
@export_category("Destination settings")
@export_enum(
	Const.DIRECTION.DOWN,
	Const.DIRECTION.LEFT,
	Const.DIRECTION.RIGHT,
	Const.DIRECTION.UP
) var facing ##Force player to face this direction upon arriving to this destination. Leave empty to keep the same facing direction.

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	SceneManager.load_start.connect(func(_loading_screen): Globals.transfer_start.emit())
	SceneManager.load_complete.connect(_complete_transfer)
	interacted.connect(transfer)

func _complete_transfer(_loaded_scene):
	Globals.transfer_complete.emit()
	process_mode = PROCESS_MODE_INHERIT

func transfer(_entity):
	if level_key:
		_transfer_to_level(_entity)
	elif destination_path and _entity:
		_transfer_to_position(_entity)

func _transfer_to_level(_entity):
	if GameManager.gm:
		GameManager.gm.current_level.destination_path = destination_path
		GameManager.gm.current_level.player_facing = entity.facing
		SceneManager.swap_scenes(
			Const.LEVEL[level_key],
			GameManager.gm.world,
			GameManager.gm.current_level,
			Const.TRANSITION.FADE_TO_BLACK
		)
	else:
		push_error("Level can be tested stand-alone, but transfer between levels requires a GameManager at the tree root.")

func _transfer_to_position(_entity):
	Globals.transfer_start.emit()
	var destination = owner.get_node_or_null(destination_path)
	if destination:
		set_player_position(entity, destination)
		if destination is Transfer:
			set_player_facing(entity, entity.facing, destination.facing)
	await get_tree().create_timer(0.5).timeout
	Globals.transfer_complete.emit()

func set_player_position(player, destination):
	if player and destination:
		player.position = destination.position

func set_player_facing(player, player_facing, facing_dir):
	var _facing = player_facing
	if facing_dir != null:
		_facing = Const.DIR_VECTOR[facing_dir]
	player.facing = _facing
