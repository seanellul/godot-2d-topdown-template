extends Node
##Trigger a StateMachine on interaction.

@onready var state_machine: StateMachine = get_node_or_null("StateMachine")
@onready var interactable: Interactable = get_node_or_null("Interactable")

func _ready() -> void:
	if interactable:
		interactable.interacted.connect(_handle_interaction)

func _handle_interaction(entity):
	if state_machine:
		state_machine.enable_next_state({
			"entity": entity
		})
	
