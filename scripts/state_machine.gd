extends Node
##Main controller for the states. States should be placed as children of a StateMachine node.
class_name StateMachine

@export_category("Config")
@export var current_state: BaseState = null
@export var sequence := false ##If true, treat this StateMachine as a sequence where all states will be executed one after the other.
@export var disabled := false ##Determines if disable this StateMachine

@onready var n_of_states = get_child_count()

var initialized := false
var previous_state: BaseState = null
var states: Array[BaseState]
var params = {}

signal state_changed(old_state, new_state)

func _ready():
	await owner.ready
	_init_states()
	_get_states()
	_enter_states()

func _init_states():
	var children = get_children(true).filter(func(node): return node is BaseState)
	for state in children:
		state.process_mode = Node.PROCESS_MODE_DISABLED
		state.state_machine = self
		initialized = true

func _get_states():
	if !current_state or current_state and !current_state.active:
		return
	states = []
	states.append(current_state)
	for child in current_state.get_children():
		if child is BaseState and child.active:
			states.append(child)

func enable_state(new_state: BaseState):
	if new_state == current_state:
		return
	_exit_states()
	if current_state:
		previous_state = current_state
		previous_state.process_mode = PROCESS_MODE_DISABLED
	current_state = new_state
	current_state.process_mode = PROCESS_MODE_INHERIT
	state_changed.emit(previous_state, current_state)
	_get_states()
	_enter_states()

func disable_state(state: BaseState):
	state.process_mode = Node.PROCESS_MODE_DISABLED
	_exit_states()
	states = []
	current_state = null

func complete_current_state():
	if sequence:
		enable_next_state()

func _process(delta):
	_update_states(delta)

func _physics_process(delta):
	_physics_update_states(delta)

func _enter_states():
	for state in states:
		print("%s entered state: %s" % [get_parent().name, state.name])
		state.enter(params)

func _exit_states():
	for state in states:
		print("%s exited state: %s" % [get_parent().name, state.name])
		state.exit()

func _update_states(delta):
	if disabled or not initialized:
		return
	for state in states:
		state.update(delta)

func _physics_update_states(delta):
	if disabled or not initialized:
		return
	for state in states:
		state.physics_update(delta)

func receive_data(data: DataState):
	if data:
		var state_node: BaseState = get_child(data.state_index)
		state_node.enable(params)

func enable_state_by_name(state_name: String):
	var state_node: BaseState =  get_node_or_null(state_name)
	if state_node:
		state_node.enable(params)
	else:
		push_warning("Can't find state with name: %s." %[state_name])

func enable_next_state(_params = null):
	var next_index = 0
	if current_state:
		var current_state_index = current_state.get_index()
		next_index = current_state_index + 1
	if next_index < n_of_states:
		var next_state: BaseState = get_child(next_index)
		if next_state:
			next_state.enable(_params)
	elif sequence and current_state:
		current_state.disable()

func enable_previous_state():
	if previous_state:
		previous_state.enable(params)
