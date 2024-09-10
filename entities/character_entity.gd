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
@export var distance_threshold: = 21.0
@export var slow_radius_size: = 5.0 ##It's multiplied by the distance_threshold
@export_group("Movement")
@export var max_speed = 300.0
@export var friction = 2000.0
@export var running_particles: GPUParticles2D = null
@export_group("Health")
@export var max_hp := 20
@export var immortal := false
@export var health_bar: PackedScene ## It needs the canvas_layer.
@export var damage_flash_power = 0.3
@export_group("Attack")
@export var attack_power := 2
@export var attack_speed := 0.08
@export_group("States")
@export var on_attack: BaseState ## State to enable when this entity attacks.
@export var on_hit: BaseState ## State to enable when this entity damages another entity.
@export var on_hurt: BaseState ## State to enable when this entity takes damage.
@export var on_recovery: BaseState ## State to enable when this entity recovers.
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
var is_hurting := false
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
	_calc_target_reached()
	_update_animation()

func _physics_process(_delta):
	is_moving = velocity != Vector2.ZERO
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

func _calc_target_reached():
	if !is_target_reached and target:
		var distance = global_position.distance_to(target.position)
		is_target_reached = distance < distance_threshold
		if is_target_reached:
			target_reached.emit(target)

func _reset_target_reached():
	if is_inside_tree():
		await get_tree().create_timer(0.5).timeout
	is_target_reached = false

func receive_data(data: DataEntity, _soft = false):
	if data:
		global_position = data.position
		facing = data.facing
		target = get_node_or_null(data.target)

func move(direction, speed_increment = 1.0):
	if is_attacking or is_charging:
		return
	var delta = get_process_delta_time()
	var target_velocity = Vector2(0, 0)
	var moving_direction := Vector2(direction.x, direction.y).normalized()
	if moving_direction:
		facing = moving_direction
		var speed = max_speed * speed_increment
		target_velocity = moving_direction * speed
	velocity = velocity.move_toward(target_velocity, friction * delta)

func move_towards_target(speed_multiplier = 1.0):
	if not target:
		return
	var target_pos = target.global_position
	var direction = global_position.direction_to(target_pos)
	move(direction, speed_multiplier)

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
	var nodes_to_flash: Array[Node] = get_tree().get_nodes_in_group(Const.GROUP.FLASH)
	for n: Sprite2D in nodes_to_flash:
		n.material.set_shader_parameter("power", power)
		if color != Color.TRANSPARENT:
			n.material.set_shader_parameter("flash_color", color)
	if (power > 0):
		await get_tree().create_timer(duration).timeout
		flash(0)

func reduce_hp(value := 0, from = ""):
	if from:
		print("%s damaged by %s" % [name, from])
	hp -= value
	if hp > 0:
		if on_hurt:
			on_hurt.enable()
	else:
		if on_death:
			on_death.enable()
	damaged.emit(hp)

func recover_hp(value := 0, from = ""):
	if from:
		print("%s regenerated by %s" % [name, from])
	hp += value
	if hp > max_hp:
		hp = max_hp
	if on_recovery:
		on_recovery.enable()

func knockback(force:= 0.0):
	velocity += -facing * force

func reset():
	pass

func stop():
	velocity = Vector2.ZERO

func disable_entity(value: bool, delay = 0.0):
	await get_tree().create_timer(delay).timeout
	process_mode = PROCESS_MODE_DISABLED if value else PROCESS_MODE_INHERIT
	stop()
