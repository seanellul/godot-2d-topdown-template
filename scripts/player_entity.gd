extends CharacterEntity
class_name PlayerEntity

@export_group("Movement")
@export var acceleration = 25.0
@export var friction = 10.0

@export_group("Attack")
@export var impulse_force = 5.0
@export var impulse_duration = 0.1
@export var attack_friction = 100.0

@export var smoke_particles: PackedScene = null
@export var hurtbox: PackedScene = null

var input_dir: Vector2
var attack_cooldown_timer: Timer

const damage_flash_power = 0.3

func _ready():
	super._ready()
	_init_attack_cooldown_timer()

func _get_is_running():
	return is_moving && Input.get_action_strength("run") > 0

func _process(delta):
	super._process(delta)
	input_dir = Input.get_vector("left", "right", "up", "down")
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

func _set_data(value):
	if data == null:
		super._set_data(value)

func move(delta, speed: float):
	if is_attacking or is_charging:
		return
	# Get the input direction and handle the movement/deceleration.
	var direction := Vector2(input_dir.x, input_dir.y).normalized()
	if direction:
		facing = direction
		var target_velocity = Vector2(input_dir.x * speed, input_dir.y * speed)
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		var target_velocity = Vector2(0, 0)
		velocity = velocity.move_toward(target_velocity, friction * delta)

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
