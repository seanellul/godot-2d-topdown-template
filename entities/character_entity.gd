extends CharacterBody2D
class_name CharacterEntity
##Script attached to the Entity node, which represents all the characters entities of the game.
##The Entity node is used as a base to create players, enemies and any other npc.

@export_group("Settings")
@export var animation_tree: AnimationTree ## The AnimationTree attached to this entity, needed to manage animations.
@export var sync_rotation: Array[Node2D] ## A list of nodes that update their rotation based on the direction the entity is facing.
@export_group("Movement")
@export var max_speed = 300.0 ## The maximum speed the entity can reach while moving.
@export var friction = 2000.0 ## Affects the time it takes for the entity to reach max_speed or to stop.
@export var blocks_detector: RayCast2D ## A RayCast2D node to identify when the entity is in front of a tile or element that blocks it.
@export var fall_detector: ShapeCast2D ## A ShapeCast2D node that identifies when the entity is falling, triggering the "on_fall" state.
@export var running_particles: GPUParticles2D = null ## A GPUParticles2D to enable when the entity is running (is_running == true).
@export_group("Health")
@export var max_hp := 20 ## The total hp of the entity. If the entity has health_bar assigned, it is the value that corresponds to the health_bar completely full.
@export var immortal := false ## Makes the entity undamageable. Exported for testing purposes.
@export var immortal_while_is_hurting := true ## Makes the entity immortal while is_hurting == true.
@export var health_bar: PackedScene ## A PackedScene that displays the entity's HP.
@export var damage_flash_power = 0.3 ## The flash power that applies to all nodes found in the "flash" group in the entity.
@export_group("Attack")
@export var attack_power := 2 ## The value this entity subtracts from another entity's HP when it attacks.
@export var attack_speed := 0.08 ## Affects the cooldown time between attacks.
@export_group("States")
@export var on_attack: BaseState ## State to enable when this entity attacks.
@export var on_hit: BaseState ## State to enable when this entity damages another entity.
@export var on_hurt: BaseState ## State to enable when this entity takes damage.
@export var on_fall: BaseState ## State to enable when this entity falls.
@export var on_recovery: BaseState ## State to enable when this entity recovers hp.
@export var on_death: BaseState ## State to enable when this entity dies (hp == 0).
@export var on_screen_entered: BaseState ## State to enable when this entity is visible on screen.
@export var on_screen_exited: BaseState ## State to enable when this entity is outside the visible screen.

@onready var hp := max_hp: ## The entity's current hp.
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
@onready var input_enabled: bool = self is PlayerEntity ## If enabled, the entity will respond to input-listening states, such as state_interact and state_input_listener.

var hp_bar: Node ## The health_bar instance, if assigned.
var screen_notifier: VisibleOnScreenNotifier2D ## The instance of a VisibleOnScreenNotifier2D node, automatically created to handle the on_screen_entered and on_screen_exited states in the entity.
var attack_cooldown_timer: Timer ## The timer that manages the cooldown time between attacks.
var facing := Vector2.DOWN: ## The direction the entity is facing.
	set(value):
		facing = value
		for n in sync_rotation:
			n.rotation = facing.angle()
var speed := 0.0 ## The current speed of the entity.
var invert_moving_direction := false ## Inverts the movement direction. Useful for moving an entity away from the target position.
var safe_position := Vector2.ZERO ## The last position of the entity that was deemed safe. It is set before a jump and is eventually reassigned to the entity by calling the return_to_safe_position method. The "state_fall" state calls this method, so it is useful if assigned to "on_fall".

@export_group("Actions")
var is_moving: bool ## True if velocity is non-zero.
var is_running: bool ## Ttrue if the entity is moving and speed > max_speed.
var is_jumping: bool ## True during a jump. It is handled by the jump() and end_jump() methods, called by the "jump" animation.
var is_attacking: bool ## Set to true when the entity enters the on_attack state, false when it leaves it.
var is_charging := false ## Set to true when the entity is charging an attack.
var is_hurting := false: ## Set to true when the entity enters the on_hurt state, false when it leaves it.
	set(value):
		is_hurting = value
		if immortal_while_is_hurting:
			immortal = is_hurting
var is_blocked := false: ## True when blocks_detector is colliding.
	get():
		return blocks_detector.is_colliding() if blocks_detector != null else false
var is_falling := false ## Set to true when the entity enters the on_fall state, false when it leaves it.

signal hp_changed(value) ## Emitted when this entity hp change.
signal damaged(hp) ## Emitted when this entity takes damage.
signal hit ## Emitted when this entity hits something when attacks.

func _ready():
	_init_health_bar()
	_init_screen_notifier()
	_init_attack_cooldown_timer()
	animation_tree.active = true
	hit.connect(func(): if on_hit: on_hit.enable())

func _process(_delta):
	_update_animation()
	if running_particles:
		running_particles.emitting = is_running && not is_jumping

func _physics_process(_delta):
	is_moving = velocity != Vector2.ZERO
	is_running = is_moving and speed > max_speed
	_check_falling()
	move_and_slide()

func _init_health_bar():
	if health_bar:
		hp_bar = health_bar.instantiate()
		hp_bar.init_hud(self)
		add_child(hp_bar)

func _init_screen_notifier():
	if on_screen_entered or on_screen_exited:
		screen_notifier = VisibleOnScreenNotifier2D.new()
		if on_screen_entered:
			screen_notifier.screen_entered.connect(func(): on_screen_entered.enable())
		if on_screen_exited:
			screen_notifier.screen_exited.connect(func(): on_screen_exited.enable())
		add_child(screen_notifier)

func _init_attack_cooldown_timer():
	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.one_shot = true
	add_child(attack_cooldown_timer)

##internal - Used to update the current animation in the AnimationTree with the facing direction.
func _update_animation():
	var current_anim = animation_tree.get("parameters/playback").get_current_node()
	if current_anim:
		animation_tree.set("parameters/%s/BlendSpace2D/blend_position" % current_anim, Vector2(facing.x, facing.y))

##internal - Checks if the entity is inside an area that it is considered a falling zone.
func _check_falling():
	if not is_falling and not is_jumping and fall_detector.is_colliding() and on_fall:
		on_fall.enable()

##Used to load entity data (from a save file).
func receive_data(data: DataEntity, _soft = false):
	if data:
		global_position = data.position
		facing = data.facing

##Moves the entity towards a position, with the possibility to modify speed and friction.
func move_towards(_position, speed_increment = 1.0, friction_increment = 1.0):
	var moving_direction = global_position.direction_to(_position)
	move(moving_direction, speed_increment, friction_increment)

##Handles entity movement, applying the right velocity to the body.
func move(direction, speed_increment = 1.0, friction_increment = 1.0):
	if is_attacking or is_charging:
		return
	var delta = get_process_delta_time()
	var target_velocity = Vector2.ZERO
	var moving_direction := Vector2(direction.x, direction.y).normalized()
	var new_friction = friction
	moving_direction *= 1 if not invert_moving_direction else -1
	if moving_direction != Vector2.ZERO:
		facing = moving_direction
		speed = max_speed * speed_increment
		new_friction = friction * friction_increment
		target_velocity = moving_direction * speed
	velocity = velocity.move_toward(target_velocity, new_friction * delta)

##Starts a jump.
func jump():
	if not is_jumping:
		safe_position = global_position
		is_jumping = true
		collision_mask ^= 1 << 2

##To be called at the end of a jump.
func end_jump():
	is_jumping = false
	collision_mask ^= 1 << 2

##Starts an attack.
func attack():
	if is_attacking or is_jumping or attack_cooldown_timer.time_left > 0:
		return
	else:
		attack_cooldown_timer.stop()
		if on_attack:
			on_attack.enable()

##To be called at the end of an attack.
func end_attack():
	if attack_cooldown_timer:
			attack_cooldown_timer.start(attack_speed)

##Applies a flash to all children Sprite2D nodes found in group "flash" of the entity. 
func flash(power := 0.0, duration := 0.1, color := Color.TRANSPARENT):
	var nodes_to_flash: Array[Node] = get_children(true).filter(func(n: Node): return n.is_in_group(Const.GROUP.FLASH))
	for n in nodes_to_flash:
		n.material.set_shader_parameter("power", power)
		if color != Color.TRANSPARENT:
			n.material.set_shader_parameter("flash_color", color)
	if (power > 0):
		await get_tree().create_timer(duration).timeout
		flash(0)

##Reduces entity hp.
func reduce_hp(value := 0, from = ""):
	if from:
		print("%s damaged by %s! value: %s" % [name, from, value])
	hp -= value
	if hp <= 0:
		if on_death:
			on_death.enable()
	damaged.emit(hp)

##Recovers entity hp.
func recover_hp(value := 0, from = ""):
	if from:
		print("%s regenerated by %s! value: %s" % [name, from, value])
	hp += value
	if hp > max_hp:
		hp = max_hp
	if on_recovery:
		on_recovery.enable()

##Useful to be called after reducing entity hp. IMPORTANT: should be called always after reduce_hp.
func hurt():
	if on_hurt:
		on_hurt.enable()

##Useful for dashing.
func add_impulse(force := 0.0):
	velocity += facing * force

##Returns the entity to the latest safe position.[br]
##safe_position is set before starting a jump.[br]
##It is considered a non-safe position a position where the entity falls.
func return_to_safe_position():
	if safe_position != Vector2.ZERO:
		global_position = safe_position

##Applies the effect of an item on the entity.
func consume_item(item: DataItem):
	var item_hp = item.change_hp
	if item_hp > 0:
		recover_hp(item_hp, item.resource_name)
	elif item_hp < 0:
		reduce_hp(-item_hp, item.resource_name)
		hurt()

##Useful to reset some entity values to an initial state.
func reset_values():
	pass

##Stops the entity, setting its velocity to 0.
func stop(smoothly := false):
	if smoothly:
		move(Vector2.ZERO)
	else:
		velocity = Vector2.ZERO

##Stops the entity and disables its process.
func disable_entity(value: bool, delay = 0.0):
	await get_tree().create_timer(delay).timeout
	process_mode = PROCESS_MODE_DISABLED if value else PROCESS_MODE_INHERIT
	stop()
