extends CharacterBody2D
class_name CharacterEntity

@export_group("Settings")
@export var animation_tree: AnimationTree
@export var target_is_player: = false
@export var target: Node2D = null: ##A Node to be followed by this entity.
	set(value):
		target = value
		target_changed.emit(value)
		_reset_target_reached()
@export_group("Movement")
@export var max_speed = 5.0
@export var run_speed_increment: = 1.5
@export var acceleration = 3000.0
@export var friction = 2000.0
@export var running_particles: GPUParticles2D = null
@export_group("Health")
@export var max_hp := 10
@export var immortal := false
@export var health_bar: PackedScene ## It needs the canvas_layer.
@export var damage_flash_power = 0.3
@export_group("Attack")
@export var attack_power := 2
@export var attack_speed := 0.08
@export var impulse_force = 5.0
@export var impulse_duration = 0.1
@export var attack_friction = 100.0
@export_group("States")
@export var on_attack: BaseState ## State to enable when this entity attacks.
@export var on_hit: BaseState ## State to enable when this entity damages another entity.
@export var on_hurt: BaseState ## State to enable when this entity takes damage.
@export var on_death: BaseState ## State to enable when this entity dies.
@export var on_screen_entered: BaseState ## State to enable when this entity is visible on screen.
@export var on_screen_exited: BaseState ## State to enable when this entity is outside the visible screen.

@onready var hp := max_hp:
	set(value):
		if immortal:
			return
		if value < 0:
			value = 0
		elif value > max_hp:
			value = max_hp
		hp = value
		print("%s HP is: %s" % [name, hp])
		hp_changed.emit(hp)

var hp_bar: Node
var screen_notifier: VisibleOnScreenNotifier3D
var attack_cooldown_timer: Timer
var facing := Vector2.DOWN

@export_group("Actions")
var is_moving: bool
var is_running: bool
@export var is_jumping: bool #exported because used in animation "jump"
@export var is_attacking: bool: #exported because used in animation "attack"
	set(value):
		is_attacking = value
		if value == true:
			attack_cooldown_timer.stop()
			if on_attack:
				on_attack.enable()
		elif attack_cooldown_timer:
			attack_cooldown_timer.start(attack_speed)
var is_charging := false
var is_damaged: bool
var is_target_reached := false

signal target_changed(target)
signal target_reached(target)
signal hp_changed(value)
signal damaged(hp)
signal hit

func _ready():
	_init_health_bar()
	_init_target()
	_init_screen_notifier()
	_init_attack_cooldown_timer()
	hit.connect(func(): if on_hit: on_hit.enable())

func _process(_delta):
	if !is_target_reached:
		is_target_reached = round(velocity) == Vector2.ZERO
		if is_target_reached:
			target_reached.emit(target)
	_update_animation()

func _physics_process(_delta):
	move_and_slide()

func _init_health_bar():
	if health_bar:
		hp_bar = health_bar.instantiate()
		hp_bar.init_hud(self)
		add_child(hp_bar)

func _init_target():
	if target_is_player:
		target = get_tree().get_first_node_in_group(Const.GROUP.PLAYER)
	elif target:
		target = target

func _init_screen_notifier():
	if on_screen_entered or on_screen_exited:
		screen_notifier = VisibleOnScreenNotifier3D.new()
		if on_screen_entered:
			screen_notifier.screen_entered.connect(func(): on_screen_entered.enable())
		if on_screen_exited:
			screen_notifier.screen_exited.connect(func(): on_screen_exited.enable())
		add_child(screen_notifier)

func _init_attack_cooldown_timer():
	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.one_shot = true
	add_child(attack_cooldown_timer)

func _update_animation():
	var current_anim = animation_tree.get("parameters/playback").get_current_node()
	if current_anim:
		animation_tree.set("parameters/%s/BlendSpace2D/blend_position" % current_anim, Vector2(facing.x, facing.y))

func _reset_target_reached():
	if is_inside_tree():
		await get_tree().create_timer(0.5).timeout
	is_target_reached = false

func receive_data(data: DataEntity):
	if data:
		global_position = data.position
		facing = data.facing
		target = get_node_or_null(data.target)

func move(direction):
	if is_attacking or is_charging:
		return
	var delta = get_process_delta_time()
	# Get the input direction and handle the movement/deceleration.
	var moving_direction := Vector2(direction.x, direction.y).normalized()
	if moving_direction:
		facing = moving_direction
		var speed = max_speed if !is_running else max_speed * run_speed_increment
		var target_velocity = Vector2(direction.x * speed, direction.y * speed)
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		var target_velocity = Vector2(0, 0)
		velocity = velocity.move_toward(target_velocity, friction * delta)
	is_moving = velocity != Vector2.ZERO

func jump():
	if not is_jumping:
		is_jumping = true

func end_jump():
	is_jumping = false

func attack():
	if is_attacking or is_jumping or attack_cooldown_timer.time_left > 0:
		return
	else:
		is_attacking = true

func end_attack():
	is_attacking = false

func flash(power := 0.0, duration := 0.1, color := Color.TRANSPARENT):
	return #TODO: add flash
	var nodes_to_flash = get_tree().get_nodes_in_group(Const.GROUP.FLASH)
	for n in nodes_to_flash:
		n.material_overlay.set_shader_parameter("power", power)
		if color != Color.TRANSPARENT:
			n.material_overlay.set_shader_parameter("flash_color", color)
	if (power > 0):
		await get_tree().create_timer(duration).timeout
		flash(0)

func take_damage(value := 0, from = ""):
	is_damaged = true
	if from:
		print_debug("%s damaged by %s" % [name, from])
	hp -= value
	if hp > 0:
		if on_hurt:
			on_hurt.enable()
	else:
		if on_death:
			on_death.enable()
	damaged.emit(hp)
	is_damaged = false

func knockback(force:= 0.0):
	velocity += -facing * force

func reset():
	pass

func stop():
	velocity = Vector2.ZERO

func disable_entity(value: bool):
	set_process(!value)
	set_physics_process(!value)
	velocity = Vector2.ZERO
