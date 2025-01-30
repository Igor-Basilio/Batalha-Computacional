extends TileMap

func _draw():
	var tile_size = get_cell_size()
	var used_cells = get_used_cells()  # All cells with a tile

	for cell in used_cells:
		# Calculate where this cell is in world coordinates
		var cell_pos = map_to_world(cell)
		# If you have Y sort or offsets, you might need an extra offset here

		# Draw an outline rectangle for the cell
		draw_rect(
			Rect2(cell_pos, tile_size),
			Color(1, 0, 0, 0.5), # semi-transparent red
			false               # false means outline only
		)

