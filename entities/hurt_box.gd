extends Area2D
class_name HurtBox

signal damaged(value: int)

func _ready() -> void:
	area_entered.connect(_on_hitbox_entered)

func _on_hitbox_entered(hitbox: HitBox):
	if !hitbox:
		return
	damaged.emit(hitbox.damage)
