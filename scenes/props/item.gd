extends Node2D

@export var interactable: Interactable
@export_category("Attributes")
@export var recover_hp: int = 0
@export var reduce_hp: int = 0

func _ready() -> void:
	if interactable:
		interactable.interacted.connect(consume_item)

func consume_item(entity: CharacterEntity):
	if entity and recover_hp > 0:
		entity.recover_hp(recover_hp, self.name)
	if entity and reduce_hp > 0:
		entity.reduce_hp(reduce_hp, self.name)

func disable():
	visible = false
	process_mode = PROCESS_MODE_DISABLED
