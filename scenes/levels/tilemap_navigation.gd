extends TileMapLayer
##To be added to the TileMapLayer that uses the Navigation Layer.

@export var obstacle_tilemap: TileMapLayer
@export var obstacle_tile_id: int

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if coords in obstacle_tilemap.get_used_cells_by_id(obstacle_tile_id):
		return true
	return false

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if coords in obstacle_tilemap.get_used_cells_by_id(obstacle_tile_id):
		tile_data.set_navigation_polygon(0, null)
