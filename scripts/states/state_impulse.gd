extends StateEntity
##Applies an inpulse to an entity.
class_name StateImpulse

@export var impulse_force := 300.0
@export var impulse_duration := 0.1

func enter(_params = null):
  super.enter(_params)
  entity.add_impulse(impulse_force)
  await get_tree().create_timer(impulse_duration).timeout
  entity.stop(true)
  entity.reset_values()
  complete()

func exit():
  super.exit()
  entity.stop()