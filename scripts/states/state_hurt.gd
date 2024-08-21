extends StateEntity
class_name StateHurt

@export var knockback_force := 5.0
@export var knockback_time := 0.1

func enter():
  super.enter()
  entity.immortal = true
  entity.knockback(knockback_force)
  await get_tree().create_timer(knockback_time).timeout
  entity.stop()
  entity.reset()

func exit():
  entity.stop()
  entity.immortal = false
