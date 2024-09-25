extends BaseState
##Prints a debug message to the terminal.
class_name StateDebug

@export var message := ""

func enter():
	print_debug(message)
	await get_tree().create_timer(0.5).timeout
	complete()
