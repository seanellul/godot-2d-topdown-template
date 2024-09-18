extends StateEntity
##Makes an entity knockback.
class_name StateHurt

@export var knockback_force := 200.0
@export var knockback_duration := 0.1

func enter():
  super.enter()
  entity.knockback(knockback_force)
  await get_tree().create_timer(knockback_duration).timeout
  entity.stop()
  entity.reset()

func exit():
  super.exit()
  entity.stop()
