extends Node2D
class_name Level

var player: PlayerEntity
var player_facing: Vector2
var destination_path: String

func _enter_tree() -> void:
	Globals.player_ready.connect(_set_player)

func _ready() -> void:
	init_scene()

func _set_player(_player):
	player = _player
	player_facing = player.facing

func get_data():
	return destination_path

func receive_data(_destination_path):
	destination_path = _destination_path
		
func init_scene():
	var destination = get_node_or_null(destination_path)
	if player:
		if destination:
			player.position = destination.position
		if destination is Transfer:
			destination.set_player_facing(player, player_facing, destination.facing)
		elif DataManager.game_data and DataManager.game_data.player_data:
			player.position = DataManager.game_data.player_data[1].position

func start_scene():
	if player:
		player.disable_entity(false)
