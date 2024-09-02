extends CharacterBody2D
class_name CharacterEntity

@export_group("Movement")
@export var max_speed = 5.0
@export var run_speed_increment: = 1.5
@export var acceleration = 3000.0
@export var friction = 2000.0
@export var target_is_player: = false
@export var target: Node2D = null: set = _set_target ## A Node to be followed by this entity.
@export var animations: Dictionary = {
	"idle": preload("res://assets/sprites/hero_idle.tres"),
	"walk": preload("res://assets/sprites/hero_idle.tres"),
	"run": preload("res://assets/sprites/hero_idle.tres"),
	"jump": preload("res://assets/sprites/hero_idle.tres"),
}
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
@export var main_sprite: Sprite2D
@export var animation_tree: AnimationTree
@export var canvas_layer: Node ## Needed for: health_bar.
@export var anim_params: Array[String] = [] ## The animations available in the AnimationTree. Used to set the blend_position of each animation (facing direction).

@onready var hp := max_hp: set = _set_hp

var hp_bar: Node
var screen_notifier: VisibleOnScreenNotifier3D
var facing := Vector2.DOWN
var is_idle: bool: set = _set_is_idle
var is_moving: bool: set = _set_is_moving
var is_running: bool: set = _set_is_running
@export var is_jumping: bool: set = _set_is_jumping
var is_attacking: bool: set = _set_is_attacking
var is_charging := false: set = _set_is_charging
var is_damaged: bool
var is_target_reached := false

signal hp_changed(value)
signal damaged(hp)
signal hit
signal target_changed(target)
signal target_reached(target)

func _ready():
	_init_health_bar()
	_init_target()
	_init_screen_notifier()
	hit.connect(func(): if on_attack: on_attack.enable())

func _process(_delta):
	if !is_target_reached:
		is_target_reached = round(velocity) == Vector2.ZERO
		if is_target_reached:
			target_reached.emit(target)
	_update_animation()

func _physics_process(_delta):
	move_and_slide()

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

func _update_animation():
	var current_anim = animation_tree.get("parameters/playback").get_current_node()
	if current_anim:
			animation_tree.set("parameters/%s/BlendSpace2D/blend_position" % current_anim, Vector2(facing.x, facing.y))

func _set_is_idle(value):
	animation_tree.set("parameters/conditions/is_idle", value)
	is_idle = value

func _set_is_moving(value):
	animation_tree.set("parameters/conditions/is_moving", value)
	is_idle = !value
	is_moving = value

func _set_is_jumping(value):
	animation_tree.set("parameters/conditions/is_jumping", value)
	is_jumping = value

func _set_is_running(value):
	animation_tree.set("parameters/conditions/is_running", value)
	is_running = value

func _set_target(value):
	target = value
	target_changed.emit(value)
	_reset_target_reached()

func _set_is_attacking(value):
	is_attacking = value

func _set_is_charging(_value):
	pass

func _reset_target_reached():
	if is_inside_tree():
		await get_tree().create_timer(0.5).timeout
	is_target_reached = false

func receive_data(data: DataEntity):
	if data:
		global_position = data.position
		facing = data.facing
		target = get_node_or_null(data.target)

func move(delta, direction):
	if is_attacking or is_charging:
		return
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

func flash(power := 0.0, duration := 0.1, color := Color.TRANSPARENT):
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

func disable_entity(value: bool):
	set_process(!value)
