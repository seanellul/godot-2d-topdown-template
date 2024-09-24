extends Node
##Base class for all states.
class_name BaseState

@export var active := true ##Set to false to avoid processing this state.
@export_category("Advance")
@export var await_completion := false ##If the StateMachine sequence is true, await the completion of the state before proceeding to the next one.
@export_group("Await")
@export var time_range := Vector2.ZERO ##If greather than 0, await N seconds before completing the action. N = random time range between min (x) and max (y).
@export var on_timeout: BaseState ##State to enable after timer runs out.

var state_machine: StateMachine
var timer: TimedState

signal completed

func _enter_tree():
	if !active:
		process_mode = PROCESS_MODE_DISABLED
	if time_range > Vector2.ZERO:
		timer = TimedState.new()
		timer.create(self, time_range)

func enable(params = null): ##Enables this state.
	if params:
		state_machine.params = params
	state_machine.enable_state(self)
	if timer:
		timer.start()
		await timer.timeout
	if on_timeout:
		on_timeout.enable(state_machine.params)
	if not await_completion:
		completed.emit()

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
	print_debug(get_path())
	if await_completion:
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
