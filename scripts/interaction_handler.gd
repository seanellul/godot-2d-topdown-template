@tool
extends Area2D
class_name InteractionHandler

var interactable: Interactable = null ## The object to interact with

func _init():
	monitoring = true
	monitorable = false
	collision_mask = 1 << 3 # set mask to layer "item"

func _enter_tree():
	if Engine.is_editor_hint():
		return
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Node2D):
	if area is Interactable:
		interactable = area
	elif area.get_parent() is Interactable:
		interactable = area.get_parent()
	if interactable and interactable.action_trigger.is_empty():
		interactable.interact(owner)

func _on_area_exited(_area: Area2D):
	interactable = null

func _unhandled_input(event):
	if interactable and not interactable.action_trigger.is_empty() and event.is_action_pressed(interactable.action_trigger):
		interactable.interact(owner)
