extends Node
##Main controller for the states. States should be placed as children of a StateMachine node.
class_name StateMachine

@export var current_state: BaseState = null

var previous_state: BaseState = null
var states: Array[BaseState]

func _ready():
	await owner.ready
	_init_states()
	_get_states()
	_enter_states()

func _init_states():
	for state in get_children(true):
		state.state_changed.connect(_on_state_changed)
		state.state_disabled.connect(_on_state_disabled)

func _get_states():
	if !current_state or current_state and !current_state.active:
		return
	states = []
	states.append(current_state)
	for child in current_state.get_children():
		if child is BaseState and child.active:
			states.append(child)

func _on_state_changed(new_state):
	if new_state == current_state:
		return
	_exit_states()
	if current_state:
		previous_state = current_state
		previous_state.current = false
	current_state = new_state
	current_state.current = true
	_get_states()
	_enter_states()

func _on_state_disabled(state):
	_exit_states()
	states = []
	state.current = false
	current_state = null

func _process(delta):
	_update_states(delta)

func _physics_process(delta):
	_physics_update_states(delta)

func _enter_states():
	for state in states:
		print("%s entered state: %s" % [get_parent().name, state.name])
		state.enter()

func _exit_states():
	for state in states:
		print("%s exited state: %s" % [get_parent().name, state.name])
		state.exit()

func _update_states(delta):
	for state in states:
		state.update(delta)

func _physics_update_states(delta):
	for state in states:
		state.physics_update(delta)

func enable_state_by_name(state_name: String):
	var state_node: BaseState =  get_node_or_null(state_name)
	if state_node:
		state_node.enable()
	else:
		push_warning("Can't find state with name: %s." %[state_name])

func receive_data(data: DataState):
	if data:
		var state_node: BaseState = get_child(data.state_index)
		state_node.enable()

func enable_next_state():
	var current_state_index = current_state.get_index()
	var next_state: BaseState = get_child(current_state_index + 1)
	if next_state:
		next_state.enable()

func enable_previous_state():
	if previous_state:
		previous_state.enable()
