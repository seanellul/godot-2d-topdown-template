extends State
## Set some properties to a node present in the parent StateMachine params.
class_name StateParamsSetter

@export_category("Set Properties")
@export var param_key: String ## The name of the param as is in the State Machine.
@export var on_enter: Dictionary[String, Variant] ## Set some properties to the node param_key found among the StateMachine params, on entering state.
@export var on_exit: Dictionary[String, Variant] ## Set some properties to the node param_key found among the StateMachine params, on exiting state.

func enter():
	var node = _get_node()
	if not node:
		return
	for prop in on_enter:
		node.set(prop, on_enter[prop])

func exit():
	var node = _get_node()
	if not node:
		return
	for prop in on_exit:
		node.set(prop, on_exit[prop])

func _get_node():
	var node = null
	if state_machine.params.has(param_key):
		node = state_machine.params[param_key]
	else:
		push_warning("Node %s not found in %s" % [param_key, get_path()])
	return node
