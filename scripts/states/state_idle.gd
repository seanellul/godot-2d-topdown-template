extends StateEntity
##Stops an entity.
class_name StateIdle

func physics_update(_delta):
	idle()

func idle():
	if entity:
		entity.stop()
