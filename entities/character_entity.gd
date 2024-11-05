extends CharacterBody2D
class_name CharacterEntity

@export_group("Settings")
@export var animation_tree: AnimationTree
@export var collision_shape: CollisionShape2D
@export var sync_rotation: Array[Node2D] ##A list of nodes to sync rotation based on the entity facing direction.
@export_group("Movement")
@export var max_speed = 300.0
@export var friction = 2000.0
@export var blocks_detector: RayCast2D
@export var fall_detector: ShapeCast2D
@export var running_particles: GPUParticles2D = null
@export_group("Health")
@export var max_hp := 20
@export var immortal := false
@export var immortal_while_is_hurting := true
@export var health_bar: PackedScene ## It needs the canvas_layer.
@export var damage_flash_power = 0.3
@export_group("Attack")
@export var attack_power := 2
@export var attack_speed := 0.08
@export_group("States")
@export var on_attack: BaseState ##State to enable when this entity attacks.
@export var on_hit: BaseState ##State to enable when this entity damages another entity.
@export var on_hurt: BaseState ##State to enable when this entity takes damage.
@export var on_fall: BaseState ##State to enable when this entity falls.
@export var on_recovery: BaseState ##State to enable when this entity recovers.
@export var on_death: BaseState ##State to enable when this entity dies.
@export var on_screen_entered: BaseState ##State to enable when this entity is visible on screen.
@export var on_screen_exited: BaseState ##State to enable when this entity is outside the visible screen.

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
@onready var input_enabled: bool = self is PlayerEntity

var hp_bar: Node
var screen_notifier: VisibleOnScreenNotifier3D
var attack_cooldown_timer: Timer
var facing := Vector2.DOWN:
	set(value):
		facing = value
		for n in sync_rotation:
			n.rotation = facing.angle()
var speed := 0.0
var flee := false
var safe_position := Vector2.ZERO

@export_group("Actions")
var is_moving: bool
var is_running: bool
var is_jumping: bool
var is_attacking: bool
var is_charging := false
var is_hurting := false:
	set(value):
		is_hurting = value
		if immortal_while_is_hurting:
			immortal = is_hurting
var is_blocked := false:
	get():
		return blocks_detector.is_colliding() if blocks_detector != null else false
var is_falling := false

signal hp_changed(value)
signal damaged(hp)
signal hit

func _ready():
	_init_health_bar()
	_init_screen_notifier()
	_init_attack_cooldown_timer()
	hit.connect(func(): if on_hit: on_hit.enable())

func _process(_delta):
	_update_animation()

func _physics_process(_delta):
	is_moving = velocity != Vector2.ZERO
	is_running = is_moving and speed > max_speed
	check_falling()
	move_and_slide()

func _init_health_bar():
	if health_bar:
		hp_bar = health_bar.instantiate()
		hp_bar.init_hud(self)
		add_child(hp_bar)

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

func receive_data(data: DataEntity, _soft = false):
	if data:
		global_position = data.position
		facing = data.facing

func move_towards(_position, speed_increment = 1.0, friction_increment = 1.0):
	var moving_direction = global_position.direction_to(_position)
	move(moving_direction, speed_increment, friction_increment)

func move(direction, speed_increment = 1.0, friction_increment = 1.0):
	if is_attacking or is_charging:
		return
	var delta = get_process_delta_time()
	var target_velocity = Vector2.ZERO
	var moving_direction := Vector2(direction.x, direction.y).normalized()
	var new_friction = friction
	moving_direction *= 1 if not flee else -1
	if moving_direction != Vector2.ZERO:
		facing = moving_direction
		speed = max_speed * speed_increment
		new_friction = friction * friction_increment
		target_velocity = moving_direction * speed
	velocity = velocity.move_toward(target_velocity, new_friction * delta)

func jump():
	if not is_jumping:
		safe_position = global_position
		is_jumping = true
		collision_mask ^= 1 << 2

func end_jump():
	is_jumping = false
	collision_mask ^= 1 << 2

func attack():
	if is_attacking or is_jumping or attack_cooldown_timer.time_left > 0:
		return
	else:
		attack_cooldown_timer.stop()
		if on_attack:
			on_attack.enable()

func end_attack():
	if attack_cooldown_timer:
			attack_cooldown_timer.start(attack_speed)

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
		print("%s damaged by %s! value: %s" % [name, from, value])
	hp -= value
	if hp <= 0:
		if on_death:
			on_death.enable()
	damaged.emit(hp)

func recover_hp(value := 0, from = ""):
	if from:
		print("%s regenerated by %s! value: %s" % [name, from, value])
	hp += value
	if hp > max_hp:
		hp = max_hp
	if on_recovery:
		on_recovery.enable()

func check_falling():
	if not is_falling and not is_jumping and fall_detector.is_colliding() and on_fall:
		on_fall.enable()

func hurt(): ##IMPORTANT: should be called always after reduce_hp.
	if on_hurt:
		on_hurt.enable()

func add_impulse(force:= 0.0):
	velocity += facing * force

func return_to_safe_position():
	if safe_position != Vector2.ZERO:
		global_position = safe_position

func consume_item(item: DataItem):
	var item_hp = item.change_hp
	if item_hp > 0:
		recover_hp(item_hp, item.resource_name)
	elif item_hp < 0:
		reduce_hp(-item_hp, item.resource_name)
		hurt()

func reset_values(): ##Useful to reset some entity values to an initial state.
	pass

func stop(smoothly := false): ##Stops the entity, setting its velocity to 0.
	if smoothly:
		move(Vector2.ZERO)
	else:
		velocity = Vector2.ZERO

func disable_entity(value: bool, delay = 0.0):
	await get_tree().create_timer(delay).timeout
	process_mode = PROCESS_MODE_DISABLED if value else PROCESS_MODE_INHERIT
	stop()
