extends CollisionShape2D
## Utility node to easily create an Area2D with a CollisionShape2D ready for StateInteract.
class_name InteractionArea2D

@export_flags_2d_physics var mask = 8

var area: Area2D

func _enter_tree() -> void:
	area = Area2D.new()

func _ready() -> void:
	var parent = get_parent()
	area.name = self.name
	area.global_position = self.position
	area.collision_layer = 0
	area.collision_mask = mask
	area.monitorable = false

	await get_tree().physics_frame
	
	self.reparent(area)
	parent.add_child(area)
	self.position = Vector2.ZERO
	self.name = "CollisionShape2D"
