extends Node

@export var anim_label: RichTextLabel
@export var info_label: RichTextLabel

var current_player_action = ""

func _ready():
	if not OS.is_debug_build():
		set_process_unhandled_key_input(false)
		print("DEBUGGER DISABLED.")
		return
	Globals.player_action.connect(_on_player_action)
	DataManager.game_saved.connect(_on_game_saved)
	DataManager.game_loaded.connect(_on_game_loaded)
	if info_label:
		info_label.draw.connect(_on_info_label_draw)

func _on_player_action(node, action, direction):
	if anim_label:
		anim_label.text = "%s: %s | %s" % [node.name, action, direction]

func _unhandled_key_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				DataManager.save_game()
			KEY_F2:
				DataManager.load_game()
			KEY_CTRL:
				_set_player_ghost()
			KEY_5:
				_stop_all_enemies()


func _set_player_ghost():
	var players = get_tree().get_nodes_in_group(Const.GROUP.PLAYER)
	for player in players:
		var coll: CollisionShape2D = player.get_node_or_null("CollisionShape2D")
		if coll:
			coll.disabled = !coll.disabled

func _stop_all_enemies():
	var enemies = get_tree().get_nodes_in_group(Const.GROUP.ENEMY)
	for enemy in enemies:
		if enemy.process_mode == Node.PROCESS_MODE_DISABLED:
			enemy.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			enemy.process_mode = Node.PROCESS_MODE_DISABLED

func _on_game_saved():
	if info_label:
		info_label.text = "Game saved!"

func _on_game_loaded():
	if info_label:
		info_label.text = "Game loaded!"

func _on_info_label_draw():
	await get_tree().create_timer(2.5).timeout
	info_label.text = ""
