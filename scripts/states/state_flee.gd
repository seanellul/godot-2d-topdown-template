extends StateEntity
class_name StateFlee

var target: Node2D = null
@export var speed_multiplier: = 1.0

func _ready():
	entity.target_changed.connect(_on_target_changed)

func physics_update(delta):
	flee(delta)

func flee(_delta):
	var target_pos = target.position
	target_pos.y += offset_y
	var direction = entity.position.direction_to(target_pos) * entity.max_speed * speed_multiplier
	var target_velocity = Vector3(-direction.x, entity.velocity.y, -direction.z)
	entity.velocity = target_velocity

func _on_target_changed(new_target):
	target = new_target
