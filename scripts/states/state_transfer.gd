extends BaseState

@export var level_key: String  = "" ##Leave empty to transfer inside the same level
@export var destination_name: String = ""

func enter():
	if level_key:
		_transfer_to_level()
	elif destination_name and params:
		_transfer_to_position()

func _transfer_to_level():
	SceneManager.swap_scenes(
		Const.LEVEL[level_key],
		GameManager.gm.world,
		GameManager.gm.current_level,
		Const.TRANSITION.FADE_TO_BLACK
	)

func _transfer_to_position():
	var entity: CharacterEntity = params.entity
	var destination = GameManager.gm.world.get_node_or_null(destination_name) if GameManager.gm else null
	if entity and destination:
		entity.position = destination.position
	
