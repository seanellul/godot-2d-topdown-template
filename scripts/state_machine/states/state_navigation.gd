@icon("../icons/StateNavigation.svg")
extends StateEntity
##Makes an entity follow a target using navigation. Requires a NavigationAgent2D.
class_name StateNavigation

@export var navigation_agent: NavigationAgent2D
@export_category("Target")
@export var target_player_id := 0: ## If greater than 0, player with the specified id will be set as target.
	set(value):
		target_player_id = value
		_init_target.call_deferred()
@export var target: Node2D = null: ## The node to follow.
	set(value):
		target = value
		if is_node_ready():
				print("%s is following: %s" % [entity_name, target])

var go := false

func enter():
	super.enter()
	NavigationServer2D.map_changed.connect(func(_map): go = true)
	_init_target.call_deferred()
	_update_target.call_deferred()

func _init_target():
	await get_tree().physics_frame
	if target_player_id > 0:
		target = Globals.get_player(target_player_id)
	elif target:
		target = target

func _update_target():
	await get_tree().physics_frame
	if is_instance_valid(target):
		navigation_agent.target_position = target.global_position

func physics_update(_delta):
	_update_target()
	_follow()

func _follow():
	if !go:
		return
	if navigation_agent.is_navigation_finished():
		return
	if entity:
		var next_path_position = navigation_agent.get_next_path_position()
		entity.move_towards(next_path_position)
