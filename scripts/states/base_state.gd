extends Node
class_name BaseState

@export var active := true ## Set to false to don't process this state.
@export_group("Timer")
@export var time_range := Vector2.ZERO ## If greather than 0 the state is timed and after N seconds the on_timeout state will be enabled. Random time range between min (x) and max (y).
@export var on_timeout: BaseState ## State to enable after time_range times out.

var current := false ## Check if the state is currently enabled.
var timer: TimedState
var params = {}

signal state_changed(new_state)

func _enter_tree():
	if !active:
		set_process(false)
		set_physics_process(false)
	elif time_range > Vector2.ZERO and on_timeout != null:
		timer = TimedState.new()
		timer.create(self, time_range)

## Enables this state.
func enable(_params = null):
	if _params:
		params = _params
	state_changed.emit(self)
	if timer:
		timer.start()
		await timer.timeout
		on_timeout.enable(params)

func enter():
	pass

func exit():
	pass

func update(_delta: float):
	pass

func physics_update(_delta: float):
	pass


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
