extends Node2D
class_name Transfer

@export var interactable: Interactable ##Assign an interactable to trigger the transfer on interaction.
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
	SceneManager.load_start.connect(func(_loading_screen): Globals.transfer_start.emit())
	SceneManager.load_complete.connect(_complete_transfer)
	if interactable:
		interactable.interacted.connect(transfer)

func _complete_transfer(_loaded_scene):
	Globals.transfer_complete.emit()
	process_mode = PROCESS_MODE_INHERIT

func transfer(entity):
	if level_key:
		_transfer_to_level(entity)
	elif destination_path and entity:
		_transfer_to_position(entity)

func _transfer_to_level(entity):
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

func _transfer_to_position(entity):
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

func disable():
	process_mode = PROCESS_MODE_DISABLED
