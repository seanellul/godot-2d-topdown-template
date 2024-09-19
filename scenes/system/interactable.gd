@tool
extends Area2D
class_name Interactable

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
var action_pressed = true

signal interacted(entity: CharacterEntity)

func _enter_tree() -> void:
	monitoring = false
	monitorable = true
	collision_layer = 1 << 3 # set layer to layer "item"
	z_index = -1
	var coll = CollisionShape2D.new()
	coll.debug_color = Color.YELLOW
	add_child(coll)
	coll.owner = get_tree().edited_scene_root

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	action_pressed = action_trigger.is_empty() or Input.is_action_pressed(action_trigger)

func enable():
	if Engine.is_editor_hint():
		return
	process_mode = PROCESS_MODE_INHERIT

func disable():
	if Engine.is_editor_hint():
		return
	process_mode = PROCESS_MODE_DISABLED

func interact(sender):
	if sender is CharacterEntity:
		entity = sender
	_on_interact(sender)

func _on_interact(sender):
	if _can_interact():
		interacting = true
		print(sender.name, " interacted with ", get_parent().name)
		if !one_shot:
			_reset_interaction()
		_do_interaction()

func _can_interact() -> bool: # Check constraints
	var can_interact = true
	if entity:
		var entity_dir = Const.DIR_BIT[entity.facing.floor()]
		can_interact = direction == null or direction > 0 and direction & entity_dir != 0
		if can_interact and entity is PlayerEntity:
			can_interact = has_item.is_empty() or entity.is_item_in_inventory(has_item) >= 0
	return can_interact and !interacting and action_pressed and is_processing()

func _do_interaction():
	interacted.emit(entity)
	if not has_item.is_empty() and entity and entity is PlayerEntity:
		entity.remove_item_from_inventory(has_item, 1)

func _reset_interaction():
	await get_tree().create_timer(reset_delay).timeout
	interacting = false
