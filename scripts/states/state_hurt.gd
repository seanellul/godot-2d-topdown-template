extends StateEntity
class_name StateHurt

@export var knockback_force := 200.0
@export var knockback_duration := 0.1
@export var immortal := false ##Set entity as immortal during hurt state.

func enter():
  super.enter()
  entity.is_hurting = true
  entity.immortal = immortal
  entity.knockback(knockback_force)
  await get_tree().create_timer(knockback_duration).timeout
  entity.stop()
  entity.reset()

func exit():
  entity.stop()
  entity.immortal = false
  entity.is_hurting = false
