extends StateEntity

@export var damage := 0

func enter(_params = null):
	super.enter(_params)
	if entity:
		entity.return_to_safe_position()
		entity.reduce_hp(damage, self.name)
