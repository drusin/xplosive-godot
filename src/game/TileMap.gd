extends TileMap

enum { 
	EMPTY = -1
	DESTROYABLE = 4,
	BREAKING = 5,
}


func explode(position, timeout):
	var world_position = world_to_map(position)
	if get_cellv(world_position) == DESTROYABLE:
		set_cellv(world_position, BREAKING)
		_create_destruction_timer(world_position, timeout)


func _create_destruction_timer(world_position, timeout):
	var timer = Timer.new()
	timer.wait_time = timeout
	timer.one_shot = true
	timer.connect("timeout", self, "_on_remove_tile_timeout", [world_position, timer])
	add_child(timer)
	timer.start()


func _on_remove_tile_timeout(world_position, timer):
	set_cellv(world_position, EMPTY)
	timer.queue_free()
