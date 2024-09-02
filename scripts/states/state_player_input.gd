extends StateEntity
class_name StatePlayerInput

@export var walls_detector: RayCast3D

var input_dir: Vector2

func update(_delta):
	input_dir = Input.get_vector("left", "right", "up", "down")
	entity.is_running = entity.is_moving and Input.get_action_strength("run") > 0

func physics_update(delta):
	_handle_inputs(delta)

func _handle_inputs(delta):
	if Input.is_action_just_pressed("jump"):
		entity.is_jumping = true
	if Input.is_action_just_pressed("attack") and not entity.is_damaged:
		entity.is_charging = true
	if Input.is_action_just_released("attack") and entity.is_charging:
		entity.is_charging = false
		entity.start_attack(delta)
	entity.move(delta, input_dir)
