extends DataItem
class_name InventoryItem

@export var quantity: int = 0

func create(item: DataItem, q: int):
	name = item.name
	icon = item.icon
	change_hp = item.change_hp
	quantity = q
