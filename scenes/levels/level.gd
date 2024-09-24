extends Node2D
class_name Level

@export var entities: Node2D

var players: Array[PlayerEntity]
var player_facing: Vector2
var destination_name: String
var player_res = preload("res://entities/player/player.tscn")

@onready var n_of_players = GameManager.gm.n_of_players if GameManager.gm else 1

func _enter_tree() -> void:
	if GameManager.gm:
		print("Current level is: ", self.name)
		GameManager.gm.current_level = self

func _ready() -> void:
	_init_players()
	_init_scene()

func _init_players():
	for n in range(n_of_players):
		var player: PlayerEntity = player_res.instantiate() as PlayerEntity
		var player_id = n + 1
		player.player_id = player_id
		players.append(player)
		entities.add_child(player)
		Globals.player_added_to_scene.emit(player)
		var p_pos = entities.get_node_or_null("P%s" %[player_id])
		if player and p_pos:
			player.global_position = p_pos.global_position
			p_pos.queue_free()

func get_data():
	return {
		"destination_name": destination_name, 
		"player_facing": players[0].facing
	}

func receive_data(data):
	destination_name = data.destination_name
	player_facing = data.player_facing

func _init_scene():
	var destination = get_node_or_null("Transfers/%s" %[destination_name])
	for player: PlayerEntity in players:
		if destination and not destination_name.is_empty():
			if destination is Transfer:
				destination.set_player_facing(player, player_facing, destination.facing)
			player.position = destination.position
		elif DataManager.game_data and DataManager.game_data.player_data:
			player.position = DataManager.game_data.player_data[player.player_id].position

func start_scene():
	for player in players:
		player.disable_entity(false)
