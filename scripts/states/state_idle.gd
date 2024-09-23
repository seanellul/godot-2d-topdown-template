extends StateEntity
##Stops an entity.
class_name StateIdle

func enter(_params = null):
	idle()

func idle():
	if entity:
		entity.stop()
