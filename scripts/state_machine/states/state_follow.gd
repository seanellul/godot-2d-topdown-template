extends StateEntity
##Makes an entity follow a target.
class_name StateFollow

@export_category("Target")
@export var target_player_id: = 0: ##If greater than 0, player with the specified id will be set as target.
	set(value):
		target_player_id = value
		call_deferred("_init_target")
@export var target: Node2D = null: ##The node to follow.
	set(value):
		target = value
		if is_node_ready():
			if not flee:
				print("%s is following: %s" %[entity_name, target])
			else:
				print("%s is fleeing from: %s" %[entity_name, target])
@export_category("Settings")
@export var flee := false: ##If true, entity will flee away from the target instead of following it.
	set(value):
		flee = value
		if entity:
			entity.invert_moving_direction = value
@export var speed_multiplier: = 1.0
@export var friction_multiplier: = 1.0

func enter():
	super.enter()
	entity.invert_moving_direction = flee
	call_deferred("_init_target")

func exit():
	super.exit()
	entity.invert_moving_direction = false

func physics_update(_delta):
	_follow()

func _follow():
	if is_instance_valid(target) and entity:
		entity.move_towards(target.global_position, speed_multiplier, friction_multiplier)

func _init_target():
	await get_tree().physics_frame
	if target_player_id > 0:
		target = Globals.get_player(target_player_id)
	elif target:
		target = target
