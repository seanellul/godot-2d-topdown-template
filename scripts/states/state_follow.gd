extends StateEntity
class_name StateFollow

@export var on_target_reached: BaseState
@export var speed_multiplier: = 1.0

func enter():
	entity.target_reached.connect(_on_target_reached)

func exit():
	entity.target_reached.disconnect(_on_target_reached)
	

func physics_update(_delta):
	_follow()

func _follow():
	entity.move_towards_target(speed_multiplier)

func _on_target_reached(_target):
	if on_target_reached:
		entity.stop()
		on_target_reached.enable()
