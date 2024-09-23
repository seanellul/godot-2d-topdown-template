extends BaseState
##Switches between states.
class_name StateSwitch

@export var states: Array[BaseState] ##The states to switch.
@export var start_state_index := 0
@export var switch_on_interaction := false ##Switches the states on interaction. Alternatively you can call switch_states manually.
@export_group("Update")
@export var remote_switch: Array[StaticEntity] ##Switch the states of other entities when this entity switches states (eg: useful for controlling doors opening with a lever).

var switch := false: ##For debugging purposes.
	set(value):
		switch_states()

func enter():
	switch_states()

func switch_states():
	for rs in remote_switch:
		rs.switch_states()
	if states.size() == 0:
		return
	var next_state
	start_state_index += 1
	if start_state_index < states.size():
		next_state = states[start_state_index]
	else:
		next_state = states[0]
		start_state_index = 0
	if next_state:
		next_state.enable()
