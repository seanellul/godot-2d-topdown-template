# Takes care of loading or creating a new save game and provides appropriate
# resources to the user interface and the entity.
extends Node

# We always keep a reference to the SaveFileManager resource here to prevent it from unloading.
var game_data: SaveFileManager

signal game_saved
signal game_loaded

func _ready():
	create_or_load_file()
	SceneManager.scene_added.connect(_load_level_data)

func create_or_load_file() -> void:
	if SaveFileManager.save_file_exists():
		game_data = SaveFileManager.load_save_file()
	else:
		game_data = SaveFileManager.new()
		save_game()
	# After creating or loading a save resource, we need to dispatch its data to the various nodes that need it.
	#_load_game()

func _load_level_data(_loaded_scene:Node, _loading_screen):
	await get_tree().create_timer(0.1).timeout
	_load_nodes_data()

func load_game() -> void:
	print_debug("loading...")
	_load_nodes_data()
	_load_player_data()
	game_loaded.emit()

func save_game() -> void:
	print_debug("saving...")
	_save_nodes_data()
	_save_player_data()
	game_data.write_save_file()
	game_saved.emit()

func _load_nodes_data():
	for node: Node in _get_save_nodes():
		var path = String(node.get_path())
		if path not in game_data.nodes_data:
			game_data.nodes_data[path] = _get_node_data(node)
		if node.has_method("receive_data"):
			node.receive_data(game_data.nodes_data[path])

func _load_player_data():
	var player: PlayerEntity = get_tree().get_first_node_in_group("player")
	if player and player.has_method("receive_data"):
		player.receive_data(game_data.player_data)

func _save_nodes_data():
	for node in _get_save_nodes():
		if node != null:
			var path = String(node.get_path())
			game_data.nodes_data[path] = _get_node_data(node)

func _save_player_data():
	var player: PlayerEntity = get_tree().get_first_node_in_group("player")
	if player and player.has_method("get_data"):
		game_data.player_data = player.get_data()

func _get_node_data(node):
	if node is CharacterEntity:
		return _get_entity_data(node)
	elif node is StateMachine:
		return _get_state_data(node)

func _get_entity_data(entity: CharacterEntity) -> DataEntity:
	var target: NodePath = ""
	var data := DataEntity.new()
	data.position = entity.global_position
	data.facing = entity.facing
	data.target = entity.target.get_path() if entity.target else target
	return data

func _get_state_data(state: StateMachine) -> DataState:
	var data := DataState.new()
	data.state_index = state.current_state.get_index()
	return data

func _get_save_nodes():
	var nodes: Array[Node] = get_tree().get_nodes_in_group(Const.GROUP.SAVE)
	return nodes
