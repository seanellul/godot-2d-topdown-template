extends Camera2D

@export var target_is_player: = false:
	set(value):
		target_is_player = value
		target = null
@export var target: Node2D = null: ##A Node to be followed by this entity.
	set(value):
		target = value
		print("%s target set to: %s" %[name, target.name if target else "null"])

func _ready() -> void:
	Globals.transfer_complete.connect(_enable_camera)

func _physics_process(_delta: float) -> void:
	if not target:
		_set_player_target()
	else:
		_follow_target()

func _disable_camera():
	position_smoothing_enabled = false

func _enable_camera():
	position_smoothing_enabled = true

func _set_player_target():
	if target_is_player:
		var player: PlayerEntity = get_tree().get_first_node_in_group(Const.GROUP.PLAYER)
		if player:
			target = player
		
func _follow_target():
	global_position = round(target.position)
