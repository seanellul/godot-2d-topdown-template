extends StateEntity
class_name StateWander

@export var wander_time_range: = Vector2.ZERO ## Min (x) and max (y) range time values
@export var speed_multiplier: = 1.0

var wander_time: float

func randomize_wander():
	entity.facing = Vector2(randf_range(-1, 1), randf_range(-1 , 1)).normalized()
	wander_time = randf_range(wander_time_range.x, wander_time_range.y)

func enter():
	super.enter()
	randomize_wander()

func update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()

func physics_update(_delta: float):
	var direction = entity.facing * entity.max_speed * speed_multiplier
	var target_velocity = Vector2(direction.x, direction.y)
	entity.velocity = target_velocity
