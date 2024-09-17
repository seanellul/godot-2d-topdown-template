extends BaseState
class_name StateSwitch

@export var states_to_enable: Array[BaseState] = []

func enter():
	for state in states_to_enable:
		state.enable()
