@icon("../icons/BaseState.svg")
extends StateEntity
##Base class for all states.
class_name StateNavigation

@export var navigation_agent: NavigationAgent2D
@export_category("Target")
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
@export var on_target_reached: BaseState

var is_target_reached := false

func enter():
	super.enter()
	navigation_agent.target_reached.connect(_on_target_reached)
	_init_target()
	call_deferred("_update_target")

func _update_target():
	await get_tree().physics_frame
	if is_instance_valid(target):
		navigation_agent.target_position = target.global_position

func physics_update(_delta):
	_update_target()
	_follow()

func _follow():
	if navigation_agent.is_navigation_finished():
		return
	if entity:
		var next_path_position = navigation_agent.get_next_path_position()
		entity.move_towards(next_path_position)

func _init_target():
	_reset_target_reached()
	if target_player_id > 0:
		target = Globals.get_player(target_player_id)
	elif target:
		target = target

func _on_target_reached():
	if is_target_reached:
		return
	is_target_reached = true
	if entity:
		entity.stop()
	if on_target_reached:
		on_target_reached.enable()
	complete()

func _reset_target_reached():
	if is_inside_tree():
		await get_tree().create_timer(0.5).timeout
	is_target_reached = false
