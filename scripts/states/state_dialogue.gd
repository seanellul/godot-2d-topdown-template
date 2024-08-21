extends BaseState
class_name StateDialogue

@export var dialogue: DialogueResource
@export var title = ""

func enter():
	if dialogue:
		DialogueManager.show_dialogue_balloon(dialogue, title)
