extends StateEntity
##Disables an entity.
class_name StateGameOver

func enter(_params = null):
  super.enter(_params)
  entity.disable_entity(true, 0.5)
