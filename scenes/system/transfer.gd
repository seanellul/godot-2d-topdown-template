@icon("res://icons/Transfer.svg")
extends Node2D
##Transfers an entity to a different level or position.
class_name Transfer

@export_category("Destination settings")
@export_file("*.tscn") var level_path = "" ## Leave empty to transfer inside the same level.
@export var destination_name: String = "" ## The name of the destnation. NOTE: destination must be in the "destination" group.
##Force the player to face this direction upon arriving to this destination. [br]
##Leave empty to keep the same facing direction.
@export_enum(
	Const.DIRECTION.DOWN,
	Const.DIRECTION.LEFT,
	Const.DIRECTION.RIGHT,
	Const.DIRECTION.UP
) var facing

func _ready() -> void:
	SceneManager.load_start.connect(func(_loading_screen): Globals.transfer_start.emit())
	SceneManager.load_complete.connect(_complete_transfer)

func _complete_transfer(_loaded_scene):
	Globals.transfer_complete.emit()
	process_mode = PROCESS_MODE_INHERIT

func transfer(params):
	var entity: CharacterEntity = params["entity"]
	if entity and level_path:
		_transfer_to_level(entity, level_path)
	elif entity and destination_name:
		_transfer_to_position(entity)

func _transfer_to_level(entity, scene_to_load):
	var current_level = Globals.get_current_level()
	if current_level:
		current_level.destination_name = destination_name
		current_level.player_facing = entity.facing
		SceneManager.swap_scenes(
			scene_to_load,
			current_level.get_parent(),
			current_level,
			Const.TRANSITION.FADE_TO_BLACK
		)

func _transfer_to_position(entity):
	Globals.transfer_start.emit()
	var destination = Globals.get_destination(destination_name)
	if destination:
		set_player_position(entity, destination)
		if destination is Transfer:
			destination.set_player_facing(entity, entity.facing, destination.facing)
	else:
		push_warning("%s: destination %s not found!" % [get_path(), destination])
	await get_tree().create_timer(0.5).timeout
	Globals.transfer_complete.emit()

func set_player_position(player, destination):
	if player and destination:
		player.position = destination.position

##Used to set the facing direction.
func set_player_facing(player, player_facing, facing_dir):
	var _facing = player_facing
	if facing_dir != null:
		_facing = Const.DIR_VECTOR[facing_dir]
	player.facing = _facing
