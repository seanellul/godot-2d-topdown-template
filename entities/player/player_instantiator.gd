extends Marker2D

@export var player_scene: PackedScene ## The player instance.
@export_range(1, 4) var player_id := 1 ## The player id.

@onready var parent = get_parent()

func _ready() -> void:
	_instantiate_player.call_deferred()

func _instantiate_player():
	var player: PlayerEntity = player_scene.instantiate() as PlayerEntity
	if player:
		player.player_id = player_id
		player.move_and_face(global_position)
		parent.add_child.call_deferred(player)
		Globals.player_added_to_scene.emit(player)
	queue_free()
