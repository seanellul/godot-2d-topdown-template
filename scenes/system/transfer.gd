extends Node2D
class_name Transfer

@export_enum(
	Const.DIRECTION.DOWN,
	Const.DIRECTION.LEFT,
	Const.DIRECTION.RIGHT,
	Const.DIRECTION.UP
) var facing ##Force player to face this direction upon arriving to this destination. Leave empty to keep the same facing direction.

func set_player_facing(player, player_facing, facing_dir):
	var _facing = player_facing
	if facing_dir != null:
		_facing = Const.DIR_VECTOR[facing_dir]
	player.facing = _facing
