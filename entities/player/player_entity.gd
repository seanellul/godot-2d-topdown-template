extends CharacterEntity
class_name PlayerEntity
##Script attached to the Player node, specifically made to represent the player entities of the game.
##The Player node is used as a base to create the main players.

@export_group("States")
@export var on_transfer_start: State ## State to enable when player starts transfering.
@export var on_transfer_end: State ## State to enable when player ends transfering.

var player_id: int = 1 ## A unique id that is assigned to the player on creation. Player 1 will have player_id = 1 and each additional player will have an incremental id, 2, 3, 4, and so on.
var equipped = 0 ## The id of the weapon equipped by the player.
var inventory: Array[ContentItem] = [] ## The items this player has in its inventory.

func _ready():
	super._ready()
	Globals.transfer_start.connect(func(): on_transfer_start.enable())
	Globals.transfer_complete.connect(func(): on_transfer_end.enable())

func reduce_hp(value := 0, from = ""):
	super.reduce_hp(value, from)
	flash(damage_flash_power)

##Get the index of the item in inventory, -1 if not found.
func is_item_in_inventory(item_name: String, quantity := 1) -> int:
	var item_index := -1
	for i in inventory.size():
		var content: ContentItem = inventory[i]
		if content.item.resource_name == item_name and content.quantity >= quantity:
			item_index = i
	return item_index

##Adds an item to the inventory.
func add_item_to_inventory(item: DataItem, quantity: int):
	var item_index = is_item_in_inventory(item.resource_name)
	if item_index >= 0:
		inventory[item_index].quantity += quantity
		print("%s updated in %s's inventory! q: %s" % [item.resource_name, self.name, inventory[item_index].quantity])
	else:
		var content = ContentItem.new()
		content.item = item
		content.quantity = quantity
		inventory.append(content)
		print("%s added to %s's inventory! q: %s" % [item.resource_name, self.name, quantity])

##Removes an item from the inventory, if the item already exists in inventory.
func remove_item_from_inventory(item_name: String, quantity: int):
	var item_index = is_item_in_inventory(item_name)
	if item_index >= 0:
		inventory[item_index].quantity -= quantity
		if inventory[item_index].quantity > 0:
			print("%s updated in %s's inventory! q: %s" % [item_name, self.name, inventory[item_index].quantity])
		else:
			inventory.remove_at(item_index)
			print("%s removed from %s's inventory! q: 0" % [item_name, self.name])

func reset_values():
	is_charging = false
	is_attacking = false

##Used to save player data to a save file. [br]
##full==false is used to avoid saving some data when moving to another level.
func get_data(full):
	var data = DataPlayer.new()
	if full:
		data.position = position
		data.facing = facing
		data.level = Globals.get_current_level().scene_file_path
	data.hp = hp
	data.max_hp = max_hp
	data.inventory = inventory
	data.equipped = 0
	return data

##Used to load player data (from a save file or when moving to another level). [br]
##full==false is used to avoid loading some data when moving to another level.
func receive_data(data, full = true):
	if data:
		if full:
			global_position = data.position
			facing = data.facing
			#level = data.level #TODO: handle level loading
		hp = data.hp
		max_hp = data.max_hp
		inventory = data.inventory
		equipped = data.equipped
