extends TileMap

enum { 
	EMPTY = -1,
	DESTROYABLE = 4,
	BREAKING = 5
}

@onready var breakable := _get_tile_atlas_coords_by_prop("name", "breakable")
@onready var breaking := _get_tile_atlas_coords_by_prop("name", "breaking")


func _get_tile_atlas_coords_by_prop(name: String, val: Variant) -> Vector2i:
	var source := tile_set.get_source(0) as TileSetAtlasSource
	for i in range(0, source.get_tiles_count()):
		if source.get_tile_data(source.get_tile_id(i), 0).get_custom_data(name) == val:
			return source.get_tile_id(i)
	return Vector2i(-1, -1)


func explode(world_position):
	var map_position = local_to_map(world_position)
	if get_cell_atlas_coords(0, map_position) == breakable:
		set_cell(0, map_position, 0, breaking)


func burning_finished(world_position):
	var map_position = local_to_map(world_position)
	if get_cell_atlas_coords(0, map_position) == breaking:
		set_cell(0, map_position, EMPTY)


func create_sync_data() -> Array:
	var cells := []
	for x in range(8):
		for y in range(8):
			cells.append({
				x = x,
				y = y,
				cell_id = get_cell_source_id(0, Vector2(x, y))
			})
	return cells


@rpc func synchronize(cells: Array) -> void:
	for cell in cells:
		set_cell(cell.x, cell.y, cell.cell_id)
