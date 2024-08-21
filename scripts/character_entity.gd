extends CharacterBody2D
class_name CharacterEntity

@export_group("Movement")
@export var max_speed = 5.0
@export var afflicted_by_gravity = false
@export var gravity: float = 0.0
@export var target_is_player: = false
@export var target: Node2D = null: set = _set_target ## A Node to be followed by this entity.
@export var is_in_air = false
@export_group("Health")
@export var max_hp := 10
@export var immortal := false
@export var health_bar: PackedScene ## It needs the canvas_layer.
@export_group("Attack")
@export var attack_power := 2
@export_group("States")
@export var on_attack: BaseState ## State to enable when this entity has damaged another entity.
@export var on_damage: BaseState ## State to enable when this entity takes damage.
@export var on_death: BaseState ## State to enable when this entity dies.
@export var on_screen_entered: BaseState ## State to enable when this entity is visible on screen.
@export var on_screen_exited: BaseState ## State to enable when this entity is outside the visible screen.
@export_group("Settings")
@export var canvas_layer: Node ## Needed for: health_bar.
@export var collision_shape: CollisionShape2D = null

@export var sprites: Array[Sprite3D] ## The list of sprites to update with this entity.
@export var anim_params: Array[String] = [] ## The animations available in the AnimationTree. Used to set the blend_position of each animation (facing direction).

@onready var hp := max_hp: set = _set_hp
var hp_bar: Node
var animation_tree: AnimationTree
var animation_state: AnimationNodeStateMachinePlayback
var screen_notifier: VisibleOnScreenNotifier3D
var facing := Vector2.DOWN: set = _set_facing
#var round_facing := Vector3.BACK: get = _get_round_facing
var is_moving: bool: get = _get_is_moving
var is_running: bool: get = _get_is_running
var is_jumping: bool: get = _get_is_jumping
var is_landing: bool: get = _get_is_landing
var is_attacking: bool: get = _get_is_attacking, set = _set_is_attacking
var is_charging := false: set = _set_is_charging
var is_damaged: bool
var is_target_reached := false

var data: DataEntity: set = _set_data

signal hp_changed(value)
signal damaged(hp)
signal hit
signal target_changed(target)
signal target_reached(target)

func _ready():
	_init_animation_tree()
	_init_health_bar()
	_init_target()
	_init_screen_notifier()
	hit.connect(func(): if on_attack: on_attack.enable())

func _process(delta):
	if !is_target_reached:
		is_target_reached = round(velocity) == Vector2.ZERO
		if is_target_reached:
			target_reached.emit(target)

func _physics_process(delta):
	# Apply gravity.
	if not is_on_floor() and afflicted_by_gravity:
		velocity.y -= gravity * delta
	move_and_slide()

func _init_animation_tree():
	animation_tree = get_node_or_null("AnimationTree")
	if animation_tree:
		animation_tree.active = true
		animation_state = animation_tree.get("parameters/playback")

func _init_health_bar():
	if health_bar && canvas_layer:
		hp_bar = health_bar.instantiate()
		hp_bar.init_health(self)
		canvas_layer.add_child(hp_bar)

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
	
func _set_hp(value):
	if immortal:
		return
	if value < 0:
		value = 0
	elif value > max_hp:
		value = max_hp
	hp = value
	print("%s HP is: %s" % [name, hp])
	hp_changed.emit(hp)

#func _get_round_facing():
	#var facing_y = roundf(facing.y) if facing.x == 0 else 0.0
	#return Vector2(roundf(facing.x), facing_y)

func _set_facing(value):
	facing = value
	if animation_tree && facing != Vector2.ZERO:
		for param in anim_params:
			animation_tree.set("parameters/%s/blend_position" % param, Vector2(facing.x, facing.y))

func _get_is_moving():
	return velocity != Vector2.ZERO

func _get_is_running():
	return is_running

func _get_is_attacking():
	return is_attacking

func _get_is_jumping():
	return is_in_air

func _get_is_landing():
	# return !is_on_floor() and velocity.y < 0
	pass

func _set_target(value):
	target = value
	target_changed.emit(value)
	_reset_target_reached()

func _reset_target_reached():
	if is_inside_tree():
		await get_tree().create_timer(0.5).timeout
	is_target_reached = false

func _set_is_attacking(value):
	is_attacking = value

func _set_is_charging(_value):
	pass

func _set_data(value):
	data = value
	if data:
		global_position = data.position
		facing = data.facing
		target = get_node_or_null(data.target)

func flash(power := 0.0, duration := 0.1, color := Color.TRANSPARENT):
	for sprite in sprites:
		sprite.material_overlay.set_shader_parameter("power", power)
		if color != Color.TRANSPARENT:
			sprite.material_overlay.set_shader_parameter("flash_color", color)
	if (power > 0):
		await get_tree().create_timer(duration).timeout
		flash(0)

func take_damage(value := 0, from = ""):
	is_damaged = true
	print_debug("%s damaged by %s" % [name, from.name])
	hp -= value
	if hp > 0:
		if on_damage:
			on_damage.enable()
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
