extends CanvasLayer

@export_category("Texture")
@export var texture_under: TextureRect ##The texture to show under the main bar.
@export var texture_progress: TextureRect ##The texture to use to represent the hp value.

var value: = 0: ##The current value of the bar.
	set(new_value):
		value = new_value
		texture_progress.size.x = gap * new_value
		texture_progress.visible = value > 0
var max_value: = 0: ##The max value of the bar.
	set(new_value):
		max_value = new_value
		texture_under.size.x = gap * new_value
var entity: CharacterEntity = null ##The entity linked to this bar.

@onready var gap = texture_progress.size.x / 2

##Used to initialize the hp bar.
func init_hud(entity_ref: CharacterEntity):
	await self.ready
	entity = entity_ref
	max_value = entity.max_hp
	value = entity.hp
	entity.connect("hp_changed", _on_hp_changed)

func _on_hp_changed(hp):
	value = hp
