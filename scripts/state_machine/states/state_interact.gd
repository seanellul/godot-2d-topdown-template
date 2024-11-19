@icon("../icons/StateInteract.svg")
extends BaseState
##Handle entity interactions.
class_name StateInteract

@export var area: Area2D ## Interaction will trigger only if entity is inside the area.
@export var interaction_area: InteractionArea2D ## Interaction will trigger only if entity is inside the area.
@export var on_interaction: BaseState ## The state to enable on interaction.
@export var on_leaving: BaseState ## The state to enable on exiting the area.
@export var action_trigger := "" ## The input action that will trigger the interaction. Leave empty to trigger on area entered.
@export_category("Requirements")
@export_group("Direction")
@export_flags(
	Const.DIRECTION.DOWN,
	Const.DIRECTION.LEFT,
	Const.DIRECTION.RIGHT,
	Const.DIRECTION.UP
) var direction ## The direction the character must face to trigger the interaction.
@export var on_direction_wrong: BaseState ## State to enable when interacting with the wrong direction.
@export_group("Items")
@export var has_items: Array[ContentItem] ## Check if the items are present in the player's inventory.
@export var on_items_missing: BaseState ## State to enable when items are missing.
@export var remove_items := true ## Remove the required items after interaction.
@export_category("Settings")
@export var one_shot := true ## If true, it can be interacted only once. Useful for chests or pickable items.
@export var reset_delay := 0.5 ## Determines after how many seconds the interactable can be triggered again. It works only if one_shot is disabled.
@export_flags("Area:4", "Body:8", "Area and Body:12") var check = 4

var entity: CharacterEntity
var interacting := false

func _ready() -> void:
	if interaction_area:
		area = interaction_area.area
	if area:
		if check == 4 or check == 12:
				area.area_entered.connect(_set_entity)
				area.area_exited.connect(_reset_entity)
		if check == 8 or check == 12:
				area.body_entered.connect(_set_entity)
				area.body_exited.connect(_reset_entity)

func enter():
	_reset_interaction()
	if area:
		var areas: Array[Area2D] = area.get_overlapping_areas()
		for a in areas:
			_set_entity(a)

func exit():
	_reset_entity(null)

func _set_entity(_area):
	var parent = _area.get_parent()
	if parent is CharacterEntity:
		entity = parent
		_try_to_interact()

func _reset_entity(_area):
	if active and not interacting:
		_do_leaving()
	entity = null

func update(_delta):
	if not entity or action_trigger.is_empty():
		return
	if entity.input_enabled and Input.is_action_just_pressed(action_trigger):
		_try_to_interact()

func _try_to_interact():
	if _can_interact():
		_do_interaction()

func _can_interact() -> bool:
	if not is_instance_valid(entity) or interacting or not active:
		return false
	if not action_trigger.is_empty() and not Input.is_action_pressed(action_trigger):
		return false
	# Check if entity is facing the right direction
	var entity_dir = Const.DIR_BIT[entity.facing.floor()]
	if direction and direction > 0 and (direction & entity_dir) == 0:
		if on_direction_wrong:
			on_direction_wrong.enable()
		return false
	# If entity is player, checks inventory for the required items
	if entity is PlayerEntity and has_items.size() > 0:
		for content: ContentItem in has_items:
			if entity.is_item_in_inventory(content.item.resource_name, content.quantity) < 0:
				if on_items_missing:
					on_items_missing.enable()
				return false
	return true

func _do_interaction():
	interacting = true
	print(entity.name, " interacted with ", get_path())
	_check_inventory_item()
	if on_interaction:
		on_interaction.enable({
			"entity": entity
		})
	if !one_shot:
		_reset_interaction()

func _do_leaving():
	interacting = true
	if on_leaving:
		on_leaving.enable()
	if !one_shot:
		_reset_interaction()

func _check_inventory_item():
	if not has_items.size() > 0 and remove_items and entity.has_method("remove_item_from_inventory"):
		for content: ContentItem in has_items:
			entity.remove_item_from_inventory(content.item.resource_name, content.quantity)

func _reset_interaction():
	interacting = true
	await get_tree().create_timer(reset_delay).timeout
	interacting = false
