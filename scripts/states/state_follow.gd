extends StateEntity
class_name StateFollow

@export var distance_threshold: = 1.0
@export var slow_radius_size: = 2.0 ## It's multiplied by the distance_threshold
@export var mass := 10.0
@export var on_target_reached: BaseState

var target: Node2D = null

func _ready():
	entity.target_changed.connect(_on_target_changed)
	entity.target_reached.connect(_on_target_reached)

func physics_update(_delta):
	follow()

func follow():
	if !target:
		return
	var target_pos = target.position
	target_pos.y += offset_y
	var direction = entity.position.direction_to(target_pos)
	if target is CharacterBody2D and !target.is_on_floor():
		direction.y = 0
	entity.velocity = Steering.arrive_to(
		entity.velocity,
		entity.position,
		target_pos,
		entity.max_speed,
		distance_threshold * slow_radius_size,
		distance_threshold,
		mass
	)

func _on_target_changed(new_target):
	target = new_target

func _on_target_reached(_target):
	if on_target_reached:
		entity.stop()
		on_target_reached.enable()
