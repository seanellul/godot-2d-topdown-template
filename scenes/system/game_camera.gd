extends Camera2D

@export var target_player_id := 0: ## If greater than 0, player with the specified id will be set as target.
	set(value):
		target_player_id = value
		target = null
@export var target: Node2D = null: ## The node to follow.
	set(value):
		target = value
		if is_node_ready():
			print("%s target set to: %s" % [name, target])

func _ready() -> void:
	Globals.player_added_to_scene.connect(_try_to_set_player_target)
	Globals.transfer_complete.connect(_enable_camera)

func _physics_process(_delta: float) -> void:
	_follow_target()

##internal - If player is moving between levels, camera will be enabled on transfer complete.
func _enable_camera():
	position_smoothing_enabled = true

##internal - Linked to the global signal player_added_to_scene, it will be called when a new player is added to the level.
func _try_to_set_player_target(_player: PlayerEntity):
	if not target and target_player_id > 0:
		var player: PlayerEntity = _player if _player.player_id == target_player_id else null
		if player:
			target = player
		
##internal - The method responsible for managing target following.
func _follow_target():
	if target and is_instance_valid(target):
		global_position = round(target.position)
