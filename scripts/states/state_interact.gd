extends BaseState
##Handle entity interactions.
class_name StateInteraction

@export var area: Area2D ##Interaction will trigger only if entity is inside the area.
@export var on_interaction: BaseState ##The state to enable on interaction.
@export_group("Constraints")
@export_flags(
	Const.DIRECTION.DOWN, 
	Const.DIRECTION.LEFT, 
	Const.DIRECTION.RIGHT, 
	Const.DIRECTION.UP
) var direction ##The direction the character must face to trigger the interaction.
@export var action_trigger := "" ##The input action that will trigger the interaction. Leave empty to trigger on area entered.
@export var has_item := "" ##Check if the item is present in the player's inventory.
@export_group("Settings")
@export var one_shot := true ##If true, it can be interacted only once. Useful for chests or pickable items.
@export var reset_delay := 0.5 ##Determines after how many seconds the interactable can be triggered again. It works only if one_shot is disabled.

var entity: CharacterEntity
var interacting := false

func enter(params = null):
	if area:
		area.area_entered.connect(_set_entity)
		area.area_exited.connect(_reset_entity)
	if params.has("entity"):
		entity = params["entity"]

func exit():
	if area:
		area.area_entered.disconnect(_set_entity)
		area.area_exited.disconnect(_reset_entity)
	entity = null

func _set_entity(_area):
	var parent = _area.get_parent()
	if parent is CharacterEntity:
		entity = parent
		if action_trigger.is_empty():
			_try_to_interact()

func _reset_entity(_area):
	entity = null

func update(_delta):
	if not entity or action_trigger.is_empty():
		return
	if Input.is_action_just_pressed(action_trigger):
		_try_to_interact()

func _try_to_interact():
	if _can_interact():
		_do_interaction()

func _can_interact() -> bool:
	if not entity or interacting:
		return false
	# Check if entity is facing the correct direction
	var entity_dir = Const.DIR_BIT[entity.facing.floor()]
	if direction and direction > 0 and (direction & entity_dir) == 0:
		return false
	# If entity is a player, check inventory for the required item
	if entity is PlayerEntity and has_item and not has_item.is_empty():
		if entity.is_item_in_inventory(has_item) < 0:
			return false
	return true

func _do_interaction():
	interacting = true
	print(entity.name, " interacted with ", get_path())
	if !one_shot:
		_reset_interaction()
	if on_interaction:
		on_interaction.enable({
			"entity": entity
		})
	_check_inventory_item()

func _check_inventory_item():
	if not has_item.is_empty() and entity.has_method("remove_item_from_inventory"):
		entity.remove_item_from_inventory(has_item, 1)

func _reset_interaction():
	await get_tree().create_timer(reset_delay).timeout
	interacting = false
