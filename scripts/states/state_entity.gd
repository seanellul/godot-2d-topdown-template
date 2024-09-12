extends BaseState
##Base class for all entity states.
class_name StateEntity

@export var entity_player_id := 0 ##If greater than 0, player with the specified id will be set as entity.
@export var entity: CharacterEntity ##The entity to apply this state. If left empty and this state is child of a CharacterEntity, that entity will be taken.

var entity_name := ""

func enter() -> void:
	if not entity:
		entity = _try_to_get_entity(self)
	if entity:
		entity_name = entity.name

func _try_to_get_entity(node):
	if entity_player_id > 0:
		return Globals.get_player(entity_player_id)
	var parent = node.get_parent()
	if parent is CharacterEntity:
		return parent
	elif parent:
		return _try_to_get_entity(parent)
	else:
		return null
