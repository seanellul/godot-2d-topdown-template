extends Node2D
class_name Level

var player: PlayerEntity

var destination_path: String

func _enter_tree() -> void:
	Globals.player_ready.connect(_set_player)

func _ready() -> void:
	init_scene()

func _set_player(_player):
	player = _player

func get_data():
	return destination_path

func receive_data(_destination_path):
	destination_path = _destination_path
		
func init_scene():
	var destination = get_node_or_null(destination_path)
	if player:
		if destination:
			player.position = destination.position
		elif DataManager.game_data and DataManager.game_data.player_data:
			player.position = DataManager.game_data.player_data.position

func start_scene():
	if player:
		player.disable_entity(false)
	
