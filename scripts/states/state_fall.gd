extends StateEntity

@export var damage := 0

func enter():
	super.enter()
	if entity:
		entity.return_to_safe_position()
		entity.reduce_hp(damage, self.name)
