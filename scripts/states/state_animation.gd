extends BaseState
class_name StateAnimation

@export var animation_player: AnimationPlayer
@export var animation: String

var saved_position

func enter():
	if animation_player:
		animation_player.current_animation = animation
	if saved_position:
		animation_player.seek(saved_position)

func exit():
	if animation_player.current_animation:
		saved_position = animation_player.current_animation_position
