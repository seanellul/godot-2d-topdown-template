extends StateEntity
##Disables an entity.
class_name StateGameOver

func enter():
  super.enter()
  entity.is_hurting = true
  entity.disable_entity(true, 0.5)
