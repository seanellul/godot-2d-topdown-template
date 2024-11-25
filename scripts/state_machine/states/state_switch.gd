extends State
##Enables states of other nodes.
class_name StateSwitch

@export var states: Array[State] ##The states to switch.

var switch := false: ##For debugging purposes.
	set(value):
		switch_states()

func enter():
	switch_states()

func switch_states():
	for state in states:
		state.enable()
