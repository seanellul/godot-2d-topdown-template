extends StateEntity
##Applies an inpulse to an entity.
class_name StateImpulse

@export var impulse_force := 300.0
@export var impulse_duration := 0.1
@export var friction := 1000.0

func enter():
  entity.velocity += entity.facing * impulse_force
  await get_tree().create_timer(impulse_duration).timeout
  entity.velocity = entity.velocity.move_toward(Vector2.ZERO, friction * get_physics_process_delta_time())
