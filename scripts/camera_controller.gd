extends Camera2D
class_name CameraController

@export_group("Settings")
@export var target: Node2D = null
@export var smooth_factor = 5.0
@export var target_player := true

var init := false

@onready var saved_smooth_factor = smooth_factor

func _ready():
	if target_player:
		target = get_tree().get_first_node_in_group(Const.GROUP.PLAYER)
	if not target or init:
		return
	smooth_factor = 1
	_follow_target(0.1)
	init = true
	smooth_factor = saved_smooth_factor

func _process(delta):
	if not target or !init:
		return
	_follow_target(delta)

func _follow_target(delta):
	var target_position = target.global_position
	var current_position = global_position
	# Extract and update x and y positions
	var new_x = lerp(current_position.x, target_position.x, smooth_factor * delta)
	var new_y = lerp(current_position.y, target_position.y, smooth_factor * delta)
	# Create new position with updated x and y
	var new_position = Vector2(new_x, new_y)
	global_position = new_position
