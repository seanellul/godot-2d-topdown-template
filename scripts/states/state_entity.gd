extends BaseState
class_name StateEntity

@export var animation: String ## The animation of the AnimationPlayer associated to this state
@export var offset_y = 0.0

@onready var entity: CharacterEntity = owner if owner is CharacterEntity else null

func _ready():
	if entity and offset_y == 0:
		offset_y = entity.global_position.y

func enter():
	_start_animation()

func _start_animation():
	if animation && entity && entity.animation_state:
		entity.animation_state.start(animation)
