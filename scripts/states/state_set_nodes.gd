extends BaseState
class_name StateSetNodes

@export var nodes_to_disable: Array[Node]
@export var nodes_to_enable: Array[Node]

func enter():
	for node in nodes_to_disable:
		node.process_mode = Node.PROCESS_MODE_DISABLED
	for node in nodes_to_enable:
		node.process_mode = Node.PROCESS_MODE_INHERIT

func exit():
	for node in nodes_to_disable:
		node.process_mode = Node.PROCESS_MODE_INHERIT
	for node in nodes_to_enable:
		node.process_mode = Node.PROCESS_MODE_DISABLED
