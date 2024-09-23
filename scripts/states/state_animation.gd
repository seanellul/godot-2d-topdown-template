extends BaseState
##Starts an animation from AnimationPlayer or AnimationTree.
class_name StateAnimation

@export var animation_player: AnimationPlayer
@export var animation_tree: AnimationTree
@export var animation: String
@export var sync_animations := false

var saved_position: float
var animation_state: AnimationNodeStateMachinePlayback

func enter(_params = null):
	if animation_player and not animation.is_empty():
		animation_player.play(animation)
		await animation_player.animation_finished
		complete()
	if animation_tree and not animation.is_empty():
		animation_state = animation_tree.get("parameters/playback") if not animation_state else animation_state
		animation_state.start(animation)
		await animation_tree.animation_finished
		complete()
	if saved_position:
		animation_player.seek(saved_position)

func exit():
	if sync_animations and animation_player and animation_player.current_animation:
		saved_position = animation_player.current_animation_position
