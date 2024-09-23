extends Node2D
class_name ChangeStateListener

@export var listen_to: Node2D ##Set a node with a StateMachine in its children.
@export var change_states: Dictionary[String, String]

@onready var state_machine: StateMachine = get_node_or_null("./StateMachine")

var sm: StateMachine

func _ready() -> void:
	if not state_machine:
		state_machine = get_node_or_null("../StateMachine")
	if listen_to:
		sm = listen_to.get_node_or_null("StateMachine")
	if sm:
		sm.state_changed.connect(_enable_states)

func _enable_states(_old_state, new_state):
	if change_states.has(new_state.name):
		var state = change_states[new_state.name]
		if not state.is_empty() and state_machine:
			state_machine.enable_state_by_name(state)
