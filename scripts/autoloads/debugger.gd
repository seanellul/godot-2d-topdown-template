extends Node

func _ready():
	if not OS.is_debug_build():
		set_process_unhandled_key_input(false)
		print("DEBUGGER DISABLED.")
		return

func _unhandled_key_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				DataManager.save_game()
			KEY_F2:
				DataManager.load_game()
			KEY_CTRL:
				_set_player_ghost()
			KEY_0:
				_reset_player_velocity()
			KEY_3:
				_restore_player_health()
			KEY_5:
				_stop_all_enemies()

func _set_player_ghost():
	for player in _get_players():
		var coll: CollisionShape2D = player.get_node_or_null("CollisionShape2D")
		if coll:
			coll.disabled = !coll.disabled

func _restore_player_health():
	for player in _get_players():
		player.recover_hp(100)

func _reset_player_velocity():
	for player in _get_players():
		player.velocity = Vector2.ZERO

func _stop_all_enemies():
	var enemies = get_tree().get_nodes_in_group(Const.GROUP.ENEMY)
	for enemy in enemies:
		if enemy.process_mode == Node.PROCESS_MODE_DISABLED:
			enemy.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			enemy.process_mode = Node.PROCESS_MODE_DISABLED

func _get_players():
	return get_tree().get_nodes_in_group(Const.GROUP.PLAYER)
