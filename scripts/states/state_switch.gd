extends BaseState
##Enables states of other nodes.
class_name StateSwitch

@export var states: Array[BaseState] ##The states to switch.

var switch := false: ##For debugging purposes.
	set(value):
		switch_states()

func enter(_params = null):
	switch_states()

func switch_states():
	for state in states:
		state.enable()
