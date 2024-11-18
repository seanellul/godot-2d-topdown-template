@icon("../icons/BaseState.svg")
extends Node
##Base class for all states.
class_name BaseState

@export var active := true ## Set to false to avoid processing this state.
@export_category("Advance")
@export_group("Await Timer")
@export var time_range := Vector2.ZERO ## If greather than 0, await N seconds before completing the state, where N is a random value between min (x) and max (y).
@export_group("")
@export var await_completion := false ## Await the completion of this state before enabling the on_completion state.
@export var on_completion: BaseState ## State to enable after state completion or on timer timeout.

var running := false ## True if the state is currently running.
var state_machine: StateMachine:
	set(value):
		state_machine = value
		for state in get_children(true).filter(func(node): return node is BaseState):
			state.state_machine = value
var timer: TimedState

signal completed

func _enter_tree():
	if !active:
		process_mode = PROCESS_MODE_DISABLED
	if time_range > Vector2.ZERO:
		await_completion = false # Await for timer timeout instead.
		timer = TimedState.new()
		timer.create(self, time_range)

func enable(params = null): ## Enables this state.
	if params:
		state_machine.params = params
	state_machine.enable_state(self)
	if timer:
		timer.start()
		await timer.timeout
		complete()
	if on_completion:
		on_completion.enable(state_machine.params)
	if not await_completion and not timer:
		complete()

func disable():
	if state_machine:
		state_machine.disable_state(self)

func enter():
	pass

func exit():
	pass

func update(_delta: float):
	pass

func physics_update(_delta: float):
	pass

func complete():
	print_debug("State %s completed" % [name])
	completed.emit()

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
