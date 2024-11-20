extends Node2D

@export var contents: Array[ContentItem] ## A list of contents to get.

signal contents_got

func get_contents(params):
	var entity: CharacterEntity = params["entity"]
	if !entity:
		push_warning("Entity is missing in %s" % [get_path()])
		return
	if contents.size() == 0 or not entity:
		return
	for content in contents:
		if content.quantity > 0:
			entity.add_item_to_inventory(content.item, content.quantity)
		else:
			entity.consume_item(content.item)
	contents_got.emit.call_deferred()