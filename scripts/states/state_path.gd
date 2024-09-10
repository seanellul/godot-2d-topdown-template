extends StateEntity
class_name StatePath

@export var path: Path2D
@export var speed_multiplier: = 1.0

var distance_threshold: = 2.0

@onready var path_curve = path.curve
@onready var current_point_id: int = 0:
	set(value):
		var new_id = value
		if new_id == path_curve.point_count:
			new_id = 0
		elif new_id < 0:
			new_id = path_curve.point_count - 1
		current_point_id = new_id

func update(_delta: float):
	_check_point_reached()

func physics_update(_delta: float):
	var position = path_curve.get_point_position(current_point_id)
	entity.move_towards(position)

func _check_point_reached():
	var position = path_curve.get_point_position(current_point_id)
	var distance = entity.global_position.distance_to(position)
	if distance < distance_threshold:
		current_point_id += 1
