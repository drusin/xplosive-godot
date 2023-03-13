extends TileMap

enum { 
	EMPTY = -1,
	DESTROYABLE = 4,
	BREAKING = 5
}


func explode(world_position):
	var map_position = local_to_map(world_position)
	if get_cell_source_id(0, map_position) == DESTROYABLE:
		set_cell(0, map_position, BREAKING)


func burning_finished(world_position):
	var map_position = local_to_map(world_position)
	if get_cell_source_id(0, map_position) == BREAKING:
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
