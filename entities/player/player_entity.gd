extends CharacterEntity
class_name PlayerEntity

@export var player_id: int = 1 ##Add players incrementing this value to create more players.
@export var equipped = 0
@export_group("States")
@export var on_transfer_start: BaseState ##State to enable when player starts transfering.
@export var on_transfer_end: BaseState ##State to enable when player ends transfering.

var inventory: Array[DataItem] = []

func _ready():
	super._ready()
	Globals.transfer_start.connect(func(): on_transfer_start.enable())
	Globals.transfer_complete.connect(func(): on_transfer_end.enable())

func _process(delta):
	super._process(delta)
	if running_particles:
		running_particles.emitting = is_running && not is_jumping

func reduce_hp(value := 0, from = ""):
	super.reduce_hp(value, from)
	flash(damage_flash_power)

func is_item_in_inventory(item_name: String) -> int: ##Get the index of the item in inventory, -1 if not found.
	var item_index := -1
	for i in inventory.size():
		var item = inventory[i]
		if item.resource_name == item_name:
			item_index = i
	return item_index

func add_item_to_inventory(item: DataItem):
	var item_index = is_item_in_inventory(item.resource_name)
	if item_index >= 0:
		inventory[item_index].quantity += item.quantity
	else:
		inventory.append(item)

func reset():
	is_charging = false
	is_attacking = false

func get_data(soft):
	var data = DataPlayer.new()
	if not soft:
		data.position = position
		data.facing = facing
		data.level = GameManager.gm.current_level.scene_file_path
	data.hp = hp
	data.max_hp = max_hp
	data.inventory = inventory
	data.equipped = 0
	return data

func receive_data(data, soft = false):
	if data:
		if not soft:
			global_position = data.position
			facing = data.facing
			#level = data.level #TODO: handle level loading
		hp = data.hp
		max_hp = data.max_hp
		inventory = data.inventory
		equipped = data.equipped
