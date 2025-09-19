extends Camera2D

@export var tilemap: TileMapLayer

func _ready():
	if tilemap:
		var rect = tilemap.get_used_rect()
		var cell_size = tilemap.tile_set.tile_size
		

		limit_left = rect.position.x * cell_size.x
		print(limit_left)
		limit_top = rect.position.y * cell_size.y
		limit_right = rect.end.x * cell_size.x
		print(limit_right)
		limit_bottom = rect.end.y * cell_size.y
