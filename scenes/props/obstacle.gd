extends Node2D

@export var interactable: Interactable
@export var damage_value: int = 1

func _ready() -> void:
	if interactable:
		interactable.interacted.connect(_apply_damage)

func _apply_damage(entity: CharacterEntity):
	if entity:
		entity.take_damage(damage_value, entity.name)
	
