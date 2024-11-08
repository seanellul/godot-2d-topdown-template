@icon("../icons/Listener.svg")
extends Node2D
class_name ChangeStateListener

@export var listen_to: Node2D ##The node should have a StateMachine in its children.
@export var change_states: Dictionary[String, String]

var listening_state_machine: StateMachine
var listened_state_machine: StateMachine

func _enter_tree() -> void:
	Globals.state_machine_initialized.connect(_set_state_machines)

func _ready() -> void:
	if listened_state_machine:
		listened_state_machine.state_changed.connect(_enable_states)

func _set_state_machines(_state_machine: StateMachine):
	var sm_parent_name = _state_machine.get_parent().name
	if sm_parent_name == listen_to.name:
		listened_state_machine = _state_machine
	elif sm_parent_name == get_parent().name:
		listening_state_machine = _state_machine

func _enable_states(_old_state, new_state):
	if change_states.has(new_state.name):
		var state = change_states[new_state.name]
		if not state.is_empty() and listening_state_machine:
			listening_state_machine.enable_state_by_name(state)