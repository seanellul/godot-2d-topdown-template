extends Node2D
class_name Level

@export var player_scene: PackedScene ##Used to instantiate N players, based on n_of_players defined in Globals.

var players: Array[PlayerEntity] ##All the players instantiated in the level.
var player_facing: Vector2 ##Used when moving between levels to save the player facing direction.
var destination_name: String ##Used when moving between levels to get the right destination position for the player in the loaded level.

@onready var n_of_players = Globals.n_of_players
@onready var entities_parent: Node2D = $Entities

func _ready() -> void:
	_init_players()
	_init_scene()

##internal - Used to instantiate N players in the level.
func _init_players():
	for n in range(n_of_players):
		var player: PlayerEntity = player_scene.instantiate() as PlayerEntity
		var player_id = n + 1
		player.player_id = player_id
		players.append(player)
		entities_parent.add_child(player)
		Globals.player_added_to_scene.emit(player)
		var p_pos = entities_parent.get_node_or_null("P%s" %[player_id])
		if player and p_pos:
			player.global_position = p_pos.global_position
			p_pos.queue_free()

##internal - Used by SceneManager to pass data between levels.
func get_data():
	return {
		"destination_name": destination_name, 
		"player_facing": players[0].facing
	}

##internal - Used by SceneManager to get data from the outgoing level.
func receive_data(data):
	destination_name = data.destination_name
	player_facing = data.player_facing

##internal - Used to initialize the level and set the player position.
func _init_scene():
	var destination = Globals.get_destination(destination_name)
	for player: PlayerEntity in players:
		if destination:
			if destination is Transfer:
				destination.set_player_facing(player, player_facing, destination.facing)
			player.position = destination.position
		elif DataManager.game_data and DataManager.game_data.player_data:
			player.position = DataManager.game_data.player_data[player.player_id].position

##internal - Called from SceneManager when the level is ready.
func start_scene():
	for player in players:
		player.disable_entity(false)
