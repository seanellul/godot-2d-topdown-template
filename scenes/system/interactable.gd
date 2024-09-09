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
@export_group("Settings")
@export var one_shot := true ##If true, it can be interacted only once. Useful for chests or pickable items.
@export var action_trigger := "" ##The input action that will trigger the interaction. Leave empty to trigger on area entered.
@export_group("")
@export var on_interaction: BaseState ##The state to enable on interaction.

var entity: CharacterEntity
var interacting := false
var action_pressed = true

signal interacted(entity: CharacterEntity)

func _init() -> void:
	monitoring = false
	monitorable = true
	collision_layer = 1 << 3 # set layer to layer "item"

func _process(_delta: float) -> void:
	action_pressed = action_trigger.is_empty() or Input.is_action_pressed(action_trigger)

func interact(sender):
	if sender is CharacterEntity:
		entity = sender
	_on_interact(sender)

func _on_interact(sender):
	if _can_interact():
		interacting = true
		print_debug(sender.name, " interacted with ", self.name)
		if !one_shot:
			reset_interaction()
		do_interaction()

func _can_interact() -> bool:
	var can_interact = true
	if entity:
		var entity_dir = Const.DIR_BIT[entity.facing.floor()]
		can_interact = direction == null or direction > 0 and direction & entity_dir != 0
	return can_interact and !interacting and action_pressed

func do_interaction():
	interacted.emit(entity)
	if on_interaction:
		on_interaction.enable({
			"entity": entity
		})

func reset_interaction():
	await get_tree().create_timer(0.5).timeout
	interacting = false
