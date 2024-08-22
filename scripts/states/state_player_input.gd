extends StateEntity
class_name StatePlayerInput

@export var run_speed_increment: = 1.5
@export var walls_detector: RayCast3D

var player_action = "" : set = _set_player_action

func physics_update(delta):
	_handle_inputs(delta)
	_update_animation()

func _handle_inputs(delta):
	if Input.is_action_just_pressed("jump"):
		%AnimationPlayer.play("jump")
	if Input.is_action_just_pressed("attack") and not entity.is_damaged:
		entity.is_charging = true
	if Input.is_action_just_released("attack") and entity.is_charging:
		entity.is_charging = false
		entity.start_attack(delta)
	var max_speed = entity.max_speed if !entity.is_running else entity.max_speed * run_speed_increment
	if entity.has_method("move") and !entity.is_jumping:
		entity.move(delta, max_speed)

func _update_animation():
	if walls_detector != null and walls_detector.is_colliding():
		pass #TODO: do something?
	if entity.is_attacking:
		player_action = Const.ANIM.ATTACK
	elif entity.is_charging:
		player_action = Const.ANIM.CHARGING
	elif entity.is_jumping:
		player_action = Const.ANIM.JUMP
	elif entity.is_running:
		player_action = Const.ANIM.RUN
	elif entity.is_moving:
		player_action = Const.ANIM.WALK
	else:
		player_action = Const.ANIM.IDLE

func _set_player_action(value):
	if value == player_action:
		return
	player_action = value
	Globals.player_action.emit(owner, value, entity.facing)
	if entity.animation_state and value in entity.anim_params:
		entity.animation_state.travel(value)
