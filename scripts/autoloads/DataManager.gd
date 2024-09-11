# Takes care of loading or creating a new save game and provides appropriate
# resources to the user interface and the entity.
extends Node

# We always keep a reference to the SaveFileManager resource here to prevent it from unloading.
var game_data: SaveFileManager

signal game_saved
signal game_loaded

func _ready():
	SceneManager.scene_added.connect(_load_level_data)
	SceneManager.load_start.connect(_save_level_data)

func reset_game_data():
	game_data = SaveFileManager.new()

func load_game_data():
	game_data = SaveFileManager.load_save_file()

func _save_level_data(_loading_screen):
	#Used to save nodes state data of the level before removing the level
	_save_nodes_data()
	_save_player_data(true)

func _load_level_data(_loaded_scene, _loading_screen):
	#Used to load nodes state data of the level when entering the level
	await get_tree().create_timer(0.01).timeout
	_load_nodes_data()
	_load_player_data(true)

func load_game() -> void:
	print_debug("loading...")
	_load_nodes_data()
	_load_player_data(false)
	game_loaded.emit()

func save_game() -> void:
	print_debug("saving...")
	_save_nodes_data()
	_save_player_data(false)
	game_data.write_save_file()
	game_saved.emit()

func _load_nodes_data():
	for node: Node in _get_save_nodes():
		var path = String(node.get_path())
		if path not in game_data.nodes_data:
			game_data.nodes_data[path] = _get_node_data(node)
		if node.has_method("receive_data"):
			node.receive_data(game_data.nodes_data[path])

func _load_player_data(soft):
	var players = get_tree().get_nodes_in_group(Const.GROUP.PLAYER)
	for player in players:
		if player.has_method("receive_data") and game_data.player_data:
			player.receive_data(game_data.player_data[player.player_id], soft)

func _save_nodes_data():
	for node in _get_save_nodes():
		if node != null:
			var path = String(node.get_path())
			game_data.nodes_data[path] = _get_node_data(node)

func _save_player_data(soft):
	var players = get_tree().get_nodes_in_group(Const.GROUP.PLAYER)
	for player in players:
		if player.has_method("get_data"):
			game_data.player_data[player.player_id] = player.get_data(soft)

func _get_node_data(node):
	if node is CharacterEntity:
		return _get_entity_data(node)
	elif node is StateMachine:
		return _get_state_data(node)

func _get_entity_data(entity: CharacterEntity) -> DataEntity:
	var data := DataEntity.new()
	data.position = entity.global_position
	data.facing = entity.facing
	return data

func _get_state_data(state: StateMachine) -> DataState:
	var data := DataState.new()
	data.state_index = state.current_state.get_index()
	return data

func _get_save_nodes():
	var nodes: Array[Node] = get_tree().get_nodes_in_group(Const.GROUP.SAVE)
	return nodes
