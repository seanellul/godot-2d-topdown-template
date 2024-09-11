extends BaseState
class_name StateEntity

var entity: CharacterEntity
var entity_name := ""

func _ready() -> void:
	entity = _try_to_get_entity(self)
	if entity:
		entity_name = entity.name

func _try_to_get_entity(node):
	var parent = node.get_parent()
	if parent is CharacterEntity:
		return parent
	elif parent:
		return _try_to_get_entity(parent)
	else:
		return null
