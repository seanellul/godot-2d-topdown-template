extends Node2D
class_name StaticEntity

@export_group("Contents")
@export var contents: Array[ContentItem] ##A list of contents to get.
@export var get_on_interaction := false ##Gets the contents on interaction. Alternatively you can call get_content manually.
@export_group("Switch")
@export var states: Array[BaseState] ##The states to switch.
@export var start_state_index := 0
@export var switch_on_interaction := false ##Switches the states on interaction. Alternatively you can call switch_states manually.
@export_subgroup("Update")
@export var remote_switch: Array[StaticEntity] ##Switch the states of other entities when this entity switches states (eg: useful for controlling doors opening with a lever).

var switch := false: ##For debugging purposes.
	set(value):
		switch_states()

@onready var interactable: Interactable = get_node_or_null("Interactable")

var entity: PlayerEntity

func _ready() -> void:
	if interactable:
		interactable.interacted.connect(_handle_interaction)

func _handle_interaction(_entity):
	_set_entity(_entity)
	if get_on_interaction:
		get_content()
	if switch_on_interaction:
		switch_states()

func _set_entity(_entity):
	entity = _entity

func get_content():
	if contents.size() == 0 or not entity:
		return
	for content in contents:
		if content.quantity > 0:
			entity.add_item_to_inventory(content.item, content.quantity)
		else:
			consume_content(content.item)

func consume_content(content: DataItem):
	var hp = content.change_hp
	if hp > 0:
		entity.recover_hp(hp, self.name)
	elif hp < 0:
		entity.reduce_hp(-hp, self.name)
		entity.hurt()

func switch_states():
	for rs in remote_switch:
		rs.switch_states()
	if states.size() == 0:
		return
	var next_state
	start_state_index += 1
	if start_state_index < states.size():
		next_state = states[start_state_index]
	else:
		next_state = states[0]
		start_state_index = 0
	if next_state:
		next_state.enable()

func disable():
	visible = false
	process_mode = PROCESS_MODE_DISABLED
	if interactable:
		interactable.disable()
			
			
