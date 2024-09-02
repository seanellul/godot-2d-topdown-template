extends CharacterEntity
class_name PlayerEntity

@export_group("Attack")
@export var impulse_force = 5.0
@export var impulse_duration = 0.1
@export var attack_friction = 100.0

@export var smoke_particles: PackedScene = null
@export var hurtbox: PackedScene = null

# var input_dir: Vector2
var attack_cooldown_timer: Timer

const damage_flash_power = 0.3

func _ready():
	super._ready()
	_init_attack_cooldown_timer()
	Globals.transfer_start.connect(func(): disable_entity(true))
	Globals.transfer_complete.connect(func(): disable_entity(false))
	Globals.player_ready.emit(self)

func _on_set_current_level():
	pass

func _process(delta):
	super._process(delta)
	if smoke_particles:
		smoke_particles.emitting = is_running && not is_jumping

func _init_attack_cooldown_timer():
	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.wait_time = 0.08 ## TODO: set based on weapon speed
	add_child(attack_cooldown_timer)

func _set_is_attacking(value):
	super._set_is_attacking(value)
	if hurtbox:
		hurtbox.disabled = value

func _set_is_charging(value):
	is_charging = value

func start_attack(delta):
	if is_attacking or attack_cooldown_timer.time_left > 0:
		return
	is_attacking = true
	attack_cooldown_timer.stop()
	velocity += facing * impulse_force
	await get_tree().create_timer(impulse_duration).timeout
	velocity = velocity.move_toward(Vector2.ZERO, attack_friction * delta)

func end_attack():
	is_attacking = false
	attack_cooldown_timer.start()

func take_damage(value := 0, from = ""):
	super.take_damage(value, from)
	flash(damage_flash_power)

func reset():
	is_charging = false
	end_attack()

func get_data():
	var data = DataPlayer.new()
	data.facing = facing
	data.position = position
	data.level = GameManager.gm.current_level.scene_file_path
	return data

func receive_data(data):
	if data:
		global_position = data.position
		facing = data.facing
