extends BaseState
class_name StateSwitch

@export var state_to_enable: BaseState = null

func enter():
	if state_to_enable:
		state_to_enable.enable()
