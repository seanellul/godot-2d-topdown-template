extends Node2D
class_name StaticEntity

@export var item_required: String ##The item required in player's inventory to get the contents.
@export var contents: Array[DataItem]

@onready var interactable: Interactable = get_node("Interactable")

var entity: PlayerEntity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if interactable:
		interactable.interacted.connect(_set_entity)
		interactable.has_item = item_required

func _set_entity(_entity):
	entity = _entity

func get_content():
	if contents.size() == 0 or not entity:
		return
	for content in contents:
		if content.storable:
			entity.add_item_to_inventory(content)
		else:
			consume_content(content)

func consume_content(content: DataItem):
	var hp = content.change_hp
	if hp > 0:
		entity.recover_hp(hp, self.name)
	elif hp < 0:
		entity.reduce_hp(-hp, self.name)

func disable():
	visible = false
	process_mode = PROCESS_MODE_DISABLED
	if interactable:
		interactable.disable()
			
			
