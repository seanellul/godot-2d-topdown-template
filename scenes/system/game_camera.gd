extends Camera2D

@export var target_player_id: = 0: ##If greater than 0, player with the specified id will be set as target.
	set(value):
		target_player_id = value
		target = null
@export var target: Node2D = null: ##The node to follow.
	set(value):
		target = value
		if name:
			print("%s target set to: %s" %[name, target])

func _ready() -> void:
	Globals.player_added_to_scene.connect(_try_to_set_player_target)
	Globals.transfer_complete.connect(_enable_camera)

func _physics_process(_delta: float) -> void:
	_follow_target()

func _enable_camera():
	position_smoothing_enabled = true

func _disable_camera():
	process_mode = PROCESS_MODE_DISABLED

func _try_to_set_player_target(_player: PlayerEntity):
	if not target and target_player_id > 0:
		var player: PlayerEntity = _player if _player.player_id == target_player_id else null
		if player:
			target = player
		
func _follow_target():
	if target and is_instance_valid(target):
		global_position = round(target.position)
