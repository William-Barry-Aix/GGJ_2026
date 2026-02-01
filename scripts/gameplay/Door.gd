extends TileMapLayer


var door1_open_atlas: Dictionary = {}
var door1_close_atlas: Dictionary = {}
var door1_is_open: bool = true
var _door1_flip_timer: float = 0.0

func _ready() -> void:
	# Appelé au chargement de la scène / du jeu.
	# On recherche directement Door1_open et Door1_close.
	var cells := find_door1_cells()
	print("[Door] Door1 cells:", cells)

	# Debug : liste toutes les cells réellement utilisées sur ce TileMapLayer
	#_debug_print_used_cells()

	# Debug : teste la recherche des tuiles Door1_open / Door1_close dans le TileSet
	door1_open_atlas = find_atlas_tile_by_custom_value("Door1_open")
	door1_close_atlas = find_atlas_tile_by_custom_value("Door1_close")
	print("[Door] Door1_open atlas tile:", door1_open_atlas)
	print("[Door] Door1_close atlas tile:", door1_close_atlas)

	# Optionnel : démarrer le flip-flop automatique toutes les 2 secondes
	_door1_flip_timer = 0.0


func _process(delta: float) -> void:
	_door1_flip_timer += delta
	if _door1_flip_timer >= 2.0:
		_door1_flip_timer = 0.0
		flip_flop_door1()

## Retourne les cellules associées à une porte donnée en se basant
## sur la custom data d'une Tile (layer de custom data dans le TileSet).
##
## door_name: "Door1" par exemple (cherchera "Door1_open" et "Door1_close").
## custom_layer_name: nom du layer de custom data dans le TileSet (par défaut "name").
func find_door_cells(door_name: String, custom_layer_name: String = "Name") -> Dictionary:
	# On autorise null, donc on évite le typage inféré sur une valeur null.
	var open_cell = null
	var close_cell = null

	var open_name := "%s_open" % door_name
	var close_name := "%s_close" % door_name

	for cell: Vector2i in get_used_cells():
		var tile_data := get_cell_tile_data(cell)
		if tile_data == null:
			continue

		var value = tile_data.get_custom_data(custom_layer_name)
		if typeof(value) != TYPE_STRING:
			continue

		if value == open_name:
			open_cell = cell
		elif value == close_name:
			close_cell = cell

	return {
		"open": open_cell,
		"close": close_cell,
	}


## Cherche dans le TileSet l'ID de tuile (atlas) dont
## custom_data[custom_layer_name] == target_value.
## Retourne un dictionnaire {"source_id", "atlas_coords", "alternative_id"} ou {} si rien trouvé.
func find_atlas_tile_by_custom_value(target_value: String, custom_layer_name: String = "Name") -> Dictionary:
	var ts: TileSet = tile_set
	if ts == null:
		print("[Door] find_atlas_tile_by_custom_value: no TileSet")
		return {}

	var custom_layer_index := ts.get_custom_data_layer_by_name(custom_layer_name)
	if custom_layer_index == -1:
		print("[Door] find_atlas_tile_by_custom_value: custom layer not found:", custom_layer_name)
		return {}

	print("[Door] find_atlas_tile_by_custom_value: target_value=", target_value, " layer=", custom_layer_name, " index=", custom_layer_index)

	var source_count := ts.get_source_count()
	print("[Door] find_atlas_tile_by_custom_value: source_count=", source_count)
	for i in source_count:
		var source_id := ts.get_source_id(i)
		var source := ts.get_source(source_id)
		if source is TileSetAtlasSource:
			var atlas_source: TileSetAtlasSource = source
			var grid_size := atlas_source.get_atlas_grid_size()
			print("[Door]   source_id=", source_id, " grid_size=", grid_size)
			for x in grid_size.x:
				for y in grid_size.y:
					var atlas_coords := Vector2i(x, y)
					var top_left := atlas_source.get_tile_at_coords(atlas_coords)
					if top_left == Vector2i(-1, -1):
						continue

					# On ne traite que la case "top-left" d'une tuile éventuellement plus grande.
					if top_left != atlas_coords:
						continue

					var tile_data := atlas_source.get_tile_data(atlas_coords, 0)
					if tile_data == null:
						continue

					var value = tile_data.get_custom_data(custom_layer_name)
					if typeof(value) == TYPE_STRING:
						print("[Door]     tile", atlas_coords, "value=", value)
						if value == target_value:
							print("[Door] >>> found tile:", source_id, atlas_coords)
							return {
								"source_id": source_id,
								"atlas_coords": atlas_coords,
								"alternative_id": 0,
							}

	print("[Door] find_atlas_tile_by_custom_value: no matching tile found for", target_value)
	return {}


## Cherche dans le TileSet l'ID de tuile (atlas) dont
## custom_data[custom_layer_name] == door_name_close.
## Retourne un dictionnaire {"source_id", "atlas_coords", "alternative_id"} ou {} si rien trouvé.
func find_door_close_atlas_tile(door_name: String, custom_layer_name: String = "Name") -> Dictionary:
	var target_name := "%s_close" % door_name
	return find_atlas_tile_by_custom_value(target_name, custom_layer_name)


## Met Door1 dans l'état ouvert ou fermé en remplaçant les tiles
## correspondantes par l'atlas voulu.
func set_door1_state(open: bool, custom_layer_name: String = "Name") -> void:
	var target_atlas := door1_open_atlas if open else door1_close_atlas
	if target_atlas.is_empty():
		print("[Door] set_door1_state: target atlas is empty (open=", open, ")")
		return

	var source_id = target_atlas.get("source_id", null)
	var atlas_coords = target_atlas.get("atlas_coords", null)
	var alternative_id = target_atlas.get("alternative_id", 0)
	if source_id == null or atlas_coords == null:
		print("[Door] set_door1_state: invalid atlas data", target_atlas)
		return

	# On remplace toutes les cases dont le Name est Door1_open ou Door1_close
	for cell: Vector2i in get_used_cells():
		var tile_data := get_cell_tile_data(cell)
		if tile_data == null:
			continue

		var value = tile_data.get_custom_data(custom_layer_name)
		if typeof(value) != TYPE_STRING:
			continue

		if value == "Door1_open" or value == "Door1_close":
			set_cell(cell, source_id, atlas_coords, alternative_id)

	door1_is_open = open
	print("[Door] set_door1_state: door is now", "OPEN" if open else "CLOSED")


## Flip-flop : inverse l'état actuel de Door1.
func flip_flop_door1(custom_layer_name: String = "Name") -> void:
	set_door1_state(not door1_is_open, custom_layer_name)


func _debug_print_used_cells() -> void:
	print("[Door] --- Debug used cells ---")

	var ts: TileSet = tile_set
	var custom_layers: Array[StringName] = []
	if ts != null:
		var layer_count := ts.get_custom_data_layers_count()
		for i in layer_count:
			custom_layers.append(ts.get_custom_data_layer_name(i))

	for cell: Vector2i in get_used_cells():
		var tile_data := get_cell_tile_data(cell)
		if tile_data == null:
			print("[Door] cell", cell, "-> no tile_data")
			continue

		var custom_data := {}
		for layer_name in custom_layers:
			custom_data[layer_name] = tile_data.get_custom_data(layer_name)

		print("[Door] cell", cell, "custom_data =", custom_data)
	print("[Door] --- end ---")


## Helper spécifique pour Door1 si besoin.
func find_door1_cells(custom_layer_name: String = "Name") -> Dictionary:
	return find_door_cells("Door1", custom_layer_name)
