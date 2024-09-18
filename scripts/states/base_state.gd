extends Node
##Base class for all states.
class_name BaseState

@export var active := true ##Set to false to avoid processing this state.
@export_category("Advance")
@export var await_completion := false ##If the StateMachine sequence is true, await the completion of the state before proceeding to the next one.
@export_group("Await")
@export var time_range := Vector2.ZERO ##If greather than 0, await N seconds before completing the action. N = random time range between min (x) and max (y).
@export var on_timeout: BaseState ##State to enable after timer runs out.
@export_category("Params")
@export var enter_params: Dictionary
@export var exit_params: Dictionary

var state_machine: StateMachine
var current := false ##Check if the state is currently enabled.
var timer: TimedState

signal state_changed(new_state)
signal state_disabled(state)
signal state_completed

func _enter_tree():
	if !active:
		process_mode = PROCESS_MODE_DISABLED
	elif time_range > Vector2.ZERO:
		timer = TimedState.new()
		timer.create(self, time_range)

func enable(_params = null): ##Enables this state.
	if _params:
		state_machine.params = _params
	state_changed.emit(self)
	if not await_completion and not timer:
		complete()
	if timer:
		timer.start()
		await timer.timeout
		if on_timeout:
			on_timeout.enable(state_machine.params)
		complete()

func disable():
	state_disabled.emit(self)

func enter():
	for key in enter_params:
		var param = get_node_and_resource(key)
		_set_value(param[0], param[2], enter_params[key])

func exit():
	for key in exit_params:
		var param = get_node_and_resource(key)
		_set_value(param[0], param[2], enter_params[key])

func update(_delta: float):
	pass

func physics_update(_delta: float):
	pass

func complete():
	state_completed.emit()

func _set_value(node: Node, property: String, value: Variant) -> void:
	var property_path = property.split(":")
	print_debug("Set: ", property_path[1], value)
	node.set(property_path[1], str_to_var(value))

class TimedState:
	var timer: Timer
	var t_range: Vector2

	signal timeout

	func create(parent: Node, time_range: Vector2):
		if not timer:
			timer = Timer.new()
			timer.one_shot = true
			parent.add_child(timer)
			t_range = time_range
	
	func start():
			timer.stop()
			timer.wait_time = randf_range(t_range.x, t_range.y)
			timer.start()
			await timer.timeout
			timeout.emit()
