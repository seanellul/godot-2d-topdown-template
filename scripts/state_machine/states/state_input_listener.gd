extends StateEntity
##Moves and controls an entity through inputs.
class_name StateInputListener

@export var run_speed_increment := 1.5

var input_dir: Vector2

func physics_update(_delta):
	if entity and entity.input_enabled:
		_handle_inputs()

func _handle_inputs():
	input_dir = Input.get_vector("left", "right", "up", "down")
	if Input.is_action_just_pressed("jump"):
		entity.jump()
	# if Input.is_action_just_pressed("attack") and not entity.is_hurting:
	# 	entity.is_charging = true
	# if Input.is_action_just_released("attack") and entity.is_charging:
	# 	entity.is_charging = false
	if Input.is_action_just_pressed("attack"):
		entity.attack()
	var speed_increment = run_speed_increment if Input.get_action_strength("run") > 0 else 1.0 
	entity.move(input_dir, speed_increment)
