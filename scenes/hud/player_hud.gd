extends CanvasLayer

@export_category("Texture")
@export var tex_under: TextureRect
@export var tex_progress: TextureRect

var value: = 0:
	set(new_value):
		value = new_value
		tex_progress.size.x = gap * new_value
		tex_progress.visible = value > 0
var max_value: = 0:
	set(new_value):
		max_value = new_value
		tex_under.size.x = gap * new_value

@onready var gap = tex_progress.size.x / 2

var entity: CharacterEntity = null

func init_hud(entity_ref: CharacterEntity):
	await self.ready
	entity = entity_ref
	max_value = entity.max_hp
	value = entity.hp
	entity.connect("hp_changed", _on_hp_changed)

func _on_hp_changed(hp):
	value = hp
