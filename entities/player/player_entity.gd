extends CharacterEntity
class_name PlayerEntity

@export var player_id: int = 1 ##Add players incrementing this value to create more players
@export var equipped = 0

var inventory: Array[DataItem] = []

func _ready():
	super._ready()
	Globals.transfer_start.connect(func(): disable_entity(true))
	Globals.transfer_complete.connect(func(): disable_entity(false))
	Globals.player_ready.emit(self)

func _process(delta):
	super._process(delta)
	if running_particles:
		running_particles.emitting = is_running && not is_jumping

func reduce_hp(value := 0, from = ""):
	super.reduce_hp(value, from)
	flash(damage_flash_power)

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
