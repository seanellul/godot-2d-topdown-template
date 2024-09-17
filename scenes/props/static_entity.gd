@tool
extends Node2D
class_name StaticEntity

@export var item_required: String ##The item required in player's inventory to get the content.
@export var sprite_index := 0:
	set(value):
		sprite_index = value
		_set_sprite_index(value)
@export var content: DataItem

@onready var interactable: Interactable = get_node("Interactable")
@onready var sprite: Sprite2D = get_node("Sprite2D")

var entity: PlayerEntity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if interactable:
		interactable.interacted.connect(_set_entity)
		interactable.item = item_required

func _set_sprite_index(index):
	if not sprite:
		return
	sprite.region_rect.position.y = sprite.region_rect.size.y * index

func _set_entity(_entity):
	entity = _entity

func get_content():
	if content and entity:
		entity.add_item_to_inventory(content)
		
			
			
