extends BaseState
##Consumes or adds contents to player's inventory.
class_name StateContents

@export var contents: Array[ContentItem] ##A list of contents to get.

var entity: CharacterEntity

func enter():
	if state_machine.params.has("entity"):
		entity = state_machine.params["entity"]
	get_contents()

func get_contents():
	if contents.size() == 0 or not entity:
		return
	for content in contents:
		if content.quantity > 0:
			entity.add_item_to_inventory(content.item, content.quantity)
		else:
			entity.consume_item(content.item)
	complete()
