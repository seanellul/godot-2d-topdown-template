extends StateEntity
##Makes an entity follow a target.
class_name StateFollow

@export var target_player_id: = 0: ##If greater than 0, player with the specified id will be set as target.
	set(value):
		target_player_id = value
		_init_target()
@export var target: Node2D = null: ##The node to follow.
	set(value):
		target = value
		_reset_target_reached()
		if is_node_ready():
			print("%s is following: %s" %[entity_name, target])
@export var distance_threshold: = 21.0
@export var on_target_reached: BaseState
@export var speed_multiplier: = 1.0
@export var friction_multiplier: = 1.0

var is_target_reached := false

signal target_reached(target)

func enter():
	super.enter()
	target_reached.connect(_on_target_reached)
	_init_target()

func exit():
	target_reached.disconnect(_on_target_reached)

func update(_delta):
	_check_target_reached()

func physics_update(_delta):
	_follow()

func _follow():
	if target and entity:
		entity.move_towards(target.global_position, speed_multiplier, friction_multiplier)

func _init_target():
	# if not current:
		# return
	_reset_target_reached()
	if target_player_id > 0:
		target = Globals.get_player(target_player_id)
	elif target:
		target = target

func _check_target_reached():
	if !is_target_reached and target:
		var distance = entity.global_position.distance_to(target.position)
		is_target_reached = distance < distance_threshold
		if is_target_reached:
			target_reached.emit(target)

func _reset_target_reached():
	if is_inside_tree():
		await get_tree().create_timer(0.5).timeout
	is_target_reached = false

func _on_target_reached(_target):
	if entity and on_target_reached:
		entity.stop()
		on_target_reached.enable()
