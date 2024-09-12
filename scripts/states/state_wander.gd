extends StateEntity
##Makes an entity wander around randomly.
class_name StateWander

@export var wander_time_range: = Vector2.ZERO ##Min (x) and max (y) range time values.
@export var speed_multiplier: = 1.0

var wander_time: float
var direction = Vector2.ZERO

func enter():
	super.enter()
	_randomize_wander()

func update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		_randomize_wander()

func physics_update(_delta: float):
	entity.move(direction, speed_multiplier)

func _randomize_wander():
	direction = Vector2(randf_range(-1, 1), randf_range(-1 , 1)).normalized()
	wander_time = randf_range(wander_time_range.x, wander_time_range.y)
