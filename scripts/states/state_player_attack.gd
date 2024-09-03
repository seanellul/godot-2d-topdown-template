extends StateEntity

func enter():
  entity.velocity += entity.facing * entity.impulse_force
  await get_tree().create_timer(entity.impulse_duration).timeout
  entity.velocity = entity.velocity.move_toward(Vector2.ZERO, entity.attack_friction * get_physics_process_delta_time())
