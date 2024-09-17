extends StaticBody2D

@export var states: Array[BaseState]
@export var start_state_index := 0

@onready var interactable: Interactable = get_node("Interactable")

func _ready() -> void:
	if interactable:
		interactable.interacted.connect(switch_states)

func switch_states(_sender):
	var next_state
	start_state_index += 1
	if start_state_index < states.size():
		next_state = states[start_state_index]
	else:
		next_state = states[0]
		start_state_index = 0
	if next_state:
		next_state.enable()
