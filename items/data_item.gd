extends Resource
class_name DataItem

@export var name: String
@export var icon: Texture2D
@export var quantity: int = 0
@export var storable := false ##If true, the item will be added to the inventory, otherwise it will consumed immediately.
@export var change_hp: int = 0