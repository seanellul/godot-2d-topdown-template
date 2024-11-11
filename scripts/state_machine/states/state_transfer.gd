@icon("../icons/StateTransfer.svg")
extends BaseState
##Transfers an entity to a different level or position.
class_name StateTransfer

@export_category("Destination settings")
@export var level_key: String  = "" ##Leave empty to transfer inside the same level.
@export var destination_name: String = "" ##The name of the destnation. NOTE: destination must be in the "destination" group.

func _ready() -> void:
	SceneManager.load_start.connect(func(_loading_screen): Globals.transfer_start.emit())
	SceneManager.load_complete.connect(_complete_transfer)

func _complete_transfer(_loaded_scene):
	Globals.transfer_complete.emit()
	process_mode = PROCESS_MODE_INHERIT

func enter():
	if state_machine.params.has("entity"):
		transfer(state_machine.params.get("entity"))

func transfer(entity):
	if level_key:
		_transfer_to_level(entity)
	elif destination_name and entity:
		_transfer_to_position(entity)

func _transfer_to_level(entity):
	var current_level = Globals.get_current_level()
	if current_level:
		current_level.destination_name = destination_name
		current_level.player_facing = entity.facing
		SceneManager.swap_scenes(
			Const.LEVEL[level_key],
			current_level.get_parent(),
			current_level,
			Const.TRANSITION.FADE_TO_BLACK
		)
	else:
		push_error("Level can be tested stand-alone, but transfer between levels requires a GameManager at the tree root.")

func _transfer_to_position(entity):
	Globals.transfer_start.emit()
	print_debug(owner.owner.name)
	print_debug(owner.get_parent().name)
	print_debug(state_machine.owner)
	print_debug(state_machine.get_parent())
	var destination = Globals.get_destination(destination_name)
	if destination:
		set_player_position(entity, destination)
		if destination is Destination:
			destination.set_player_facing(entity, entity.facing, destination.facing)
	else:
		push_warning("%s: destination %s not found!" %[get_path(), destination])
	await get_tree().create_timer(0.5).timeout
	Globals.transfer_complete.emit()

func set_player_position(player, destination):
	if player and destination:
		player.position = destination.position
