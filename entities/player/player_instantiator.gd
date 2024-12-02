extends Marker2D

@export var player_scene: PackedScene ## The player instance.
@export_range(1, 4) var player_id := 1 ## The player id.

@onready var parent = get_parent()

func _ready() -> void:
	_instantiate_player.call_deferred()

func _instantiate_player():
	var player: PlayerEntity = player_scene.instantiate() as PlayerEntity
	player.player_id = player_id
	parent.add_child(player)
	Globals.player_added_to_scene.emit(player)
	if player:
		player.global_position = self.global_position
		queue_free()
