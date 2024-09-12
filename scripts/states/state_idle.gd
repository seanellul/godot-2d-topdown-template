extends StateEntity
##Stops an entity.
class_name StateIdle

func enter():
	idle()

func idle():
	if entity:
		entity.stop()
