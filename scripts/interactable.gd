@tool
extends Node2D
class_name Interactable

@export_group("Constraints")
@export_flags(
	Const.DIRECTION.DOWN, 
	Const.DIRECTION.LEFT, 
	Const.DIRECTION.RIGHT, 
	Const.DIRECTION.UP
) var direction ## The direction the character must face to trigger the interaction.
@export_group("Settings")
@export var one_shot := true ## If true, it can be interacted only once. Useful for chests or pickable items.
@export var action_trigger := "" ## The input action that will trigger the interaction. Leave empty to trigger on area entered.

var entity: CharacterEntity
var interacting := false

func _enter_tree():
	child_order_changed.connect(update_configuration_warnings)

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
	var can_interact := true
	if entity:
		var entity_dir = Const.DIR_BIT[entity.facing]
		can_interact = direction == null or direction > 0 and direction & entity_dir != 0
	return can_interact and !interacting

func do_interaction():
	pass

func reset_interaction():
	await get_tree().create_timer(1).timeout
	interacting = false

func _get_configuration_warnings():
	var warnings: PackedStringArray = []
	var area = null
	for c in get_children():
		if c is Area2D:
			area = c
			break
	if area == null:
		warnings.append("Interactable needs an %s node to work.\nConsider adding an %s node with 'monitoring' off and 'monitorable' on." % ["Area2D"])
	return warnings
