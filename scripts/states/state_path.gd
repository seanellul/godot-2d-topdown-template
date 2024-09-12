extends StateEntity
##Makes an entity follow a path defined in a Path2D node.
class_name StatePath

@export var path: Path2D
@export var loop := false ##If true, after reaching the last point entity will go back to the first one and repeat the path.
@export var distance_threshold: = 2.0
@export var speed_multiplier: = 1.0
@export var friction_multiplier: = 1.0
@export_group("On path completed")
@export var enable_state_by_reference: BaseState ##State to enable when entity reaches the last point of the path.
@export var enable_state_by_name: String ##State name to enable when entity reaches the last point of the path.

@onready var path_curve = path.curve
@onready var current_point_id: int = 0:
	set(value):
		var new_id = value
		if new_id == path_curve.point_count:
			if loop:
				new_id = 0
			elif enable_state_by_reference:
				enable_state_by_reference.enable()
			elif enable_state_by_name and entity.state_machine:
				disable()
				entity.state_machine.enable_state_by_name(enable_state_by_name)
		elif new_id < 0:
			new_id = path_curve.point_count - 1
		current_point_id = new_id
		if current_point_id < path_curve.point_count:
			_set_target_position()

var target_position := Vector2.ZERO

func enter():
	super.enter()
	if entity is PlayerEntity:
		entity.start_auto_move()
	_set_target_position()

func update(_delta: float):
	_check_point_reached()

func _set_target_position():
	target_position = path_curve.get_point_position(current_point_id) + path.global_position

func physics_update(_delta: float):
	if not entity:
		return
	entity.move_towards(target_position)

func _check_point_reached():
	if not entity:
		return
	var distance = entity.global_position.distance_to(target_position)
	if distance < distance_threshold:
		current_point_id += 1
