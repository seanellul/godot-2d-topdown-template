@tool
extends Area2D
class_name HurtBox

@export var health_component: HealthComponent

func _init() -> void:
	monitorable = false
	monitoring = true
	collision_layer = 0
	z_index = -1

func _ready() -> void:
	area_entered.connect(_on_hitbox_entered)

func _on_hitbox_entered(hitbox: HitBox):
	if !hitbox or !health_component:
		return
	health_component.change_hp(hitbox.change_hp, hitbox.owner.name)
